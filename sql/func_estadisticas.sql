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
Realizamos el análisis sólo de la columna amount ya que el resto son claves
y fechas cuyas métricas carecen de sentido.
Utilizamos CTE para mantener la claridad de la consulta. */

WITH RANGO AS (select round(avg(amount)-2*stddev_pop(amount),4)lim_inf,
round(avg(amount)+2*stddev_pop(amount),4) lim_sup from payment),
OUTLIER as(select amount from payment 
where amount<(select lim_inf from RANGO)  or amount>(select lim_sup from RANGO))
select 'amount' columna,
count(amount) cant_Registros,
round(stddev_pop(amount),4) desvio_est,
min(amount) minimo,
percentile_cont(0.05) within group (order by amount) P05,
percentile_cont(0.25) within group (order by amount) primer_cuartil,
percentile_cont(0.5) within group (order by amount) mediana,
round(avg(amount),3) promedio,
percentile_cont(0.75) within group (order by amount) tercer_cuartil,
percentile_cont(0.95) within group (order by amount) P95,
max(amount) maximo,
sum(case when amount=0 then 1 else 0 end) cant_ceros,
round(100.0*(sum(case when amount=0 then 1 else 0 end))/count(amount),4) porcentaje_ceros,
sum(case when amount<0 then 1 else 0 end) cant_negativos,
round(100.0*(sum(case when amount<0 then 1 else 0 end))/count(amount),4) porcentaje_negativos,
sum(case when amount in (select o.amount from OUTLIER o) then 1 else 0 end) cant_outliers
from payment;

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

