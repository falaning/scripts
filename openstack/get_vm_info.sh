#!/bin/bash

# Считаем количество вм в файле vm_list
echo "Количество ВМ в файле vm_list:"
X_NUMBER=`wc -l < vm_list`
echo $X_NUMBER
i=0

# Читаем список виртуальных машин из файла
while read vm_name; do
  echo ""
  let i=i+1
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo "Информаиця о  ВМ #$i из $X_NUMBER:                                                                                                                    |"
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo "Имя ВМ:"
  echo $vm_name
  echo ""
  echo "Гипервизор ВМ:"
  openstack server show -f json $vm_name | grep OS-EXT-SRV-ATTR:host
  echo ""
  echo "Статус ВМ:"
  openstack server show -f json $vm_name | grep OS-EXT-STS:power_state
  openstack server show -f json $vm_name | grep OS-EXT-STS:vm_state
  openstack server show -f json $vm_name | grep status
  echo ""
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo "Информация о flavor данной ВМ:                                                                                                               |"
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  flavor_name=$(openstack server show -f yaml $vm_name | grep 'flavor:' | awk '{print $2}')
  openstack flavor show -f json $flavor_name | grep name
  openstack flavor show -f json $flavor_name | grep vcpus
  openstack flavor show -f json $flavor_name | grep ram
  openstack flavor show -f json $flavor_name | grep disk
  openstack flavor show -f json $flavor_name | grep swap
  echo ""
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo ""
  echo "---> СЛЕДУЮЩАЯ ВМ --->"
  echo ""
done < vm_list


# Подводим итоги
echo "Видимо всё :)"
echo ""
echo "-----------------------------------------------"
echo "Вот список всех ВМ, участвовавших в миграции: |"
echo "-----------------------------------------------"
echo "/////////////////////////////////////////////"
echo ""
cat vm_list
echo ""
echo "/////////////////////////////////////////////"
echo ""
sleep 1s
echo ""
echo "Конец работы скрипта."
echo ""
