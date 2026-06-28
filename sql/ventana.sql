-- Tendencia de los ingresos de las rentas (media movil semanal del amount) SUM(7)
WITH ventas_por_dia AS (SELECT DATE(payment_date) fecha, SUM(amount) monto FROM payment GROUP BY DATE(payment_date)) 
SELECT fecha, ROUND(AVG(monto) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) 
FROM ventas_por_dia ORDER BY fecha;

-- Intervalo entre ventas de cada cliente activo (no lo separaria por cliente)
-- LAG()

SELECT c.customer_id,
 EXTRACT(DAY FROM rental_date-lag(rental_date) 
        OVER(PARTITION BY c.customer_id ORDER BY rental_date)) intervalo
FROM rental r INNER JOIN customer c ON c.customer_id=r.customer_id AND c.active=true;


