
`ifndef HGLOBAL_V_FILE
`define HGLOBAL_V_FILE 1
//--------------------------------------------

`define NS_ON 1
`define NS_OFF 0

`define NS_TRUE 1
`define NS_FALSE 0

`define ns_bit_toggle(bb) bb <= ~bb

`define ns_f_10HZ 1250000
`define ns_f_5HZ 2500000
`define ns_f_2HZ 6250000
`define ns_f_1HZ 12500000

`define NS_ADDRESS_SIZE 6
`define NS_DATA_SIZE 4
`define NS_REDUN_SIZE 4 // MUST BE LESS THAN the full message size ((NS_ADDRESS_SIZE * 2) + NS_DATA_SIZE) 

`define NS_PACKET_SIZE 3 // MUST BE LESS THAN the full message size ((NS_ADDRESS_SIZE * 2) + NS_DATA_SIZE) 

`define NS_1to2_FSZ 1
`define NS_2to1_FSZ 2
`define NS_PACKOUT_FSZ 4  // 1, 2 or 4 ***ONLY***
`define NS_PACKIN_FSZ 4  // 1, 2 or 4 ***ONLY***

`define NS_REQ_CKS 1
`define NS_ACK_CKS 1

`define NS_2to1_REQ_CKS 1
`define NS_2to1_ACK_CKS 1

`define NS_GT_OP 1
`define NS_GTE_OP 2
`define NS_LT_OP 3
`define NS_LTE_OP 4
`define NS_EQ_OP 5


