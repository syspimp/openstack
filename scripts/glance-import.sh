#!/bin/bash
# this will import all glance images from the $FILES directory
# or one file, give ghe full path ie ./glance-import -f /shelf/compute4/glance-images/myimg.raw
# the meta data should exist, ie /shelf/compute4/glance-images/myimg.raw.metadata
source /root/keystonerc_user
FILES='/shelf/compute4/glance-images'
TYPES=( qcow2 )
#TYPES=( qcow2 raw iso vhd vmdk )
PROPS=''


do_all()
{
  for type in ${TYPES[@]}
  do
    for IMAGE in `ls ${FILES}/*.${type}`
    do
      if [ ! -f "${IMAGE}.metadata" ] ; then
         echo "Could not find metadata, aborting import for ${IMAGE}"
         continue;
      fi
      NIC=$(grep "hw_nic_model" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      [ ! -z "$NIC" ] && PROPS="$PROPS --property hw_nic_model='${NIC}'"
      VIF=$(grep "hw_vif_model" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      [ ! -z "$VIF" ] && PROPS="$PROPS --property hw_vif_model='${VIF}'"
      BUS=$(grep "hw_disk_bus" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      [ ! -z "$BUS" ] && PROPS="$PROPS --property hw_disk_bus='${BUS}'"
      OS=$(grep "os_type" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      [ ! -z "$OS" ] && PROPS="$PROPS --property os_type='${OS}'"
      NAME=$(grep -v "_type_name" ${IMAGE}.metadata | grep name |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      CONTAINER=$(grep "container_format" ${IMAGE}.metadata |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      DISK=$(grep "disk_format" ${IMAGE}.metadata |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      PUBLIC=$(grep "public" ${IMAGE}.metadata |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
      glance image-create --name="${NAME}" ${PROPS} --is-public=${PUBLIC} --container-format=${CONTAINER} --disk-format=${DISK} < ${IMAGE}
      PROPS=''
    done
  done
}

do_image()
{
  IMAGE="$1"
  if [ -e "${IMAGE}" ]
  then
    NIC=$(grep "hw_nic_model" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    [ ! -z "$NIC" ] && PROPS="$PROPS --property hw_nic_model='${NIC}'"
    VIF=$(grep "hw_vif_model" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    [ ! -z "$VIF" ] && PROPS="$PROPS --property hw_vif_model='${VIF}'"
    BUS=$(grep "hw_disk_bus" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    [ ! -z "$BUS" ] && PROPS="$PROPS --property hw_disk_bus='${BUS}'"
    OS=$(grep "os_type" ${IMAGE}.metadata | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    [ ! -z "$OS" ] && PROPS="$PROPS --property os_type='${OS}'"
    NAME=$(grep -v "_type_name" ${IMAGE}.metadata | grep name |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    CONTAINER=$(grep "container_format" ${IMAGE}.metadata |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    DISK=$(grep "disk_format" ${IMAGE}.metadata |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    PUBLIC=$(grep "public" ${IMAGE}.metadata |  cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//')
    glance image-create --name="${NAME}" ${PROPS} --is-public=${PUBLIC} --container-format=${CONTAINER} --disk-format=${DISK} < ${IMAGE}
  else
    echo "${IMAGE} do not exist. Give full path"
  fi
}

while getopts "df:a" OPTION
do
  case "$OPTION" in
     # debug
     d) set -x
     ;;
     f) do_image ${OPTARG}
     ;;
     a) do_all
     ;;
  esac
done

