
# =======================================

SRC_CFLAGS := -DMC_IS_ZNQ_CODE ${MC_STD_EPH_CFLAGS} ${DBG_FLAG} 
SRC_CXXFLAGS := -DMC_IS_ZNQ_CODE ${MC_STD_EPH_CXXFLAGS} ${DBG_FLAG} 

SRC_INCDIRS := ${BJ_HOST_INCLUDES}

SOURCES := cnf_preload/preload_sornet.cpp

