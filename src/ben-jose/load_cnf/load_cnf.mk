
#SRC_IN_SECTIONS := -fdata-sections -ffunction-sections
SRC_IN_SECTIONS := 

#LD_IN_SECTIONS := --gc-sections
LD_IN_SECTIONS := 

SRC_BJ_HOST_DIR := ../host_code

# =======================================

TARGET := libload_cnf.a

TGT_LDFLAGS := ${MC_STD_EPH_LDFLAGS} ${LD_IN_SECTIONS} 
TGT_LDLIBS  := ${MC_STD_EPH_LDLIBS}
TGT_PREREQS := ${MC_EPH_LIBS}

TGT_CC := e-gcc
TGT_CXX := e-g++
TGT_LINKER := e-ld

define POST_OPERS
	e-objdump -D $(TARGET_DIR)/$(TARGET) > $(TARGET_DIR)/$(TARGET).s
	printf "====================================\nFinished building "$(TARGET)"\n\n\n" 
endef

TGT_POSTMAKE := ${POST_OPERS}

SRC_CFLAGS := -DMC_IS_EPH_CODE ${MC_STD_EPH_CFLAGS} ${MC_DBG_FLAG} ${SRC_IN_SECTIONS}
SRC_CXXFLAGS := -DMC_IS_EPH_CODE ${MC_STD_EPH_CXXFLAGS} ${MC_DBG_FLAG} ${SRC_IN_SECTIONS}

SRC_INCDIRS := \
	${MC_STD_INCDIRS} \
	${SRC_BJ_DIR}/load_cnf \
	${SRC_BJ_DIR}/host_code/cnf_preload \


SOURCES := load_cnf.cpp

