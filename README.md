# TP_BASES_DE_DATOS

## Instalacion

Instalar dependencias desde la raiz del proyecto:

```powershell
python -m pip install -r requirements.txt
```

Regenerar datos Pagila: (Ya viene generado dentro de la carpeta sql)

```powershell
python py\generar_pagila_faker.py
```

El comando genera `sql\pagila-faker-test.sql`.

## Cargar Pagila En Docker Local

<!-- Antes de ejecutar los scripts, el contenedor Docker local con PostgreSQL tiene que estar levantado y listo para aceptar conexiones. -->

Los scripts `install-pagila.ps1` y `install-pagila.sh` copian `sql\pagila-schema.sql` y `sql\pagila-faker-test.sql` al contenedor, recrean el schema `public`, crean las tablas e insertan los datos.

En Windows:

```powershell
.\install-pagila.ps1
```

En macOS/Linux:

```bash
chmod +x install-pagila.sh
./install-pagila.sh
```

Si el contenedor o credenciales tienen otros nombres, en Windows:

```powershell
.\install-pagila.ps1 `
  -Container ibd_postgres_db `
  -User ibd_postgres `
  -Db pagila
```

En macOS/Linux:

```bash
./install-pagila.sh \
  -c ibd_postgres_db \
  -u ibd_postgres \
  -d pagila
```

## Carga Manual Paso A Paso

Si no pudiste usar los instaladores, podes ejecutar los mismos pasos a mano. Los valores usados por defecto son:

- Contenedor Docker: `ibd_postgres_db`
- Usuario PostgreSQL: `ibd_postgres`
- Database administrativa existente: `ibd_postgres`
- Database Pagila a crear/cargar: `pagila`

### PowerShell

Desde la raiz del proyecto:

```powershell
python -m pip install -r requirements.txt
```

Opcional, solo si queres regenerar los datos:

```powershell
python py\generar_pagila_faker.py
```

Copiar los archivos SQL al contenedor:

```powershell
docker cp .\sql\pagila-schema.sql ibd_postgres_db:/pagila-schema.sql
docker cp .\sql\pagila-faker-test.sql ibd_postgres_db:/pagila-faker-test.sql
```

Verificar si la database `pagila` existe:

```powershell
docker exec -i ibd_postgres_db psql -v ON_ERROR_STOP=1 -U ibd_postgres -d ibd_postgres -tAc "SELECT 1 FROM pg_database WHERE datname = 'pagila'"
```

Si el comando anterior no devuelve `1`, crear la database:

```powershell
docker exec -i ibd_postgres_db createdb -U ibd_postgres --maintenance-db=ibd_postgres pagila
```

Cargar schema y datos:

```powershell
docker exec -i ibd_postgres_db psql -v ON_ERROR_STOP=1 -U ibd_postgres -d pagila -f /pagila-schema.sql
docker exec -i ibd_postgres_db psql -v ON_ERROR_STOP=1 -U ibd_postgres -d pagila -f /pagila-faker-test.sql
```

### Bash / Git Bash

Desde la raiz del proyecto:

```bash
python -m pip install -r requirements.txt
```

Opcional, solo si queres regenerar los datos:

```bash
python py/generar_pagila_faker.py
```

Copiar los archivos SQL al contenedor:

```bash
docker cp ./sql/pagila-schema.sql ibd_postgres_db:/pagila-schema.sql
docker cp ./sql/pagila-faker-test.sql ibd_postgres_db:/pagila-faker-test.sql
```

Verificar si la database `pagila` existe:

```bash
docker exec -i ibd_postgres_db psql -v ON_ERROR_STOP=1 -U ibd_postgres -d ibd_postgres -tAc "SELECT 1 FROM pg_database WHERE datname = 'pagila'"
```

Si el comando anterior no devuelve `1`, crear la database:

```bash
docker exec -i ibd_postgres_db createdb -U ibd_postgres --maintenance-db=ibd_postgres pagila
```

Cargar schema y datos:

```bash
MSYS_NO_PATHCONV=1 docker exec -i ibd_postgres_db psql -v ON_ERROR_STOP=1 -U ibd_postgres -d pagila -f /pagila-schema.sql
MSYS_NO_PATHCONV=1 docker exec -i ibd_postgres_db psql -v ON_ERROR_STOP=1 -U ibd_postgres -d pagila -f /pagila-faker-test.sql
```

En macOS/Linux tambien funcionan sin `MSYS_NO_PATHCONV=1`; ese prefijo es necesario en Git Bash para que no convierta `/pagila-schema.sql` a una ruta de Windows.
