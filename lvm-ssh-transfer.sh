#!/bin/bash

#LVM copy via SSH
#Source: https://github.com/daniol/lvm-ssh-transfer
#License (GNU General Public License v3.0): https://github.com/daniol/lvm-ssh-transfer/blob/master/LICENSE

#Initialize arguments
group=""
volume=""
dest=""
verify="n"

#Parse arguments
#Source: https://unix.stackexchange.com/a/388038
while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi
  shift
done

#Validate arguments
if [ -z "$group" ]
then
 echo "Argument error: Group volume is empty"
 exit 22
fi
if [ -z "$volume" ]
then
 echo "Argument error: Volume name is empty"
 exit 22
fi
if [ -z "$dest" ]
then
 echo "Argument error: destination (IP/Host) is empty"
 exit 22
fi

#Get source volume size
size=$(lvs $group/$volume --units b -o size --no-headings | xargs)
if [ $? -ne 0 ]
then
 echo "The logical volume /dev/$group/$volume does not exist"
 exit $?
fi

#Create remote volume
ssh $dest lvcreate -L$size -n$volume $group

if [ $? -ne 0 ]
then
  echo "The creation of the logical volume /dev/$group/$volume on $dest failed" >&2
  exit $?
fi

#Copy data
echo "Copying /dev/$group/$volume to $dest (ssh)..."
dd if=/dev/$group/$volume bs=4096 | gzip | ssh $dest "gzip -d | dd of=/dev/$group/$volume bs=4096"

if [ $? -ne 0 ]
then
  echo "The copy of the logical volume /dev/$group/$volume on $dest failed" >&2
  exit $?
fi

if [ -z "$verify" ]
then
 sha_local=$(sha1sum -b /dev/$group/$volume | awk '{print $1}')
 sha_remote=$(ssh $dest "sha1sum -b /dev/$group/$volume" | awk '{print $1}')
 if [ "$sha_local" != "$sha_remote" ]
 then
  echo "The data was corrupted ($sha_local / $sha_remote)!"
  exit 61
 else
  echo "The data was transfered fine ($sha_local)"
 fi
fi

#Everything OK
exit 0
