##################################################################
# Executables
##################################################################

BACKGROUND		:= &
BIBTEX			:= bibtex
CLEAR			:= clear
CP				:= cp
DIFF			:= diff
DVIPS			:= dvips -Ppdf -G0
ECHO			:= echo
FIG2DEV			:= fig2dev
FIND			:= find
GREP			:= grep
LATEX2HTML 		:= latex2html
IGNORE_RESULT 	:= -
MAKEINDEX		:= makeindex
MUTE			:= @
MV				:= mv
PDFLATEX		:= pdflatex
PS2PDF			:= ps2pdf
RM				:= rm -f
SILENT			:= >/dev/null
SPACE 			:= $(empty) $(empty)
TEX				:= latex
TOUCH			:= touch
VERBOSE_OFF		:= false &&
VERBOSE_ON		:= true &&
VERBOSE			:= $(VERBOSE_ON)
VERYSILENT		:= 1>/dev/null 2>/dev/null


##################################################################
# Display Codes (this is so we can track passes)
##################################################################

MOVE_TO_COL		:= $(MUTE)$(ECHO) -n "\\033[60G"
SETCOLOUR_BLACK	:= $(MUTE)$(ECHO) -n "\\033[0;30m"
SETCOLOUR_BLUE	:= $(MUTE)$(ECHO) -n "\\033[0;34m"
SETCOLOUR_GREEN := $(MUTE)$(ECHO) -n "\\033[0;32m"
SETCOLOUR_RED 	:= $(MUTE)$(ECHO) -n "\\033[0;31m"
RESTORE_COLOUR	:= $(MUTE)$(ECHO) -n "\\033[0;37m"


##################################################################
# Configuration
##################################################################

MAIN_DOC		:= SemiAuto
OUT_DIR			:= ../output
HTML_OUT_DIR	:= $(OUT_DIR)/html

BIB_SRC			:= $(shell $(FIND) . \( -type f -o -type l \) -name "*.bib")
BST_SRC			:= $(shell $(FIND) . \( -type f -o -type l \) -name "*.bst")
FIG_SRC			:= $(shell $(FIND) . \( -type f -o -type l \) -name "*.fig")
STY_SRC			:= $(shell $(FIND) . \( -type f -o -type l \) -name "*.sty")
TEX_SRC			:= $(shell $(FIND) . \( -type f -o -type l \) -name "*.tex")

# If the BIB_SRC is not empty, then we need to generate the bbl database. So we 
# define it here.
ifneq ($(strip $(BIB_SRC)),)
BBL_SRC			:= $(MAIN_DOC).bbl
endif

# Remove all built-in rules
.SUFFIXES:

##################################################################
# Targets
##################################################################

# Main target
all: dvi ps pdf
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
	
delete-files:
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting files."
	$(MUTE)$(RM) *.aux *.bbl *.blg *.glo *.idx *.ilg *.ind *.ist *.lof *.log *.lot *.toc

# Clean
.PHONY: clean
clean: delete-files
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"

# Dist-clean
.PHONY: distclean
distclean: delete-files	
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"


##################################################################
# Output Targets
##################################################################

# DVI output
dvi: $(OUT_DIR)/$(MAIN_DOC).dvi
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"

# Portable Document Format (PDF) Output
pdf: $(BIB_SRC) $(OUT_DIR)/$(MAIN_DOC).pdf
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
	
# Postscript Output
ps: $(OUT_DIR)/$(MAIN_DOC).ps $(FIG_SRC)
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"

# TODO: html output doesn't seem to work
# HTML Output
html: $(HTML_OUT_DIR)/$(MAIN_DOC).html $(FIG_SRC)
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"

# Index generation
index: $(MAIN_DOC).aux $(MAIN_DOC).idx $(MAIN_DOC).ilg $(MAIN_DOC).ind


##################################################################
# Rules
##################################################################

# AUX file
%.aux: %.tex
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
#	$(MOVE_TO_COL)
	$(IGNORE_RESULT)$(SETCOLOUR_GREEN)
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "=========================TEX -> AUX PASS=============================="
	$(MUTE)$(TEX) $(*F)
	$(IGNORE_RESULT)$(RESTORE_COLOUR)

