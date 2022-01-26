#!/bin/bash
# basic script to mount/unmount secondary storage drives
# also supportes mounting .tc files as truecrypt containers
# also supportes mounting .img files 

#EXCLUDE='sda|nvme0n1|vg0-root|luks|docker'
EXCLUDE=${PRIMITIVE_MOUNT_EXCLUDE:='docker'}
#EXCLUDEBLK="7" # <major_num>. 7 loop
EXCLUDEBLK="999" # <major_num>. 7 loop
FILEMANAGERCMD=${PRIMITIVE_MOUNT_FILEMANAGERCMD:="dbus-launch xdg-open"} # called on mount when X available

USAGE=$(cat <<EOM
  $(basename $0) [/dev/blk [fs]]
  $(basename $0) [truecrypt.tc [mount_point]]
  $(basename $0) [file.img [mount_point]]
EOM
)

# sudo call integrity check: only root should be able to change script
l=($(/usr/bin/ls -l `/usr/bin/readlink -f $0`))
([ ${l[0]:2:1} != "-" ] && [ "${l[2]}" != "root" ]) ||
([ ${l[0]:5:1} != "-" ] && [ "${l[3]}" != "root" ]) ||
 [ ${l[0]:8:1} != "-" ] && { echo -e "only root should be able to modify\n${l[@]}"; exit 1;}

# stop if a command is missing
err=0
for cmd in lsblk lsof sudo mount  egrep awk sed cut id; do
  command -v $cmd >/dev/null && continue || { echo "need $cmd. command not found."; err=1; }
done
test $err -eq 1 && exit 1

IFS=$'\n'
DEVS=$(lsblk --exclude $EXCLUDEBLK -n --paths --output NAME,FSTYPE,TYPE,MOUNTPOINT,LABEL | egrep -v "${EXCLUDE}")

if [ $# -eq 0 ]; then
  echo -e "Usage:\n$USAGE"
	echo "Select device:"
	COLUMNS=1
	select DEV in $DEVS; do
		break
	done
	FSTYPE=$(echo $DEV | sed 's/^ *[^\/]*//' | awk '{print $2}')
	TYPE=$(echo $DEV | sed 's/^ *[^\/]*//' | awk '{print $3}')
	DEV=$(echo $DEV | sed 's/^ *[^\/]*//' | awk '{print $1}')
else
	DEV="$1"
fi

if [ ! -e "$DEV" ]; then
	echo -e "\"$DEV\" not a dev or file"
	exit 1
fi


MOUNTED_AT=$(lsblk -n --paths --list | grep $DEV | cut -d ' ' -f 2- | grep '/' | sed 's/^[^\/]\+\(\/\S\+\).*/\1/g')
myUID=$(id -u)

if [ ${DEV: -3} == ".tc" ]; then
  echo "$DEV is truecrypt container"
  NAME=$(basename $DEV)
  if [ "${MOUNTED_AT}" != "" ]; then
		set -x
		sudo umount $DEV && sudo cryptsetup close $NAME || sudo lsof +d "${MOUNTED_AT}"        
		set +x
  else
		test -n "$2" && MNT="$2" || MNT=/mnt/$(basename $DEV)
		mkdir $MNT 2>/dev/null
		set -x
		sudo cryptsetup --type tcrypt open $DEV $NAME && \
		#sudo mount -o uid=$myUID,umask=0077 /dev/mapper/$NAME $MNT || exit
		sudo mount -o gid=users,fmask=113,dmask=002 /dev/mapper/$NAME $MNT || exit
		set +x
  fi
elif [ ${DEV: -4} == ".img" ]; then
  echo "$DEV is img file"
  MNT=/mnt/$(basename $DEV)
  if [ "${MOUNTED_AT}" != "" ]; then
		echo sudo umount $DEV 	
		sudo umount $DEV || sudo lsof +d "${MOUNTED_AT}"        
  else
		mkdir $MNT 2>/dev/null
  	echo sudo mount -o loop,rw,uid=$myUID,umask=0077 $DEV $MNT
  	sudo mount -o loop,rw,uid=$myUID,umask=0077 $DEV $MNT || exit
  fi
elif [ "$FSTYPE" == "crypto_LUKS" ] || [ "$TYPE" == "crypt" ] ; then
  NAME=$(basename $DEV)
  if sudo cryptsetup isLuks $DEV ; then
    echo "$DEV is crypto_LUKS type root device"
    MNT=/mnt/$(basename $DEV)
    DEVLUKS=crypt_$NAME
  else 
    echo "$DEV is crypt type mapped device (implies already mounted)"
    MNT=$(lsblk --output MOUNTPOINT $DEV | tail -1)
    NAME=$(basename $DEV)
    DEVLUKS=$NAME
  fi
  # figure out if mounted without depending on lsblk
  mount | grep -q $DEVLUKS && MOUNTED_AT=$MNT
  if [ "${MOUNTED_AT}" != "" ]; then
		echo sudo umount $DEV 	
		set -x
		sudo umount $MNT && sudo cryptsetup close $DEVLUKS || sudo lsof +d "${MOUNTED_AT}"        
		set +x
		sudo dmsetup ls
  else
		sudo mkdir $MNT 2>/dev/null
		echo sudo cryptsetup luksOpen $DEV $DEVLUKS
		sudo cryptsetup luksOpen $DEV $DEVLUKS
		set -x
		sudo mount -o user,nofail,noauto,x-gvfs-show  /dev/mapper/$DEVLUKS $MNT  \
		|| exit
		set +x
  fi
else
  if [ "${MOUNTED_AT}" != "" ]; then
		echo sudo umount $DEV 	
		sudo umount $DEV || sudo lsof +d "${MOUNTED_AT}"        
  else
		MNT=/mnt/$(basename $DEV)
		mkdir $MNT 2>/dev/null
		if [ $# -ge 2 ]; then
			echo sudo mount -o rw,uid=$myUID,umask=0077 $DEV $MNT -t $2
			sudo mount -o rw,uid=$myUID,umask=0077 $DEV $MNT -t $2 || exit
			#sudo mount $DEV $MNT -t $2 || exit
		else
			echo sudo mount -o uid=$myUID,umask=0077 $DEV $MNT || sudo mount $DEV $MNT
			sudo mount -o uid=$myUID,umask=0077 $DEV $MNT || \
			sudo mount $DEV $MNT || exit
		fi
		ls $MNT
  	# if x available open file manager
  	if xset q &>/dev/null; then
  	  eval $FILEMANAGERCMD $MNT
  	fi
  fi
fi

exit 0
