create_design tdp_ram36k
target_device GEMINI_COMPACT_104x68
add_design_file ../rtl/on_chip_memory.v
add_simulation_file ../../../tb_test_design/TDP_RAM36K_tb.v 
set_top_testbench TDP_RAM36K_tb
set_top_module on_chip_memory
simulation_options compilation icarus rtl -DSIM
simulate rtl icarus -DSIM
analyze
synthesize delay
simulation_options compilation icarus gate
simulate gate icarus -DGATE
