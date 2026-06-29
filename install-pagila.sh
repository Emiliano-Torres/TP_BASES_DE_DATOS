#!/usr/bin/env bash
set -euo pipefail

container="ibd_postgres_db"
user="ibd_postgres"
db="pagila"
maintenance_db="ibd_postgres"

usage() {
    cat <<EOF
Uso: ./install-pagila.sh

Opciones:
  -c contenedor   Nombre del contenedor Docker. Default: $container
  -u usuario      Usuario de PostgreSQL. Default: $user
  -d db           Base Pagila a recrear. Default: $db
  -m db_admin     Base existente para crear/verificar Pagila. Default: $maintenance_db
  -h              Mostrar ayuda.
EOF
}

while getopts ":c:u:d:m:h" opt; do
    case "$opt" in
        c) container="$OPTARG" ;;
        u) user="$OPTARG" ;;
        d) db="$OPTARG" ;;
        m) maintenance_db="$OPTARG" ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Opcion invalida: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "La opcion -$OPTARG requiere un valor." >&2
            usage
            exit 1
            ;;
    esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
schema_path="$script_dir/sql/pagila-schema.sql"
data_path="$script_dir/sql/pagila-faker-test.sql"

if [ ! -f "$schema_path" ]; then
    echo "No se encontro el schema en: $schema_path" >&2
    exit 1
fi

if [ ! -f "$data_path" ]; then
    echo "No se encontro el archivo de datos en: $data_path" >&2
    echo "Generalo antes con: python py/generar_pagila_faker.py" >&2
    exit 1
fi

echo "Copiando schema al contenedor..."
docker cp "$schema_path" "$container:/pagila-schema.sql"

echo "Copiando datos al contenedor..."
docker cp "$data_path" "$container:/pagila-faker-test.sql"

echo "Verificando database $db..."
if [ "$(docker exec -i "$container" psql -v ON_ERROR_STOP=1 -U "$user" -d "$maintenance_db" -tAc "SELECT 1 FROM pg_database WHERE datname = '$db'")" = "1" ]; then
    echo "La database $db ya existe."
else
    echo "Creando database $db..."
    docker exec -i "$container" createdb -U "$user" "--maintenance-db=$maintenance_db" "$db"
    echo "Database $db creada correctamente."
fi

echo "Recreando schema y creando tablas..."
MSYS_NO_PATHCONV=1 docker exec -i "$container" psql -v ON_ERROR_STOP=1 -U "$user" -d "$db" -f /pagila-schema.sql
echo "Schema creado correctamente."

echo "Insertando datos..."
MSYS_NO_PATHCONV=1 docker exec -i "$container" psql -v ON_ERROR_STOP=1 -U "$user" -d "$db" -f /pagila-faker-test.sql
echo "Datos insertados correctamente."
echo "Instalacion de Pagila completada correctamente."
