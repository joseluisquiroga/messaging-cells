
BUILD_DIR := ./hg_build
TARGET_DIR := ./

HL_CURR_DIR := $(shell pwd)

BMETAL_CFLAGS := -Wall -std=gnu11 -ffreestanding -nostdlib -nostartfiles -fno-default-inline 

BMETAL_CXXFLAGS_P1 := -Wall -std=c++17 -nostdlib -fno-exceptions -fno-unwind-tables -fno-extern-tls-init
BMETAL_CXXFLAGS_P2 := -fno-rtti -fno-default-inline -fno-threadsafe-statics -fno-elide-constructors
BMETAL_CXXFLAGS := ${BMETAL_CXXFLAGS_P1} ${BMETAL_CXXFLAGS_P2}

HG_DBG_FLAG := -DFULL_DEBUG

HG_BASE_DIR := .

# -------------------------------------------------------------------------------------------


TARGET := gennet.elf

TGT_POSTMAKE := printf "====================================\nFinished building "$(TARGET)"\n\n\n"

SRC_CFLAGS := ${BMETAL_CFLAGS} ${HG_DBG_FLAG} 
SRC_CXXFLAGS := ${BMETAL_CXXFLAGS} ${HG_DBG_FLAG} 

SOURCES := \
	${HG_BASE_DIR}/hgen_net.cpp \

