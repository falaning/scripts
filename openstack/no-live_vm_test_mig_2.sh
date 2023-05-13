#!/bin/bash

# Запрашиваем имя гипервизора
echo "Введите имя гипервизора для миграции:"
echo "(короткое имя, например: r3-102-pble)"
echo ""
read hypervisor_name
echo ""
echo "Количество ВМ в файле vm_list:"
X_NUMBER=`wc -l < vm_list`
echo $X_NUMBER
i=0

# Читаем список виртуальных машин из файла и мигрируем каждую на указанный гипервизор
while read vm_name; do
  echo ""
  let i=i+1
  echo "Сейчас мигрируется ВМ #$i из $X_NUMBER:"
  echo $vm_name
  echo ""
  openstack server --os-compute-api-version 2.56 migrate $vm_name --wait --host $hypervisor_name
  echo ""
  echo "Миграция завершена"
  echo "Ждём 5 секунд для безопасности..."
  sleep 5s
  echo ""
  echo "Данные о ВМ:"
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo ""
  openstack server show --fit $vm_name | grep OS-EXT-SRV-ATTR:host
  openstack server show --fit $vm_name | grep OS-EXT-STS:power_state
  openstack server show --fit $vm_name | grep OS-EXT-STS:vm_state
  openstack server show --fit $vm_name | grep status
  echo ""
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo ""
  echo "-------->!Переходим к следующей ВМ!<--------"
done < vm_list

echo "Видимо всё :)"
echo ""
echo "Вот список всех ВМ, участвовавших в миграции:"
echo ""
cat vm_list
echo ""
sleep 1s
echo "Данные о гипервизоре:"
sleep 1s

# show_hy_info.sh

FULL_NAME_HYPER=`openstack hypervisor list --fit | grep $hypervisor_name | awk -F"|" '{ print $3}'`
echo $FULL_NAME_HYPER
echo ""
echo "Количество vCPU"
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
openstack hypervisor show --fit $FULL_NAME_HYPER | grep vcpus
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "Места на Disk"
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
openstack hypervisor show --fit $FULL_NAME_HYPER | grep disk
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "количество Ram"
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
openstack hypervisor show --fit $FULL_NAME_HYPER | grep ram
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "Конец работы скрипта."
echo ""
