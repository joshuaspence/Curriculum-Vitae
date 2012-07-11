# Makefile for compiling a LaTeX document split into multiple directories.
#
# Author:	Joshua Spence
# Version:	1.0.0
# Date:		11 July 2012
#
# TO OBTAIN INSTRUCTIONS FOR USING THIS FILE, RUN:
#    make help
################################################################################

################################################################################
# File details
################################################################################	
FILENAME     := LaTeX Root Makefile
AUTHOR       := Joshua Spence
VERSION      := 1.0.0
VERSION_DATE := 11 July 2012

################################################################################
# External Programs
################################################################################
# Basic Shell Utilities
BASENAME     ?= basename
COMPARE      ?= cmp
CONCATENATE  ?= cat
COPY_FORCE   ?= cp --force
COPY_SAFE    ?= cp
DELETE_FORCE ?= rm --force
DELETE_SAFE  ?= rm
DIRNAME      ?= dirname
ECHO         ?= echo
EXPRESSION   ?= expr
FIND         ?= find
GREP         ?= egrep
LINK         ?= ln --symbolic
MAKE         ?= make
MD5SUM       ?= md5sum
MOVE_FORCE   ?= mv --force
MOVE_SAFE    ?= mv
PERL         ?= perl
READLINK     ?= readlink --canonicalize
SED          ?= sed
SLEEP        ?= sleep
SORT         ?= sort
TAIL         ?= tail
TEST         ?= test
TOUCH        ?= touch
UNIQUE       ?= uniq
XARGS        ?= xargs

# Check whether or not to use 'safe' commands
ifdef SAFE
COPY         ?= $(COPY_SAFE)
DELETE       ?= $(DELETE_SAFE)
MOVE         ?= $(MOVE_SAFE)
else
COPY         ?= $(COPY_FORCE)
DELETE       ?= $(DELETE_FORCE)
MOVE         ?= $(MOVE_FORCE)
endif

# Non-essential programs
PDF_READER   ?= acroread

# Define "DEBUG" to echo commands
ifndef DEBUG
MUTE        ?= @
else
MUTE        ?= 
endif

# Define "VERBOSE" to add verbose options to commands
ifdef VERBOSE
COPY        += --verbose
DELETE      += --verbose
LINK        += --verbose
MAKE        += --debug
MOVE        += --verbose
endif

# Suppress output
NO_STDOUT   ?= 1>/dev/null
NO_STDERR   ?= 2>/dev/null

################################################################################
# Utility macros
################################################################################

