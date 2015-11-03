#!/bin/bash
#
# Usage: generate_cpio_rootfs.sh <platform_name>
#        generate_cpio_rootfs.sh <platform_name> clean
#        generate_cpio_rootfs.sh <platform_name> nocpio

echo "Generator for a simple initramfs root filesystem for some ARM targets"
CURDIR="$(dirname "$(readlink -f "$0")")"
STAGEDIR=${CURDIR}/stage
BUILDDIR=${CURDIR}/build
OUTFILE=${HOME}/rootfs-$1.cpio

if [ "$2" = "clean" -o "$2" = "distclean" ]; then
    echo "Cleaning"
    rm -rf ${STAGEDIR} ${BUILDDIR}
    rm -f ${OUTFILE} ${CURDIR}/etc/hostname ${CURDIR}/etc/inittab
    rm -f ${CURDIR}/filelist-tmp.txt ${CURDIR}/filelist-final.txt
    exit 0
fi
if [ "$2" = "distclean" ]; then
    rm -rf ${CURDIR}/busybox
fi

STRACEVER=strace-4.7
STRACE=${CURDIR}/${STRACEVER}

# Helper function to copy one level of files and then one level
# of links from a directory to another directory.
function clone_dir()
{
    SRCDIR=$1
    DSTDIR=$2
    FILES=`find ${SRCDIR} -maxdepth 1 -type f`
    for file in ${FILES} ; do
	BASE=`basename $file`
	cp $file ${DSTDIR}/${BASE}
	# ${STRIP} -s ${DSTDIR}/${BASE}
    done;
    # Clone links from the toolchain binary library dir
    LINKS=`find ${SRCDIR} -maxdepth 1 -type l`
    cd ${DSTDIR}
    for file in ${LINKS} ; do
	BASE=`basename $file`
	TARGET=`readlink $file`
	ln -sf ${TARGET} ${BASE}
    done;
    cd ${CURDIR}
}

