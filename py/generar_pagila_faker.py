from __future__ import annotations

import csv
import random
from datetime import datetime, timedelta
from decimal import Decimal
from pathlib import Path

try:
    from faker import Faker
except ModuleNotFoundError as exc:
    raise SystemExit(
        "No se encontro la libreria Faker. Instalacion: python -m pip install Faker"
    ) from exc


FILM_COUNT = 800
BASE_DIR = Path(__file__).resolve().parent.parent
OUTPUT_FILE = BASE_DIR / "sql" / "pagila-faker-test.sql"

INVENTORY_COUNT = 6000
CUSTOMER_COUNT = 5000
RENTAL_COUNT = 30_000
ACTOR_COUNT = 200
STORE_COUNT = 4
COUNTRY_COUNT = 35
CITY_COUNT = 250
CATEGORY_NAMES = [
    "Action",
    "Animation",
    "Children",
    "Classics",
    "Comedy",
    "Documentary",
    "Drama",
    "Family",
    "Foreign",
    "Games",
    "Horror",
    "Music",
    "New",
    "Sci-Fi",
    "Sports",
    "Travel",
    "Thriller",
    "Romance",
    "Mystery",
    "Adventure",
]
MAIN_LANGUAGE_CODES = ("en", "es", "fr", "de", "it", "pt")
PAYMENT_METHODS = ("Billetera Virtual", "Efectivo", "Debito", "Credito")
EMAIL_DOMAINS = ["gmail.com", "hotmail.com", "outlook.com", "yahoo.com", "example.com"]



fake = Faker("es_AR")
Faker.seed(20260615)
random.seed(20260615)


def sql_text(value: object) -> str:
    if value is None:
        return "NULL"
    text = str(value).replace("\\", "\\\\").replace("'", "''")
    return f"'{text}'"

def generate_email(first_name: str, last_name: str, used_emails: set) -> str:
    clean_first = "".join(filter(str.isalpha, first_name.lower()))
    clean_last = "".join(filter(str.isalpha, last_name.lower()))
    
    email = f"{clean_first}.{clean_last}@{random.choice(EMAIL_DOMAINS)}"
    
    # Si existe, intentar añadir números
    while email in used_emails:
        email = f"{clean_first}{clean_last}{random.randint(1, 999)}@{random.choice(EMAIL_DOMAINS)}"
    
    used_emails.add(email)
    return email


def sql_bool(value: bool) -> str:
    return "true" if value else "false"


def sql_ts(value: datetime) -> str:
    return sql_text(value.strftime("%Y-%m-%d %H:%M:%S"))


def money(min_value: str = "1.99", max_value: str = "19.99") -> Decimal:
    cents = random.randint(int(Decimal(min_value) * 100), int(Decimal(max_value) * 100))
    return Decimal(cents) / Decimal(100)


def write_insert(handle, table: str, columns: tuple[str, ...], rows) -> None:
    handle.write(f"INSERT INTO public.{table} ({', '.join(columns)}) VALUES\n")
    rendered_rows = []
    for row in rows:
        rendered_rows.append("    (" + ", ".join(row) + ")")
    handle.write(",\n".join(rendered_rows))
    handle.write(";\n\n")


def sql_int_or_null(value: str) -> str:
    value = value.strip()
    return str(int(value)) if value else "NULL"


def load_languages(path: str) -> list[tuple[str, str]]:
    with open(path, "r", encoding="utf-8-sig", newline="") as handle:
        languages = [
            (row["alpha2"].upper(), row["English"])
            for row in csv.DictReader(handle)
            if row["alpha2"].strip() and row["English"].strip()
        ]

    rows = {code.lower(): name for code, name in languages}
    missing = [code for code in MAIN_LANGUAGE_CODES if code not in rows]
    if missing:
        raise SystemExit(
            f"Faltan codigos de lenguaje en {path}: {', '.join(missing)}"
        )

    return languages


