#return
set clk_val 10
create_clock -period $clk_val [get_ports clk] -name clk
set_clock_uncertainty 0.3 [get_clocks clk]
# Era o do Ulisses
# set_clock_uncertainty -setup [expr $clk_val*0.1] [get_clocks clk]
set_clock_transition -max [expr $clk_val*0.1] [get_clocks clk]
set_clock_latency -source -max [expr $clk_val*0.05] [get_clocks clk]
set_clock_latency -max [expr $clk_val*0.03] [get_clocks clk]
set_clock_transition -rise 0.1 [get_clocks clk]
set_clock_transition -fall 0.1 [get_clocks clk]

set_input_delay 0.1 -clock clk [all_inputs]
set_output_delay 0.1 -clock clk [all_outputs]
# Era o do Ulisses
set_input_delay 2.0 -clock clk [get_ports [remove_from_collection [all_inputs] clk]]
set_output_delay 2.0 -clock clk [get_ports [all_outputs]]

set_load -max 0.04 [all_outputs]
set_input_transition -min [expr $clk_val*0.01] [remove_from_collection [all_inputs] clk]
set_input_transition -max [expr $clk_val*0.1] [remove_from_collection [all_inputs] clk]
#return

# # #acho que não tem muito recurso comum
# set_app_var compile_enable_resource_sharing true

# # #pode aumentar o fanout: subexpressões comuns
# set_app_var compile_new_structural_opt true

# # # minimizacao logica
# set_app_var compile_map_effort high
# set_app_var compile_area_effort high
# set_app_var compile_timing_effort high

# # # minimizacao logica FSMs testar one_hot
# set_fsm_encoding -type compact

# # set_fsm_encoding -type compact   
# fsm_compile -minimize_states

# # #pode aumentar latência, mas nesse caso não importa
# optimize_registers -design top

#"posso" usar o -ignore_tns
set_max_area 3500

set_fsm_minimize true

ungroup -all -flatten

set_optimize_registers true
optimize_netlist -area -no_boundary_optimization
# set_boundary_optimization true