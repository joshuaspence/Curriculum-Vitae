##################################################################
# Executables
##################################################################

ACROREAD		:= acroread
BACKGROUND		:= &
ECHO			:= echo
EVINCE			:= evince
FIND			:= find
IGNORE_RESULT 	:= -
LN			  	:= ln -s
MAKE			:= make
MKDIR			:= mkdir -p
MUTE			:= @
RM				:= rm -f
SILENT			:= >/dev/null
SPACE 			:= $(empty) $(empty)
VERYSILENT		:= 1>/dev/null 2>/dev/null
XDVI		  	:= xdvi


##################################################################
# Configuration
##################################################################

MAIN_DOC		:= Résumé

BUILD_DIR		:= build
EXT_DIR			:= ext
FIG_DIR			:= img
IMG_DIR			:= img
SRC_DIR			:= src
OUT_DIR			:= output
HTML_OUT_DIR	:= $(OUT_DIR)/

BIB_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.bib")
BST_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.bst")
FIG_SRC			:= $(shell $(FIND) $(FIG_DIR) -type f -name "*.eps" -o -name "*.png")
STY_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.sty")
TEX_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.tex")


##################################################################
# Targets
##################################################################

# Main target
all: pre makeall post
makeall:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) all
		
# To be run before make
pre: make-directories make-symlinks
	
# Make output directories
make-directories:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating directories."
	$(MUTE)$(MKDIR) $(OUT_DIR)
	$(MUTE)$(MKDIR) $(HTML_OUT_DIR)
	
# Make symbolic links
.IGNORE: make-symlinks
make-symlinks: 
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating symbolic links."
	$(MUTE)$(LN) $(foreach bib, $(BIB_SRC), "$(realpath $(bib))") $(BUILD_DIR)/ $(VERYSILENT) || true
	$(MUTE)$(LN) $(foreach bst, $(BST_SRC), "$(realpath $(bst))") $(BUILD_DIR)/ $(VERYSILENT) || true
	$(MUTE)$(LN) $(foreach sty, $(STY_SRC), "$(realpath $(sty))") $(BUILD_DIR)/ $(VERYSILENT) || true
	$(MUTE)$(LN) $(foreach tex, $(TEX_SRC), "$(realpath $(tex))") $(BUILD_DIR)/ $(VERYSILENT) || true
	$(MUTE)$(LN) "$(realpath $(IMG_DIR))" $(BUILD_DIR)/ $(VERYSILENT) || true

# To be run after make
post: 

delete-out-directories:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting directories."
	$(MUTE)$(RM) -r $(OUT_DIR)
	
delete-aux-files:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting files."
	$(MUTE)$(RM) $(shell find $(BUILD_DIR) -mindepth 1 -name Makefile -prune -o -print)

##################################################################

# Clean (removes auxillary files but not output files)
.PHONY: clean
clean: delete-aux-files
	$(MUTE)$(MAKE) -C $(BUILD_DIR) $@

# Dist-clean (also removes output files)
.PHONY: distclean
distclean: delete-out-directories delete-aux-files
	$(MUTE)$(MAKE) -C $(BUILD_DIR) $@

##################################################################

# DVI Output
dvi: pre makedvi post
makedvi:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) dvi
	
# Postscript Output
ps: pre makeps post
makeps:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) ps
	
# HTML Output
html: pre makehtml post
makehtml:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) html

# Portable Document Format (PDF) Output
pdf: pre makepdf post
makepdf:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) pdf

##################################################################

# Read the DVI
.PHONY: dvi
xdvi:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) dvi
	$(MUTE)$(XDVI) $(OUT_DIR)/$(MAIN_DOC) $(SILENT) $(BACKGROUND)

# Read the PDF
.PHONY: read
read:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) pdf
	$(EVINCE) $(OUT_DIR)/$(MAIN_DOC).pdf $(BACKGROUND)

# Read the PDF using Acrobat
.PHONY: aread
aread:
	$(MUTE)$(MAKE) -C $(BUILD_DIR) pdf
	$(ACROREAD) $(OUT_DIR)/$(MAIN_DOC).pdf $(BACKGROUND)
