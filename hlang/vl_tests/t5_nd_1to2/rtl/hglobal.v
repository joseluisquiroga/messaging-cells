
`ifndef HGLOBAL_V_FILE
`define HGLOBAL_V_FILE 1
//--------------------------------------------

`define ON 1
`define OFF 0

`define TRUE 1
`define FALSE 0

`define bit_toggle(bb) bb <= ~bb

`define f_10HZ 1250000
`define f_5HZ 2500000
`define f_2HZ 6250000
`define f_1HZ 12500000
	
`define ADDRESS_SIZE 6
`define DATA_SIZE 4

`define MSG_DATA_1 5
`define MSG_DATA_2 7

`define GT_OP 1
`define GTE_OP 2
`define LT_OP 3
`define LTE_OP 4
`define EQ_OP 5

`define CMP_OP(op, pm1, pm2) ( \
	(op == `GT_OP)? \
		((pm1) > (pm2)):( \
	(op == `GTE_OP)? \
		((pm1) >= (pm2)):( \
	(op == `LT_OP)? \
		((pm1) < (pm2)):( \
	(op == `LTE_OP)? \
		((pm1) <= (pm2)):( \
		(pm1) == (pm2) \
	))))) 
	

`define RANGE_CMP_OP(is_dbl, op1, pm1, pm2, op2, pm3, pm4) ( \
	(is_dbl == `TRUE)?(`CMP_OP(op1, pm1, pm2) && `CMP_OP(op2, pm3, pm4)):(`CMP_OP(op1, pm1, pm2)) )

	
`define COPY_MSG(addr_src, data_src, addr_dst, data_dst) \
	addr_dst <= addr_src; \
	data_dst <= data_src; 

	
//--------------------------------------------
`endif // HGLOBAL_V_FILE
