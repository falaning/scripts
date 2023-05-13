#!/bin/bash

echo "Количество гипервизоров в файле hyper_list:"
X_NUMBER=`wc -l < hyper_list`
echo $X_NUMBER
i=0

# Читаем список гиперов
while read hyper_name; do
  echo ""
  let i=i+1
  FULL_NAME_HYPER=`openstack hypervisor list --fit | grep $hyper_name | awk -F"|" '{ print $3}'`
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo "Гипервизор  #$i из $X_NUMBER:"
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo ""
  echo $FULL_NAME_HYPER
  echo ""
  openstack hypervisor show -f json $FULL_NAME_HYPER | grep vcpus
  echo ""
  echo "----------------------------------------------------------------------------------------------------------------------------------------------"
  echo ""
  echo ""
done < hyper_list

echo ""
echo "Вот список всех гипервизоров:"
echo ""
cat hyper_list
echo ""
echo "Конец работы скрипта."
echo ""
