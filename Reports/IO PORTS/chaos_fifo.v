// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Sun Nov 30 18:39:38 2025
// Host        : HOFUD running 64-bit major release  (build 9200)
// Command     : write_verilog {C:/Users/RISHIK NAIR/Downloads/To-do/FIFO_Random_Depth/chaos_fifo.v} -mode pin_planning
//               -force
// Design      : chaos_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xcvu9p-flga2104-2L-e
// --------------------------------------------------------------------------------
module chaos_fifo(current_max_depth, rd_data, wr_data, clk, empty, full, rd_en, rst_n, wr_en);
  output [10:0] current_max_depth;
  output [7:0] rd_data;
  input [7:0] wr_data;
  input clk;
  output empty;
  output full;
  input rd_en;
  input rst_n;
  input wr_en;

endmodule
