package test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "../src/axi_lite_include.svh"

    `include "test_scoreboard.svh"
    `include "master_test_env.svh"
    `include "slave_test_env.svh"
    
    `include "base_test.svh"
    `include "master_test.svh"
    `include "slave_test.svh"
    
endpackage