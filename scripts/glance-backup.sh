#!/bin/bash
#set -x
KEYSTONRC="/root/keystonerc_user"
SAVEDIR="/shelf/compute4/glance-images"

if [ -e  "$KEYSTONRC" ]
then
  source $KEYSTONRC
else
  echo "I need credential file $KEYSTONRC to do work. Failure."
  exit 1
fi

glance image-list | grep active | while read line ;
do
  IMAGEID=$(echo $line | awk '{print $2}')
  NAME=$(echo $line | cut -d\| -f3| sed -e 's/^ *//' -e 's/ *$//'|sed -e 's/ /-/g')
  DISK=$(echo $line | cut -d\| -f4| sed -e 's/^ *//' -e 's/ *$//')
  CONTAINER=$(echo $line | cut -d\| -f5| sed -e 's/^ *//' -e 's/ *$//')
  SAVEFILE="${SAVEDIR}/${NAME}-${CONTAINER}.${DISK}"
  if [ ! -e "$SAVEFILE" ]
  then
    echo "Saving Image '${NAME}' to ${SAVEFILE} ..."
    # save it!
    time glance image-download ${IMAGEID} --file ${SAVEFILE}
    glance image-show ${IMAGEID} > ${SAVEFILE}.metadata
  else
    echo "File already exists ..."
  fi
done
