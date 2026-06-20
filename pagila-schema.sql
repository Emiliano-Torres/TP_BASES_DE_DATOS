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
    language_id varchar(2) NOT NULL
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
    manager_id INT NOT NULL,
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
    payment_id INT NOT NULL,
    staff_id INT NOT NULL,
    CONSTRAINT rental_dates_coherent CHECK (return_date > rental_date)
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




