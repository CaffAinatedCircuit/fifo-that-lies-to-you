-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Sun Nov 30 18:39:38 2025
-- Host        : HOFUD running 64-bit major release  (build 9200)
-- Command     : write_vhdl {C:/Users/RISHIK NAIR/Downloads/To-do/FIFO_Random_Depth/chaos_fifo.vhd} -mode pin_planning
--               -force
-- Design      : chaos_fifo
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcvu9p-flga2104-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity chaos_fifo is
  Port ( 
    current_max_depth : out STD_LOGIC_VECTOR ( 10 downto 0 );
    rd_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    wr_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    clk : in STD_LOGIC;
    empty : out STD_LOGIC;
    full : out STD_LOGIC;
    rd_en : in STD_LOGIC;
    rst_n : in STD_LOGIC;
    wr_en : in STD_LOGIC
  );

end chaos_fifo;

architecture Behavioral of chaos_fifo is 
begin

end Behavioral;
