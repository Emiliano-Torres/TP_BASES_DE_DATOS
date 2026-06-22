/*******************************************************************************
   Creamos Tablas (entidades, atributos, primary keys, restricciones de dominio)
********************************************************************************/

-- CUSTOMER
CREATE TABLE public.customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL, 
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(60),
    active boolean DEFAULT true NOT NULL,
    address_id INT NOT NULL,
    CONSTRAINT customer_email_format CHECK (email IS NULL OR email LIKE '%@%.%')
);

-- STAFF
CREATE TABLE public.staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(60),
    active boolean DEFAULT true NOT NULL,
    username VARCHAR(30), 
    password VARCHAR(70),
    picture bytea,
    address_id INT NOT NULL,
    store_id INT NOT NULL,
    CONSTRAINT staff_email_format    CHECK (email    IS NULL OR email    LIKE '%@%.%'),
    CONSTRAINT staff_username_unique UNIQUE (username)
);

-- ACTOR
CREATE TABLE public.actor (
    actor_id SERIAL PRIMARY KEY, 
    first_name varchar(30) NOT NULL,
    last_name varchar(30) NOT NULL
);

-- FILM
CREATE TABLE public.film (
    film_id SERIAL PRIMARY KEY,
    title varchar(200) NOT NULL,
    description text,
    release_year INT,
    length_minutes INT,
    language_id varchar(2) NOT NULL,
    CONSTRAINT film_length_positive CHECK (length_minutes IS NULL OR length_minutes > 0)
);

-- CATEGORY
CREATE TABLE public.category (
    category_id SERIAL PRIMARY KEY,
    name varchar(120) NOT NULL
);

-- LANGUAGE
CREATE TABLE public.language (
    language_id varchar(2) PRIMARY KEY,
    name text NOT NULL
);


-- STORE
CREATE TABLE public.store (
    store_id SERIAL PRIMARY KEY,
    address_id INT NOT NULL,
    manager_id INT,
    email VARCHAR(60),
    CONSTRAINT store_email_format CHECK (email IS NULL OR email LIKE '%@%.%')
);

-- INVENTORY
CREATE TABLE public.inventory (
    inventory_id SERIAL PRIMARY KEY,
    unit_price NUMERIC(10,2) NOT NULL,
    film_id INT NOT NULL,
    store_id INT NOT NULL,
    CONSTRAINT inventory_price_not_negative CHECK (unit_price >= 0)
    );

-- PAYMENT
CREATE TABLE public.payment (
    payment_id SERIAL PRIMARY KEY,
    amount numeric(10,2) NOT NULL,
    payment_date timestamp NOT NULL,
    staff_id INT NOT NULL,
    pay_method_id INT NOT NULL,
    rental_id INT NOT NULL, 
    CONSTRAINT payment_amount_not_negative CHECK (amount >= 0)
);

-- PAY METHOD
CREATE TABLE public.pay_method (
    pay_method_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- RENTAL
CREATE TABLE public.rental (
    rental_id SERIAL PRIMARY KEY,
    rental_date timestamp NOT NULL,
    return_date timestamp NOT NULL,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    CONSTRAINT rental_dates_coherent CHECK (return_date IS NULL OR return_date > rental_date)
);

-- ADDRESS
CREATE TABLE public.address (
    address_id SERIAL PRIMARY KEY,
    postal_code VARCHAR(30) NOT NULL,
    number INT,
    floor INT, 
    unit_number varchar(10),
    street_id INT NOT NULL
);

-- STREET
CREATE TABLE public.street (
    street_id SERIAL PRIMARY KEY,
    name varchar(70) NOT NULL,
    city_id int NOT NULL
);

-- CITY
CREATE TABLE public.city (
    city_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country_code INT NOT NULL
);

-- COUNTRY
CREATE TABLE public.country (
    country_code INT PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    alpha_2 character(2),
    alpha_3 character(3),
    region_code INT NOT NULL

);

-- REGION
CREATE TABLE public.region (
    region_code INT PRIMARY KEY,
    region VARCHAR(40)
);

-- FILM_ACTOR
CREATE TABLE public.film_actor(
    actor_id INT NOT NULL,
    film_id INT NOT NULL,
    CONSTRAINT film_actor_pkey PRIMARY KEY  (film_id, actor_id)
);

-- FILM_CATEGORY
CREATE TABLE public.film_category(
    film_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT film_category_pkey PRIMARY KEY (film_id, category_id)
);


-- RENTAL_INVENTORY
CREATE TABLE public.rental_inventory(
    inventory_id INT NOT NULL,
    rental_id INT NOT NULL,
    CONSTRAINT rental_inventory_pkey PRIMARY KEY  (rental_id,inventory_id)
);

/*******************************************************************************
   Claves foraneas
********************************************************************************/

-- FILM_ACTOR
ALTER TABLE film_actor ADD CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actor (actor_id);
ALTER TABLE film_actor ADD CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id);

