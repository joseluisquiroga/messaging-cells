
#include <stdio.h>
#include "global.h"
#include "booter.h"

//======================================================================
// off chip shared memory

mc_off_sys_st* bjz_pt_external_host_data_obj = mc_null;

//=====================================================================
// global funcs

bjk_glb_sys_st	bjh_glb_sys_data;

void 
bjk_abort(mc_addr_t err, char* msg) {
	char full_msg[200];
	snprintf(full_msg, 200, "ABORTED_ZNQ_HOST_MC_SYS. %s\n", msg);
	bjh_abort_func(err, full_msg);
}

bjk_glb_sys_st*
bjk_get_glb_sys(){
	return &bjh_glb_sys_data;
}

void 
bjk_set_irq0_handler(){
}
