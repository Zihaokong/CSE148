/*
 * mips_cpu.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * The top level module for the MIPS32 processor FPGA design. The port list
 * corresponds to the pins of our target device Cyclone V SoC chip. CLOCK_50 is
 * a 50MHz reference clock input from a crystal oscillator. The actual logic
 * of the MIPS processor is inside the mips_core module. All the other logics
 * are generated with Altera Qsys (the sdram module) and you are not required
 * to understand it.
 *
 * Generally speaking, you should not change this file.
 */

//=======================================================
//  The port list is generated by Terasic System Builder
//=======================================================
`include "mips_cpu.svh"

module mips_cpu(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

	logic clk, rst_n, rst_n_core;
	logic locked;
	mem_read_ifc  i_cache_read();
	mem_write_ifc d_cache_write();
	mem_read_ifc  d_cache_read();

	pass_done_ifc pass_done();

//=======================================================
//  Structural coding
//=======================================================

	assign rst_n_core = rst_n & locked & SW[1];
	// SW[0] used as a hard reset
	// SW[1] used as a soft reset (only reset the core)

	assign LEDR[1:0] = pass_done.code;
	// Tie the output of core to the output of cpu. Otherwise all logic of the
	// core might be removed during synthesis

	/*
	 * This module is generated with qsys, which contains
	 * 1. A pll to generate a 100MHz clock from the 50MHz reference clock
	 * 2. A memory controller which communicates with IS42R16320D external sdram
	 * 3. Arbiters and buffers between mem_read/write and memory controller
	 * For detailed information about this module, please see the documentation
	 */
	sdram u0 (
		.clk_clk                              (CLOCK_50),						//                   clk.clk

		.d_cache_read_control_fixed_location  (1'b0),							//  d_cache_read_control.fixed_location
		.d_cache_read_control_read_base       (d_cache_read.control_base),		//                      .read_base
		.d_cache_read_control_read_length     (d_cache_read.control_length),	//                      .read_length
		.d_cache_read_control_go              (d_cache_read.control_go),		//                      .go
		.d_cache_read_control_done            (d_cache_read.control_done),		//                      .done
		.d_cache_read_control_early_done      (),								//                      .early_done
		.d_cache_read_user_read_buffer        (d_cache_read.user_re),			//     d_cache_read_user.read_buffer
		.d_cache_read_user_buffer_output_data (d_cache_read.user_data),			//                      .buffer_output_data
		.d_cache_read_user_data_available     (d_cache_read.user_available),	//                      .data_available

		.d_cache_write_control_fixed_location (1'b0),							// d_cache_write_control.fixed_location
		.d_cache_write_control_write_base     (d_cache_write.control_base),		//                      .write_base
		.d_cache_write_control_write_length   (d_cache_write.control_length),	//                      .write_length
		.d_cache_write_control_go             (d_cache_write.control_go),		//                      .go
		.d_cache_write_control_done           (d_cache_write.control_done),		//                      .done
		.d_cache_write_user_write_buffer      (d_cache_write.user_we),			//    d_cache_write_user.write_buffer
		.d_cache_write_user_buffer_input_data (d_cache_write.user_data),		//                      .buffer_input_data
		.d_cache_write_user_buffer_full       (d_cache_write.user_full),		//                      .buffer_full

		.i_cache_read_control_fixed_location  (1'b0),							//  i_cache_read_control.fixed_location
		.i_cache_read_control_read_base       (i_cache_read.control_base),		//                      .read_base
		.i_cache_read_control_read_length     (i_cache_read.control_length),	//                      .read_length
		.i_cache_read_control_go              (i_cache_read.control_go),		//                      .go
		.i_cache_read_control_done            (i_cache_read.control_done),		//                      .done
		.i_cache_read_control_early_done      (),								//                      .early_done
		.i_cache_read_user_read_buffer        (i_cache_read.user_re),			//     i_cache_read_user.read_buffer
		.i_cache_read_user_buffer_output_data (i_cache_read.user_data),			//                      .buffer_output_data
		.i_cache_read_user_data_available     (i_cache_read.user_available),	//                      .data_available

		.mips_core_clk_clk                    (clk),							//         mips_core_clk.clk
		.mips_core_rst_reset_n                (rst_n),							//         mips_core_rst.reset_n
		.pll_0_locked_export                  (locked),							//          pll_0_locked.export
		.reset_reset_n                        (SW[0]),							//                 reset.reset_n

		.sdram_clk_clk                        (DRAM_CLK),						//             sdram_clk.clk
		.sdram_controller_wire_addr           (DRAM_ADDR),						// sdram_controller_wire.addr
		.sdram_controller_wire_ba             (DRAM_BA),						//                      .ba
		.sdram_controller_wire_cas_n          (DRAM_CAS_N),						//                      .cas_n
		.sdram_controller_wire_cke            (DRAM_CKE),						//                      .cke
		.sdram_controller_wire_cs_n           (DRAM_CS_N),						//                      .cs_n
		.sdram_controller_wire_dq             (DRAM_DQ),						//                      .dq
		.sdram_controller_wire_dqm            ({DRAM_UDQM, DRAM_LDQM}),			//                      .dqm
		.sdram_controller_wire_ras_n          (DRAM_RAS_N),						//                      .ras_n
		.sdram_controller_wire_we_n           (DRAM_WE_N)						//                      .we_n
	);

	// This is the real 5-stage mips core
	mips_core MIPS_CORE (
		.clk, .rst_n(rst_n_core),

		.i_cache_read,
		.d_cache_write,
		.d_cache_read,

		.pass_done
	);

endmodule
