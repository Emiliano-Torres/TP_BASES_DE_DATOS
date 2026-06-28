/* 2.2 Funciones Estadisticas
Analizamos la tabla payment
C1: Para cada columna: cantidad total de filas, cantidad y porcentaje de 
filas con valor no nulo, cantidad de valores diferentes. */

select 'payment_id' nombre_columna,
count(*) total_filas, 
count(payment_id) total_no_nulas, 
sum(case when payment_id is null then 1 else 0 end) total_nulas,
round(count(payment_id)*100.0/count(*),2) porcentaje_no_nulo,
count (distinct payment_id) valores_distintos
from payment
union all
select 'amount' nombre_columna,
count(*) total_filas, 
count(amount) total_no_nulas, 
sum(case when amount is null then 1 else 0 end) total_nulas,
round(count(amount)*100.0/count(*),2) porcentaje_no_nulo,
count (distinct amount) valores_distintos
from payment
union all
select 'payment_date' nombre_columna,
count(*) total_filas, 
count(payment_date) total_no_nulas, 
sum(case when payment_date is null then 1 else 0 end) total_nulas,
round(count(payment_date)*100.0/count(*),2)porcentaje_no_nulo,
count (distinct payment_date) valores_distintos
from payment
union all
select 'pay_method_id' nombre_columna,
count(*) total_filas, 
count(pay_method_id) total_no_nulas, 
sum(case when pay_method_id is null then 1 else 0 end) total_nulas,
round(count(pay_method_id)*100.0/count(*),2) porcentaje_no_nulo,
count (distinct pay_method_id) valores_distintos
from payment
union all
select 'rental_id' nombre_columna,
count(*) total_filas, 
count(rental_id) total_no_nulas, 
sum(case when rental_id is null then 1 else 0 end) total_nulas,
round(count(rental_id)*100.0/count(*),2) porcentaje_no_nulo,
count (distinct rental_id) valores_distintos
from payment;


/* C2:  Para cada columna considerada numérica: desvío estandard, mínimo, P05,
primer cuartil, mediana, promedio, tercer cuartil, P95, máximo, cantidad y 
porcentaje de ceros, cantidad y porcentaje de valores negativos, cantidad de
outliers.

Consideramos que un valor es outlier cuando se encuentra fuera del intervalo
[media-2*desvioestandar, media+2*desvioestandar] 
Realizamos el análisis sólo de la columna amount y las fecha de payment ya que el resto son claves
cuyas métricas carecen de sentido.
Utilizamos CTE para mantener la claridad de la consulta. */
WITH rango AS (
    SELECT 
        round((avg(amount) - 2 * stddev_pop(amount))::numeric, 4) AS lim_inf,
        round((avg(amount) + 2 * stddev_pop(amount))::numeric, 4) AS lim_sup
    FROM payment
),
outlier AS (
    SELECT amount
    FROM payment
    WHERE amount < (SELECT lim_inf FROM rango)
       OR amount > (SELECT lim_sup FROM rango)
)
SELECT 
    'amount' AS columna,
    count(amount)::text AS cant_registros,
    round(stddev_pop(amount)::numeric, 4)::text AS desvio_est,
    min(amount)::text AS minimo,
    (percentile_cont(0.05) WITHIN GROUP (ORDER BY amount))::text AS p05,
    (percentile_cont(0.25) WITHIN GROUP (ORDER BY amount))::text AS primer_cuartil,
    (percentile_cont(0.50) WITHIN GROUP (ORDER BY amount))::text AS mediana,
    round(avg(amount)::numeric, 3)::text AS promedio,
    (percentile_cont(0.75) WITHIN GROUP (ORDER BY amount))::text AS tercer_cuartil,
    (percentile_cont(0.95) WITHIN GROUP (ORDER BY amount))::text AS p95,
    max(amount)::text AS maximo,
    sum(CASE WHEN amount = 0 THEN 1 ELSE 0 END)::text AS cant_ceros,
    round(100.0 * sum(CASE WHEN amount = 0 THEN 1 ELSE 0 END) / count(amount),4)::text AS porcentaje_ceros,
    sum(CASE WHEN amount < 0 THEN 1 ELSE 0 END)::text AS cant_negativos,
    round(100.0 * sum(CASE WHEN amount < 0 THEN 1 ELSE 0 END) / count(amount),4)::text AS porcentaje_negativos,
    sum(CASE WHEN amount IN (SELECT o.amount FROM outlier o) THEN 1 ELSE 0 END)::text AS cant_outliers
FROM payment
UNION ALL
SELECT 
    'payment_date' AS columna,
    count(payment_date)::text AS cant_registros,
    'No aplica' AS desvio_est,
    min(payment_date)::text AS minimo,
    (percentile_disc(0.05) WITHIN GROUP (ORDER BY payment_date))::text AS p05,
    (percentile_disc(0.25) WITHIN GROUP (ORDER BY payment_date))::text AS primer_cuartil,
    (percentile_disc(0.50) WITHIN GROUP (ORDER BY payment_date))::text AS mediana,
    'No aplica' AS promedio,
    (percentile_disc(0.75) WITHIN GROUP (ORDER BY payment_date))::text AS tercer_cuartil,
    (percentile_disc(0.95) WITHIN GROUP (ORDER BY payment_date))::text AS p95,
    max(payment_date)::text AS maximo,
    'No aplica' AS cant_ceros,
    'No aplica' AS porcentaje_ceros,
    'No aplica' AS cant_negativos,
    'No aplica' AS porcentaje_negativos,
    'No aplica' AS cant_outliers
FROM payment;


/* C3: Para cada columna considerada categórica: la frecuencia y el porcentaje
de los hasta 10 valores más frecuentes (de mayor a menor frecuencia),
y del resto.
*/

-- Analisis para columna payment_method

WITH mejor_pay_method as(select pay_method_id, count(pay_method_id) cant_veces,
row_number() over (order by count(pay_method_id) DESC) AS posicion
from payment
group by pay_method_id),
ranking as(select (case when m.posicion<=10 then p.name else 'otros' end) metodo,
sum(m.cant_veces) frecuencia, 
round(sum(m.cant_veces)*100.0/(select sum(cant_veces) from mejor_pay_method),2) porcentaje
from mejor_pay_method m
join pay_method p on m.pay_method_id=p.pay_method_id
group by (case when m.posicion<=10 then p.name else 'otros' end)
order by frecuencia desc)
select * from ranking
order by (case when metodo='otros' then 1 else 0 end), frecuencia desc;

