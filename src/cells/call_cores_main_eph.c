

#include "global.h"

//----------------------------------------------------------------------------
/*! \mainpage <h1>Introduction</h1>

<p>
This selected doxy generated documentation of the <a href="https://github.com/messaging-cells/messaging-cells" target="blank">Messaging Cells</a> Library is a description of the most releveant classes and functions that 
help in the understanding of the API and inner-workig of the library. The user is encoraged to look at the source
files when in doubt about the behaviour of the library abstractions.

\warning This documentation is in alpha stage. It is missing even expected info. You are wellcome to help.

<h2>Feedback</h2>

<p>
For comments, wishes or any feedback drop them in the <a href="https://github.com/messaging-cells/messaging-cells.github.io/issues">issues</a> page of the github <a href="https://github.com/messaging-cells/messaging-cells.github.io">project</a>.

<h2>Documentation modules</h2>

<p>
This documentation is gruped in the following <a href="modules.html">modules</a> (do not confuse with the library feature to partition the user's code):

<ul>
<li>
\ref docgrp_debug_features
<li>
\ref docgrp_messaging
<li>
\ref docgrp_memory_features
<li>
\ref docgrp_addressing_features
<li>
\ref docgrp_linking_features
<li>
\ref docgrp_loading_features 
<li>
\ref docgrp_inner_working
</ul>

<h1>Examples</h1>

<p>
The following examples illustrate how to use the library:

<ol>
<li>
\ref hello_world.cpp
<li>
\ref send_msg.cpp
<li>
\ref philo.cpp
<li>
\ref docgrp_modules
</ol>

<br><br><br><br>


*/

//============================================================
/*! \defgroup docgrp_debug_features Debug features

\brief Module describing debug features

\details 
<p>
The debug features are basically two:

<ul>
<li>
All functions in \ref log.h to print and log in the host. Functions like: \ref mck_slog and \ref mck_slog2. 
<li>
Functions to get the stack trace. When calling \ref mck_get_call_stack_trace and when aborting execution by calling \ref mck_abort you get the stack trace printed in the host.
</ul>

<p>
The most simple example of usage of a log function is \ref hello_world.cpp program.

<br><br><br><br>

*/

//============================================================
/*! \defgroup docgrp_messaging Messaging

\brief Module describing messaging

\details 
<p>
Messagging is done beetween two \ref cell s by sending \ref missive s. So no messages ;)

<p>
The most simple example of messaging usage is the \ref send_msg.cpp program.

<p>
The classical more complex example of the 
<a href="https://en.wikipedia.org/wiki/Dining_philosophers_problem" target="blank">eating philosophers</a> 
is coded in the \ref philo.cpp program and shows some
\ref docgrp_addressing_features and \ref docgrp_memory_features of the library.

<p>
Messaging has deterministic behaviour. No indeterminism. Unlike the <a href="https://en.wikipedia.org/wiki/Actor_model" target="blank">Actor Model</a>. 

<p>
For a any pair of cells Cell_A and Cell_B:
<ul>
<li>
A message sent by Cell_A is always received by Cell_B only once.
<li>
Messages are always received by Cell_B in the same order they are sent by Cell_A.
<li>
Cell_A (sending) always does local core writing and Cell_B (receiving) always does remote core reading. 
No message copying.
</ul>

<br><br><br><br>


*/

