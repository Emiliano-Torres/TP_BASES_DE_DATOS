DROP INDEX IF EXISTS idx_payment_date_payment;

EXPLAIN ANALYZE
WITH ventas_por_dia AS (SELECT DATE(payment_date) fecha, SUM(amount) monto FROM payment GROUP BY DATE(payment_date)) 
SELECT fecha, ROUND(AVG(monto) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) 
FROM ventas_por_dia ORDER BY fecha;

CREATE INDEX idx_payment_date_payment ON payment(DATE(payment_date));

EXPLAIN ANALYZE
WITH ventas_por_dia AS (SELECT DATE(payment_date) fecha, SUM(amount) monto FROM payment GROUP BY DATE(payment_date)) 
SELECT fecha, ROUND(AVG(monto) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) 
FROM ventas_por_dia ORDER BY fecha;