`define NS_CMP_OP(op, pm1, pm2) ( \
	(op == `NS_GT_OP)? \
		((pm1) > (pm2)):( \
	(op == `NS_GTE_OP)? \
		((pm1) >= (pm2)):( \
	(op == `NS_LT_OP)? \
		((pm1) < (pm2)):( \
	(op == `NS_LTE_OP)? \
		((pm1) <= (pm2)):( \
		(pm1) == (pm2) \
	))))) 


`define NS_RANGE_CMP_OP(is_dbl, op1, pm1, pm2, op2, pm3, pm4) ( \
	(is_dbl == `NS_TRUE)?(`NS_CMP_OP(op1, pm1, pm2) && `NS_CMP_OP(op2, pm3, pm4)):(`NS_CMP_OP(op1, pm1, pm2)) )
	

// DBG CLOCKS
// ----------------------------------------------------------------------------

`define NS_DECLARE_DBG_CLK(nam, idx, lim) \
	reg [1:0] clk_idx_``nam = idx; \
	reg [CLK_WDH-1:0] lim_clk_``nam = lim; \
	reg [CLK_WDH-1:0] cnt_clk_``nam = 1; \
	reg clk_``nam = 0;


`define NS_INC_DBG_CLK(nam, base_clk) \
	if((cnt_clk_``nam == 0) || (cnt_clk_``nam == lim_clk_``nam)) begin \
		cnt_clk_``nam <= 1; \
		`ns_bit_toggle(clk_``nam); \
	end \
	else  begin \
		cnt_clk_``nam <= (cnt_clk_``nam << 1); \
	end 


`define NS_INIT_DBG_ARR_IDXS(idxs_arr) \
		idxs_arr[0] <= 0; \
		idxs_arr[1] <= 0; \
		idxs_arr[2] <= 0; \
		idxs_arr[3] <= 0; 


`define NS_INC_DBG_ARR3(idxs_arr, max_idx) \
	if(idxs_arr[3] == max_idx) begin \
		`NS_INIT_DBG_ARR_IDXS(idxs_arr) \
	end \
	else \
	begin \
		idxs_arr[3] <= idxs_arr[3] + 1; \
	end


`define NS_INC_DBG_ARR2(idxs_arr, max_idx) \
	if(idxs_arr[2] == max_idx) begin \
		idxs_arr[2] <= 0; \
		`NS_INC_DBG_ARR3(idxs_arr, max_idx) \
	end \
	else \
	begin \
		idxs_arr[2] <= idxs_arr[2] + 1; \
	end


`define NS_INC_DBG_ARR1(idxs_arr, max_idx) \
	if(idxs_arr[1] == max_idx) begin \
		idxs_arr[1] <= 0; \
		`NS_INC_DBG_ARR2(idxs_arr, max_idx) \
	end \
	else \
	begin \
		idxs_arr[1] <= idxs_arr[1] + 1; \
	end


`define NS_INC_DBG_ARR0(idxs_arr, max_idx) \
	if(idxs_arr[0] == max_idx) begin \
		idxs_arr[0] <= 0; \
		`NS_INC_DBG_ARR1(idxs_arr, max_idx) \
	end \
	else \
	begin \
		idxs_arr[0] <= idxs_arr[0] + 1; \
	end


`define NS_INC_DBG_IDXS_ARR(idxs_arr, max_idx) `NS_INC_DBG_ARR0(idxs_arr, max_idx)


`define NS_SET_LIM_DBG_CLK(nam, lims_arr, idxs_arr) lim_clk_``nam <= lims_arr[idxs_arr[clk_idx_``nam]];

// DBG CHANNELS
// ----------------------------------------------------------------------------

`define NS_DECLARE_DBG_CHNL(dbg) \
	input wire dbg``_clk, \
	input wire dbg``_doit, \
	input wire [7:0] dbg``_case, \
	output wire [3:0] dbg``_leds, \
	output wire [3:0] dbg``_disp0, \
	output wire [3:0] dbg``_disp1


`define NS_DECLARE_DBG_LINK(lnk) \
	wire [0:0] lnk``_doit; \
	wire [7:0] lnk``_case; \
	wire [3:0] lnk``_leds; \
	wire [3:0] lnk``_disp0; \
	wire [3:0] lnk``_disp1; 


`define NS_INSTA_DBG_CHNL(chn, lnk, the_clk) \
	.chn``_clk(the_clk), \
	.chn``_doit(lnk``_doit), \
	.chn``_case(lnk``_case), \
	.chn``_leds(lnk``_leds), \
	.chn``_disp0(lnk``_disp0), \
	.chn``_disp1(lnk``_disp1)


`define NS_DECLARE_REG_DBG(lnk) \
	reg [3:0] lnk``_leds = 0; \
	reg [3:0] lnk``_disp0 = 0; \
	reg [3:0] lnk``_disp1 = 0; 


`define NS_MOV_REG_DBG(dst, src) \
	dst``_leds <= src``_leds; \
	dst``_disp0 <= src``_disp0; \
	dst``_disp1 <= src``_disp1;


`define NS_ASSIGN_OUT_DBG(ou, mg) \
	assign ou``_leds = mg``_leds; \
	assign ou``_disp0 = mg``_disp0; \
	assign ou``_disp1 = mg``_disp1; 


`define NS_DEBOUNCER_DBG_BUT(clk, nam) \
	wire rdy_but_``nam; \
	debouncer #(.TOT_CKS(TOT_DEBOUNCE_CLICK)) \
	it_but_``nam ( \
		.i_Clk(clk), \
		.reset(reset), \
		.ready(rdy_but_``nam), \
		.bouncing(i_Switch_``nam), \
		.steady(w_Switch_``nam) \
	);


// MESSAGES
// ----------------------------------------------------------------------------


`define NS_FULL_MSG_SZ  (ASZ + ASZ + DSZ + RSZ)


`define NS_DECLARE_REG_MSG(mg) \
	reg [ASZ-1:0] mg``_src = 0; \
	reg [ASZ-1:0] mg``_dst = 0; \
	reg [DSZ-1:0] mg``_dat = 0; \
	reg [RSZ-1:0] mg``_red = 0; \


`define NS_DECLARE_IN_MSG(mg) \
	input wire [ASZ-1:0] mg``_src, \
	input wire [ASZ-1:0] mg``_dst, \
	input wire [DSZ-1:0] mg``_dat, \
	input wire [RSZ-1:0] mg``_red


`define NS_DECLARE_OUT_MSG(mg) \
	output wire [ASZ-1:0] mg``_src, \
	output wire [ASZ-1:0] mg``_dst, \
	output wire [DSZ-1:0] mg``_dat, \
	output wire [RSZ-1:0] mg``_red


`define NS_ASSIGN_OUT_MSG(ou, mg) \
	assign ou``_src = mg``_src; \
	assign ou``_dst = mg``_dst; \
	assign ou``_dat = mg``_dat; \
	assign ou``_red = mg``_red; \


`define NS_MOV_REG_MSG(mg_dst, mg_src) \
	mg_dst``_src <= mg_src``_src; \
	mg_dst``_dst <= mg_src``_dst; \
	mg_dst``_dat <= mg_src``_dat; \
	mg_dst``_red <= mg_src``_red; 


`define NS_REG_MSG_EQ(mg, eq_src, eq_dst, eq_dat) ((mg``_src == eq_src) && (mg``_dst == eq_dst) && (mg``_dat == eq_dat))


`define NS_REG_MSG_RED_EQ(mg, eq_src, eq_dst, eq_dat, eq_red) ((mg``_src == eq_src) && \
	(mg``_dst == eq_dst) && (mg``_dat == eq_dat) && (mg``_red == eq_red))


// CHANNELS
// ----------------------------------------------------------------------------

`define NS_DECLARE_OUT_CHNL(nam) \
	`NS_DECLARE_OUT_MSG(nam), \
	output wire nam``_req, \
	input wire nam``_ack_dirty


`define NS_DECLARE_IN_CHNL(nam) \
	`NS_DECLARE_IN_MSG(nam), \
	input wire nam``_req_dirty, \
	output wire nam``_ack


`define NS_DEBOUNCER_REQ(clk, nam) \
	wire nam``_rdy; \
	wire nam``_req; \
	debouncer #(.TOT_CKS(RCV_REQ_CKS)) \
	it_``nam``_req( \
		.i_Clk(clk), \
		.reset(reset), \
		.ready(nam``_rdy), \
		.bouncing(nam``_req_dirty), \
		.steady(nam``_req) \
	);


`define NS_DEBOUNCER_ACK(clk, nam) \
	wire nam``_rdy; \
	wire nam``_ack; \
	debouncer #(.TOT_CKS(SND_ACK_CKS)) \
	it_``nam``_ack( \
		.i_Clk(clk), \
		.reset(reset), \
		.ready(nam``_rdy), \
		.bouncing(nam``_ack_dirty), \
		.steady(nam``_ack) \
	);


`define NS_DECLARE_LINK(lnk) \
	wire [ASZ-1:0] lnk``_src; \
	wire [ASZ-1:0] lnk``_dst; \
	wire [DSZ-1:0] lnk``_dat; \
	wire [RSZ-1:0] lnk``_red; \
	wire lnk``_req; \
	wire lnk``_ack; 


`define NS_INSTA_MSG_CHNL(chn, lnk) \
	.chn``_src(lnk``_src), \
	.chn``_dst(lnk``_dst), \
	.chn``_dat(lnk``_dat), \
	.chn``_red(lnk``_red)


`define NS_INSTA_SND_CHNL(chn, lnk) \
	`NS_INSTA_MSG_CHNL(chn, lnk), \
	.chn``_req(lnk``_req), \
	.chn``_ack_dirty(lnk``_ack)


`define NS_INSTA_RCV_CHNL(chn, lnk) \
	`NS_INSTA_MSG_CHNL(chn, lnk), \
	.chn``_req_dirty(lnk``_req), \
	.chn``_ack(lnk``_ack)

	
`define NS_REG_MSG_INIT(mg) \
	mg``_src <= 0; \
	mg``_dst <= 0; \
	mg``_dat <= 0; \
	mg``_red <= 0; \


// FIFOS
// ----------------------------------------------------------------------------

`define NS_DECLARE_FIFO(fif) \
	integer fif``ii = 0; \
	reg [0:0] fif``_busy [FSZ-1:0]; \
	reg [`NS_FULL_MSG_SZ-1:0] fif``_data[FSZ-1:0]; \
	reg [FIFO_IDX_WIDTH:0] fif``_hd_idx = 0; \
	reg [FIFO_IDX_WIDTH:0] fif``_tl_idx = 0; \
	wire fif``_hd_eq_tl = (fif``_hd_idx == fif``_tl_idx); \
	wire fif``_hd_busy = fif``_busy[fif``_hd_idx]; \
	wire fif``_tl_busy = (fif``_hd_eq_tl)?(fif``_hd_busy):(fif``_busy[fif``_tl_idx]);


`define NS_FIFO_INIT(fif) \
	for(fif``ii = 0; fif``ii < FSZ; fif``ii = fif``ii+1) begin \
		fif``_busy[fif``ii] <= `NS_OFF; \
	end \
	for(fif``ii = 0; fif``ii < FSZ; fif``ii = fif``ii+1) begin \
		fif``_data[fif``ii] <= 0; \
	end \
	fif``_hd_idx <= 0; \
	fif``_tl_idx <= 0;


`define NS_GET_SEQ_MSG(chn) {chn``_src, chn``_dst, chn``_dat, chn``_red}


`define NS_FIFO_SET_IDX(chn, fif, idx) fif``_data[idx] <= `NS_GET_SEQ_MSG(chn);

// ASZ + ASZ + DSZ + RSZ
`define NS_MG_SRC_SECTION  ((ASZ + ASZ + DSZ + RSZ)-1):(ASZ + DSZ + RSZ)
`define NS_MG_DST_SECTION  ((ASZ + DSZ + RSZ)-1):(DSZ + RSZ)
`define NS_MG_DAT_SECTION  ((DSZ + RSZ)-1):RSZ
`define NS_MG_RED_SECTION  (RSZ-1):0


`define NS_SEQ_SET(seq, chn) \
	seq[`NS_MG_SRC_SECTION] <= chn``_src; \
	seq[`NS_MG_DST_SECTION] <= chn``_dst; \
	seq[`NS_MG_DAT_SECTION] <= chn``_dat; \
	seq[`NS_MG_RED_SECTION] <= chn``_red;


`define NS_SEQ_GET(seq, chn) \
	chn``_src <= seq[`NS_MG_SRC_SECTION]; \
	chn``_dst <= seq[`NS_MG_DST_SECTION]; \
	chn``_dat <= seq[`NS_MG_DAT_SECTION]; \
	chn``_red <= seq[`NS_MG_RED_SECTION]; 


//`define NS_FIFO_SET_IDX(chn, fif, idx) `NS_SEQ_SET(fif``_data[idx], chn)

//`define NS_FIFO_GET_IDX(chn, fif, idx) `NS_SEQ_GET(fif``_data[idx], chn)

/*
`define NS_FIFO_SET_IDX(chn, fif, idx) \
	fif``_data[idx][`NS_MG_SRC_SECTION] <= chn``_src; \
	fif``_data[idx][`NS_MG_DST_SECTION] <= chn``_dst; \
	fif``_data[idx][`NS_MG_DAT_SECTION] <= chn``_dat; \
	fif``_data[idx][`NS_MG_RED_SECTION] <= chn``_red; 
*/


`define NS_FIFO_GET_IDX(chn, fif, idx) \
	chn``_src <= fif``_data[idx][`NS_MG_SRC_SECTION]; \
	chn``_dst <= fif``_data[idx][`NS_MG_DST_SECTION]; \
	chn``_dat <= fif``_data[idx][`NS_MG_DAT_SECTION]; \
	chn``_red <= fif``_data[idx][`NS_MG_RED_SECTION];
	

`define NS_IDX_EQ(idx, max_idx) (/* verilator lint_off WIDTH */ ((idx) == (max_idx)) /* verilator lint_on WIDTH */)


`define NS_INC_IDX(idx, arr_sz) \
	if(`NS_IDX_EQ(idx, (arr_sz - 1))) begin \
		idx <= 0; \
	end else begin \
		idx <= idx + 1; \
	end 


`define NS_FIFO_TRY_INC_HEAD(fif, mg_in, the_ack) \
	if((! the_ack) && (! fif``_hd_busy)) begin \
		fif``_busy[fif``_hd_idx] <= `NS_ON; \
		`NS_FIFO_SET_IDX(mg_in, fif, fif``_hd_idx); \
		`NS_INC_IDX(fif``_hd_idx, FSZ); \
		the_ack <= `NS_ON; \
	end


`define NS_FIFO_TRY_ADD_HEAD(fif, mg_in, has_added_hd) \
	if((! fif``_hd_busy) && (! has_added_hd)) begin \
		fif``_busy[fif``_hd_idx] <= `NS_ON; \
		`NS_FIFO_SET_IDX(mg_in, fif, fif``_hd_idx); \
		`NS_INC_IDX(fif``_hd_idx, FSZ); \
		has_added_hd <= `NS_ON; \
	end


`define NS_FIFO_ACK_ADDED_HEAD(fif, the_ack, has_added_hd) \
	if(has_added_hd) begin \
		has_added_hd <= `NS_OFF; \
		the_ack <= `NS_ON; \
	end


`define NS_FIFO_TRY_INC_TAIL(fif, mg_out, out_is_busy) \
	if(fif``_tl_busy && ! out_is_busy) begin \
		fif``_busy[fif``_tl_idx] <= `NS_OFF; \
		out_is_busy <= `NS_ON; \
		`NS_FIFO_GET_IDX(mg_out, fif, fif``_tl_idx); \
		`NS_INC_IDX(fif``_tl_idx, FSZ); \
	end


`define NS_FIFO_TRY_SET_OUT(fif, mg_out, the_out_ack, the_req, out_is_busy) \
	`NS_FIFO_TRY_INC_TAIL(fif, mg_out, out_is_busy) \
	if(out_is_busy) begin \
		if(! the_req && ! the_out_ack) begin \
			the_req <= `NS_ON; \
		end \
		if(the_req && the_out_ack) begin \
			out_is_busy <= `NS_OFF; \
			the_req <= `NS_OFF; \
		end \
	end


// PACKETS
// ----------------------------------------------------------------------------

`define NS_DECLARE_REG_PACKETS(pks) \
	integer pks``ii = 0; \
	reg [0:0] pks``_busy = 0; \
	reg [PSZ-1:0] pks``_packets[TOT_PKS-1:0]; \
	reg [PACKETS_IDX_WIDTH:0] pks``_pks_idx = 0; 


`define NS_DECLARE_REG_PAKOUT(pks) \
	`NS_DECLARE_REG_PACKETS(pks) \
	reg [0:0] pks``_pkio_busy = 0; \
	reg [PSZ-1:0] pks``_pakio = 0;


`define NS_DECLARE_PAKOUT_CHNL(nam) \
	output wire [PSZ-1:0] nam``_pakio, \
	output wire nam``_req, \
	input wire nam``_ack_dirty


`define NS_DECLARE_PAKIN_CHNL(nam) \
	input wire [PSZ-1:0] nam``_pakio, \
	input wire nam``_req_dirty, \
	output wire nam``_ack


`define NS_DECLARE_PAKIO_LINK(lnk) \
	wire [PSZ-1:0] lnk``_pakio; \
	wire lnk``_req; \
	wire lnk``_ack; 


`define NS_INSTA_RCV_PAKIO_CHNL(chn, lnk) \
	.chn``_pakio(lnk``_pakio), \
	.chn``_req_dirty(lnk``_req), \
	.chn``_ack(lnk``_ack)


`define NS_INSTA_SND_PAKIO_CHNL(chn, lnk) \
	.chn``_pakio(lnk``_pakio), \
	.chn``_req(lnk``_req), \
	.chn``_ack_dirty(lnk``_ack)


`define NS_PACKETS_INIT(pks, busy_init) \
	pks``_busy <= busy_init; \
	for(pks``ii = 0; pks``ii < TOT_PKS; pks``ii = pks``ii+1) begin \
		pks``_packets[pks``ii] <= 0; \
	end \
	pks``_pks_idx <= 0;


`define NS_PACKOUT_INIT(pks) \
	`NS_PACKETS_INIT(pks, `NS_OFF) \
	pks``_pkio_busy <= 0; \
	pks``_pakio <= 0;


`define NS_MG_SEL_DAT_AA (`NS_FULL_MSG_SZ-1)

`define NS_MG_SEL_DAT_BB ((TOT_PKS-1)*PSZ)

`define NS_MG_SEL_PAK(ii) ii*PSZ +: PSZ

`define NS_MOV_FIFO_IDX_TO_PAKS(pks, fif, idx) \
	for(pks``ii = 0; pks``ii < TOT_PKS-1; pks``ii = pks``ii + 1) begin \
		pks``_packets[pks``ii] <= fif``_data[idx][`NS_MG_SEL_PAK(pks``ii)]; \
	end \
	if((`NS_FULL_MSG_SZ % PSZ) > 0) begin \
		pks``_packets[TOT_PKS-1][((`NS_FULL_MSG_SZ % PSZ)-1):0] <= fif``_data[idx][`NS_MG_SEL_DAT_AA:`NS_MG_SEL_DAT_BB]; \
	end else begin \
		pks``_packets[TOT_PKS-1] <= 0; \
	end


`define NS_MOV_PAKS_TO_FIFO_IDX(pks, fif, idx) \
	for(pks``ii = 0; pks``ii < TOT_PKS-1; pks``ii = pks``ii + 1) begin \
		fif``_data[idx][`NS_MG_SEL_PAK(pks``ii)] <= pks``_packets[pks``ii]; \
	end \
	if((`NS_FULL_MSG_SZ % PSZ) > 0) begin \
		fif``_data[idx][`NS_MG_SEL_DAT_AA:`NS_MG_SEL_DAT_BB] <= pks``_packets[TOT_PKS-1][((`NS_FULL_MSG_SZ % PSZ)-1):0]; \
	end


`define NS_FIFO_TO_PAKS_TRY_INC_TAIL(fif, pks) \
	if(! pks``_busy && fif``_tl_busy) begin \
		fif``_busy[fif``_tl_idx] <= `NS_OFF; \
		`NS_MOV_FIFO_IDX_TO_PAKS(pks, fif, fif``_tl_idx); \
		`NS_INC_IDX(fif``_tl_idx, FSZ); \
		pks``_busy <= `NS_ON; \
	end 


`define NS_PACKOUT_TRY_INC(pks, the_out_ack, the_req) \
	if(pks``_busy) begin \
		if(! pks``_pkio_busy) begin \
			pks``_pkio_busy <= `NS_ON; \
			pks``_pakio <= pks``_packets[pks``_pks_idx]; \
			`NS_INC_IDX(pks``_pks_idx, TOT_PKS); \
		end \
		else \
		if(! the_req && ! the_out_ack && pks``_pkio_busy) begin \
			the_req <= `NS_ON; \
		end \
		else \
		if(the_req && the_out_ack) begin \
			if(pks``_pkio_busy) begin \
				pks``_pkio_busy <= `NS_OFF; \
				if(pks``_pks_idx == 0) begin \
					pks``_busy <= `NS_OFF; \
				end \
			end \
			the_req <= `NS_OFF; \
		end \
	end 


`define NS_PACKIN_TRY_INC(pks, pk_in, fif, the_ack) \
	if(pks``_busy) begin \
		if(pk_in``_req && (! the_ack)) begin \
			pks``_packets[pks``_pks_idx] <= pk_in``_pakio; \
			`NS_INC_IDX(pks``_pks_idx, TOT_PKS); \
			the_ack <= `NS_ON; \
		end \
		else \
		if((! pk_in``_req) && the_ack) begin \
			if(pks``_pks_idx == 0) begin \
				pks``_busy <= `NS_OFF; \
			end \
			the_ack <= `NS_OFF; \
		end \
	end \
	else \
	begin \
		if(! fif``_hd_busy) begin \
			fif``_busy[fif``_hd_idx] <= `NS_ON; \
			`NS_MOV_PAKS_TO_FIFO_IDX(pks, fif, fif``_hd_idx); \
			`NS_INC_IDX(fif``_hd_idx, FSZ); \
			pks``_busy <= `NS_ON; \
		end \
	end 




//--------------------------------------------
`endif // HGLOBAL_V_FILE
