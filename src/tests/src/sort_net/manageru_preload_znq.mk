
SRC_CFLAGS := -DMC_IS_ZNQ_CODE ${MC_STD_EPH_CFLAGS} ${DBG_FLAG} 
SRC_CXXFLAGS := -DMC_IS_ZNQ_CODE ${MC_STD_EPH_CXXFLAGS} ${DBG_FLAG} 

SRC_INCDIRS := $(MC_STD_INCDIRS)

SOURCES := manageru_preload.cpp

