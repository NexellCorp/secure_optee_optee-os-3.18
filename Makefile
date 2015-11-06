# Makefile for HiKey UEFI boot firmware
#
# 'make help' for details

SHELL = /bin/bash
CURL = curl -L
BL33_UEFI = 0

ifeq ($(V),1)
  Q :=
  ECHO := @:
else
  Q := @
  ECHO := @echo
endif

.PHONY: _all
_all:
	$(Q)if [ ! -L linux ] ; then ln -s ../../kernel/kernel-3.18 linux ; fi
	$(Q)if [ ! -L u-boot ] ; then ln -s ../../bootloader/u-boot-2014.07 u-boot ; fi
	$(Q)$(MAKE) all $(filter-out _all,$(MAKECMDGOALS))

all: build-lloader build-fip build-linux build-initramfs

pre_clean:
	$(Q)if [ ! -L linux ] ; then ln -s ../../kernel/kernel-3.18 linux ; fi
	$(Q)if [ ! -L u-boot ] ; then ln -s ../../bootloader/u-boot-2014.07 u-boot ; fi

post_clean:
	$(Q)if [ -L linux ] ; then rm linux ; fi
	$(Q)if [ -L u-boot ] ; then rm u-boot ; fi
	$(Q)if [ -L buildroot ] ; then rm buildroot ; fi

clean: clean-bl1-bl2-bl31-fip clean-bl33 clean-lloader
clean: clean-linux-dtb clean-initramfs clean-optee-linuxdriver
clean: clean-optee-client clean-bl32 clean-aes-perf clean-helloworld

cleaner: pre_clean clean post_clean

distclean: cleaner

help:
	@echo "Makefile for NXP5430-drone board u-boot firmware/kernel"
	@echo
	@echo "- Run 'make' to build the following images:"
	@echo "  LLOADER = $(LLOADER) with:"
	@echo "      [BL1 = $(BL1)]"
	@echo "      [l-loader/*.S]"
	@echo "  FIP = $(FIP) with:"
	@echo "      [BL2 = $(BL2)]"
	@echo "      [BL31 = $(BL31)]"
	@echo "      [BL32 = $(BL32)]"
	@echo "      [BL33 = $(BL33)]"
	@echo "  INITRAMFS = $(INITRAMFS) with"
	@echo "      [OPTEE-LINUXDRIVER = $(optee-linuxdriver-files)]"
	@echo "      [OPTEE-CLIENT = optee_client/out/libteec.so*" \
	             "optee_client/out/tee-supplicant/tee-supplicant]"
	@echo "      [OPTEE-TEST = out/usr/local/bin/xtest" \
	             "out/lib/optee_armtz/*.ta]"
	@echo "- 'make clean' removes most files generated by make, except the"
	@echo "downloaded files/tarballs and the directories they were"
	@echo "extracted to."
	@echo "- 'make cleaner' also removes tar directories."
	@echo "- 'make distclean' removes all generated or downloaded files."
	@echo
	@echo "Image files can be built separately with e.g., 'make build-fip'"
	@echo "or 'make build-bl1', and so on. Note: In order to speed up the "
	@echo "build and reduce output when working on a single component,"
	@echo "build-<foo> will NOT invoke build-<bar>."
	@echo "Therefore, if you want to make sure that <bar> is up-to-date,"
	@echo "use 'make build-<foo> build-<bar>'."

ifneq (,$(shell which ccache))
CCACHE = ccache # do not remove this comment or the trailing space will go
endif

filename = $(lastword $(subst /, ,$(1)))

# Read stdin, expand ${VAR} environment variables, output to stdout
# http://superuser.com/a/302847
define expand-env-var
awk '{while(match($$0,"[$$]{[^}]*}")) {var=substr($$0,RSTART+2,RLENGTH -3);gsub("[$$]{"var"}",ENVIRON[var])}}1'
endef

#
# Aarch64 toolchain
#
# If you don't want to download the aarch64 toolchain, comment out
# the next line and set CROSS_COMPILE to your compiler command
CROSS_COMPILE ?= $(CCACHE)aarch64-linux-gnu-

#
# Aarch32 toolchain
#
# If you don't want to download the aarch32 toolchain, comment out
# the next line and set CROSS_COMPILE32 to your compiler command
CROSS_COMPILE32 ?= $(CCACHE)arm-linux-gnueabihf-


#
# U-BOOT
#

BL33 = u-boot/u-boot.bin

.PHONY: build-bl33
build-bl33:: $(aarch64-linux-gnu-gcc)
build-bl33 $(BL33)::
	$(ECHO) '  BUILD   $@'
	$(Q)set -e ; cd u-boot ; \
	    $(MAKE) s5p6818_arm64_drone_config ; \
	    $(MAKE) CROSS_COMPILE="$(CROSS_COMPILE)"
	$(Q)touch ${BL33}

