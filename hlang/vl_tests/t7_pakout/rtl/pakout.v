
`include "hglobal.v"

`default_nettype	none

`define NS_DBG_MSG_CASES(num, mg) \
	8'h``num``1 : \
	begin \
		rg_dbg_disp0 <= mg``_src[ASZ-1:4]; \
		rg_dbg_disp1 <= mg``_src[3:0]; \
	end \
	8'h``num``2 : \
	begin \
		rg_dbg_disp0 <= mg``_dst[ASZ-1:4]; \
		rg_dbg_disp1 <= mg``_dst[3:0]; \
	end \
	8'h``num``3 : \
	begin \
		rg_dbg_disp0 <= 0; \
		rg_dbg_disp1 <= mg``_dat[3:0]; \
	end \
	8'h``num``4 : \
	begin \
		rg_dbg_disp0 <= 0; \
		rg_dbg_disp1 <= mg``_red; \
	end \



module pakout
#(parameter 
	PSZ=`NS_PACKET_SIZE, 
	FSZ=`NS_PACKOUT_FSZ, 
	ASZ=`NS_ADDRESS_SIZE, 
	DSZ=`NS_DATA_SIZE, 
	RSZ=`NS_REDUN_SIZE,
)(
	input wire i_clk,
	input wire reset,
	output wire ready,
	
	`NS_DECLARE_PAKOUT_CHNL(snd0)
	`NS_DECLARE_IN_CHNL(rcv0)
	
	`NS_DECLARE_DBG_CHNL(dbg)
);
	`NS_DECLARE_REG_DBG(rg_dbg)
	
	reg [0:0] rg_rdy = `NS_OFF;
	
	// out0 regs
	`NS_DECLARE_REG_PAKOUT(rgo0)
	reg [0:0] rgo0_req = `NS_OFF;

	// inp0 regs
	reg [0:0] rgi0_ack = `NS_OFF;

	// fifos
	`NS_DECLARE_FIFO(bf0)
	
	reg [0:0] added_hd = `NS_OFF;

	/*
	always @(posedge i_clk)
	begin
		if(reset) begin
			rg_rdy <= `NS_OFF;
		end
		if(! reset && ! rg_rdy) begin
			rg_rdy <= `NS_ON;
			
			`NS_PACKOUT_INIT(rgo0)
			rgo0_req <= `NS_OFF;
			
			rgi0_ack <= `NS_OFF;
			
			`NS_FIFO_INIT(bf0);
		end
		if(! reset && rg_rdy) begin
			if(! added_hd) begin
				if(rcv0_req && (! rgi0_ack)) begin
					`NS_FIFO_TRY_ADD_HEAD(bf0, rcv0, added_hd);
					//`NS_FIFO_TRY_INC_HEAD(bf0, rcv0, rgi0_ack);
				end
			end
			else
			begin
				`NS_FIFO_ACK_ADDED_HEAD(bf0, rgi0_ack, added_hd);
			end
			if((! rcv0_req) && rgi0_ack) begin
				rgi0_ack <= `NS_OFF;
			end

			`NS_FIFO_TO_PAKS_TRY_INC_TAIL(bf0, rgo0)
			else
			`NS_PACKOUT_TRY_INC(rgo0, snd0_ack, rgo0_req)
		end
	end
	*/
	
	`NS_DECLARE_REG_MSG(dbg_fif)
	`NS_DECLARE_REG_MSG(mg_aux1)
	`NS_DECLARE_REG_MSG(mg_aux2)
	`NS_DECLARE_REG_MSG(mg_aux3)
	
	reg [`NS_FULL_MSG_SZ-1:0] mg_data;
	
	//calc_redun #(.ASZ(ASZ), .DSZ(DSZ), .RSZ(RSZ)) 
	//	obj1 (dbg_fif_src, dbg_fif_dst, dbg_fif_dat, dbg_fif_calc_redun);

	//calc_redun #(.ASZ(ASZ), .DSZ(DSZ), .RSZ(RSZ)) 
	//	obj2 (rcv0_src, rcv0_dst, rcv0_dat, rcv0_redun);
	localparam ST_INI = 8'h20;
	localparam ST_SET = 8'h21;
	localparam ST_GET = 8'h22;
	localparam ST_CHK = 8'h23;

	reg [7:0] all_err = 0;
	reg [7:0] curr_state = ST_INI;
		
	always @(posedge dbg_clk)
	begin
		/*
		if(! reset && rg_rdy) begin
		end
		*/
		if(rcv0_req) begin
		if(dbg_doit) begin
			case(curr_state)
			//case(dbg_case)
				ST_INI :
				begin
					`NS_FIFO_INIT(bf0);
					rg_dbg_disp0 <= 7;
					rg_dbg_disp1 <= 1;
					curr_state <= ST_SET;
				end
				ST_SET :
				begin
					`NS_FIFO_SET_IDX(rcv0, bf0, 1)
					`NS_MOV_REG_MSG(mg_aux1, rcv0)
					`NS_SEQ_SET(mg_data, rcv0)
					rg_dbg_disp0 <= 7;
					rg_dbg_disp1 <= 2;
					curr_state <= ST_GET;
				end
				ST_GET :
				begin
					`NS_FIFO_GET_IDX(dbg_fif, bf0, 1)
					`NS_MOV_REG_MSG(mg_aux2, mg_aux1)
					`NS_SEQ_GET(mg_data, mg_aux3)
					rg_dbg_disp0 <= 7;
					rg_dbg_disp1 <= 3;
					curr_state <= ST_CHK;
				end
				ST_CHK:
				begin
					if(! `NS_REG_MSG_RED_EQ(dbg_fif, 3, 0, 5, 15)) begin
						all_err[0:0] <= `NS_ON;
					end
					if(! `NS_REG_MSG_RED_EQ(rcv0, 3, 2, 5, 15)) begin
						all_err[1:1] <= `NS_ON;
					end
					if(! `NS_REG_MSG_RED_EQ(mg_aux1, 3, 2, 5, 15)) begin
						all_err[2:2] <= `NS_ON;
					end
					if(! `NS_REG_MSG_RED_EQ(mg_aux2, 3, 2, 5, 15)) begin
						all_err[3:3] <= `NS_ON;
					end
					if(! `NS_REG_MSG_RED_EQ(mg_aux3, 3, 2, 5, 15)) begin
						all_err[4:4] <= `NS_ON;
					end
					rg_dbg_disp0 <= 7;
					rg_dbg_disp1 <= 4;
				end

				/*
				`NS_DBG_MSG_CASES(3, dbg_fif) 
				`NS_DBG_MSG_CASES(4, rcv0) 
				`NS_DBG_MSG_CASES(5, mg_aux1) 
				`NS_DBG_MSG_CASES(6, mg_aux2) 
				`NS_DBG_MSG_CASES(7, mg_aux3) 
				*/
				
				/*8'h51 :
				begin
					rg_dbg_disp0 <= 0;
					rg_dbg_disp1[PSZ-1:0] <= snd0_pakio;
				end*/
				
			endcase
			rg_dbg_leds[0:0] <= 0;
			rg_dbg_leds[1:1] <= 0;
			rg_dbg_leds[2:2] <= rcv0_req;
			rg_dbg_leds[3:3] <= (|  all_err);;
		end
		end
	end
	
	assign ready = rg_rdy;
	
	//out1
	assign snd0_pakio = rgo0_pakio;
	assign snd0_req = rgo0_req;

	//inp0
	assign rcv0_ack = rgi0_ack;

	`NS_ASSIGN_OUT_DBG(dbg, rg_dbg)
	
endmodule
