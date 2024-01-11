create_design sync_fifo_R36W36
target_device GEMINI_COMPACT_104x68
add_design_file ../rtl/sync_fifo_R36W36.v
add_simulation_file ../../tb_test_design/tb_sync_fifo_R36W36.v 
set_top_testbench tb_sync_fifo_R36W36
set_top_module sync_fifo_R36W36
simulation_options compilation icarus rtl -DSIM
simulate rtl icarus -DSIM
analyze
synthesize delay
simulation_options compilation icarus gate
simulate gate icarus -DGATE
catch {
    packing
}
set folderPath "./sync_fifo_R36W36/run_1/synth_1_1/impl_1_1_1/"
set folderName "simulate_pnr"
file mkdir [file join $folderPath $folderName]
set folderPath "./sync_fifo_R36W36/run_1/synth_1_1/impl_1_1_1/"
set folderName "routing"
file mkdir [file join $folderPath $folderName]
file copy -force ../../../BRAM/rs_tdp36k_post_pnr_mapping.v sync_fifo_R36W36/run_1/synth_1_1/impl_1_1_1/simulate_pnr/
file copy -force ../impl/sync_fifo_R36W36_post_route.v sync_fifo_R36W36/run_1/synth_1_1/impl_1_1_1/routing/
simulation_options compilation icarus -DPNR=1 pnr
simulate pnr icarus -DPNR
global_placement
place
route