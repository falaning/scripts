#!/bin/bash

# Запрашиваем имя гипервизора
echo "Введите имя гипервизора (по умолчанию: все гипервизоры):"
echo "(введите короткое имя, наприме: r3-106-pble)"
read hypervisor_name

# Если имя гипервизора не указано, получаем список всех гипервизоров
if [ -z "$hypervisor_name" ]; then
    hypervisor_list=$(openstack hypervisor list -f value -c "Hypervisor Hostname")
else
    hypervisor_list=$hypervisor_name
fi

# Получаем список ID виртуальных машин на каждом гипервизоре
for hypervisor in $hypervisor_list; do
    echo "Список VM на гипервизоре $hypervisor:"
    openstack server list --all-projects --host $hypervisor -f value -c ID
done
