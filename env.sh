DB_SERVER_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=$(podman logs mysql 2>&1| grep "GENERATED ROOT PASSWORD" | awk -F ": " '{ print $2}')
