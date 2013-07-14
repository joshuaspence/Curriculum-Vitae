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

.DEFAULT: all
.PHONY: all
all: $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT).pdf) \
     $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT).ps)

.PHONY: clean
clean:
	$(RUBBER) $(RUBBER_FLAGS) --clean --pdf $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT))
	$(RUBBER) $(RUBBER_FLAGS) --clean --ps $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT))

#===============================================================================
# Rules
#===============================================================================

%.pdf: src/*.tex
	$(RUBBER) $(RUBBER_FLAGS) --pdf $*

%.ps: src/*.tex
	$(RUBBER) $(RUBBER_FLAGS) --ps $*