# $(call clean-whitespace,string)
#
# Removed unnecessary repeated whitespacing from within a string. Useful for 
# aesthetic purposes.
#
# Note that "\$$" is used for a single "$" symbol. The backslash is used to 
# escape the "$" symbol for the shell. The additional "$" symbol is used to 
# escape the "$" symbol for make.
define clean-whitespace
$(shell $(ECHO) -n '$1' | \
$(PERL) -e "
use Text::ParseWords;
@words = quotewords('\s+', 1, <STDIN>);
my \$$output = "\"\"";
foreach (@words) {
	\$$output = "\""\$$output \$$_"\""
}
\$$output =~ s/^\s+//;
\$$output =~ s/\s+\$$//;
print(\$$output);")
endef

# $(call trace-message,msg)
trace-message = -@$(ECHO) $1

# $(call verbose-message,msg)
ifdef VERBOSE
verbose-message = -@$(call trace-message,$1)
endif

# $(call count,var)
# Count the number of elements in a variable.
count = $(shell $(EXPRESSION) 0 $(foreach V,$1,+ 1))

# $(call print-variable,var)
# Print the name and value of a variable.
print-variable = $(info $1=$($1))

# $(call print-variables)
# Print all makefile variables
define print-variables
$(foreach V,$(sort $(filter-out print-variable%,$(.VARIABLES))), 
	$(if $(filter file,$(origin $V)),
		$(call print-variable,$V)))
endef

# $(call copy,source1 source2 ...,destination)
copy = $(MUTE)$(if $1,$(COPY) $1 $2,$(sh_true))

# $(call copy-if-exists,source,destination)
copy-if-exists = $(MUTE)$(if $(call test-exists,$1),$(call copy,$1,$2),$(sh_true))

# $(call create-symlinks,source1 source2 ...,destination)
create-symlinks = $(MUTE)$(if $1,$(LINK) $1 $2,$(sh_true))

# $(call remove-temporary-files,filenames)
remove-temporary-files = $(MUTE)$(if $(KEEP_TEMP),$(sh_true),$(if $1,$(DELETE) $1,$(sh_true)))

# Don't call this directly - it is here to avoid calling wildcard more than
# once in remove-files.
remove-files-helper	= $(MUTE)$(if $(call test-exists,$1),$(DELETE) $1,$(sh_true))

# $(call remove-files,file1 file2)
remove-files = $(MUTE)$(call remove-files-helper,$(wildcard $1))

# Don't call this directly - it is here to avoid calling wildcard more than
# once in remove-symlinks.
remove-symlinks-helper = $(MUTE)$(if $(call test-symlink,$1),$(DELETE) $1,$(sh_true))

# $(call remove-symlinks,file1 file2)
remove-symlinks = $(MUTE)$(call remove-symlinks-helper,$(wildcard $1))

# $(call touch-file,file1 file2 ...)
touch-file = $(MUTE)$(TOUCH) $1

# $(call write-text-to-file,file,text)
write-text-to-file = $(MUTE)$(ECHO) $2 > $1

# $(call append-text-to-file,file,text)
append-text-to-file = $(MUTE)$(ECHO) $2 >> $1

# $(call create-dependency-file,dependents,dependencies,dependency-file)
create-dependency-file = $(MUTE)$(call append-text-to-file,$3,'$1: $2')

# Test that a file exists
# $(call test-exists,file)
test-exists		= [ -e '$1' ]
# $(call test-not-exists,file)
test-not-exists = [ ! -e '$1' ]

# Test that a symlink exists
# $(call test-symlink,file)
test-symlink	= [ -L '$1' ]

# $(call find-files,path,name)
# Find all files below a specified directory with a given name.
find-files = $(shell $(FIND) $1 -type f -name $2)

# $(call find-all-files,directory1 directory2 ...,name)
# Find all files below specified directories with a given name.
find-all-files = $(strip $(foreach d,$1,$(call find-files,$d,$2)))

# $(call get-relative-path,from,to)
get-relative-path = $(shell \
source="$$($(READLINK) $1)"; \
target="$$($(READLINK) $2)"; \
\
common_part="$$source"; \
back="."; \
while [ "$${target\#$$common_part}" = "$${target}" ]; do \
	common_part="$$($(DIRNAME) $$common_part)"; \
	back="$${back}/.."; \
done; \
\
back=$$($(ECHO) $$back | $(SED) 's/\.\///'); \
\
echo $${back}$${target\#$$common_part}; \
)

# Characters that are hard to specify in certain places
space := $(empty) $(empty)
colon := \:
comma := ,

# Useful shell definitions
sh_true	 := :
sh_false := ! :

# Removes all cleanable files in the given list
# $(call clean-files,file1 file2 file3 ...)
# Works exactly like remove-files, but filters out files in $(neverclean)
clean-files = $(call remove-files-helper,$(call cleanable-files,$(wildcard $1)))

# Utility function for obtaining all files not specified in $(neverclean)
# $(call cleanable-files,file1 file2 file3 ...)
# Returns the list of files that is not in $(wildcard $(neverclean))
cleanable-files = $(filter-out $(wildcard $(neverclean)), $1)

################################################################################
# Configuration
#-------------------------------------------------------------------------------
# This makefile is configured in a file named "Configuration.mk".
################################################################################
include Configuration.mk

# Error checking
# To make sure the configuration file contained the appropriate definitions.
ifndef BUILD_DIR
$(error Build directory not specified. 'BUILD_DIR' not defined.)
endif
ifndef EXT_DIRS
$(warning External directory not specified. 'EXT_DIRS' not defined.)
endif
ifndef IMG_DIRS
$(warning Image directory not specified. 'IMG_DIRS' not defined.)
endif
ifndef SRC_DIRS
$(error Source directory not specified. 'SRC_DIRS' not defined.)
endif

# Make sure there is only one build directory.
ifneq ($(call count,$(BUILD_DIR)),1)
$(error Only one build directory sould be specified.)
endif

# Set default configuration variables
# If these variables were not set in the configuration file
BUILD_DIR  ?=
EXT_DIRS   ?=
IMG_DIRS   ?=
OTHER_DIRS ?=
SRC_DIRS   ?=
source_extensions ?= .bib .bst .cls .sty .tex
neverclean ?=

# TODO: Warn if a directory cannot be found.
$(foreach e,$(source_extensions),$(eval $(e)_directories ?= $(empty)))

# If set to something, will cause temporary files to not be deleted immediately
KEEP_TEMP ?=

# Files that should never be removed from the build directory.
build_persist += Makefile Variables.ini .gitignore

################################################################################
# Automatic stuff
################################################################################
# File extensions
DEPS_EXT      := .d
TIMESTAMP_EXT := .timestamp

# Some relative paths
ROOT_DIR           = .
BUILD_DIR_RELATIVE = $(call get-relative-path,$(BUILD_DIR),$(ROOT_DIR))/

# The location of the LaTeX sources files. The files in this variable depend on
# the source_extensions and $(source_extensions)_directories.
SOURCES = $(call clean-whitespace,$(foreach e,$(source_extensions),$(call find-all-files,$($(e)_directories),"*$e")))

# Files to be symlinked into the build directory.
SYMLINK_FILES     = $(SOURCES)

# Directories containing files to be symlinked into the build directory.
# These directories form the dependencies of for build directory symlink 
# regeneration.
SYMLINK_FILE_DIRS = $(foreach e,$(source_extensions),$($(e)_directories))

# Directories to be symlinked into the build directory.
SYMLINK_DIRS      = $(IMG_DIRS) $(OTHER_DIRS)

# Files to be symlinked into the build directory, relative to the root 
# directory.
build_symlinks_sources = $(call clean-whitespace,$(SYMLINK_FILES) $(SYMLINK_DIRS))

# Symlinks files in the build directory, relative to the root directory.	   
build_symlinks = $(foreach s,$(build_symlinks_sources),$(BUILD_DIR)/$(shell $(BASENAME) $s))

# Source of the build directory symlinks, relative to the build directory path.
build_symlinks_relative = $(call clean-whitespace, \
           $(foreach f,$(SYMLINK_FILES),$(call addprefix,$(BUILD_DIR_RELATIVE),$f)) \
		   $(foreach d,$(SYMLINK_DIRS),$(call addprefix,$(BUILD_DIR_RELATIVE),$d)))
		   
# Files in the build directory that shouldn't appear in a "clean" build.
# These files are deleted on a "forceclean"
build_dirty_files := $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach p,$(build_persist), -o -name $p) \) -prune -o -print))

