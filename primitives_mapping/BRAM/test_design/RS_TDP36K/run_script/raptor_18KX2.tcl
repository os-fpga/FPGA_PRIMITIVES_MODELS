create_design rs_tdp18kx2
target_device GEMINI_COMPACT_104x68
add_design_file ../rtl/on_chip_memory_18KX2.v
add_design_file ../../../rs_tdp36k_post_pnr_mapping.v
add_simulation_file ../../../tb_test_design/RS_TDP36K_to_TDP_RAM18KX2_tb.v 
set_top_testbench RS_TDP36K_to_TDP_RAM18KX2_tb
set_top_module on_chip_memory_18KX2
simulation_options compilation icarus rtl -DSIM
simulate rtl icarus -DSIM
analyze
synthesize delay
simulation_options compilation icarus gate
simulate gate icarus -DGATE
