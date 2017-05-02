/*
  File: e-loader.c

  This file is part of the Epiphany Software Development Kit.

  Copyright (C) 2013 Adapteva, Inc.
  See AUTHORS for list of contributors.
  Support e-mail: <support@adapteva.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  and the GNU Lesser General Public License along with this program,
  see the files COPYING and COPYING.LESSER.  If not, see
  <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <err.h>
#include <elf.h>
#include <inttypes.h>

#include "e-hal.h"
#include "core_loader_znq.h"
//include "esim-target.h"
#include "shared.h"
#include "booter.h"

bool LOAD_WITH_MEMCPY = false;

void ee_get_coords_from_id(e_epiphany_t *dev, unsigned coreid,
								  unsigned *row, unsigned *col);


extern e_platform_t e_platform;

e_return_stat_t bjl_load_elf(int row, int col, load_info_t *ld_dat);

bjl_loader_diag_t bjl_load_verbose = L_D3;

void
bj_ck_memload(uint8_t* dst, uint8_t* src, size_t sz){
	bool ok = true;
	for(long aa = 0; aa < sz; aa++){
		if(dst[aa] != src[aa]){
			ok = false;
			break;
		}
	}
	if(! ok){
		bjh_write_file("SOURCE_shd_mem_dump.dat", src, sz, false);
		bjh_write_file("DEST_shd_mem_dump.dat", dst, sz, false);
		bjh_abort_func(9, "bj_ck_memload() FAILED !! CODE_LOADING_FAILED !!\n");
	}
}

uint8_t*
bj_memload(uint8_t* dest, const uint8_t* src, bj_size_t sz){
	bj_size_t idx = 0;
	for(idx = 0; idx < sz; idx++){
		bj_set_off_chip_var(dest[idx], src[idx]);
	}
	return dest;
}

#define EM_ADAPTEVA_EPIPHANY   0x1223  /* Adapteva's Epiphany architecture.  */
bool bjl_is_epiphany_exec_elf(Elf32_Ehdr *ehdr)
{
	bool ok = true;
	if(! ehdr){ 
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "bjl_is_epiphany_exec_elf(): ERROR_1\n"); }
		return false;
	}
	if(memcmp(ehdr->e_ident, ELFMAG, SELFMAG) != 0){ 
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "bjl_is_epiphany_exec_elf(): NOT ELFMAG\n"); }
		ok = false;
	}
	if(ehdr->e_ident[EI_CLASS] != ELFCLASS32){
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "bjl_is_epiphany_exec_elf(): NOT ELFCLASS32\n"); }
		ok = false;
	}
	if(ehdr->e_type != ET_EXEC){
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "bjl_is_epiphany_exec_elf(): NOT ET_EXEC\n"); }
		ok = false;
	}
	if(ehdr->e_version != EV_CURRENT){
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "bjl_is_epiphany_exec_elf(): NOT EV_CURRENT\n"); }
		ok = false;
	}
	if(ehdr->e_machine != EM_ADAPTEVA_EPIPHANY){
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "bjl_is_epiphany_exec_elf(): NOT EM_ADAPTEVA_EPIPHANY\n"); }
		ok = false;
	}

	return ok;
}

static void bjl_clear_sram(e_epiphany_t *dev, unsigned row, unsigned col,unsigned rows, unsigned cols)
{
	unsigned i, j;
	size_t sram_size;
	void *empty;

	/* Assume one chip type */
	sram_size = e_platform.chip[0].sram_size;

	empty = alloca(sram_size);
	memset(empty, 0, sram_size);

	for (i = row; i < row + rows; i++){
		for (j = col; j < col + cols; j++){
			e_write(dev, i, j, 0, empty, sram_size);
		}
	}
}