# All dependency files generated by this Makefile
all_deps       := $(BUILD_DIR)$(DEPS_EXT)

# All timestamp files generated by this Makefile.
all_timestamps := $(BUILD_DIR)$(TIMESTAMP_EXT)

################################################################################
# Make configuration
################################################################################
.DEFAULT_GOAL := all

# Clear out the standard interfering make suffixes
.SUFFIXES:

################################################################################
# LaTeX build configurations
#-------------------------------------------------------------------------------
# Define rules for compiling the project with LaTeX.
################################################################################
MAKE_LATEX ?= $(MAKE) -C $(BUILD_DIR)

ifdef DEBUG
MAKE_LATEX += SHELL_DEBUG=1
endif

ifdef VERBOSE
MAKE_LATEX += VERBOSE=1
endif

ifdef KEEP_TEMP
MAKE_LATEX += KEEP_TEMP=1
endif

################################################################################
# Targets
################################################################################

# Main target.
.PHONY: all
all: $(BUILD_DIR)

# Compile the LaTeX document.
# Build directory depends on build directory timestamp, which will be 
# out-of-date if symlinks need to be regenerated.
.PHONY: $(BUILD_DIR)
$(BUILD_DIR): $(BUILD_DIR)$(TIMESTAMP_EXT)
	$(MAKE_LATEX)