-- FILM_CATEGORY
ALTER TABLE film_category ADD CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES category (category_id);
ALTER TABLE film_category ADD CONSTRAINT film_category_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id);

-- RENTAL_INVENTORY
ALTER TABLE rental_inventory ADD CONSTRAINT rental_inventory_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id);
ALTER TABLE rental_inventory ADD CONSTRAINT rental_inventory_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental (rental_id);

-- CUSTOMER
ALTER TABLE customer ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id);

-- RENTAL
ALTER TABLE rental ADD CONSTRAINT rental_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff (staff_id);
ALTER TABLE rental ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer (customer_id);

-- INVENTORY
ALTER TABLE inventory ADD CONSTRAINT inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id);
ALTER TABLE inventory ADD CONSTRAINT inventory_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id);

-- STAFF
ALTER TABLE staff ADD CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id);
ALTER TABLE staff ADD CONSTRAINT staff_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id);

-- PAYMENT
ALTER TABLE payment ADD CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff (staff_id);
ALTER TABLE payment ADD CONSTRAINT payment_method_id_fkey FOREIGN KEY (pay_method_id) REFERENCES pay_method (pay_method_id);
ALTER TABLE payment ADD CONSTRAINT payment_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental (rental_id);

-- STORE
ALTER TABLE store ADD CONSTRAINT store_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id);
ALTER TABLE store ADD CONSTRAINT store_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES staff (staff_id);

-- ADDRESS
ALTER TABLE address ADD CONSTRAINT address_street_id_fkey FOREIGN KEY (street_id) REFERENCES street (street_id);

-- STREET
ALTER TABLE street ADD CONSTRAINT street_city_id_fkey FOREIGN KEY (city_id) REFERENCES city (city_id);

-- CITY
ALTER TABLE city ADD CONSTRAINT city_country_code_fkey FOREIGN KEY (country_code) REFERENCES country (country_code);

-- COUNTRY
ALTER TABLE country ADD CONSTRAINT country_region_code_fkey FOREIGN KEY (region_code) REFERENCES region (region_code);

-- FILM
ALTER TABLE film ADD CONSTRAINT film_language_id_fkey FOREIGN KEY (language_id) REFERENCES language (language_id);

/*******************************************************************************
   Reglas de negocio
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
    v_rental_date   TIMESTAMP;
    v_return_date   TIMESTAMP;
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
       AND ri.rental_id <> NEW.rental_id -- excluir la misma fila
       -- solapamiento
       AND r.rental_date < v_return_date
       AND r.return_date > v_rental_date;

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
     WHERE film_id = NEW.film_id
       AND store_id = NEW.store_id
       AND inventory_id <> NEW.inventory_id -- excluir la propia fila en UPDATE
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
    v_return_date TIMESTAMP;
BEGIN
    -- Obtenemos las fechas del rental asociado
    SELECT rental_date, return_date
      INTO v_rental_date, v_return_date
      FROM public.rental
     WHERE rental_id = NEW.rental_id;

    -- Validamos que el payment_date esté estrictamente dentro del rango [rental, return]
    IF NEW.payment_date < v_rental_date OR NEW.payment_date > v_return_date THEN
        RAISE EXCEPTION
            'El payment_date (%) del payment con id (%) debe estar comprendido entre el rental_date (%) y el return_date (%) del rental asociado.',
            NEW.payment_date, NEW.payment_id, v_rental_date, v_return_date;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_check_payment_date
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
    v_amount     NUMERIC(10,2);
    v_sum_prices NUMERIC(10,2);
    v_rental_id  INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_rental_id := OLD.rental_id;
    ELSE
        v_rental_id := NEW.rental_id;
    END IF;

    -- Monto registrado en payment
    SELECT amount
      INTO v_amount
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