int bj_load_group(load_info_t *ld_dat){

	e_mem_t      emem;
	unsigned int irow, icol;
	int          status;
	int          fd;
	struct stat  st;
	void        *file;
	e_return_stat_t retval;

	e_set_host_verbosity(H_D0);

	const char *executable = ld_dat->executable;
	e_epiphany_t *dev = ld_dat->dev;
	unsigned row = ld_dat->row;
	unsigned col = ld_dat->col;
	unsigned rows = ld_dat->rows;
	unsigned cols = ld_dat->cols;

	status = E_OK;
	bj_link_syms_data_st* lk_dat = &(BJ_EXTERNAL_RAM_LOAD_DATA);

	if (!dev) {
		warnx("ERROR: Can't connect to Epiphany or external memory.\n");
		return E_ERR;
	}

	// Allocate External DRAM for the epiphany executable code
	// TODO: this is barely scalable. Really need to test ext. mem size to load
	// and possibly split the ext. mem accesses into 1MB chunks.

	if (e_alloc(&emem, 0, lk_dat->extnl_ram_size)) {
		warnx("\nERROR: Can't allocate external memory buffer!\n\n");
		return E_ERR;
	}

	fd = open(executable, O_RDONLY);
	if (fd == -1) {
		warnx("ERROR: Can't open executable file \"%s\".\n", executable);
		e_free(&emem);
		return E_ERR;
	}

	if (fstat(fd, &st) == -1) {
		warnx("ERROR: Can't stat file \"%s\".\n", executable);
		close(fd);
		e_free(&emem);
		return E_ERR;
    }

	file = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (file == MAP_FAILED) {
		warnx("ERROR: Can't mmap file \"%s\".\n", executable);
		close(fd);
		e_free(&emem);
		return E_ERR;
    }
	
	uint8_t* pt_mem_start = (uint8_t*)(emem.base);
	uint8_t* pt_mem_end = pt_mem_start + lk_dat->extnl_ram_size;
	uint8_t* pt_file_start = (uint8_t*)(file);
	uint8_t* pt_file_end = pt_mem_start + st.st_size;
	bjl_diag(L_D3) {
		fprintf(BJ_STDERR, "load_group(): mem_beg=%p end=%p file_beg=%p end=%p\n",
				pt_mem_start, pt_mem_end, pt_file_start, pt_file_end); 
	}

	if (bjl_is_epiphany_exec_elf((Elf32_Ehdr *) file)) {
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "load_group(): loading ELF file %s ...\n", executable); }
	} else {
		bjl_diag(L_D1) { fprintf(BJ_STDERR, "load_group(): ERROR: unidentified file format\n"); }
		warnx("ERROR: Can't load executable file: unidentified format.\n");
		status = E_ERR;
		goto out;
	}

	bjl_clear_sram(dev, row, col, rows, cols);

	ld_dat->file = file;
	ld_dat->emem = &emem;

	for (irow=row; irow<(row+rows); irow++) {
		for (icol=col; icol<(col+cols); icol++) {
			retval = bjl_load_elf(irow, icol, ld_dat);

			if (retval == E_ERR) {
				warnx("ERROR: Can't load executable file \"%s\".\n", executable);
				status = E_ERR;
				goto out;
			}
		}
	}

	bjl_diag(L_D1) { fprintf(BJ_STDERR, "load_group(): done loading.\n"); }

out:
	munmap(file, st.st_size);
	close(fd);
	e_free(&emem);

	return status;
}

#define BJL_COREID(_addr) ((_addr) >> 20)
static inline bool bjl_is_local(uint32_t addr)
{
	return BJL_COREID(addr) == 0;
}

static bool bjl_is_valid_addr(uint32_t addr)
{
	return bjl_is_local(addr)
		|| e_is_addr_on_chip((void *) addr)
		|| e_is_addr_in_emem(addr);
}

static bool bjl_is_valid_range(uint32_t from, uint32_t size)
{
	/* Always allow empty range */
	if (!size)
		return true;

	return bjl_is_valid_addr(from) && bjl_is_valid_addr(from + size - 1);
}

