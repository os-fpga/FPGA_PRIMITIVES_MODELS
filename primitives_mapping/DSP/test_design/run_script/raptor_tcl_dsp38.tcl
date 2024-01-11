create_design dsp38_inst_design
target_device GEMINI_COMPACT_104x68
add_design_file ../rtl/dsp38_inst_design.v
add_simulation_file ../../tb_test_design/tb_dsp38_inst_design.v 
set_top_testbench tb_dsp38_inst_design
set_top_module dsp38_inst_design
simulation_options compilation icarus rtl -DSIM
simulate rtl icarus -DSIM
analyze
synthesize delay
simulation_options compilation icarus gate
simulate gate icarus -DGATE
packing
global_placement
place
route
simulation_options compilation icarus -DPNR=1 pnr
add_simulation_file ../../rs_dsp_multxxx_post_pnr_mapping.v
simulate pnr icarus -DPNR
