
// attribute.h

#ifndef BJ_ATTRIBUTE_H
#define BJ_ATTRIBUTE_H

#ifdef __cplusplus
extern "C"
{
#endif

//======================================================================
// function attibutes

// Use with static when needed

#ifdef IS_EMU_CODE
	#define bj_opt_sz_fn 
	#define bj_no_opt_fn 
	// define bj_inline_fn inline 
	#define bj_inline_fn inline __attribute__((always_inline)) 
	#define bj_isr_fn 
	#define bj_asm(code) 
	#define bj_section(sec)
	#define bj_align(aa)
	#define bj_code_dram 
#else //IS_EMU_CODE

#define bj_opt_sz_fn __attribute__((optimize("Os")))
#define bj_no_opt_fn __attribute__((optimize("O0")))
#define bj_inline_fn inline __attribute__((always_inline)) 

#ifdef IS_CORE_CODE
	#define bj_isr_fn __attribute__((interrupt)) 
#else
	#define bj_isr_fn 
#endif

#define bj_asm __asm__ __volatile__

#define bj_section(sec) __attribute__ ((section (sec)))
#define bj_align(aa)	__attribute__ ((aligned (aa)))
	
#ifdef IS_CORE_CODE
	#define bj_code_dram bj_section("code_dram")
#else
	#define bj_code_dram 
#endif

#endif	//IS_EMU_CODE
	
#ifdef __cplusplus
}
#endif

#endif // BJ_ATTRIBUTE_H

