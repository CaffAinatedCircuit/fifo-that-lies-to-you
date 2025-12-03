create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_input_jitter [get_clocks -regexp -nocase .*] 0.000
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {wr_data[*]}]
set_input_delay -clock [get_clocks clk] -max -add_delay 2.000 [get_ports {wr_data[*]}]
