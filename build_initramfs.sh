#!/bin/bash
TOP=$(pwd)
export CC_DIR=$TOP/toolchains/gcc-linaro-4.9-2014.11-x86_64_aarch64-linux-gnu
export PATH=${CC_DIR}/bin:$PATH
KERNEL_VERSION=`cd linux ; make --no-print-directory -s kernelversion`
INITRAMFS="initramfs.gz"
MOUNT_DIR=".tmpramfs"

if [ -f ./${INITRAMFS} ] ; then
	echo "Already file : ${INITRAMFS}"
	exit 0
fi

if [ ! -L ./buildroot ] ; then
	echo "make link file -> buildroot"
	ln -s ../../platform/common/fs/buildroot buildroot
fi

if [ ! -f ./buildroot/out/ramdisk.gz ] ; then
	echo "GEN buildroot"
	cd ./buildroot/buildroot-2015.02
	cp ../configs/br.2015.02.aarch64_glibc_tiny_rfs.config .config
	make -j${_NPROCESSORS_ONLN}

	cd ../
	./scripts/mk_ramfs.sh -r ./out/rootfs -c ./out
fi

cd ${TOP}
if [ -d ${MOUNT_DIR} ] ; then
	sudo umount ${MOUNT_DIR};
	yes | sudo rm -rf ${MOUNT_DIR}
fi

mkdir -p ${MOUNT_DIR}
cp ./buildroot/out/ramdisk.gz .
gzip -d ./ramdisk.gz
sudo mount -o loop,rw,sync ./ramdisk ./${MOUNT_DIR}

cd ${TOP}/${MOUNT_DIR}

# rc.d entry for OP-TEE (start on boot)
sudo cp ${TOP}/init.d.optee ./etc/init.d/optee
if [ ! -L ./etc/init.d/S09_optee ] ; then
	cd ./etc/init.d
	sudo ln -s ./optee ./S09_optee
	cd ${TOP}/${MOUNT_DIR}
fi

# OP-TEE device
if [ ! -d ./lib/modules ] ; then
	sudo mkdir ./lib/modules
	sudo chmod 755 ./lib/modules
fi
if [ ! -d ./lib/modules/${KERNEL_VERSION} ] ; then
	sudo mkdir ./lib/modules/${KERNEL_VERSION}
	sudo chmod 755 ./lib/modules/${KERNEL_VERSION}
fi
sudo cp ${TOP}/optee_linuxdriver/core/optee.ko ./lib/modules/${KERNEL_VERSION}/optee.ko
sudo cp ${TOP}/optee_linuxdriver/armtz/optee_armtz.ko ./lib/modules/${KERNEL_VERSION}/optee_armtz.ko
 
# OP-TEE client
sudo cp ${TOP}/optee_client/out/export/bin/tee-supplicant ./bin/tee-supplicant
if [ ! -d ./lib/aarch64-linux-gnu ] ; then
	sudo mkdir ./lib/aarch64-linux-gnu
	sudo chmod 755 ./lib/aarch64-linux-gnu
fi
#sudo cp ${TOP}/optee_client/out/export/lib/libteec.so.1.0 ./lib/aarch64-linux-gnu/libteec.so.1.0
#sudo cp ${TOP}/optee_client/out/export/lib/libteec.so.1.0 ./lib/aarch64-linux-gnu/libteec.so.1
#sudo cp ${TOP}/optee_client/out/export/lib/libteec.so.1.0 ./lib/aarch64-linux-gnu/libteec.so
 
sudo cp ${TOP}/optee_client/out/export/lib/libteec.so.1.0 ./lib/libteec.so.1.0
sudo cp ${TOP}/optee_client/out/export/lib/libteec.so.1.0 ./lib/libteec.so.1
sudo cp ${TOP}/optee_client/out/export/lib/libteec.so.1.0 ./lib/libteec.so
 
# OP-TEE tests
sudo cp ${TOP}/optee_test/out/xtest/xtest ./bin/xtest

if [ ! -d ./lib/optee_armtz ] ; then
	sudo mkdir ./lib/optee_armtz
	sudo chmod 755 ./lib/optee_armtz
fi
sudo cp ${TOP}/optee_test/out/ta/rpc_test/d17f73a0-36ef-11e1-984a0002a5d5c51b.ta ./lib/optee_armtz/d17f73a0-36ef-11e1-984a0002a5d5c51b.ta
sudo cp ${TOP}/optee_test/out/ta/crypt/cb3e5ba0-adf1-11e0-998b0002a5d5c51b.ta ./lib/optee_armtz/cb3e5ba0-adf1-11e0-998b0002a5d5c51b.ta
sudo cp ${TOP}/optee_test/out/ta/storage/b689f2a7-8adf-477a-9f9932e90c0ad0a2.ta ./lib/optee_armtz/b689f2a7-8adf-477a-9f9932e90c0ad0a2.ta
sudo cp ${TOP}/optee_test/out/ta/os_test/5b9e0e40-2636-11e1-ad9e0002a5d5c51b.ta ./lib/optee_armtz/5b9e0e40-2636-11e1-ad9e0002a5d5c51b.ta
sudo cp ${TOP}/optee_test/out/ta/create_fail_test/c3f6e2c0-3548-11e1-b86c0800200c9a66.ta ./lib/optee_armtz/c3f6e2c0-3548-11e1-b86c0800200c9a66.ta
sudo cp ${TOP}/optee_test/out/ta/sims/e6a33ed4-562b-463a-bb7eff5e15a493c8.ta ./lib/optee_armtz/e6a33ed4-562b-463a-bb7eff5e15a493c8.ta
 
# AES benchmark application
sudo cp ${TOP}/aes-perf/out/aes-perf/aes-perf ./bin/aes-perf
sudo chmod 755 ./bin/aes-perf
sudo cp ${TOP}/aes-perf/out/ta/e626662e-c0e2-485c-b8c809fbce6edf3d.ta ./lib/optee_armtz/e626662e-c0e2-485c-b8c809fbce6edf3d.ta
 
# Hello world test application
sudo cp ${TOP}/helloworld/out/helloworld/helloworld ./bin/helloworld
sudo chmod 755 ./bin/helloworld
sudo cp ${TOP}/helloworld/out/ta/968c7511-9ace-43fe-8a78faf988096de5.ta ./lib/optee_armtz/968c7511-9ace-43fe-8a78faf988096de5.ta

sudo chmod 444 ./lib/optee_armtz/*.ta

cd ${TOP}
sudo umount ${MOUNT_DIR}
sudo gzip -f ./ramdisk 
sudo rm -rf ${MOUNT_DIR}
cp ramdisk.gz ./${INITRAMFS} 
rm ramdisk.gz
