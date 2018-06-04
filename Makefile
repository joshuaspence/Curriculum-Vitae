# Configuration
BUILD_DIR  := build
SOURCE_DIR := src
TEXPATH    := sty

SOURCES := $(wildcard $(SOURCE_DIR)/*.tex)
TARGET  := curriculum_vitae

# Executables
PDF_VIEWER ?= evince
RUBBER     ?= rubber

# Flags
RUBBER_FLAGS += --into $(BUILD_DIR)
RUBBER_FLAGS += --maxerr -1
RUBBER_FLAGS += $(addprefix --texpath $(CURDIR)/,$(TEXPATH))
RUBBER_FLAGS += --warn all

# Targets
.PHONY: build
build: pdf

.PHONY: clean
clean:
	rm --force --recursive --verbose $(BUILD_DIR)

.PHONY: pdf
pdf: $(BUILD_DIR)/$(TARGET).pdf

.PHONY: view
view: $(BUILD_DIR)/$(TARGET).pdf
	$(PDF_VIEWER) $< &

# Rules
$(BUILD_DIR)/$(TARGET).pdf: $(SOURCE_DIR)/$(TARGET).tex $(SOURCES)
	mkdir --parents $(BUILD_DIR)
	$(RUBBER) $(RUBBER_FLAGS) --pdf $<
