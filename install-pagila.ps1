$container = "ibd_postgres_db"
$user = "ibd_postgres"
$adminDb = "ibd_postgres"
$db = "pagila"

docker exec -i $container psql -U $user -d $adminDb -c "DROP DATABASE IF EXISTS $db;"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker exec -i $container psql -U $user -d $adminDb -c "CREATE DATABASE $db;"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker cp pagila-schema.sql ${container}:/pagila-schema.sql
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker cp pagila-faker-test.sql ${container}:/pagila-faker-test.sql
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

docker exec -i $container psql -v ON_ERROR_STOP=1 -U $user -d $db -f /pagila-schema.sql
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Schema creado correctamente." -ForegroundColor Green

docker exec -i $container psql -v ON_ERROR_STOP=1 -U $user -d $db -f /pagila-faker-test.sql
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Datos insertados correctamente." -ForegroundColor Green
Write-Host "Instalacion de Pagila completada correctamente." -ForegroundColor Green