clean-bl33:
	$(ECHO) '  CLEAN   $@'
	$(Q) $(MAKE) -C u-boot clean

#
# ARM Trusted Firmware
#

ATF_DEBUG = 0
ifeq ($(ATF_DEBUG),1)
ATF = arm-trusted-firmware/build/nxp5430/debug
else
ATF = arm-trusted-firmware/build/nxp5430/release
endif
BL1 = $(ATF)/bl1.bin
BL2 = $(ATF)/bl2.bin
BL30 = mcuimage.bin
BL31 = $(ATF)/bl31.bin
# Comment out to not include OP-TEE OS image in fip.bin
BL32 = optee_os/out/arm-plat-nxp5430/core/tee.bin
FIP = $(ATF)/fip.bin

ARMTF_FLAGS := PLAT=nxp5430 DEBUG=$(ATF_DEBUG)
#ARMTF_FLAGS += LOG_LEVEL=40
ARMTF_EXPORTS := NEED_BL30=no BL30=$(PWD)/$(BL30) BL33=$(PWD)/$(BL33) #CFLAGS=""
ifneq (,$(BL32))
ARMTF_FLAGS += SPD=opteed
ARMTF_EXPORTS += BL32=$(PWD)/$(BL32)
endif

define arm-tf-make
        $(ECHO) '  BUILD   build-$(strip $(1)) [$@]'
        +$(Q)export $(ARMTF_EXPORTS) ; \
	    $(MAKE) -C arm-trusted-firmware $(ARMTF_FLAGS) $(1)
endef

.PHONY: build-bl1
build-bl1 $(BL1): $(aarch64-linux-gnu-gcc)
	$(call arm-tf-make, bl1) CROSS_COMPILE="$(CROSS_COMPILE)"

.PHONY: build-bl2
build-bl2 $(BL2): $(aarch64-linux-gnu-gcc)
	$(call arm-tf-make, bl2) CROSS_COMPILE="$(CROSS_COMPILE)"

.PHONY: build-bl31
build-bl31 $(BL31): $(aarch64-linux-gnu-gcc)
	$(call arm-tf-make, bl31) CROSS_COMPILE="$(CROSS_COMPILE)"


ifneq ($(filter all build-bl2,$(MAKECMDGOALS)),)
tf-deps += build-bl2
endif
ifneq ($(filter all build-bl31,$(MAKECMDGOALS)),)
tf-deps += build-bl31
endif
ifneq ($(filter all build-bl32,$(MAKECMDGOALS)),)
tf-deps += build-bl32
endif
ifneq ($(filter all build-bl33,$(MAKECMDGOALS)),)
tf-deps += build-bl33
endif

.PHONY: build-fip
build-fip:: $(tf-deps)
build-fip $(FIP)::
	$(call arm-tf-make, fip)

clean-bl1-bl2-bl31-fip:
	$(ECHO) '  CLEAN   edk2/BaseTools'
	$(Q)export $(ARMTF_EXPORTS) ; \
	    $(MAKE) -C arm-trusted-firmware $(ARMTF_FLAGS) clean

#
# l-loader
#

LLOADER = l-loader/l-loader.bin
PTABLE = l-loader/ptable.img

ifneq ($(filter all build-bl1,$(MAKECMDGOALS)),)
lloader-deps += build-bl1
endif

# FIXME: adding $(BL1) as a dependency [after $(LLOADER)::] breaks
# parallel build (-j) because the same rule is run twice simultaneously
# $ make -j9 build-bl1 build-lloader
#   BUILD   build-bl1 # $@ = build-bl1
#   BUILD   build-bl1 # $@ = arm-trusted-firmware/build/.../bl1.bin
# make[1]: Entering directory '/home/jerome/work/hikey_uefi/arm-trusted-firmware'
# make[1]: Entering directory '/home/jerome/work/hikey_uefi/arm-trusted-firmware'
#   DEPS    build/nxp5430/debug/bl31/bl31.ld.d
#   DEPS    build/nxp5430/debug/bl31/bl31.ld.d
.PHONY: build-lloader
build-lloader:: $(lloader-deps) $(arm-linux-gnueabihf-gcc)
build-lloader $(LLOADER)::
	$(ECHO) '  BUILD   build-lloader'
	$(Q)$(MAKE) -C l-loader BL1=$(PWD)/$(BL1) CROSS_COMPILE="$(CROSS_COMPILE32)" l-loader.bin

clean-lloader:
	$(ECHO) '  CLEAN   $@'
	$(Q)$(MAKE) -C l-loader clean

#
# Linux/DTB
#

# FIXME: 'make build-linux' needlessy (?) recompiles a few files (efi.o...)
# each time it is run