//============================================================
/*! \defgroup docgrp_memory_features Memory features

\brief Module describing memory features

\details 

<h2>In-core RAM partitions</h2>

<p>
The RAM memory of each core is divided in:

<ol>
<li>
Kernel code.
<li>
Stack.
<li>
Module code. See \ref docgrp_loading_features
<li>
Dynamically allocatable memory.
</ol>

<p>
The sizes and location are configurable in the GNU link script. See \ref docgrp_linking_features.

<h2>Dynamic memory</h2>

<p>
The in-core dynamic memory is handled in a two fold way:

<h3>First time heap allocation</h3>

<p>
The first time an object is allocated the library calls external code (off-core) of the 
<a href="https://github.com/dimonomid/umm_malloc" target="blank">umm_malloc</a> allocator.

<h3>Reusing objects</h3>

<p>
Objects are never really expected to be freed (umm_free call) under normal use of the library. 
They just get acquired (see for example \ref cell::acquire) ; and when finisehd using them, they should
call the \ref agent::release method to get inited and put in a one-per-class double linked list 
(\ref grip) of available objects (see \ref agent::get_available virtual method). 

<p>
The one-per-class acquire and the \ref agent::release are small footprint methods runned from in-core memory 
(as opposed to the umm_malloc functions) that can be used in the user's high performance code.

<p>
This double folded approach to memory managment also helps to avoid bad 
referencing of objects because a \ref cell might have been \ref agent::release d but the reference is still
valid, so the code will not behave as expected (there is an error) but it will not hang.

<p> 
Functions like \ref cell::separate \ref cell::acquire are provided for base classes but the user
is expected to use macro \ref MCK_DECLARE_MEM_METHODS and macro \ref MCK_DEFINE_MEM_METHODS to declare 
and define these functions for derived classes. The macro \ref MCK_DEFINE_ACQUIRE_ALLOC can also be used for 
classes of objects that will not get \ref agent::release d and therefore do not declare an available list.

<h3>Eating Philosophers</h3>

<p>
The classical example <a href="https://en.wikipedia.org/wiki/Dining_philosophers_problem" target="blank">eating philosophers</a> for synchronizing concurrency is given in the \ref philo.cpp example program.

<br><br><br><br>


*/

//============================================================
/*! \defgroup docgrp_addressing_features Addressing features

\brief Module describing addressing convertion functions.

\details 

<p>
Addressing is handled with the help of macros and functions that help to map beetween the different
kinds of addressing of the Epiphany architecture.

<p>
Whether it is: 

<ul>
<li>
From the epiphany side (hardware addresses).
	<ol>
	<li>
	local-core. 
		<ul>
		<li>
		Zero based (without core id).
		<li>
		With local core id.
		</ul>
	<li>
	remote-core. 
	<li>
	off-core (outside of the epiphany system in the shared mem with the host)
	</ol>
<li>
From the host side (linux virtual addresses mapped to hardware addresses).
	<ol>
	<li>
	in-core. Inside the RAM of a core of the epiphany system (no register mem). 
	<li>
	off-core 
	</ol>
</ul>

<p>
The most used functions are in files \ref shared_eph3.h and \ref shared.h

<h1>Implicit addressing symmetry</h1>
<p>
In the examples it is used an implicit symmetry: The fact that two objects that are allocated in 
exactly the same order in different cores have the same local address.

<p>
For example when in the \ref mc_cores_main function of the \ref philo.cpp program, 
the line:

<pre>
	philo_core* core_dat = philo_core::acquire_alloc();
</pre>

<p>
allocates a global 'core_dat' variable it is done in every core, so all data inside will have
the same local address in every core.

<p>
So the macro \ref glb_stick will return the same local pointer in every core and that is why by 
calling \ref mc_addr_set_id with it and the id of another core as in the macro \ref get_stick 
the \ref chopstick of an other core can be addressed in orther to send it \ref missive s. 
The same happens for \ref glb_philo. 

<br><br><br><br>

*/

//============================================================
/*! \defgroup docgrp_linking_features Linking features

\brief Module describing linking features.

\details 
<p>
This group corresponds to two main areas:

<ol>
<li>
The values you can set in the link script. See example \ref mc-linker-script.ldf. See also file
\ref loader.h
<li>
The techniques used to partition your code in modules. See \ref docgrp_modules
</ol>

<br><br><br><br>

*/

//============================================================
/*! \defgroup docgrp_loading_features Loading features

\brief Module describing loading features.

\details 
<p>
This group corresponds to basically two main features:
<ul>
<li> The posibility to customize the tree that defines the order in which the library's kernel is loaded in the cores. See \ref loader.h and \ref broadcast_maps_eph.c
<li> The posibility to load different modules in different cores. See \ref docgrp_modules
</ul>

<br><br><br><br>

*/

//============================================================
/*! \defgroup docgrp_inner_working Inner-working

\brief Module describing basic inner-working of the library.

\details 

<br><br><br><br>

*/


int main() {
	mc_cores_main();
	return 0;
}

