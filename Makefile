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
RUBBER_FLAGS += --texpath sty

#===============================================================================
# Targets
#===============================================================================

.DEFAULT: all
.PHONY: all
all: $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT).pdf)

src/%.pdf: src/*.tex
	$(RUBBER) $(RUBBER_FLAGS) --pdf src/$*

.PHONY: clean
clean:
	$(RUBBER) $(RUBBER_FLAGS) --clean --pdf $(foreach OUTPUT,$(OUTPUTS),src/$(OUTPUT))
