/*******************************************************************************
    Creamos claves foraneas
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
ALTER TABLE rental ADD CONSTRAINT rental_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES payment (payment_id);
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



