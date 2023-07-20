#!/usr/bin/env bash
if [[ -z $1 ]];
then 
    echo "Usage:" $0 "image_file"
    exit 1
fi
img_file=$1
if [[ ! -f "$img_file" ]]; then
    echo "$img_file not found"
    exit 1
fi
check_command(){
    if [ $? -eq 0 ]; then
        echo "...success"
    else
        echo "...fail"
        losetup -d $next_loopdev
        exit 1
    fi
}
next_loopdev=$(losetup -f)
echo Mounting $img_file on $next_loopdev...
losetup $next_loopdev $img_file
check_command
losetup $next_loopdev
echo Accessing partitions on $img_file
partprobe $next_loopdev
check_command
echo Launcing gparted...
gparted $next_loopdev
echo Freeing $img_file from $next_loopdev
losetup -d $next_loopdev
check_command 
new_size=$(fdisk -l bc3-1.img|tail -1|awk '{print $3}')
echo Truncate $img_file to $new_size
read -p "Do you want to proceed ? (yes/no) " yn
case $yn in 
	yes ) echo ok, truncate...;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac
truncate --size=$[($new_size+1)*512] $img_file
check_command
