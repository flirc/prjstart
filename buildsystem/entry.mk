# Determine where we were run from. If we were not run from the location of the
# makefile, record the PWD as ROOTPWD and then nest
THISFILE := $(lastword $(MAKEFILE_LIST))
THISFILEBASE := $(notdir $(THISFILE))
PWD := $(shell pwd)

ifneq ($(realpath $(THISFILE)),$(PWD)/$(THISFILEBASE))

# Save the root pwd
export ROOTPWD := $(PWD)

.PHONY : nest
nest:
	@$(MAKE) -C $(dir $(THISFILE)) -f $(THISFILEBASE)

%:
	@$(MAKE) -C $(dir $(THISFILE)) -f $(THISFILEBASE) $@

else
##### Main Section #############################################################
include func.mk

# Check to make sure make wasn't run from the buildsystem directory
ifeq ($(ROOTPWD),)
$(error Do not run make from the buildsystem directory (or -C to here))
endif

# Host OS
export HOSTOS := $(call TOUPPER,$(call USCORESUB,$(shell uname -s)))

# Verbose Option
ifeq ($(VERBOSE),1)
export Q :=
export VERBOSE := 1
else
export Q := @
export VERBOSE := 0
endif

# Machine Name and Tool Versions
export MACHINE := $(call USCORESUB,$(shell uname -sm))
export CCNAME := $(call USCORESUB,$(notdir $(realpath $(shell which $(CC)))))

# Build Directory
export BUILDDIR_ROOT := $(ROOTPWD)/buildresults
export BUILDDIR := $(BUILDDIR_ROOT)/$(MACHINE)/$(CCNAME)

# Build the target list
sinclude $(BUILDDIR_ROOT)/targets.mk

.DEFAULT_GOAL := help
.PHONY : help
help:
	@echo "Targets:"
	$(call PRINTLIST, $(sort $(TARGET_LIST)), -> )

### Utility Rules ###
.PHONY : clean
clean :
	$(Q)-rm -rf $(BUILDDIR_ROOT)
	$(call OUTPUTINFO,CLEAN,$(BUILDDIR_ROOT))

# Target makefile generation rule
$(BUILDDIR_ROOT)/targets.mk : $(ROOTPWD)/Targets.csv
	$(Q)[ -d "$(@D)" ] || mkdir -p "$(@D)"
	$(Q)awk -f target_list.awk $^ > $@

endif
