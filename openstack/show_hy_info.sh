#!/bin/bash

echo "Введите имя короткое гипервизора (например r3-102-pble):"
read HYPERVISOR
FULL_NAME_HYPER=`openstack hypervisor list --fit | grep $HYPERVISOR | awk -F"|" '{ print $3}'`
echo $FULL_NAME_HYPER
openstack hypervisor show --fit $FULL_NAME_HYPER | grep vcpus
openstack hypervisor show --fit $FULL_NAME_HYPER | grep disk
openstack hypervisor show --fit $FULL_NAME_HYPER | grep ram
