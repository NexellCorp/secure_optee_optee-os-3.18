#!/bin/sh
#
# Generate partition table for 4GB eMMC on LCB
# tiny: for test
# hisilicon: 40 entries. It could be compatible with fastboot from hisilicon.
# linaro-android: 6 entries.
#

SECTOR_SIZE=512
TEMP_FILE=/tmp/tmp_file.img
OUT_MAIN_PTABLE=prm_ptable.img
OUT_BACKUP_PTABLE=sec_ptable.img

#PTABLE=tiny
PTABLE=linaro-android

case $PTABLE in
tiny)
	SECTOR_NUMBER=81920
	;;
hisilicon)
	# 4GB
	#SECTOR_NUMBER=8388608
	SECTOR_NUMBER=7553024
	;;
linaro-android)
	# 4GB
	#SECTOR_NUMBER=8388608
	SECTOR_NUMBER=7553024
	;;
esac

BK_PTABLE_LBA=`expr $SECTOR_NUMBER - 33`
echo $BK_PTABLE_LBA

# get the whole partition table
case $PTABLE in
tiny)
	dd if=/dev/zero of=$TEMP_FILE bs=$SECTOR_SIZE count=$SECTOR_NUMBER
	sgdisk -U -R -v $TEMP_FILE
	sgdisk -n 1:2048:4095 -t 1:0700 -u 1:F9F21F01-A8D4-5F0E-9746-594869AEC3E4 -c 1:"vrl" -p $TEMP_FILE
	sgdisk -n 2:4096:6143 -t 2:0700 -u 2:F9F21F02-A8D4-5F04-9746-594869AEC3E4 -c 2:"vrl_backup" -p $TEMP_FILE
	;;
linaro-android)
	dd if=/dev/zero of=$TEMP_FILE bs=$SECTOR_SIZE count=$SECTOR_NUMBER
	sgdisk -U 2CB85345-6A91-4043-8203-723F0D28FBE8 -v $TEMP_FILE
	#[1: vrl: 1M-2M]
	sgdisk -n 1:2048:4095 -t 1:0700 -u 1:496847AB-56A1-4CD5-A1AD-47F4ACF055C9 -c 1:"vrl" $TEMP_FILE
	#[2: vrl_backup: 2M-3M]
	sgdisk -n 2:4096:6143 -t 2:0700 -u 2:61A36FC1-8EFB-4899-84D8-B61642EFA723 -c 2:"vrl_backup" $TEMP_FILE
	#[3: mcuimage: 3M-4M]
	sgdisk -n 3:6144:8191 -t 3:0700 -u 3:65007411-962D-4781-9B2C-51DD7DF22CC3 -c 3:"mcuimage" $TEMP_FILE
	#[4: fastboot: 4M-12M]
	sgdisk -n 4:8192:24575 -t 4:EF02 -u 4:496847AB-56A1-4CD5-A1AD-47F4ACF055C9 -c 4:"fastboot" $TEMP_FILE
	#[5: nvme: 12M-14M]
	sgdisk -n 5:24576:28671 -t 5:0700 -u 5:00354BCD-BBCB-4CB3-B5AE-CDEFCB5DAC43 -c 5:"nvme" $TEMP_FILE
	#[6: boot: 14M-78M]
	sgdisk -n 6:28672:159743 -t 6:EF00 -u 6:5C0F213C-17E1-4149-88C8-8B50FB4EC70E -c 6:"boot" $TEMP_FILE
	#[7: reserved: 78M-334M]
	sgdisk -n 7:159744:684031 -t 7:0700 -u 7:BED8EBDC-298E-4A7A-B1F1-2500D98453B7 -c 7:"reserved" $TEMP_FILE
	#[8: cache: 334M-590M]
	sgdisk -n 8:684032:1208319 -t 8:8301 -u 8:A092C620-D178-4CA7-B540-C4E26BD6D2E2 -c 8:"cache" $TEMP_FILE
	#[9: system: 590M-2126M]
	sgdisk -n 9:1208319:4354047 -t 9:8300 -u 9:FC56E345-2E8E-49AE-B2F8-5B9D263FE377 -c 9:"system" $TEMP_FILE
	#[10: userdata: 2126M-3662M]
	sgdisk -n 10:4354048:7499775 -t 10:8300 -u 10:064111F6-463B-4CE1-876B-13F3684CE164 -c 10:"userdata" -p $TEMP_FILE
	;;
*)
	echo "Specify the wrong partition table $PTABLE"
	;;
esac

# get the main part of partition table
dd if=$TEMP_FILE of=$OUT_MAIN_PTABLE bs=$SECTOR_SIZE count=34

# get the backup part of partition table
dd if=$TEMP_FILE of=$OUT_BACKUP_PTABLE skip=$BK_PTABLE_LBA bs=$SECTOR_SIZE count=33

rm $TEMP_FILE
