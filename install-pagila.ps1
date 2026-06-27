param(
    [string]$Container = "ibd_postgres_db",
    [string]$User = "ibd_postgres",
    [string]$Db = "pagila"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$schemaPath = Join-Path $scriptDir "sql\pagila-schema.sql"
$dataPath = Join-Path $scriptDir "pagila-faker-test.sql"

if (-not (Test-Path $schemaPath)) {
    Write-Host "No se encontro el schema en: $schemaPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dataPath)) {
    Write-Host "No se encontro el archivo de datos en: $dataPath" -ForegroundColor Red
    Write-Host "Generalo antes con: python py\generar_pagila_faker.py" -ForegroundColor Yellow
    exit 1
}

function Invoke-Checked {
    param(
        [string]$Message,
        [string]$Command,
        [string[]]$Arguments
    )

    Write-Host $Message -ForegroundColor Cyan
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

Invoke-Checked -Message "Copiando schema al contenedor..." -Command "docker" -Arguments @(
    "cp",
    $schemaPath,
    "${Container}:/pagila-schema.sql"
)

Invoke-Checked -Message "Copiando datos al contenedor..." -Command "docker" -Arguments @(
    "cp",
    $dataPath,
    "${Container}:/pagila-faker-test.sql"
)

Invoke-Checked -Message "Recreando schema y creando tablas..." -Command "docker" -Arguments @(
    "exec",
    "-i",
    $Container,
    "psql",
    "-v",
    "ON_ERROR_STOP=1",
    "-U",
    $User,
    "-d",
    $Db,
    "-f",
    "/pagila-schema.sql"
)
Write-Host "Schema creado correctamente." -ForegroundColor Green

Invoke-Checked -Message "Insertando datos..." -Command "docker" -Arguments @(
    "exec",
    "-i",
    $Container,
    "psql",
    "-v",
    "ON_ERROR_STOP=1",
    "-U",
    $User,
    "-d",
    $Db,
    "-f",
    "/pagila-faker-test.sql"
)
Write-Host "Datos insertados correctamente." -ForegroundColor Green
Write-Host "Instalacion de Pagila completada correctamente." -ForegroundColor Green
