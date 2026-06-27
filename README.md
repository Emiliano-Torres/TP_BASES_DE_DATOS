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

Antes de ejecutar los scripts, el contenedor Docker local con PostgreSQL tiene que estar levantado y listo para aceptar conexiones.

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