LINUX = linux/arch/arm64/boot/Image
DTB = nexell/s5p6818-asb-optee.dtb
DTB2 = linux/arch/arm64/boot/dts/$(DTB)
# Config fragments to merge with the default kernel configuration
KCONFIGS += linux/arch/arm64/configs/s5p6818_asb_optee_linux_defconfig

ifneq ($(filter all build-linux,$(MAKECMDGOALS)),)
linux-build-deps += build-dtb
endif

.PHONY: build-linux
build-linux:: $(linux-build-deps) $(aarch64-linux-gnu-gcc)
build-linux $(LINUX):: linux/.config
	$(ECHO) '  BUILD   build-linux'
	$(Q)flock .linuxbuildinprogress $(MAKE) -C linux ARCH=arm64 LOCALVERSION= Image

build-dtb:: $(aarch64-linux-gnu-gcc)
build-dtb $(DTB):: linux/.config
	$(ECHO) '  BUILD   build-dtb'
	$(Q)flock .linuxbuildinprogress $(MAKE) -C linux ARCH=arm64 $(DTB)

linux/.config: $(KCONFIGS)
	$(ECHO) '  BUILD   $@'
	$(Q)cp $(KCONFIGS) linux/.config

linux/usr/gen_init_cpio: linux/.config
	$(ECHO) '  BUILD   $@'
	$(Q)$(MAKE) -C linux/usr ARCH=arm64 gen_init_cpio

clean-linux-dtb:
	$(ECHO) '  CLEAN   $@'
	$(Q)$(MAKE) -C linux ARCH=arm64 clean
	$(Q)rm -f linux/.config
	$(Q)rm -f .linuxbuildinprogress

#
# Initramfs
#

INITRAMFS = initramfs.gz

ifneq ($(filter all build-optee-linuxdriver,$(MAKECMDGOALS)),)
initramfs-deps += build-optee-linuxdriver
endif
ifneq ($(filter all build-optee-client,$(MAKECMDGOALS)),)
initramfs-deps += build-optee-client
endif
ifneq ($(filter all build-aes-perf,$(MAKECMDGOALS)),)
initramfs-deps += build-aes-perf
endif
ifneq ($(filter all build-helloworld,$(MAKECMDGOALS)),)
initramfs-deps += build-helloworld
endif
ifneq ($(filter all build-optee-test,$(MAKECMDGOALS)),)
initramfs-deps += build-optee-test
endif

.PHONY: build-initramfs
build-initramfs:: $(initramfs-deps)
build-initramfs:: ./build_initramfs.sh
	$(ECHO) "  GEN    $(INITRAMFS)"
	$(Q)./build_initramfs.sh

clean-initramfs:
	$(ECHO) "  CLEAN  $@"
	$(Q)rm -f $(INITRAMFS)

#
# OP-TEE Linux driver
#

optee-linuxdriver-files := optee_linuxdriver/optee.ko \
                           optee_linuxdriver/optee_armtz.ko

ifneq ($(filter all build-linux,$(MAKECMDGOALS)),)
optee-linuxdriver-deps += build-linux
endif

.PHONY: build-optee-linuxdriver
build-optee-linuxdriver:: $(optee-linuxdriver-deps)
build-optee-linuxdriver $(optee-linuxdriver-files):: $(aarch64-linux-gnu-gcc)
	$(ECHO) '  BUILD   build-optee-linuxdriver'
	$(Q)$(MAKE) -C linux \
	   ARCH=arm64 \
	   LOCALVERSION= \
	   M=$(PWD)/optee_linuxdriver \
	   modules

clean-optee-linuxdriver:
	$(ECHO) '  CLEAN   $@'
	$(Q)$(MAKE) -C linux \
	   ARCH=arm64 \
	   LOCALVERSION= \
	   M=$(PWD)/optee_linuxdriver \
	   clean

#
# OP-TEE client library and tee-supplicant executable
#

.PHONY: build-optee-client
build-optee-client: $(aarch64-linux-gnu-gcc)
	$(ECHO) '  BUILD   $@'
	$(Q)$(MAKE) -C optee_client CROSS_COMPILE="$(CROSS_COMPILE)"

clean-optee-client:
	$(ECHO) '  CLEAN   $@'
	$(Q)$(MAKE) -C optee_client clean

#
# OP-TEE OS
#

optee-os-flags := CROSS_COMPILE="$(CROSS_COMPILE32)" PLATFORM=nxp5430
optee-os-flags += DEBUG=0
optee-os-flags += CFG_TEE_CORE_LOG_LEVEL=2 # 0=none 1=err 2=info 3=debug 4=flow
#optee-os-flags += CFG_WITH_PAGER=y
#optee-os-flags += CFG_TEE_TA_LOG_LEVEL=3

