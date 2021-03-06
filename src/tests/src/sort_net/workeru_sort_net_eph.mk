

#*************************************************************
#
#This file is part of messaging-cells.
#
#messaging-cells is free software: you can redistribute it and/or modify
#it under the terms of the version 3 of the GNU General Public 
#License as published by the Free Software Foundation.
#
#messaging-cells is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with messaging-cells.  If not, see <http://www.gnu.org/licenses/>.
#
#------------------------------------------------------------
#
#Copyright (C) 2017-2018. QUIROGA BELTRAN, Jose Luis.
#Id (cedula): 79523732 de Bogota - Colombia.
#See https://messaging-cells.github.io/
#
#messaging-cells is free software thanks to The Glory of Our Lord 
#	Yashua Melej Hamashiaj.
#Our Resurrected and Living, both in Body and Spirit, 
#	Prince of Peace.
#
#------------------------------------------------------------


SORT_NET_DBG := -DFULL_DEBUG

define SET_STD_LIB_LDFLAG
ifeq "${SORT_NET_DBG}" ""
	SORT_NET_STD_C_LDLIBS := 
else
	SORT_NET_STD_C_LDLIBS := ${MC_STD_C_LDLIBS}
endif	
endef

$(eval $(SET_STD_LIB_LDFLAG))


# =======================================

SORT_NET_LDF=sort_net/sort_net.ldf

TARGET := sort_net_eph.elf

TGT_LDFLAGS := -T ${SORT_NET_LDF} ${MC_EPH_LDFLAGS_2} ${LD_IN_SECTIONS} 
TGT_LDLIBS  := ${MC_STD_EPH_LDLIBS} ${SORT_NET_STD_C_LDLIBS}
TGT_PREREQS := ${MC_EPH_LIBS}

TGT_CC := e-gcc
TGT_CXX := e-g++
TGT_LINKER := e-ld

define POST_OPERS
	e-objdump -D $(TARGET_DIR)/$(TARGET) > $(TARGET_DIR)/$(TARGET).s
	e-objdump -h $(TARGET_DIR)/$(TARGET) > $(TARGET_DIR)/$(TARGET)_sizes.txt
	printf "====================================\nFinished building "$(TARGET)"\n\n\n" 
endef

TGT_POSTMAKE := ${POST_OPERS}

SRC_CFLAGS := -DMC_IS_EPH_CODE ${MC_STD_EPH_CFLAGS} ${SORT_NET_DBG} ${SRC_IN_SECTIONS}
SRC_CXXFLAGS := -DMC_IS_EPH_CODE ${MC_STD_EPH_CXXFLAGS} ${SORT_NET_DBG} ${SRC_IN_SECTIONS}

SRC_INCDIRS := ${MC_STD_INCDIRS}

SOURCES := workerus_sort_net.cpp


