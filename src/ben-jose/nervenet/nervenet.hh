

/*************************************************************

This file is part of ben-jose.

ben-jose is free software: you can redistribute it and/or modify
it under the terms of the version 3 of the GNU General Public 
License as published by the Free Software Foundation.

ben-jose is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with ben-jose.  If not, see <http://www.gnu.org/licenses/>.

------------------------------------------------------------

Copyright (C) 2007-2012, 2014-2016. QUIROGA BELTRAN, Jose Luis.
Id (cedula): 79523732 de Bogota - Colombia.
See https://github.com/joseluisquiroga/ben-jose

ben-jose is free software thanks to The Glory of Our Lord 
	Yashua Melej Hamashiaj.
Our Resurrected and Living, both in Body and Spirit, 
	Prince of Peace.

------------------------------------------------------------

nervenet.hh

Declaration of nervenet class.

--------------------------------------------------------------*/

#ifndef NERVENET_H
#define NERVENET_H

#include "cell.hh"

class pre_cnf_node;
class synapse;
class nervenode;
class polaron;
class neuron;
class nervenet;

#define bj_load_cod mc_mod1_cod
#define bj_load_dat mc_mod1_dat

#define bj_stabi_cod mc_mod2_cod
#define bj_stabi_dat mc_mod2_dat

#define bj_nervenet_cod 
#define bj_nervenet_dat 
#define bj_nervenet_mem mc_mod0_cod

//define bj_nervenet_cod mc_comm_cod
//define bj_nervenet_dat mc_comm_dat

typedef long num_nod_t;
typedef uint8_t num_syn_t;

#define BJ_MAX_NODE_SZ mc_maxof(num_syn_t)

enum node_kind_t : uint8_t {
	nd_invalid = 0,
	nd_pos,
	nd_neg,
	nd_ccl
};

enum load_tok_t : mck_token_t {
	tok_invalid,
	tok_nw_syn,
	tok_end_load
};

enum bj_hdlr_idx_t : uint8_t {
	idx_invalid,
	idx_synset,
	idx_synapse,
	idx_polaron,
	idx_neuron,
	idx_nervenet,
	idx_total
};

class mc_aligned synset : public cell {
public:
	MCK_DECLARE_MEM_METHODS(synset, bj_nervenet_mem)

	synset*		parent;

	num_syn_t 	tot_syn;
	grip		all_syn;
	grip		all_grp;

	synset() bj_nervenet_cod;
	~synset() bj_nervenet_cod;

	virtual mc_opt_sz_fn 
	void init_me(int caller = 0);

	void add_left_synapse(synapse* snp);

	void stabi_handler(missive* msv) bj_stabi_cod;

	void calc_stabi_arr_rec(num_syn_t cap, num_syn_t* arr, num_syn_t& ii) bj_stabi_cod;
};

class mc_aligned synapse : public cell {
public:
	MCK_DECLARE_MEM_METHODS(synapse, bj_nervenet_mem)

	synset*		left_vessel;

	binder		right_handle;
	synset*		right_vessel;

	nervenode*	owner;
	void*		mate;

	synapse() mc_external_code_ram;
	~synapse() mc_external_code_ram;

	virtual mc_opt_sz_fn 
	void init_me(int caller = 0) mc_external_code_ram;

	void load_handler(missive* msv) bj_load_cod;
	void stabi_handler(missive* msv) bj_stabi_cod;
};

#define bj_get_syn_of_rgt_handle(bdr) ((synapse*)(((uint8_t*)bdr) - mc_offsetof(&synapse::right_handle)))

class mc_aligned neurostate {
public:
	synset			charged;

	synset			stabi_target;
	num_syn_t		stabi_num_complete;
	num_syn_t		stabi_arr_cap;
	num_syn_t		stabi_arr_sz;
	num_syn_t*		stabi_arr;

	neurostate();
	~neurostate();

	virtual mc_opt_sz_fn 
	void init_me(int caller = 0);

	void calc_stabi_arr() bj_stabi_cod;
};

class mc_aligned nervenode : public cell {
public:
	node_kind_t 	ki;
	long			id;
	num_syn_t		sz;

	neurostate		left_side;
	neurostate		right_side;

	nervenode() mc_external_code_ram;
	~nervenode() mc_external_code_ram;

	virtual mc_opt_sz_fn 
	void init_me(int caller = 0) mc_external_code_ram;

	void init_nervenode_with(pre_cnf_node* nod) bj_load_cod;
};

class mc_aligned neuron : public nervenode {
public:
	MCK_DECLARE_MEM_METHODS(neuron, bj_nervenet_mem)
	
	neuron() mc_external_code_ram;
	~neuron() mc_external_code_ram;

	void stabi_handler(missive* msv) bj_stabi_cod;

	void stabi_neuron_start() bj_stabi_cod;
};

class mc_aligned polaron : public nervenode {
public:
	MCK_DECLARE_MEM_METHODS(polaron, bj_nervenet_mem)
	
	polaron*		opp;

	neuron*		left_src;
	neuron*		right_src;

	polaron() mc_external_code_ram;
	~polaron() mc_external_code_ram;

	virtual mc_opt_sz_fn 
	void init_me(int caller = 0) mc_external_code_ram;

	void load_handler(missive* msv) bj_load_cod;
	void stabi_handler(missive* msv) bj_stabi_cod;
};

#define MAGIC_VAL 987654

class mc_aligned nervenet : public cell  {
public:
	MCK_DECLARE_MEM_METHODS(nervenet, bj_nervenet_mem)

	long MAGIC;

	grip		ava_synsets;
	grip		ava_synapses;
	grip		ava_polarons;
	grip		ava_neurons;

	missive_handler_t all_handlers[idx_total];

	nervenet*	shd_cnf;

	num_nod_t tot_neus;
	num_nod_t tot_vars;
	num_nod_t tot_lits;
	num_nod_t tot_rels;

	num_nod_t tot_loading;
	num_nod_t tot_loaded;

	grip	all_neu;
	grip	all_pos;
	grip	all_neg;

	nervenet() mc_external_code_ram;
	~nervenet() mc_external_code_ram;

	void init_nervenet_with(nervenet* nvnet) mc_external_code_ram;

	void stabi_handler(missive* msv) bj_stabi_cod;

	void stabi_nervenet_start() bj_stabi_cod;
};

#define bj_nervenet ((nervenet*)(kernel::get_sys()->user_data))
#define bj_ava_synsets (bj_nervenet->ava_synsets)
#define bj_ava_synapses (bj_nervenet->ava_synapses)
#define bj_ava_polarons (bj_nervenet->ava_polarons)
#define bj_ava_neurons (bj_nervenet->ava_neurons)

#define bj_handlers (bj_nervenet->all_handlers)

#define BJ_DEFINE_nervenet_methods() \
nervenet::nervenet(){ \
		MAGIC = MAGIC_VAL; \
\
		handler_idx = idx_nervenet; \
\
		mc_init_arr_vals(idx_total, all_handlers, mc_null); \
\
		shd_cnf = mc_null; \
\
		tot_neus = 0; \
		tot_vars = 0; \
		tot_lits = 0; \
		tot_rels = 0; \
\
		tot_loading = 0; \
		tot_loaded = 0; \
	} \
\
nervenet::~nervenet(){} \

// end of BJ_DEFINE_nervenet_methods

extern missive_handler_t bj_nil_handlers[];

void bj_print_loaded_poles(grip& all_pol, node_kind_t ki) mc_external_code_ram;
void bj_print_loaded_cnf() mc_external_code_ram;


#endif		// NERVENET_H