# 64-bit TEE Core
# FIXME: Compiler bug? xtest 4002 hangs (endless loop) when:
# - TEE Core is 64-bit (OPTEE_64BIT=1 below) and compiler is aarch64-linux-gnu-gcc
#   4.9.2-10ubuntu13, and
# - DEBUG=0, and
# - 32-bit user libraries are built with arm-linux-gnueabihf-gcc 4.9.2-10ubuntu10
# Set DEBUG=1, or set $(arm-linux-gnueabihf-) to build user code with:
#   'arm-linux-gnueabihf-gcc (crosstool-NG linaro-1.13.1-4.8-2013.08 - Linaro GCC 2013.08)
#    4.8.2 20130805 (prerelease)'
# or with:
#   'arm-linux-gnueabihf-gcc (Linaro GCC 2014.11) 4.9.3 20141031 (prerelease)'
# and the problem disappears.
OPTEE_64BIT ?= 1
ifeq ($(OPTEE_64BIT),1)
optee-os-flags += CFG_ARM64_core=y CROSS_COMPILE_core="$(CROSS_COMPILE)"
endif

.PHONY: build-bl32
build-bl32:: $(aarch64-linux-gnu-gcc) $(arm-linux-gnueabihf-gcc)
build-bl32::
	$(ECHO) '  BUILD   $@'
	$(Q)$(MAKE) -C optee_os $(optee-os-flags)

.PHONY: clean-bl32
clean-bl32:
	$(ECHO) '  CLEAN   $@'
	$(Q)$(MAKE) -C optee_os $(optee-os-flags) clean


#
# OP-TEE tests (xtest)
#

all: build-optee-test
clean: clean-optee-test

optee-test-flags := CROSS_COMPILE_HOST="$(CROSS_COMPILE)" \
		    CROSS_COMPILE_TA="$(CROSS_COMPILE32)" \
		    TA_DEV_KIT_DIR=$(PWD)/optee_os/out/arm-plat-nxp5430/export-user_ta \
		    O=$(PWD)/optee_test/out #CFG_TEE_TA_LOG_LEVEL=3

ifneq ($(filter all build-bl32,$(MAKECMDGOALS)),)
optee-test-deps += build-bl32
endif
ifneq ($(filter all build-optee-client,$(MAKECMDGOALS)),)
optee-test-deps += build-optee-client
endif

.PHONY: build-optee-test
build-optee-test:: $(optee-test-deps)
build-optee-test:: $(aarch64-linux-gnu-gcc)
	$(ECHO) '  BUILD   $@'
	$(Q)$(MAKE) -C optee_test $(optee-test-flags)

# FIXME:
# No "make clean" in optee_test: fails if optee_os has been cleaned
# previously.
clean-optee-test:
	$(ECHO) '  CLEAN   $@'
	$(Q)rm -rf optee_test/out

#
# aes-perf (AES crypto performance test)
#

aes-perf-flags := CROSS_COMPILE_HOST="$(CROSS_COMPILE)" \
		  CROSS_COMPILE_TA="$(CROSS_COMPILE32)" \
		  TA_DEV_KIT_DIR=$(PWD)/optee_os/out/arm-plat-nxp5430/export-user_ta \

ifneq ($(filter all build-bl32,$(MAKECMDGOALS)),)
aes-perf-deps += build-bl32
endif
ifneq ($(filter all build-optee-client,$(MAKECMDGOALS)),)
aes-perf-deps += build-optee-client
endif

.PHONY: build-aes-perf
build-aes-perf:: $(aes-perf-deps)
build-aes-perf:: $(aarch64-linux-gnu-gcc)
	$(ECHO) '  BUILD   $@'
	$(Q)$(MAKE) -C aes-perf $(aes-perf-flags)

clean-aes-perf:
	$(ECHO) '  CLEAN   $@'
	$(Q)rm -rf aes-perf/out

#
# helloworld
#

helloworld-flags := CROSS_COMPILE_HOST="$(CROSS_COMPILE)" \
		    CROSS_COMPILE_TA="$(CROSS_COMPILE32)" \
		    TA_DEV_KIT_DIR=$(PWD)/optee_os/out/arm-plat-nxp5430/export-user_ta \

ifneq ($(filter all build-bl32,$(MAKECMDGOALS)),)
helloworld-deps += build-bl32
endif
ifneq ($(filter all build-optee-client,$(MAKECMDGOALS)),)
helloworld-deps += build-optee-client
endif

.PHONY: build-helloworld
build-helloworld:: $(helloworld-deps)
build-helloworld:: $(aarch64-linux-gnu-gcc)
	$(ECHO) '  BUILD   $@'
	$(Q)$(MAKE) -C helloworld $(helloworld-flags)

clean-helloworld:
	$(ECHO) '  CLEAN   $@'
	$(Q)rm -rf helloworld/out

