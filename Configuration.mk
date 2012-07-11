# Directories
BUILD_DIR  := build
OTHER_DIRS := 
EXT_DIRS   := ext
IMG_DIRS   := img
SRC_DIRS   := src

# Files in the build directory which should not be deleted on a 'clean'
build_persist := 

# The location of the LaTeX sources files
source_extensions := .tex
.tex_directories  := $(SRC_DIRS)