case $1 in
    "i486")
	echo "Building Intel i486 root filesystem"
	export ARCH=i486
	CC_PREFIX=i486
	CC_DIR=/var/linus/cross-compiler-i486
	LIBCBASE=${CC_DIR}
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-march=i486 -mtune=i486 -m32"
	cp etc/inittab-pc etc/inittab
	echo "i486" > etc/hostname
	;;
    "i586")
	echo "Building Intel i586 Pentium root filesystem"
	export ARCH=i586
	CC_PREFIX=i586
	CC_DIR=/var/linus/cross-compiler-i586
	LIBCBASE=${CC_DIR}
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	# Skip -mtune pentium-mmx for generic Pentium image
	CFLAGS="-march=i586 -mtune=pentium-mmx -m32"
	cp etc/inittab-pc etc/inittab
	echo "i586" > etc/hostname
	;;
    "h3600")
	echo "Building SA110 Compaq h3600 ARMv4 root filesystem"
	export ARCH=arm
	# Use ARMv4l base for SA1100 rootfs builds
	# This is the convention of Rob Landley's binaries
	CC_PREFIX=armv4l
	CC_DIR=/var/linus/cross-compiler-armv4l
	LIBCBASE=${CC_DIR}
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mno-thumb-interwork -mcpu=strongarm1100"
	cp etc/inittab-sa1100 etc/inittab
	echo "h3600" > etc/hostname
	;;
    "nslu2")
	echo "Building NSLU2 ARMv5TE XScale root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-none-linux-gnueabi
	CC_DIR=/var/linus/arm-2010q1
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5te -mtune=xscale"
	cp etc/inittab-xscale etc/inittab
	echo "nslu2" > etc/hostname
	;;
    "integrator")
	echo "Building Integrator ARMv4 root filesystem"
	export ARCH=arm

	# Use ARMv4T base for Integrator rootfs builds
	#CC_PREFIX=armv4tl
	#CC_DIR=/var/linus/cross-compiler-armv4tl
	#LIBCBASE=${CC_DIR}
	#CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv4t -mtune=arm9tdmi"

	# Works but no framebuffer... (error on mmap)
	#CC_PREFIX=armv4l
	#CC_DIR=/var/linus/cross-compiler-armv4l
	#LIBCBASE=${CC_DIR}
	#CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mno-thumb-interwork -mcpu=arm920t"

	# Code Sourcery
	CC_PREFIX=arm-none-linux-gnueabi
	CC_DIR=/var/linus/arm-2010q1
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc/armv4t
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv4t -mtune=arm9tdmi"

	cp etc/inittab-integrator etc/inittab
	echo "integrator" > etc/hostname
	;;
    "msm8660")
	echo "Building Qualcomm MSM8660 root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-linux-gnueabihf
	CC_DIR=/var/linus/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-marm -mabi=aapcs-linux -mthumb -mthumb-interwork -mcpu=cortex-a9"
	cp etc/inittab-msm8660 etc/inittab
	echo "Ux500" > etc/hostname
	;;
    "nhk8815")
	echo "Building Nomadik NHK8815 root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-linux-gnueabi
	CC_DIR=/var/linus/arm-2010q1
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-nhk8815 etc/inittab
	echo "NHK8815" > etc/hostname
	;;
    "u300")
	echo "Building ST-Ericsson U300 root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-linux-gnueabi
	CC_DIR=/var/linus/arm-2010q1
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-u300 etc/inittab
	echo "U300" > etc/hostname
	;;
    "ux500")
	echo "Building ST-Ericsson Ux500 root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-linux-gnueabihf
	CC_DIR=/var/linus/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-marm -mabi=aapcs-linux -mthumb -mthumb-interwork -mcpu=cortex-a9"
	cp etc/inittab-ux500 etc/inittab
	echo "Ux500" > etc/hostname
	;;
    "exynos")
	echo "Building Samsung Exynos root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-linux-gnueabihf
	CC_DIR=/var/linus/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-marm -mabi=aapcs-linux -mthumb -mthumb-interwork -mcpu=cortex-a15"
	cp etc/inittab-exynos etc/inittab
	echo "Exynos" > etc/hostname
	;;
    "versatile")
	echo "Building ARM Versatile root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-none-linux-gnueabi
	CC_DIR=/var/linus/arm-2010q1
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CFLAGS="-msoft-float -marm -mabi=aapcs-linux -mthumb -mthumb-interwork -march=armv5t -mtune=arm9tdmi"
	cp etc/inittab-versatile etc/inittab
	echo "Versatile" > etc/hostname
	;;
    "vexpress")
	echo "Building Versatile Express root filesystem"
	export ARCH=arm
	CC_PREFIX=arm-linux-gnueabihf
	if [ ! -n "${CC_DIR}" ]; then
		echo "CC_DIR must be set as environment variable before calling this script"
		exit
	fi
	#CC_DIR=/var/linus/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	CC_DIR=${CC_DIR}
	CC_PREFIX=${CC_PREFIX}
	CFLAGS="-marm -mabi=aapcs-linux -mthumb -mthumb-interwork -mcpu=cortex-a15"
	cp etc/inittab-vexpress etc/inittab
	echo "Vexpress" > etc/hostname
	;;
    "fvp-aarch64")
	echo "Building FVP Aarch64 root filesystem"
	export ARCH=arm64
	CC_PREFIX=aarch64-linux-gnu
	if [ ! -n "${CC_DIR}" ]; then
		echo "CC_DIR must be set as environment variable before calling this script"
		exit
	fi
	#CC_DIR=/home/jens/aarch64-toolchain/gcc-linaro-aarch64-linux-gnu-4.8-2013.11_linux
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	#CFLAGS="-marm -mabi=aapcs-linux -mthumb -mthumb-interwork -mcpu=cortex-a15"
	cp etc/inittab-vexpress etc/inittab
	echo "FVP" > etc/hostname
	;;
    "hikey")
	echo "Building HiKey Aarch64 root filesystem"
	export ARCH=arm64
	CC_PREFIX=aarch64-linux-gnu
	if [ ! -n "${CC_DIR}" ]; then
		echo "CC_DIR must be set as environment variable before calling this script"
		exit
        fi
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	cp etc/inittab-vexpress etc/inittab
	echo "HiKey" > etc/hostname
	;;
    "nxp5430")
	echo "Building NXP5430 Aarch64 root filesystem"
	export ARCH=arm64
	CC_PREFIX=aarch64-linux-gnu
	if [ ! -n "${CC_DIR}" ]; then
		echo "CC_DIR must be set as environment variable before calling this script"
		exit
        fi
	LIBCBASE=${CC_DIR}/${CC_PREFIX}/libc
	cp etc/inittab-nxp5430 etc/inittab
	echo "Nexell" > etc/hostname
	;;
    *)
	echo "Usage: $0 [i486|i586|h3600|integrator|msm8660|nhk8815|u300|ux500|exynos|versatile|vexpress|fvp-aarch64|nxp5430]"
	exit 1
	;;
esac

# Define more tools
STRIP=${CC_PREFIX}-strip