def main_languages(languages: list[tuple[str, str]]) -> list[tuple[str, str]]:
    language_by_code = {code: name for code, name in languages}
    return [
        (code.upper(), language_by_code[code.upper()])
        for code in MAIN_LANGUAGE_CODES
    ]


def load_countries(path: str) -> list[dict[str, str]]:
    with open(path, "r", encoding="utf-8-sig", newline="") as handle:
        countries = [
            row
            for row in csv.DictReader(handle)
            if row["country-code"].strip()
            and row["name"].strip()
            and row["region-code"].strip()
            and row["region"].strip()
        ]

    if len(countries) < COUNTRY_COUNT:
        raise SystemExit(
            f"{path} tiene {len(countries)} paises con region valida; "
            f"se necesitan {COUNTRY_COUNT}."
        )

    return countries


def make_countries(source_rows: list[dict[str, str]]):
    return [
        (
            sql_int_or_null(row["country-code"]),
            sql_text(row["name"][:40]),
            sql_text(row["alpha-2"][:2]),
            sql_text(row["alpha-3"][:3]),
            sql_int_or_null(row["region-code"]),
        )
        for row in source_rows
    ]


def make_regions(source_rows: list[dict[str, str]]):
    regions = {
        int(row["region-code"]): row["region"][:40]
        for row in source_rows
        if row["region-code"].strip() and row["region"].strip()
    }
    return [
        (str(region_code), sql_text(name))
        for region_code, name in sorted(regions.items())
    ]


