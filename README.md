This repository contains the software required to boot the HiKey board
with OP-TEE:
- ARM Trusted Firmware
- EDK2
- Linux kernel
- BusyBox
- OP-TEE (OS, driver, client library)
- OP-TEE tests


## Usage

### 1. Prerequisites

On the hardware side, you need:
- A [HiKey board](https://www.96boards.org/products/hikey/)
- A power supply (8 - 18V, 2A, 1.7mm jack)
- A PC running Linux (I use Ubuntu 15.04 x86_64)
- A USB cable (male/male, A to micro-B) to connect your PC to the board
- A serial to USB adapter cable to connect to the SoC's UART0 (console).
  This  is not strictly required but chances are you won't be able to
  debug any bootloader/secure OS code without it.
  You need a 1.8V-compatible serial cable. The one I use is made by FTDI and
  is reference TTL-232RG-VIP. Not cheap, but works fine.
  Wiring for this cable is as follows:
```
 RED [VCC]     <==> Pin 1 [1.8V]
 BLACK [GND]   <==> Pin 3 [DGND]
 YELLOW [RXD]  <==> Pin 4 [UART0_TX]
 ORANGE [TXD]  <==> Pin 2 [UART0_RX]
 GREEN  [RTS#] <==> (not connected)
 BROWN  [CTS#] <==> (not connected)
```

As for software:
```
sudo apt-get install \
    android-tools-fastboot \
    autoconf \
    curl \
    gdisk \
    python-serial \
    uuid-dev
```

If you are running a 64-bit linux distribution, you may also need
the following:
```
sudo apt-get install libc6:i386 libstdc++6:i386 libz1:i386
```

"Known good" cross compilers/toolchains are downloaded aytomatically from
linaro.org by the Makefile.

Also, to get the USB devices recognized properly (i.e., the HiKey board in
recovery mode will show up as /dev/HiKey and fastboot will properly detect
the board), just do:

```
sudo cp 51-hikey.rules to /etc/udev/rules.d/
```

### 2. How to build
```
# Initialize URLs for git submodules
git submodule init

# Fetch submodules (will take time)
git submodule update

# Fetch the cross-compilers (~ 90MB) and build
# Note: generation of boot.img uses 'sudo'
make -j8
```

For 64-bit TEE Core, use `make -j8 OPTEE_64BIT=1`.
If you don't have access to the optee_test repository, you can still clone
all other submodules and build without the tests.

### 3. How to flash the firmware onto the board

Refer to:
```
make help
```

### 4. How to run OP-TEE tests (xtest)

On the HiKey console:
```
modprobe optee_armtz
tee-supplicant&
xtest
```