echo "OUTFILE = ${OUTFILE}"

echo "Check prerequisites..."
echo "Set up cross compiler at: ${CC_DIR}"
export PATH="$PATH:${CC_DIR}/bin"
echo -n "Check crosscompiler ... "
which ${CC_PREFIX}-gcc > /dev/null ; if [ ! $? -eq 0 ] ; then
    echo "ERROR: cross-compiler ${CC_PREFIX}-gcc not in PATH=$PATH!"
    echo "ABORTING."
    exit 1
else
    echo "OK"
fi

echo -n "Check ccache ..."
which ccache > /dev/null ; if [ ! $? -eq 0 ] ; then
    echo "No"
else
    echo "Yes"
    # Set $CCACHE to "ccache " only if unset
    CCACHE=${CCACHE-ccache }
fi

echo -n "Check # of CPUs ..."
_NPROCESSORS_ONLN=`getconf _NPROCESSORS_ONLN`
echo $_NPROCESSORS_ONLN

if [ "$2" != "nocpio" ]; then
    echo -n "gen_init_cpio ... "
    which gen_init_cpio > /dev/null ; if [ ! $? -eq 0 ] ; then
        echo "ERROR: gen_init_cpio not in PATH=$PATH!"
        echo "Copy this binary from the Linux build tree."
        echo "Or set your PATH into the Linux kernel tree, I don't care..."
        echo "ABORTING."
        exit 1
    else
        echo "OK"
    fi
fi

# Clone the busybox git if we don't have it...
if [ ! -d busybox ] ; then
    echo "It appears we're missing a busybox git, cloning it."
    git clone git://busybox.net/busybox.git busybox
    if [ ! -d busybox ] ; then
	echo "Failed. ABORTING."
	exit 1
    fi
fi

# Copy the template of static files to be used
cp filelist.txt filelist-tmp.txt

# Prep dirs
mkdir -p ${STAGEDIR}
mkdir -p ${STAGEDIR}/lib
mkdir -p ${STAGEDIR}/sbin
mkdir -p ${BUILDDIR}

# For using the git version
cd busybox
if [ ! -e ${BUILDDIR}/.config ]; then
  make O=${BUILDDIR} defconfig
  echo "Configuring cross compiler etc..."
  # Comment in this line to create a statically linked busybox
  #sed -i "s/^#.*CONFIG_STATIC.*/CONFIG_STATIC=y/" ${BUILDDIR}/.config
  sed -i -e "s/CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"${CCACHE}${CC_PREFIX}-\"/g" ${BUILDDIR}/.config
  sed -i -e "s/CONFIG_EXTRA_CFLAGS=\"\"/CONFIG_EXTRA_CFLAGS=\"${CFLAGS}\"/g" ${BUILDDIR}/.config
  sed -i -e "s/CONFIG_PREFIX=\".*\"/CONFIG_PREFIX=\"..\/stage\"/g" ${BUILDDIR}/.config
  # Turn off "eject" command, we don't have a CDROM
  sed -i -e "s/CONFIG_EJECT=y/\# CONFIG_EJECT is not set/g" ${BUILDDIR}/.config
  sed -i -e "s/CONFIG_FEATURE_EJECT_SCSI=y/\# CONFIG_FEATURE_EJECT_SCSI is not set/g" ${BUILDDIR}/.config
  #make O=${BUILDDIR} menuconfig
fi
make -j${_NPROCESSORS_ONLN} O=${BUILDDIR}
make O=${BUILDDIR} install
cd ${CURDIR}

# First the flat library where arch-independent stuff will
# end up
clone_dir ${LIBCBASE}/lib ${STAGEDIR}/lib

# The C library may be in a per-arch subdir (multiarch)
# OR it may not...
if [ -d ${LIBCBASE}/lib/${CC_PREFIX} ] ; then
    mkdir -p ${STAGEDIR}/lib/${CC_PREFIX}
    echo "dir /lib/${CC_PREFIX} 755 0 0" >> filelist-tmp.txt
    clone_dir ${LIBCBASE}/lib/${CC_PREFIX} ${STAGEDIR}/lib/${CC_PREFIX}
fi

# Add files by searching stage directory
BINFILES=`find ${STAGEDIR}/bin -maxdepth 1 -type f`
for file in ${BINFILES} ; do
    BASE=`basename $file`
    echo "file /bin/${BASE} $file 755 0 0" >> filelist-tmp.txt
