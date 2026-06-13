--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE DOMAIN public."bigint" AS bigint;

CREATE TYPE public.mpaa_rating AS ENUM (
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17'
);

CREATE DOMAIN public.year AS integer
	CONSTRAINT year_check CHECK (((VALUE >= 1901) AND (VALUE <= 2155)));

CREATE SEQUENCE public.customer_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.customer (
    customer_id integer DEFAULT nextval('public.customer_customer_id_seq'::regclass) NOT NULL,
    store_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text,
    address_id integer NOT NULL,
    activebool boolean DEFAULT true NOT NULL,
    create_date date DEFAULT CURRENT_DATE NOT NULL,
    last_update timestamp with time zone DEFAULT now(),
    active integer
);

CREATE SEQUENCE public.actor_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.actor (
    actor_id integer DEFAULT nextval('public.actor_actor_id_seq'::regclass) NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.category (
    category_id integer DEFAULT nextval('public.category_category_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.film_film_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.film (
    film_id integer DEFAULT nextval('public.film_film_id_seq'::regclass) NOT NULL,
    title text NOT NULL,
    description text,
    release_year public.year,
    language_id varchar(2) NOT NULL,
    original_language_id varchar(2),
    rental_duration smallint DEFAULT 3 NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    length smallint,
    replacement_cost numeric(5,2) DEFAULT 19.99 NOT NULL,
    rating public.mpaa_rating DEFAULT 'G'::public.mpaa_rating,
    last_update timestamp with time zone DEFAULT now() NOT NULL,
    special_features text[],
    fulltext tsvector NOT NULL
);

CREATE TABLE public.film_actor (
    actor_id integer NOT NULL,
    film_id integer NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.film_category (
    film_id integer NOT NULL,
    category_id integer NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.address_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.address (
    address_id integer DEFAULT nextval('public.address_address_id_seq'::regclass) NOT NULL,
    address text NOT NULL,
    address2 text,
    district text NOT NULL,
    city_id integer NOT NULL,
    postal_code text,
    phone text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.city_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.city (
    city_id integer DEFAULT nextval('public.city_city_id_seq'::regclass) NOT NULL,
    city text NOT NULL,
    country_code integer NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.country (
    country_code integer PRIMARY KEY,
    name text NOT NULL,
    alpha_2 character(2),
    alpha_3 character(3),
    iso_3166_2 text,
    region text,
    sub_region text,
    intermediate_region text,
    region_code integer,
    sub_region_code integer,
    intermediate_region_code integer
);

CREATE SEQUENCE public.inventory_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.inventory (
    inventory_id integer DEFAULT nextval('public.inventory_inventory_id_seq'::regclass) NOT NULL,
    film_id integer NOT NULL,
    store_id integer NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.language (
    language_id varchar(2) PRIMARY KEY,
    name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.payment_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.payment (
    payment_id integer DEFAULT nextval('public.payment_payment_id_seq'::regclass) NOT NULL,
    customer_id integer NOT NULL,
    staff_id integer NOT NULL,
    rental_id integer NOT NULL,
    amount numeric(5,2) NOT NULL,
    payment_date timestamp with time zone NOT NULL,
    PRIMARY KEY (payment_date, payment_id)
);

CREATE SEQUENCE public.rental_rental_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.rental (
    rental_id integer DEFAULT nextval('public.rental_rental_id_seq'::regclass) NOT NULL,
    rental_date timestamp with time zone NOT NULL,
    inventory_id integer NOT NULL,
    customer_id integer NOT NULL,
    return_date timestamp with time zone,
    staff_id integer NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE public.staff_staff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.staff (
    staff_id integer DEFAULT nextval('public.staff_staff_id_seq'::regclass) NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    address_id integer NOT NULL,
    email text,
    store_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    username text NOT NULL,
    password text,
    last_update timestamp with time zone DEFAULT now() NOT NULL,
    picture bytea
);

CREATE SEQUENCE public.store_store_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.store (
    store_id integer DEFAULT nextval('public.store_store_id_seq'::regclass) NOT NULL,
    manager_staff_id integer NOT NULL,
    address_id integer NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);


