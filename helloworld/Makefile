export CROSS_COMPILE_HOST ?= aarch64-linux-gnu-
export CROSS_COMPILE_TA ?= arm-linux-gnueabihf-
export TA_DEV_KIT_DIR ?= $(CURDIR)/../optee_os/out/arm-plat-hikey/export-user_ta
export OPTEE_CLIENT_PATH ?= $(CURDIR)/../optee_client

ifneq ($O,)
	out-dir := $O
else
	# If no build folder has been specified, then create all build files in
	# the current directory under a folder named out.
	out-dir := $(CURDIR)/out
endif

ifneq ($V,1)
export q := @
export cmd-echo-silent := echo
else
export q :=
export cmd-echo-silent := true
endif
ifneq ($(filter 4.%,$(MAKE_VERSION)),)  # make-4
ifneq ($(filter %s ,$(firstword x$(MAKEFLAGS))),)
export cmd-echo-silent := true
endif
else                                    # make-3.8x
ifneq ($(findstring s, $(MAKEFLAGS)),)
export cmd-echo-silent := true
endif
endif

.PHONY: all
all: helloworld ta

.PHONY: helloworld
helloworld:
	$(q)mkdir -p $(out-dir)/helloworld
	$(q)$(MAKE) -C host O=$(out-dir)/helloworld

.PHONY: ta
ta:
	$(q)mkdir -p $(out-dir)/ta
	$(q)$(MAKE) -C ta O=$(out-dir)/ta

.PHONY: clean
clean: clean-helloworld clean-ta

.PHONY: clean-helloworld
clean-helloworld:
	$(q)$(MAKE) -C host O=$(out-dir)/helloworld q=$(q) clean

.PHONY: clean-ta
clean-ta:
	$(q)$(MAKE) -C ta O=$(out-dir)/ta q=$(q) clean

