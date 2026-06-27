/*******************************************************************************
   Etapa 1.3. Consultas para validar la consistencia de los datos cargados.
********************************************************************************/

-- Participación total de RENTAL en relación GENERATES con PAYMENT

SELECT COUNT(*) as sin_pago_asociado FROM RENTAL r
LEFT JOIN PAYMENT p ON r.rental_id = p.rental_id
WHERE p.payment_id is NULL;

-- Partipación total de RENTAL en relación PARTICIPATES IN con INVENTORY
SELECT COUNT(*) as sin_pelicula_asociada FROM RENTAL r
LEFT JOIN RENTAL_INVENTORY ri ON r.rental_id = ri.rental_id
WHERE ri.inventory_id is NULL;

-- Participación total de FILM en relación BELONGS TO con CATEGORY
SELECT COUNT(*) as sin_categoria_asociada FROM FILM f
LEFT JOIN FILM_CATEGORY fi ON f.film_id = fi.film_id
WHERE fi.category_id is NULL;

-- Participación total de FILM en relación ACTS IN con ACTOR
SELECT COUNT(*) as sin_actor_asociado FROM FILM f
LEFT JOIN FILM_ACTOR fa ON f.film_id = fa.film_id
WHERE fa.actor_id is NULL;

-- REGLA 1: Un item del inventario no puede estar rentado en intervalos de tiempo solapados.
SELECT COUNT(*) AS overlaps
FROM rental_inventory ri1
INNER JOIN rental r1 ON r1.rental_id = ri1.rental_id
INNER JOIN rental_inventory ri2 ON ri2.inventory_id = ri1.inventory_id
INNER JOIN rental r2 ON r2.rental_id = ri2.rental_id
WHERE ri1.rental_id <> ri2.rental_id
AND r1.rental_date < r2.return_date
AND r1.return_date > r2.rental_date;

-- REGLA 2: Copias de la misma pelicula en la misma tienda deben tener el mismo unit_price.
SELECT COUNT(*) AS precios_distintos
FROM inventory i1
INNER JOIN inventory i2 
ON i1.film_id = i2.film_id
AND i1.store_id = i2.store_id
AND i1.inventory_id <> i2.inventory_id
WHERE i1.unit_price <> i2.unit_price;

-- REGLA 3: El payment_date debe ser igual al rental_date de su renta asociada.
SELECT COUNT (*) as fechas_distintas FROM PAYMENT p
INNER JOIN RENTAL r ON r.rental_id = p.rental_id
WHERE rental_date <> payment_date;

-- REGLA 4 : REGLA 4: El amount del payment debe ser igual a la suma de los unit_price de todos los ítems del inventario de la renta asociada.
WITH sub as (
    SELECT ri.rental_id, SUM(i.unit_price) AS suma_precios
    FROM inventory i
    INNER JOIN rental_inventory ri ON ri.inventory_id = i.inventory_id
    GROUP BY ri.rental_id )
SELECT COUNT(*) AS precios_distintos
FROM sub
INNER JOIN payment p ON p.rental_id = sub.rental_id
WHERE sub.suma_precios <> p.amount;

