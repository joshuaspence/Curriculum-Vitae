#===============================================================================
# Configuration
#===============================================================================

OUTPUTS := curriculum_vitae

RUBBER ?= rubber
ifdef FORCE
RUBBER_FLAGS += --force
endif
RUBBER_FLAGS += --inplace
RUBBER_FLAGS += --maxerr -1
ifdef QUIET
RUBBER_FLAGS += --quiet
endif
RUBBER_FLAGS += --texpath sty
ifdef VERBOSE
RUBBER_FLAGS += --verbose
endif

#===============================================================================
# Targets
#===============================================================================

.PHONY: all
all: dvi pdf ps

.PHONY: dvi
dvi: $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT).dvi)

.PHONY: pdf
pdf: $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT).pdf)

.PHONY: ps
ps: $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT).ps)

.PHONY: clean
clean:
	$(RUBBER) $(RUBBER_FLAGS) --clean $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT))
	$(RUBBER) $(RUBBER_FLAGS) --clean --pdf $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT))
	$(RUBBER) $(RUBBER_FLAGS) --clean --ps $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT))

#===============================================================================
# Rules
#===============================================================================

%.dvi: .FORCE
	$(RUBBER) $(RUBBER_FLAGS) $*

%.pdf: .FORCE
	$(RUBBER) $(RUBBER_FLAGS) --pdf $*

%.ps: .FORCE
	$(RUBBER) $(RUBBER_FLAGS) --ps $*

.PHONY: .FORCE
.FORCE:
