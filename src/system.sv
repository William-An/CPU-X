/**
 * File name:	system.sv
 * Created:	12/22/2021
 * Author:	Weili An
 * Email:	an107@purdue.edu
 * Version:	1.0 Initial Design Entry
 * Description:	Top-level entry for the CPU implementation
 */

`timescale 1ns / 100ps

`include "include/rv32ima_pkg.svh"
`include "include/datapath_if.svh"

import rv32ima_pkg::*;

module system
(
	input clk,
	input nrst
);

	// Testing synthesis size
	datapath_if dpif(clk, nrst);

	datapath dp0(dpif);

endmodule