e_return_stat_t
bjl_load_elf(int row, int col, load_info_t *ld_dat)
{
	int ii;
	Elf32_Ehdr *ehdr;
	Elf32_Phdr *phdr;
	Elf32_Shdr *shdr, *sh_strtab;
	const char *strtab;
	bool       islocal, isonchip, isexternal;
	int        ihdr;
	unsigned  globrow, globcol;
	unsigned   coreid;
	uintptr_t  dst;
	/* TODO: Make src const (need fix in esim.h first) */

	e_mem_t *emem = ld_dat->emem;
	uint8_t   *src = (uint8_t *) ld_dat->file;

	e_epiphany_t *dev = ld_dat->dev;
	bj_link_syms_data_st* lk_dat = &(BJ_EXTERNAL_RAM_LOAD_DATA);

	BJL_MARK_USED(phdr);
	BJL_MARK_USED(ihdr);
	BJL_MARK_USED(shdr);
	BJL_MARK_USED(sh_strtab);
	BJL_MARK_USED(strtab);

	islocal  = false;
	isonchip = false;
	isexternal = false;
	BJL_MARK_USED(isexternal);

	ehdr = (Elf32_Ehdr *) &src[0];
	phdr = (Elf32_Phdr *) &src[ehdr->e_phoff];
	shdr = (Elf32_Shdr *) &src[ehdr->e_shoff];
	int shnum = ehdr->e_shnum;

	sh_strtab = &shdr[ehdr->e_shstrndx];
	strtab = (char *) &src[sh_strtab->sh_offset];

	for (ii = 0; ii < shnum; ii++) {
		if (!bjl_is_valid_range(shdr[ii].sh_addr, shdr[ii].sh_size)){
			return E_ERR;
		}
	}

	for (ii = 0; ii < shnum; ii++) {
		Elf32_Addr ld_addr = shdr[ii].sh_addr;
		Elf32_Word ld_sz = shdr[ii].sh_size;
		Elf32_Word ld_src_sz = shdr[ii].sh_size;
		Elf32_Off  ld_src_off = shdr[ii].sh_offset;
		Elf32_Word ld_tp = shdr[ii].sh_type;
		Elf32_Word ld_flags = shdr[ii].sh_flags;

		const char* sect_nm = &strtab[shdr[ii].sh_name];

		/* Nothing to do if section is empty */
		if(ld_sz == 0){
			continue;
		}

		if(ld_tp != SHT_PROGBITS){
			continue;
		}

		if((ld_flags & SHF_ALLOC) != SHF_ALLOC){
			continue;
		}

		islocal = bjl_is_local(ld_addr);
		isonchip = islocal ? true
						   /* TODO: Don't cast to void */
						   : e_is_addr_on_chip((void *) ((uintptr_t) ld_addr));
		isexternal = false;

		bjl_diag(L_D3) {
			fprintf(BJ_STDERR, "%d. process_elf(): SECTION %s copying the data (%d bytes)",
					ii, sect_nm, ld_src_sz); }

		/* Address calculation */
		char* dbg_case = "(undef)";
		if (islocal) {
			bjl_diag(L_D3) { dbg_case = "(local)"; 
					fprintf(BJ_STDERR, "%d.(local) to core (%d,%d)\n", ii, row, col); }

			// TODO: should this be p_paddr instead of p_vaddr?
			dst = ((uintptr_t) dev->core[row][col].mems.base)
				+ ld_addr;
		} else if (isonchip) {
			coreid = ld_addr >> 20;

			ee_get_coords_from_id(dev, coreid, &globrow, &globcol);
			bj_core_co_t g_ro = bj_id_to_ro(coreid);
			bj_core_co_t g_co = bj_id_to_co(coreid);
			BJH_CK(g_ro == globrow);
			BJH_CK(g_co == globcol);

			bjl_diag(L_D3) { dbg_case = "(onchip)"; 
				fprintf(BJ_STDERR, "%d.(onchip) to core (%d,%d)\n", ii, globrow, globcol); }
			// TODO: should this be p_paddr instead of p_vaddr?
			dst = ((uintptr_t) dev->core[globrow][globcol].mems.base) + (ld_addr & 0x000fffff);
		} else {
			isexternal = true;
			// If it is not on an eCore, it's in external memory.
			dst = ld_addr - emem->ephy_base + (uintptr_t) emem->base;
			bjl_diag(L_D3) { dbg_case = "(external)"; 
				fprintf(BJ_STDERR,
						"%d. process_elf(): (external) converting virtual (%p) to physical (%p)...\n", ii, 
						(void*) ld_addr,
						(void*) dst); }

		}

		/* Write */
		uint8_t* pt_dst = (void *) dst;
		uint8_t* pt_src = &src[ld_src_off];
		size_t blk_sz = ld_src_sz;

		uint8_t* pt_dst_end = pt_dst + blk_sz;
		uint8_t* pt_src_end = pt_src + blk_sz;

		uint8_t* pt_ram_base = (uint8_t*)(emem->base);
		uint8_t* pt_end_code = (pt_ram_base + lk_dat->extnl_data_disp);
		uint8_t* pt_end_mem = (pt_ram_base + lk_dat->extnl_ram_size);
		BJL_MARK_USED(pt_end_code);
		BJL_MARK_USED(pt_end_mem);

		bjl_diag(L_D1) { fprintf(BJ_STDERR, 
				"%d.LOADING(%s). row=%d col=%d dst=%p end=%p src=%p end=%p sz=%d p_vaddr=%04x (%p).\n", 
				ii, dbg_case, row, col, pt_dst, pt_dst_end, pt_src, pt_src_end, blk_sz, ld_addr, 
				(void*)ld_addr); 
		}

		/*if(isexternal){
			if(pt_dst_end > pt_end_code){
				bjl_diag(L_D3) {
					fprintf(BJ_STDERR,
							"%d.process_elf(): SKIP section %s virtual (%p) to physical (%p). SIZE=%u\n",
							ii, sect_nm, (void*) ld_addr, (void*) dst, blk_sz); 
				}
				continue;	// Its data (an structure) NOT code.
			}
		}*/

		if(LOAD_WITH_MEMCPY){
			memcpy(pt_dst, pt_src, blk_sz);
		} else {
			bj_memload(pt_dst, pt_src, blk_sz);
		}

		bj_ck_memload(pt_dst, pt_src, blk_sz);	// LEAVE THIS. IT CAN FAIL !!!!

		//memcpy((void *) dst, &src[ld_src_off], ld_src_sz);
	}

	return E_OK;
}


