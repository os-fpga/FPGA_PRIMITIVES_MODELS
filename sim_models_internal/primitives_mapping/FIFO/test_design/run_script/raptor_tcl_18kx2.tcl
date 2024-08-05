create_design sync_split_fifo_R18W18_R9W9
target_device GEMINI_COMPACT_104x68
add_design_file ../rtl/sync_split_fifo_R18W18_R9W9.v
add_simulation_file ../../tb_test_design/tb_sync_split_fifo_R18W18_R9W9.v 
set_top_testbench tb_sync_split_fifo_R18W18_R9W9
set_top_module sync_split_fifo_R18W18_R9W9
simulation_options compilation icarus rtl -DSIM
simulate rtl icarus -DSIM
analyze
synthesize delay
simulation_options compilation icarus gate
simulate gate icarus -DGATE
catch {
    packing
}
set folderPath "./sync_split_fifo_R18W18_R9W9/run_1/synth_1_1/impl_1_1_1/"
set folderName "simulate_pnr"
file mkdir [file join $folderPath $folderName]
set folderPath "./sync_split_fifo_R18W18_R9W9/run_1/synth_1_1/impl_1_1_1/"
set folderName "routing"
file mkdir [file join $folderPath $folderName]
file copy -force ../../../BRAM/rs_tdp36k_post_pnr_mapping.v sync_split_fifo_R18W18_R9W9/run_1/synth_1_1/impl_1_1_1/simulate_pnr/
file copy -force ../impl/sync_split_fifo_R18W18_R9W9_post_route.v sync_split_fifo_R18W18_R9W9/run_1/synth_1_1/impl_1_1_1/routing/
simulation_options compilation icarus -DPNR=1 pnr
simulate pnr icarus -DPNR
global_placement
place
route