def main() -> None:
    output = OUTPUT_FILE
    languages = load_languages(str(BASE_DIR / "csv" / "language-codes.csv"))
    film_languages = main_languages(languages)
    source_countries = load_countries(str(BASE_DIR / "csv" / "maestra_paises.csv"))
    generated_country_ids = [
        int(row["country-code"])
        for row in source_countries
        if row["region-code"].strip() and row["region"].strip()
    ][:COUNTRY_COUNT]
    city_ids = list(range(1, CITY_COUNT + 1))
    address_count = CUSTOMER_COUNT + STORE_COUNT
    address_ids = list(range(1, address_count + 1))
    street_ids = list(range(1, address_count + 1))
    customer_address_ids = address_ids[:CUSTOMER_COUNT]
    store_address_ids = address_ids[CUSTOMER_COUNT :]
    used_emails = set()

    with open(output, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("-- Datos generados por generar_pagila_faker.py para pagila-schema.sql\n")
        handle.write("-- Ejecutar luego de crear el esquema.\n\n")
        handle.write("BEGIN;\n\n")

        write_insert(
            handle,
            "language",
            ("language_id", "name"),
            [(sql_text(code), sql_text(name)) for code, name in languages],
        )

        write_insert(
            handle,
            "region",
            ("region_code", "region"),
            make_regions(source_countries),
        )

        write_insert(
            handle,
            "country",
            ("country_code", "name", "alpha_2", "alpha_3", "region_code"),
            make_countries(source_countries),
        )

        write_insert(
            handle,
            "city",
            ("city_id", "name", "country_code"),
            (
                (
                    str(city_id),
                    sql_text(fake.city()[:50]),
                    str(random.choice(generated_country_ids)),
                )
                for city_id in city_ids
            ),
        )

        write_insert(
            handle,
            "street",
            ("street_id", "name", "city_id"),
            (
                (
                    str(street_id),
                    sql_text(fake.street_name()[:70]),
                    str(random.choice(city_ids)),
                )
                for street_id in street_ids
            ),
        )

        write_insert(
            handle,
            "address",
            ("address_id", "postal_code", "number", "floor", "unit_number", "street_id"),
            (
                (
                    str(address_id),
                    sql_text(fake.postcode()[:30]),
                    str(random.randint(1, 9999)),
                    str(random.randint(0, 20)) if random.random() < 0.35 else "NULL",
                    sql_text(f"{random.choice('ABCDEFGH')}{random.randint(1, 20)}")
                    if random.random() < 0.35
                    else "NULL",
                    str(street_ids[address_id - 1]),
                )
                for address_id in address_ids
            ),
        )

        write_insert(
            handle,
            "store",
            ("store_id", "address_id", "email"),
            (
                (
                    str(store_id),
                    str(store_address_ids[store_id - 1]),
                    sql_text(fake.unique.email()[:60]),
                )
                for store_id in range(1, STORE_COUNT + 1)
            ),
        )

        customer_rows = []
        for customer_id in range(1, CUSTOMER_COUNT + 1):
            first = fake.first_name()
            last = fake.last_name()
            customer_rows.append((
                str(customer_id),
                sql_text(first[:30]),
                sql_text(last[:30]),
                sql_text(generate_email(first, last, used_emails)[:60]),
                sql_bool(random.random() > 0.04),
                str(customer_address_ids[customer_id - 1]),
            ))
                
        write_insert(handle, "customer", 
                     ("customer_id","first_name","last_name","email","active","address_id")
                     , customer_rows)

        write_insert(
            handle,
            "category",
            ("category_id", "name"),
            (
                (str(category_id), sql_text(name))
                for category_id, name in enumerate(CATEGORY_NAMES, start=1)
            ),
        )

        write_insert(
            handle,
            "actor",
            ("actor_id", "first_name", "last_name"),
            (
                (
                    str(actor_id),
                    sql_text(fake.first_name()[:30]),
                    sql_text(fake.last_name()[:30]),
                )
                for actor_id in range(1, ACTOR_COUNT + 1)
            ),
        )

        film_category_rows = []
        film_actor_rows = []
        film_rows = []
        for film_id in range(1, FILM_COUNT + 1):
            words = fake.words(nb=random.randint(2, 4), unique=True)
            title = " ".join(word.capitalize() for word in words)
            film_rows.append(
                (
                    str(film_id),
                    sql_text(title[:200]),
                    sql_text(fake.paragraph(nb_sentences=3)),
                    str(random.randint(1980, 2026)),
                    str(random.randint(60, 185)),
                    sql_text(random.choice(film_languages)[0]),
                )
            )
            film_category_rows.append(
                (str(film_id), str(random.randint(1, len(CATEGORY_NAMES))))
            )
            for actor_id in random.sample(range(1, ACTOR_COUNT + 1), random.randint(2, 6)):
                film_actor_rows.append((str(actor_id), str(film_id)))

        write_insert(
            handle,
            "film",
            ("film_id", "title", "description", "release_year", "length_minutes", "language_id"),
            film_rows,
        )

        write_insert(
            handle,
            "film_category",
            ("film_id", "category_id"),
            film_category_rows,
        )

        write_insert(
            handle,
            "film_actor",
            ("actor_id", "film_id"),
            film_actor_rows,
        )

        inventory_rows = []
        inventory_prices: dict[int, Decimal] = {}
        film_store_prices: dict[tuple[int, int], Decimal] = {}
        inventory_by_store: dict[int, list[int]] = {
            store_id: [] for store_id in range(1, STORE_COUNT + 1)
        }
        for inventory_id in range(1, INVENTORY_COUNT + 1):
            store_id = random.randint(1, STORE_COUNT)
            film_id = random.randint(1, FILM_COUNT)
            unit_price = film_store_prices.setdefault(
                (film_id, store_id),
                money("2.99", "29.99"),
            )
            inventory_prices[inventory_id] = unit_price
            inventory_by_store[store_id].append(inventory_id)
            inventory_rows.append(
                (
                    str(inventory_id),
                    f"{unit_price:.2f}",
                    str(film_id),
                    str(store_id),
                )
            )

        write_insert(
            handle,
            "inventory",
            ("inventory_id", "unit_price", "film_id", "store_id"),
            inventory_rows,
        )

        rental_rows = []
        rental_inventory_rows = []
        payment_rows = []
        start_date = datetime(2023, 1, 1, 9, 0, 0)
        rental_dates = sorted(
            start_date + timedelta(minutes=random.randint(0, 60 * 24 * 365 * 3))
            for _ in range(RENTAL_COUNT)
        )
        inventory_available_at = {
            inventory_id: start_date
            for inventory_id in range(1, INVENTORY_COUNT + 1)
        }
        write_insert(
            handle,
            "pay_method",
            ("pay_method_id", "name"),
            (
                (str(pay_method_id), sql_text(name))
                for pay_method_id, name in enumerate(PAYMENT_METHODS, start=1)
            ),
        )

        for rental_id, rental_date in enumerate(rental_dates, start=1):
            customer_id = random.randint(1, CUSTOMER_COUNT)
            return_date = rental_date + timedelta(days=random.randint(1, 14))
            available_by_store = {
                store_id: [
                    inventory_id
                    for inventory_id in inventory_by_store[store_id]
                    if inventory_available_at[inventory_id] <= rental_date
                ]
                for store_id in range(1, STORE_COUNT + 1)
            }
            stores_with_inventory = [
                store_id
                for store_id, available_ids in available_by_store.items()
                if available_ids
            ]
            if not stores_with_inventory:
                raise RuntimeError(
                    f"No hay inventario disponible para la renta {rental_id}."
                )
            store_id = random.choice(stores_with_inventory)
            available_inventory_ids = available_by_store[store_id]
            item_count = min(random.randint(1, 5), len(available_inventory_ids))
            rented_inventory_ids = random.sample(
                available_inventory_ids,
                item_count,
            )
            for inventory_id in rented_inventory_ids:
                inventory_available_at[inventory_id] = return_date
            amount = sum(
                (inventory_prices[inventory_id] for inventory_id in rented_inventory_ids),
                Decimal("0.00"),
            )

            rental_rows.append(
                (
                    str(rental_id),
                    sql_ts(rental_date),
                    sql_ts(return_date),
                    str(customer_id),
                )
            )
            rental_inventory_rows.extend(
                (str(inventory_id), str(rental_id))
                for inventory_id in rented_inventory_ids
            )
            payment_rows.append(
                (
                    str(rental_id),
                    f"{amount:.2f}",
                    sql_ts(rental_date),
                    str(random.randint(1, len(PAYMENT_METHODS))),
                    str(rental_id),
                )
            )

        write_insert(
            handle,
            "rental",
            ("rental_id", "rental_date", "return_date", "customer_id"),
            rental_rows,
        )

        write_insert(
            handle,
            "rental_inventory",
            ("inventory_id", "rental_id"),
            rental_inventory_rows,
        )

        write_insert(
            handle,
            "payment",
            ("payment_id", "amount", "payment_date", "pay_method_id", "rental_id"),
            payment_rows,
        )

        for table, column, value in (
            ("city", "city_id", CITY_COUNT),
            ("street", "street_id", address_count),
            ("address", "address_id", address_count),
            ("store", "store_id", STORE_COUNT),
            ("customer", "customer_id", CUSTOMER_COUNT),
            ("category", "category_id", len(CATEGORY_NAMES)),
            ("actor", "actor_id", ACTOR_COUNT),
            ("film", "film_id", FILM_COUNT),
            ("inventory", "inventory_id", INVENTORY_COUNT),
            ("pay_method", "pay_method_id", len(PAYMENT_METHODS)),
            ("payment", "payment_id", RENTAL_COUNT),
            ("rental", "rental_id", RENTAL_COUNT),
        ):
            handle.write(
                f"SELECT setval(pg_get_serial_sequence('public.{table}', '{column}'), {value}, true);\n"
            )

        handle.write("\nCOMMIT;\n")

    print(f"SQL generado en {output}")
    print(f"Peliculas: {FILM_COUNT}")
    print(f"Inventario: {INVENTORY_COUNT}")
    print(f"Clientes: {CUSTOMER_COUNT}")
    print(f"Rentas: {RENTAL_COUNT}")
    print(f"Payments: {RENTAL_COUNT} (uno por renta)")

if __name__ == "__main__":
    main()
