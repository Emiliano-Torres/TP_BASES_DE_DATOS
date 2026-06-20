/*******************************************************************************
   Constraints/Reglas de negocio
********************************************************************************/

/** 
REGLA 1: Un item del inventario no puede estar rentado en intervalos de tiempo solapados.
- Un inventory_id solo puede aparecer en una renta activa a la vez.
- Se controla al insertar/actualizar un registro en la tabla rental_inventory.
**/

CREATE OR REPLACE FUNCTION public.fn_check_inventory_overlap()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_rental_date  TIMESTAMP;
    v_return_date  TIMESTAMP;
    v_overlap_count INT;

BEGIN
    -- Fechas del alquiler que se está insertando
    SELECT rental_date, return_date
      INTO v_rental_date, v_return_date
      FROM public.rental
     WHERE rental_id = NEW.rental_id;
 
    -- Contar rentas que usan el mismo inventory_id con fechas solapadas
    SELECT COUNT(*)
      INTO v_overlap_count
      FROM public.rental_inventory ri
      JOIN public.rental r ON r.rental_id = ri.rental_id
     WHERE ri.inventory_id = NEW.inventory_id
       AND ri.rental_id   <> NEW.rental_id  -- excluir la misma fila
       -- solapamiento
       AND r.rental_date  <  v_return_date
       AND r.return_date  >  v_rental_date;
 
    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION
            'El registro del inventario con id % ya está rentado en ese período (hay solapamiento de fechas).',
            NEW.inventory_id;
    END IF;
 
    RETURN NEW;
END;
$$;
 
CREATE TRIGGER trg_check_inventory_overlap
BEFORE INSERT OR UPDATE ON public.rental_inventory
FOR EACH ROW EXECUTE FUNCTION public.fn_check_inventory_overlap();

/** 
REGLA 2: Copias de la misma pelicula en la misma tienda deben tener el mismo unit_price.
- Se controla al insertar/actualizar un registro en la tabla inventory.
**/

CREATE OR REPLACE FUNCTION public.fn_check_inventory_price_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_existing_price NUMERIC(10,2);
BEGIN
    SELECT unit_price
      INTO v_existing_price
      FROM public.inventory
     WHERE film_id    = NEW.film_id
       AND store_id   = NEW.store_id
       AND inventory_id <> NEW.inventory_id   -- excluir la propia fila en UPDATE
     LIMIT 1;
 
    IF FOUND AND v_existing_price <> NEW.unit_price THEN
        RAISE EXCEPTION
            'El precio de la película con id % en la tienda con id % debe ser % (igual al resto de las copias).',
            NEW.film_id, NEW.store_id, v_existing_price;
    END IF;
 
    RETURN NEW;
END;
$$;
 
CREATE TRIGGER trg_check_inventory_price_consistency
BEFORE INSERT OR UPDATE ON public.inventory
FOR EACH ROW EXECUTE FUNCTION public.fn_check_inventory_price_consistency();


/** 
REGLA 3: El payment_date debe ser igual al rental_date de su renta asociada.
- Se controla al insertar/actualizar un registro en la tabla payment.
**/

CREATE OR REPLACE FUNCTION public.fn_check_payment_date()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_rental_date TIMESTAMP;
BEGIN
    SELECT rental_date INTO v_rental_date
      FROM public.rental
     WHERE rental_id = NEW.rental_id;

    IF NEW.payment_date <> v_rental_date THEN
        RAISE EXCEPTION
            'El payment_date (%) del payment con id (%) debe ser igual al rental_date (%) del rental asociado.',
            NEW.payment_date,NEW.payment_id, v_rental_date;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_payment_date
BEFORE INSERT OR UPDATE ON public.payment
FOR EACH ROW EXECUTE FUNCTION public.fn_check_payment_date();

/** 
REGLA 4: El amount del payment debe ser igual a la suma de los unit_price de todos los ítems del inventario de la renta asociada.
- Se controla al insertar/actualizar/borrar un registro en rental_inventory y al insertar/actualizar payment.
**/

CREATE OR REPLACE FUNCTION public.fn_check_payment_amount()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_amount       NUMERIC(10,2);
    v_sum_prices   NUMERIC(10,2);
    v_rental_id    INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_rental_id := OLD.rental_id;
    ELSE
        v_rental_id := NEW.rental_id;
    END IF;

    -- Monto registrado en payment
    SELECT amount INTO v_amount
      FROM public.payment
     WHERE rental_id = v_rental_id;
 
    -- Suma de los unit_price de las películas en ese rental
    SELECT COALESCE(SUM(i.unit_price), 0)
      INTO v_sum_prices
      FROM public.rental_inventory ri
      JOIN public.inventory i ON i.inventory_id = ri.inventory_id
     WHERE ri.rental_id = v_rental_id;
 
    IF v_sum_prices > 0 AND v_amount <> v_sum_prices THEN
        RAISE EXCEPTION
            'El monto del pago (%) no coincide con la suma de los precios de las películas rentadas (%) para el rental %.',
            v_amount, v_sum_prices, v_rental_id;
    END IF;
 
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

-- Trigger sobre payment 
CREATE TRIGGER trg_check_payment_amount_on_payment
AFTER INSERT OR UPDATE ON public.payment
FOR EACH ROW EXECUTE FUNCTION public.fn_check_payment_amount();

-- Trigger sobre rental_inventory 
CREATE TRIGGER trg_check_payment_amount_on_rental_inventory
AFTER INSERT OR UPDATE OR DELETE ON public.rental_inventory
FOR EACH ROW EXECUTE FUNCTION public.fn_check_payment_amount();
