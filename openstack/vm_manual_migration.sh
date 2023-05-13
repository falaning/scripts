#!/bin/bash

# Запрашиваем имя гипервизора
echo "Введите имя гипервизора (по умолчанию: любой доступный гипервизор):"
read hypervisor_name

# Если имя гипервизора не указано, используем любой доступный гипервизор
if [ -z "$hypervisor_name" ]; then
    hypervisor_option=""
else
    hypervisor_option="--target-host $hypervisor_name"
fi

# Мигрируем каждую виртуальную машину из списка
while read vm_name; do
    echo "Миграция виртуальной машины $vm_name на гипервизор $hypervisor_name"
    openstack server --os-compute-api-version 2.56 migrate --live-migration $vm_name --host $hypervisor_option --wait
    sleep 5s # добавляем паузу в 5 секунд между миграциями
done < vm_list
