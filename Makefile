##################################################################
# Author details
##################################################################
AUTHOR			:= $(shell cat AUTHORS | perl -p -n -e 's/\r?\n/, /;' | perl -p -e 's/, $$//;')

##################################################################
# Executables
##################################################################

ACROREAD		:= acroread
CHANGE_DIR		:= cd
DELETE			:= rm
ECHO			:= echo
FIND			:= find
LATEXMK			:= latexmk
LINK		  	:= ln --symbolic
MAKE			:= make
MUTE			:= @
READLINK		:= readlink --canonicalize
SILENT			:= >/dev/null
SPACE 			:= $(empty) $(empty)
TOUCH			:= touch
VERYSILENT		:= 1>/dev/null 2>/dev/null


##################################################################
# Configuration
##################################################################

BUILD_DIR		:= build
EXT_DIR			:= ext
IMG_DIR			:= img
SRC_DIR			:= src

OUTPUT_PDF		:= CirriculumVitae.pdf

# Files in the build directory which should not be deleted on a 'clean'
BUILD_PERSIST   := Makefile Variables.ini latexmkrc

# The location of the LaTeX sources files
BIB_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.bib")
BST_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.bst")
CLS_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.cls")
STY_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.sty") $(shell $(FIND) $(SRC_DIR) -type f -name "*.sty")
TEX_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.tex")


##################################################################
# Automatic configuration
##################################################################

BUILD_FILES          = $(shell find $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach persist, $(BUILD_PERSIST), -o -name $(persist)) \) -prune -o -print)
BUILD_FILES_SYMLINKS = $(shell find $(BUILD_DIR) -mindepth 1 \( -type l \) -print)
OUTPUT_PDF_PATH      = $(shell $(FIND) $(BUILD_DIR) -type f -name "$(OUTPUT_PDF)" -exec $(READLINK) {} \;)

##################################################################
# Targets
##################################################################

# Main target.
# - Simply runs `latexmk' in the build directory.
.PHONY: all
all: pre $(OUTPUT_FILE)
ifneq ($(BUILD_DIR),)
	$(MUTE)$(CHANGE_DIR) $(BUILD_DIR); $(LATEXMK)
else
	$(error No build directory specified.)
endif

# Tasks to be execute before the thesis is compiled. 
# - Creates symbolic links in the build directory.
.PHONY: pre
pre: .symlinks.done

# Create symbolic links to the LaTeX source files in the build subdirectory.
# Creates a .done file to indicate to make that this task need not be completed 
# again.
.symlinks.done:
	-@$(ECHO) "Creating symbolic links."
ifneq ($(BIB_SRC),)
	$(MUTE)$(LINK) $(foreach bib, $(BIB_SRC), "$(realpath $(bib))") $(BUILD_DIR)/
endif
ifneq ($(BST_SRC),)
	$(MUTE)$(LINK) $(foreach bst, $(BST_SRC), "$(realpath $(bst))") $(BUILD_DIR)/
endif
ifneq ($(CLS_SRC),)
	$(MUTE)$(LINK) $(foreach cls, $(CLS_SRC), "$(realpath $(cls))") $(BUILD_DIR)/
endif
ifneq ($(STY_SRC),)
	$(MUTE)$(LINK) $(foreach sty, $(STY_SRC), "$(realpath $(sty))") $(BUILD_DIR)/
endif
ifneq ($(TEX_SRC),)
	$(MUTE)$(LINK) $(foreach tex, $(TEX_SRC), "$(realpath $(tex))") $(BUILD_DIR)/
endif
ifneq ($(IMG_DIR),)
	$(MUTE)$(LINK) "$(realpath $(IMG_DIR))" $(BUILD_DIR)/
endif
	$(MUTE)$(ECHO) "This file prevents make from creating symbolic links in the 'build' directory." > $@
	
# Delete leftover auxillary files from the build subdirectory.
.PHONY: rm-files
rm-files:
	-@$(ECHO) "Deleting any leftover build files."
ifneq ($(BUILD_FILES),)
	$(MUTE)$(DELETE) $(BUILD_FILES)
endif

# Delete symbolic links from the build subdirectory.
.PHONY: rm-symlinks
rm-symlinks:
	-@$(ECHO) "Deleting symbolic links."
ifneq ($(BUILD_FILES_SYMLINKS),)
	$(MUTE)$(DELETE) $(BUILD_FILES_SYMLINKS)
endif
	$(MUTE)$(DELETE) .symlinks.done


##################################################################

# Removes build files but not output files.
.PHONY: clean
clean:
ifneq ($(BUILD_DIR),)
	$(MUTE)$(CHANGE_DIR) $(BUILD_DIR); $(LATEXMK) -c
else
	$(error No build directory specified.)
endif

# Remove build files and output files
.PHONY: distclean
distclean: rm-symlinks rm-files
	
##################################################################

# Create a symbolic link to the output PDF
$(OUTPUT_PDF):
ifneq ($(OUTPUT_PDF_PATH),)
	$(MUTE)$(LINK) "$(OUTPUT_PDF_PATH)" "$@"
else
	$(error Cannot find output PDF.)
endif

# Read the output PDF
.PHONY: read
read: all $(OUTPUT_PDF)
ifneq ($(OUTPUT_PDF),)
	$(ACROREAD) $(OUTPUT_PDF) &
else
	$(error Cannot find output PDF.)
endif


##################################################################
# Help
##################################################################
.PHONY: help
help:
	@$(ECHO) "================================================================================"
	@$(ECHO) "Makefile for compiling the thesis."
	@$(ECHO) "Author: $(AUTHOR)"
	@$(ECHO) "================================================================================"
	@$(ECHO) "Targets are:"
	@$(ECHO) "    all                  Compile the thesis. The thesis will be output to "
	@$(ECHO) "                         '$(OUTPUT_PDF)'."
	@$(ECHO) "    pre                  Runs any tasks that must be executed before compilation"
	@$(ECHO) "                         can begin."
	@$(ECHO) "    .symlinks.done       Create symbolic links in the '$(BUILD_DIR)' "
	@$(ECHO) "                         subdirectory to all required files for the build."
	@$(ECHO) "    rm-files             Deletes all remaining auxillary files from the "
	@$(ECHO) "                         '$(BUILD_DIR)' subdirectory."
	@$(ECHO) "    rm-symlinks          Deletes the symbolic links from the '$(BUILD_DIR)' "
	@$(ECHO) "                         subdirectory."
	@$(ECHO) "    clean                Cleans the '$(BUILD_DIR)' subdirectory."
	@$(ECHO) "    distclean            Removes symbolic links and remaining auxillary files "
	@$(ECHO) "                         from the '$(BUILD_DIR)' subdirectory."
	@$(ECHO) "    read                 Compiles the thesis and then opens the document with "
	@$(ECHO) "                         '$(ACROREAD)'."
	@$(ECHO) "    help                 Display the help file for instructions on how to "
	@$(ECHO) "                         compile the thesis."
	@$(ECHO) "--------------------------------------------------------------------------------"
