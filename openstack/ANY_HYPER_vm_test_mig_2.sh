#!/bin/bash

# Запрашиваем имя гипервизора
echo "Начинается миграция ВМ из списка vm_list на рандомные гипервизоры."
echo "(!)"
echo "Нажмите Enter чтобы продолжить, или отмените с помощью CTRL + C"
echo "(!)"
echo ""
read
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
  openstack server --os-compute-api-version 2.56 migrate --live-migration $vm_name --wait
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
echo "----------------------------------------------------------------------------------------------------------------------------------------------"
echo ""
echo "Конец работы скрипта."
echo ""
