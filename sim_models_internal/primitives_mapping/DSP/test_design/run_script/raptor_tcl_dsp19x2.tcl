create_design dsp19x2_inst_design
target_device GEMINI_COMPACT_104x68
add_design_file ../rtl/dsp19x2_inst_design.v
add_simulation_file ../../tb_test_design/tb_dsp19x2_inst_design.v 
set_top_testbench tb_dsp19x2_inst_design
set_top_module dsp19x2_inst_design
simulation_options compilation icarus rtl -DSIM
simulate rtl icarus -DSIM
analyze
synthesize delay
simulation_options compilation icarus gate
catch {
    simulate gate icarus -DGATE
    packing
}
set folderPath "./dsp19x2_inst_design/run_1/synth_1_1/impl_1_1_1/"
set folderName "simulate_pnr"
file mkdir [file join $folderPath $folderName]
set folderPath "./dsp19x2_inst_design/run_1/synth_1_1/impl_1_1_1/"
set folderName "routing"
file mkdir [file join $folderPath $folderName]
file copy -force ../../../BRAM/rs_tdp36k_post_pnr_mapping.v dsp19x2_inst_design/run_1/synth_1_1/impl_1_1_1/simulate_pnr/
file copy -force ../impl/dsp19x2_inst_design_post_route.v dsp19x2_inst_design/run_1/synth_1_1/impl_1_1_1/routing/
simulation_options compilation icarus -DPNR=1 pnr
add_simulation_file ../../rs_dsp_multxxx_post_pnr_mapping.v
simulate pnr icarus -DPNR
global_placement
place
route