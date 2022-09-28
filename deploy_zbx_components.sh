podman run --name mysql -v $(pwd)/my.cnf:/etc/my.cnf:Z --network podman  -p 127.0.0.1:3306:33060 -d docker.io/mysql/mysql-server:latest
sleep 15
source $(pwd)/env.sh

podman exec mysql mysql -u root -p$MYSQL_PASSWORD -e "ALTER USER 'root'@'localhost' IDENTIFIED  BY '${MYSQL_PASSWORD}'" --connect-expired-password
podman exec mysql mysql -u root -p$MYSQL_PASSWORD -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'"
podman exec mysql mysql -u root -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'zabbix'@'%' WITH GRANT OPTION"
#podman exec mysql mysql -u root -p$MYSQL_PASSWORD -e "CREATE DATABASE zabbix"

podman run --name zabbix-server --network podman  -p 127.0.0.1:10051:10051 -e DB_SERVER_HOST="mysql.dns.podman" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD=$MYSQL_PASSWORD -d docker.io/zabbix/zabbix-server-mysql:latest

podman run --name zabbix-web -v $(pwd)/httpd.conf:/etc/apache2/httpd.conf:Z --network podman -e DB_SERVER_HOST="mysql.dns.podman" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD=$MYSQL_PASSWORD -e ZBX_SERVER_HOST="zabbix-server.dns.podman" -e PHP_TZ="Europe/Oslo" -p 127.0.0.1:8080:8080 -d docker.io/zabbix/zabbix-web-apache-mysql:latest

podman run --name zabbix-proxy --network podman -e DB_SERVER_HOST="mysql.dns.podman" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD=$MYSQL_PASSWORD -e ZBX_HOSTNAME=zabbix-proxy.dns.podman -e ZBX_SERVER_HOST="zabbix-server.dns.podman" -d docker.io/zabbix/zabbix-proxy-mysql

podman run --name zabbix-agent -e ZBX_HOSTNAME="zabbix-agent.dns.podman"  --network podman -e ZBX_SERVER_HOST="zabbix-proxy.dns.podman" -d docker.io/zabbix/zabbix-agent
