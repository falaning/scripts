#!/bin/bash

#+---------------------------------------------------------------------------------------------+
#|                                                                                             |
#|  В данной версии скрипта 2.0 была добавлена возможность записи вывода ID ВМ в файл vm_list  |
#|                                                                                             |
#+---------------------------------------------------------------------------------------------+

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
    echo ""
    openstack server list --all-projects --host $hypervisor -f value -c ID
done

# Спрашиваем нужна ли запись ID ВМ в файл vm_list
echo ""
echo ""
echo "-------------------------------------------------"
echo "Вы хотите записать данные ID ВМ в файл vm_list?"
echo 'Напишите "да" или "yes" если хотите записать,'
echo 'либо нажмите "Enter" чтобы ничего не записывать'
echo "-------------------------------------------------"
read answer

if [ "$answer" = "yes" ] || [ “$answer” = “да” ] || [ "$answer" = "Yes" ] || [ “$answer” = “Да” ]
then
    echo "Начинается запись..."
    echo > vm_list
    for hypervisor in $hypervisor_list; do
	openstack server list --all-projects --host $hypervisor -f value -c ID > vm_list
    done
    echo ""
    echo "...Запись завершена"
else
    echo "Запись не произведена"
fi
