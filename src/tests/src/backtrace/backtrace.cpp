

/*************************************************************

This file is part of messaging-cells.

messaging-cells is free software: you can redistribute it and/or modify
it under the terms of the version 3 of the GNU General Public 
License as published by the Free Software Foundation.

messaging-cells is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with messaging-cells.  If not, see <http://www.gnu.org/licenses/>.

------------------------------------------------------------

Copyright (C) 2017-2018. QUIROGA BELTRAN, Jose Luis.
Id (cedula): 79523732 de Bogota - Colombia.
See https://messaging-cells.github.io/

messaging-cells is free software thanks to The Glory of Our Lord 
	Yashua Melej Hamashiaj.
Our Resurrected and Living, both in Body and Spirit, 
	Prince of Peace.

------------------------------------------------------------*/


#include "cell.hh"

void func_1(int aa){
	mck_abort((mc_addr_t)func_1, mc_cstr("Forced abort in backtrace test"));
}

void func_2(char bb, int aa){
	func_1(aa + 5);
}

void func_3(char* cc, int aa){
	func_2('x', aa * 7);
}

void mc_workerus_main() {
	mck_glb_init(false);

	mck_slog2("BACKTRACE_TEST\n");	
	func_3(mc_cstr("calling func3"), 33);

	mck_glb_finish();
}

