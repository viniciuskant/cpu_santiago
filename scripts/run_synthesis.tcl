source scripts/setup.tcl
set REPORTS_DIR "reports"
set OUTPUTS_DIR "outputs"

# Logic library setup:
set_app_var synthetic_library dw_foundation.sldb
set_app_var search_path "~/lab_cpu/rtl ${DB_PATH}"
set_app_var target_library "saed32rvt_tt1p05v25c.db" 
set_app_var link_library "* $target_library $synthetic_library"

## Cria diretório work se não existir
set work_path "./work"
if {![file isdirectory $work_path]} {
    file mkdir $work_path
}

# Limpa designs anteriores e define WORK
remove_design -all
define_design_lib WORK -path $work_path

# como inclui no search não preciso colocar a pasta, pesne no 
# search como um export no PATH
analyze -format sverilog register_bank.sv
analyze -format sverilog mux.sv
analyze -format sverilog ALU.sv
analyze -format sverilog control.sv
analyze -format sverilog memory.sv
analyze -format sverilog top.sv

elaborate top

list_designs
report_design_lib WORK

current_design top

link

Aplica constraints
create_clock -name clk -period 10.0 [find port "clk"]
set_input_delay 2.0 -clock clk [remove_from_collection [all_inputs] [get_ports "clk"]]
set_output_delay 2.0 -clock clk [all_outputs]

# se remover não terá módulos
# set compile_ultra_ungroup_dw false
# set compile_ultra_ungroup_dw_high_fanout false
# compile_ultra no_autogroup -scan
# compile_ultra 
compile

# reportar resultados
report_area > reports/area.rpt
report_timing > reports/timing.rpt
report_power > reports/power.rpt

echo "Synthesis completed successfully!"