# Read the output PDF
.PHONY: read
read: $(BUILD_DIR)
	$(ACROREAD) $(BUILD_DIR)/*.pdf &

################################################################################
# Dependency targets
################################################################################

# Build directory dependencies
$(BUILD_DIR)$(DEPS_EXT):
	$(call verbose-message,"Creating $@.")
	$(call create-dependency-file,$(BUILD_DIR)$(TIMESTAMP_EXT),$(SYMLINK_FILE_DIRS),$@)

# Rebuilding the build directory timestamp involves regenerating the build 
# directory symlinks.
-include $(BUILD_DIR)$(DEPS_EXT)
$(BUILD_DIR)$(TIMESTAMP_EXT): $(BUILD_DIR)$(DEPS_EXT)
	$(call trace-message,"Creating symbolic links.")
	$(call verbose-message,"Deleting existing symlinks.")
	$(call remove-symlinks,$(build_symlinks))
	$(call verbose-message,"Creating new symlinks.")
	$(call create-symlinks,$(build_symlinks_relative),$(BUILD_DIR)/)
	$(call verbose-message,"Updating $@.")
	$(call write-text-to-file,$@,"### This file is used to detect when $(BUILD_DIR) symlinks need to be regenerated.")

################################################################################
# Clean targets
################################################################################
# Removes build files but not output files.
.PHONY: clean
clean: clean-latex

# Remove build files and output files
.PHONY: distclean
distclean: clean-latex clean-deps clean-timestamps clean-symlinks

# Force removal of leftover files in build directorty
.PHONY: forceclean
forceclean: force-clean-build

# Clean latex build
.PHONY: clean-latex
clean-latex:
	$(call trace-message,"Cleaning LaTeX build.")
	$(MAKE_LATEX) clean

# Remove dependency files
.PHONY: clean-deps
clean-deps:
	$(call trace-message,"Cleaning dependency files.")
	$(MUTE)$(call clean-files,$(all_deps))

# Remove timestamp files
.PHONY: clean-timestamps
clean-timestamps:
	$(call trace-message,"Cleaning timestamp files.")
	$(MUTE)$(call clean-files,$(all_timestamps))

# Delete symbolic links from the build subdirectory.
.PHONY: clean-symlinks
clean-symlinks:
	$(call trace-message,"Deleting symbolic links from build subdirectory.")
	$(call remove-symlinks,$(build_symlinks))

# Delete leftover auxillary files from the build subdirectory.
.PHONY: force-clean-build
force-clean-build:
	$(call trace-message,"Manually removing leftover build files.")
	$(call remove-files,$(build_dirty_files))
	
################################################################################
# Informational targets
################################################################################
# Dump makefile variables
.PHONY: info
info:
	$(call variable-dump)

define variable-dump
	$(info # Basic Shell Utilities)
	$(call print-variable,BASENAME)
	$(call print-variable,COMPARE)
	$(call print-variable,CONCATENATE)
	$(call print-variable,COPY_FORCE)
	$(call print-variable,COPY_SAFE)
	$(call print-variable,DELETE_FORCE)
	$(call print-variable,DELETE_SAFE)
	$(call print-variable,DIRNAME)
	$(call print-variable,ECHO)
	$(call print-variable,EXPRESSION)
	$(call print-variable,FIND)
	$(call print-variable,GREP)
	$(call print-variable,LINK)
	$(call print-variable,MAKE)
	$(call print-variable,MD5SUM)
	$(call print-variable,MOVE_FORCE)
	$(call print-variable,MOVE_SAFE)
	$(call print-variable,PERL)
	$(call print-variable,READLINK)
	$(call print-variable,SED)
	$(call print-variable,SLEEP)
	$(call print-variable,SORT)
	$(call print-variable,TAIL)
	$(call print-variable,TEST)
	$(call print-variable,TOUCH)
	$(call print-variable,UNIQUE)
	$(call print-variable,XARGS)
	$(info )
	
	$(info # Other Utilities)
	$(call print-variable,PDF_READER)
	$(call print-variable,MUTE)
	$(call print-variable,DEBUG)
	$(call print-variable,VERBOSE)
	$(call print-variable,NO_STDOUT)
	$(call print-variable,NO_STDERR)
	$(call print-variable,FIND)
	$(call print-variable,GREP)
	$(call print-variable,LINK)
	$(call print-variable,MAKE)
	$(call print-variable,MD5SUM)
	$(call print-variable,MOVE_FORCE)
	$(call print-variable,MOVE_SAFE)
	$(call print-variable,PERL)
	$(call print-variable,READLINK)
	$(call print-variable,SED)
	$(call print-variable,SLEEP)
	$(call print-variable,SORT)
	$(call print-variable,TAIL)
	$(call print-variable,TEST)
	$(call print-variable,TOUCH)
	$(call print-variable,UNIQUE)
	$(call print-variable,XARGS)
	$(info )
	
	$(info # Configuration)
	$(call print-variable,BUILD_DIR)
	$(call print-variable,EXT_DIRS)
	$(call print-variable,IMG_DIRS)
	$(call print-variable,OTHER_DIRS)
	$(call print-variable,SRC_DIRS)
	$(call print-variable,source_extensions)
	$(call print-variable,never_clean)
	$(foreach e,$(source_extensions),$(call print-variable,$(e)_directories))
	$(call print-variable,KEEP_TEMP)
	$(call print-variable,BUILD_PERSIST)
	$(info )
	
	$(info # Automatic Stuff)
	$(call print-variable,DEPS_EXT)
	$(call print-variable,TIMESTAMP_EXT)
	$(call print-variable,ROOT_DIR)
	$(call print-variable BUILD_DIR_RELATIVE)
	$(info )
	
	$(info # Sources)
	$(call print-variable,SOURCES)
	$(info )
	
	$(info # Symlinks)
	$(call print-variable,build_symlinks_sources)
	$(call print-variable,build_symlinks)
	$(call print-variable,build_symlinks_relative)
	$(info )
	
	$(info # Auxillary files)
	$(call print-variable,all_deps)
	$(call print-variable,all_timestamps)
	$(call print-variable,build_dirty_files)
	$(info )
	
	$(info # LaTeX)
	$(call print-variable,MAKE_LATEX)
	$(info )
endef

# Display help
.PHONY: help
help:
	$(call help-text)

define help-text
#===============================================================================
# Makefile for compiling a LaTeX project split into multiple directories.
#-------------------------------------------------------------------------------
# Name:    $(FILENAME)
# Author:  $(AUTHOR)
# Version: $(VERSION)
# Date:    $(VERSION_DATE)
#===============================================================================
#
# USAGE:
#     make [VERBOSE=1] [DEBUG=1] [KEEP_TEMP=1] <target(s)>
#
#
# TARGETS:
#     all
#           Runs all tasks necessary to compile the project.
#
#     $(BUILD_DIR)
#           Compile the LaTeX project.
#     
#     $(BUILD_DIR)$(DEPS_EXT)
#           TODO
#
#     $(BUILD_DIR)$(TIMESTAMP_EXT)
#           TODO
#
#     clean
#           Cleans the '$(BUILD_DIR)' subdirectory.
#
#     distclean
#           Removes symbolic links and remaining auxillary files from the 
#           '$(BUILD_DIR)' subdirectory.
#
#     help
#           Display the help file for instructions on how to compile the LaTeX 
#           project.
#
#     info
#           Print out all variables used in the Makefile. Useful for debugging 
#           purposes.
#
#     read
#           Compiles the LaTeX project and then opens the document with 
#           '$(PDF_READER)'.
#
#
# CONFIGURATION VARIABLES:
#   The following variables should be set in a file called 'Configuration.mk'.
#
#     BUILD_DIR
#           TODO
#
#     EXT_DIRS
#           TODO
#
#     IMG_DIRS
#           TODO
#
#     SRC_DIRS
#           TODO
#
#     source_extensions ?= .bib .bst .cls .sty .tex
#           TODO
#
#     neverclean
#           TODO
#
#     $(foreach e,$(source_extensions),$(e)_directories)
#           TODO
#
#     build_persist ?= Makefile Variables.ini
#           Files that should never be removed from the build directory.
#------------------------------------------------------------------------------- 
endef
