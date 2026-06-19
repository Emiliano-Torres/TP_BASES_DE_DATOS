$container = "ibd_postgres_db"
$user = "ibd_postgres"
$adminDb = "ibd_postgres"
$db = "pagila"

docker exec -i $container psql -U $user -d $adminDb -c "DROP DATABASE IF EXISTS $db;"
docker exec -i $container psql -U $user -d $adminDb -c "CREATE DATABASE $db;"

docker cp pagila-schema.sql ${container}:/pagila-schema.sql
docker cp pagila-faker-test.sql ${container}:/pagila-faker-test.sql
docker cp pagila-foreign-key.sql ${container}:/pagila-foreign-key.sql

docker exec -i $container psql -U $user -d $db -f /pagila-schema.sql
docker exec -i $container psql -U $user -d $db -f /pagila-faker-test.sql
docker exec -i $container psql -U $user -d $db -f /pagila-foreign-key.sql