# BBL file
%.bbl: %.tex
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building	target: $@"
ifneq ($(strip $(BIB_SRC)),)
#	$(IGNORE_RESULT)$(MUTE)$(MOVE_TO_COL)
	$(IGNORE_RESULT)$(MUTE)$(SETCOLOUR_RED)
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "===========================BIBTEX PASS================================"
	$(MUTE)$(BIBTEX) $(*F)
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "===========================BIBTEX/LaTeX PASS================================"
	$(MUTE)$(TEX) $(*F)
	$(IGNORE_RESULT)$(MUTE)$(RESTORE_COLOUR)
endif

# EPS file
%.eps: %.fig
	$(MUTE)$(ECHO) "Generating figure $@..."
	$(MUTE)$(FIG2DEV) -L ps $< $@

# To generate a .idx file from a .tex file
%.ilg: %.idx
#	$(IGNORE_RESULT)$(MUTE)$(MOVE_TO_COL)
	$(IGNORE_RESULT)$(MUTE)$(SETCOLOUR_BLUE)
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "=========================Indexing Pass================================"
	$(MUTE)$(MAKEINDEX) $(*F)
	$(MUTE)$(TEX) $(*F)
	
$(MAIN_DOC).idx:
	$(TOUCH) $@

# To generate a .dvi file from a .aux file
$(OUT_DIR)/%.dvi: %.aux
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
#	$(IGNORE_RESULT)$(MOVE_TO_COL)
	$(IGNORE_RESULT)$(SETCOLOUR_BLUE)
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "=========================AUX -> DVI PASS=============================="
	$(MUTE)$(TEX) -output-directory $(OUT_DIR) $(*F)
	$(IGNORE_RESULT)$(RESTORE_COLOUR)

# To generate a .ps file from a .dvi file
$(OUT_DIR)/%.ps: $(OUT_DIR)/%.dvi
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
	$(MUTE)$(DVIPS) -o $(OUT_DIR)/$(*F).ps $(*F).dvi

# To generate .html files from a .dvi file
$(HTML_OUT_DIR)/%.html: $(OUT_DIR)/%.dvi
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
	$(LATEX2HTML) -dir $(HTML_OUT_DIR) $(*F).dvi

# To generate a .pdf file from a .tex file
$(OUT_DIR)/%.pdf: %.aux $(TEX_SRC) $(BBL_SRC) $(BST_SRC)
	$(IGNORE_RESULT)$(MUTE)$(VERBOSE) $(ECHO) "Building target: $@"
#	$(IGNORE_RESULT)$(MOVE_TO_COL)
	$(IGNORE_RESULT)$(SETCOLOUR_BLUE)
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "=========================AUX -> PDF PASS=============================="
	$(MUTE)$(PDFLATEX) -output-directory $(OUT_DIR) $(*F)
	$(IGNORE_RESULT)$(RESTORE_COLOUR)
	
##################################################################
# Dependencies
##################################################################
$(MAIN_DOC).tex:             $(filter-out $(MAIN_DOC).tex, $(TEX_SRC))
$(MAIN_DOC).aux:             $(TEX_SRC)
$(MAIN_DOC).bbl:             $(TEX_SRC) $(BIB_SRC)
$(OUT_DIR)/$(MAIN_DOC).dvi:  $(TEX_SRC) $(FIG_SRC) $(STY_SRC) $(BBL_SRC) $(BST_SRC) index
$(OUT_DIR)/$(MAIN_DOC).html: $(TEX_SRC) $(FIG_SRC) $(STY_SRC) $(BBL_SRC) $(BST_SRC) index
$(OUT_DIR)/$(MAIN_DOC).ps:   $(TEX_SRC) $(FIG_SRC) $(STY_SRC) $(BBL_SRC) $(BST_SRC) index
$(OUT_DIR)/$(MAIN_DOC).pdf:  $(TEX_SRC) $(FIG_SRC) $(STY_SRC) $(BBL_SRC) $(BST_SRC) index
