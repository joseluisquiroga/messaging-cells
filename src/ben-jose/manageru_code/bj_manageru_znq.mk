
SRC_BJ_HOST_DIR := .

# =======================================

TARGET := bj_host_znq.elf

TGT_LDFLAGS := ${MC_STD_ZNQ_LDFLAGS}
TGT_LDLIBS  := ${MC_STD_ZNQ_LDLIBS} -static-libstdc++ -static-libgcc -ldimacs 
TGT_PREREQS := ${MC_ZNQ_LIBS} libdimacs.a 

TGT_CC := $(CROSS_COMPILE)gcc
TGT_CXX := $(CROSS_COMPILE)g++
TGT_LINKER := $(CROSS_COMPILE)g++

TGT_POSTMAKE := printf "====================================\nFinished building "$(TARGET)"\n\n\n"

SRC_CFLAGS := -DMC_IS_ZNQ_CODE -Wall -std=gnu11 ${MC_DBG_FLAG}
SRC_CXXFLAGS := -DMC_IS_ZNQ_CODE -Wall -std=c++14 ${MC_DBG_FLAG}

SRC_INCDIRS := ${BJ_HOST_INCLUDES}

SUBMAKEFILES := ./lib-dimacs-znq.mk ./cnf_preload_znq.mk ./sornet_preload_znq.mk 

SOURCES := \
	bj_manageru_code.cpp \


