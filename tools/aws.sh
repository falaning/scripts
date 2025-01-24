#!/bin/bash

# Этот скрипт устанавливает aws cli и настраивает подключение к S3 бакету в Cloud.ru

screen -S aws_setup_session /bin/bash -c '

# Установка
echo ""
echo "Установка aws cli"
echo ""
sudo apt update -y
sudo apt-get install awscli -y
echo ""
clear
echo "Установка завершена!"
echo ""

# Настройка

echo "Настройка подключения к S3 бакету"
echo ""
echo "Для параметра aws_access_key_id введите <tenant_id>:<key_id>."
echo "Для параметра aws_secret_access_key введите <key_secret>."
echo "Для параметра Default region name введите регион ru-central-1"
echo "Для параметра Default output format: просто нажать Enter (или написатиь json если нужно)"
echo ""
aws configure
clear
echo ""
echo "Конфигурирование завершено!"
echo ""
echo "Ваща итоговая конфигурация:"
echo ""
echo "+---------------------------------------------------------------------------------------------+"
echo ".aws/credentials"
echo "+---------------------------------------------------------------------------------------------+"
cat .aws/credentials
echo "+---------------------------------------------------------------------------------------------+"
echo ""
echo "Нажмите Enter чтобы продолжить."
read JUST_SKIP
clear

# Проверка соединения

echo ""
echo "Проверка подключения к S3 бакету."
echo ""
echo "Введите название вашего бакета:"
echo ""
read MY_BUCKET
clear
echo ""
echo "Проверка подключения..."
echo ""
echo "Список файлов в бакете:"
echo ""
echo "+---------------------------------------------------------------------------------------------+"
echo "Bucket: $MY_BUCKET"
echo "+---------------------------------------------------------------------------------------------+"
aws --endpoint-url=https://s3.cloud.ru \
   s3 ls --recursive s3://$MY_BUCKET
echo "+---------------------------------------------------------------------------------------------+"
echo ""
echo "Скрипт завершён!"
echo ""
echo "Нажмите Enter чтобы закрыть это окно."
echo ""
read SCRIPT_EXIT
exit
'
