#!/bin/bash

# Этот скрипт устанавливает barman и postgresql, проводит настройку и вообще готовит barman "под ключ"

# Подготовка

sudo apt update -y
sudo apt upgrade -y
sudo apt-get install postgresql -y
sleep 5
sudo apt-get install barman -y


# Создание пользователя

clear
echo "Сейчас создаётся пользователь barman"
echo "Придумайте пароль: "
echo ""
sudo -u postgres createuser -s -P barman
sleep 5

# Postgre config

echo "# For barman" >> /etc/postgresql/14/main/pg_hba.conf
echo "host    all             barman          127.0.0.1/32            md5" >> /etc/postgresql/14/main/pg_hba.conf
sudo systemctl restart postgresql

# Postgre config 2

CONFIG_FILE="/etc/postgresql/14/main/postgresql.conf"

NEW_CONFIG="
wal_level = replica
archive_mode = on
archive_command = 'cp %p /var/lib/barman/wal/%f'
max_wal_senders = 3
wal_keep_size = 128
"

echo "$NEW_CONFIG" >> "$CONFIG_FILE"
echo "Конфигурация успешно добавлена."

# Barman config

touch /etc/barman.d/local_postgres.conf
echo '[local_postgres]' >> /etc/barman.d/local_postgres.conf
echo 'description = "Local PostgreSQL server"' >> /etc/barman.d/local_postgres.conf
echo 'conninfo = user=barman dbname=postgres' >> /etc/barman.d/local_postgres.conf
echo 'backup_directory = /var/lib/barman/local_postgres' >> /etc/barman.d/local_postgres.conf
echo 'retention_policy = RECOVERY WINDOW OF 7 DAYS' >> /etc/barman.d/local_postgres.conf
echo 'backup_method = postgres' >> /etc/barman.d/local_postgres.conf
echo 'archiver = on' >> /etc/barman.d/local_postgres.conf
echo 'streaming_archiver = on' >> /etc/barman.d/local_postgres.conf
echo 'slot_name = barman' >> /etc/barman.d/local_postgres.conf
echo 'backup_options = concurrent_backup' >> /etc/barman.d/local_postgres.conf
echo 'ssh_command = ""' >> /etc/barman.d/local_postgres.conf
echo ""
echo "Готовый файл: /etc/barman.d/local_postgres.conf"
echo ""
cat /etc/barman.d/local_postgres.conf
echo ""

# Создание директории и выдача прав на неё

mkdir /var/lib/barman/wal
chgrp -R postgres /var/lib/barman
chmod -R g+rwx /var/lib/barman
usermod -aG postgres barman
chown -R postgres:postgres /var/lib/barman/wal/
chmod -R 700 /var/lib/barman/wal/
sudo chmod -R 770 /var/lib/barman/wal

# Создание слота репликации

set -e
sudo -u postgres psql -t -d postgres -c "SELECT * FROM pg_create_physical_replication_slot('barman');"
echo ""

# Включаем archive_mode

echo "Включаю archive_mode..."
sudo -u postgres sh -c 'cd /tmp && psql -t -d postgres -c "ALTER SYSTEM SET archive_mode TO 'on';"'
echo ""

# Устанавливаем archive_command

echo "Устанавливаю archive_command..."
sudo -u postgres sh -c "cd /tmp && psql <<EOF
ALTER SYSTEM SET archive_command TO 'cp \"%p\" \"/var/lib/barman/wal/%f\"';
\q
EOF"

sleep 5

# Перезагружаем базы

echo "Перезагружаю базу..."
systemctl restart postgresql
echo "База перезагружена!"
echo ""

# Проверяем новые значения

echo "Проверяю новые значения:"
archive_mode=$(sudo -u postgres sh -c "cd /tmp && psql -t -d postgres -c 'SHOW archive_mode;'")
archive_command=$(sudo -u postgres sh -c "cd /tmp && psql -t -d postgres -c 'SHOW archive_command;'")
replica_slot=$(sudo -u postgres sh -c "psql -t -d postgres -c 'SELECT * FROM pg_replication_slots;'")
echo ""
echo "archive_mode:"
echo $archive_mode
echo "archive_command:"
echo $archive_command
echo "replica_slot"
echo $replica_slot
echo ""

# Создание systemd unit'а для запуса wal-стриминга

WAL_UNIT="/etc/systemd/system/barman-receive-wal.service"

WAL_INFO="
[Unit]
Description=Run barman receive-wal for local_postgres
After=network.target

[Service]
Type=simple
User=barman
ExecStart=/usr/bin/barman receive-wal local_postgres
Restart=always

[Install]
WantedBy=multi-user.target
"

echo "$WAL_INFO" > "$WAL_UNIT"
echo "WAL-юнит успешно создан."

# Приминение юнита

sudo systemctl daemon-reload
sleep 5
sudo systemctl start barman-receive-wal
sleep 5
sudo systemctl enable barman-receive-wal
sleep 5

# Снова ребут базы

systemctl restart postgresql

# Настройка завершена. Можно сделать тестовый бекап.

echo ""
echo "Настройка Barman завершена!"
echo ""
echo "Бекапы будут храниться в этой директории:"
echo "/var/lib/barman/wal"
echo ""
echo "Для тестового бекапа введите команду:"
echo ""
echo "sudo -u barman barman backup local_postgres --wait"
echo ""