done;
SBINFILES=`find ${STAGEDIR}/sbin -maxdepth 1 -type f`
for file in ${SBINFILES} ; do
    BASE=`basename $file`
    echo "file /sbin/${BASE} $file 755 0 0" >> filelist-tmp.txt
done;
LIBFILES=`find ${STAGEDIR}/lib -maxdepth 1 -type f`
for file in ${LIBFILES} ; do
    BASE=`basename $file`
    echo "file /lib/${BASE} $file 755 0 0" >> filelist-tmp.txt
done;
LIBLINKS=`find ${STAGEDIR}/lib -maxdepth 1 -type l`
for file in ${LIBLINKS} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /lib/${BASE} ${TARGET} 755 0 0" >> filelist-tmp.txt
done;

# Add multiarch libarary dir
if [ -d ${STAGEDIR}/lib/${CC_PREFIX} ] ; then
echo "dir /lib/${CC_PREFIX} 755 0 0" >> filelist-tmp.txt
CLIBFILES=`find ${STAGEDIR}/lib/${CC_PREFIX} -maxdepth 1 -type f`
for file in ${CLIBFILES} ; do
    BASE=`basename $file`
    echo "file /lib/${CC_PREFIX}/${BASE} $file 755 0 0" >> filelist-tmp.txt
done;
CLIBLINKS=`find ${STAGEDIR}/lib/${CC_PREFIX} -maxdepth 1 -type l`
for file in ${CLIBLINKS} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /lib/${CC_PREFIX}/${BASE} ${TARGET} 755 0 0" >> filelist-tmp.txt
done;
fi

# Add links by searching stage directory
LINKSBIN=`find ${STAGEDIR}/bin -maxdepth 1 -type l`
for file in ${LINKSBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /bin/${BASE} ${TARGET} 755 0 0" >> filelist-tmp.txt
done;
LINKSSBIN=`find ${STAGEDIR}/sbin -maxdepth 1 -type l`
for file in ${LINKSSBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /sbin/${BASE} ${TARGET} 755 0 0" >> filelist-tmp.txt
done;
LINKSUSRBIN=`find ${STAGEDIR}/usr/bin -maxdepth 1 -type l`
for file in ${LINKSUSRBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /usr/bin/${BASE} ${TARGET} 755 0 0" >> filelist-tmp.txt
done;
LINKSUSRSBIN=`find ${STAGEDIR}/usr/sbin -maxdepth 1 -type l`
for file in ${LINKSUSRSBIN} ; do
    BASE=`basename $file`
    TARGET=`readlink $file`
    echo "slink /sbin/${BASE} ${TARGET} 755 0 0" >> filelist-tmp.txt
done;

echo "Compiling fbtest..."
${CCACHE}${CC_PREFIX}-gcc ${CFLAGS} -o ${STAGEDIR}/usr/bin/fbtest fbtest/fbtest.c
echo "file /usr/bin/fbtest ${STAGEDIR}/usr/bin/fbtest 755 0 0" >> filelist-tmp.txt

# Extra stuff per platform
case $1 in
    "i486")
	;;
    "i586")
	;;
    "h3600")
	# Splash image for VGA console
	echo "file /etc/splash-320x240.ppm etc/splash-320x240.ppm 644 0 0" >> filelist-tmp.txt
	;;
    "nslu2")
	;;
    "integrator")
	# Splash image for VGA console
	echo "file /etc/splash.ppm etc/splash-640x480-rgba5551.ppm 644 0 0" >> filelist-tmp.txt
	;;
    "msm8660")
	;;
    "nhk8815")
	;;
    "u300")
	;;
    "ux500")
	;;
    "exynos")
	;;
    "versatile")
	# Splash image for VGA console
	echo "file /etc/splash.ppm etc/splash-640x480-rgba5551.ppm 644 0 0" >> filelist-tmp.txt
	;;
    "vexpress")
	;;
    "fvp-aarch64")
	;;
    "hikey")
	;;
    "nxp5430")
	;;
    *)
	echo "Forgot to update special per-platform rules."
	exit 1
	;;
esac

diff filelist-final.txt filelist-tmp.txt >/dev/null 2>&1 || mv filelist-tmp.txt filelist-final.txt

if [ "$2" != "nocpio" ]; then
    gen_init_cpio filelist-final.txt > ${HOME}/rootfs.cpio
    #rm filelist-tmp.txt
    if [ -f ${HOME}/rootfs.cpio ] ; then
        mv ${HOME}/rootfs.cpio ${OUTFILE}
    fi
    echo "New rootfs ready in ${OUTFILE}"
fi

