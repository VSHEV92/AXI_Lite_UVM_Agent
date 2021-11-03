class base_test extends uvm_test;

    `uvm_component_utils(base_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task shutdown_phase(uvm_phase phase);
    
    axi_lite_wr_sequence axi_lite_seqc_wr;
    axi_lite_rd_sequence axi_lite_seqc_rd;
    
    axi_lite_sequence_config axi_lite_seqc_config;
    
endclass

// --------------------------------------------------------------------
function void base_test::build_phase(uvm_phase phase);
    
    axi_lite_seqc_wr = axi_lite_wr_sequence::type_id::create("axi_lite_seqc_wr", this);
    axi_lite_seqc_rd = axi_lite_rd_sequence::type_id::create("axi_lite_seqc_rd", this);
    
    axi_lite_seqc_config = axi_lite_sequence_config::type_id::create("axi_lite_seqc_config");
    
    axi_lite_seqc_wr.axi_lite_seqc_config = axi_lite_seqc_config;
    axi_lite_seqc_rd.axi_lite_seqc_config = axi_lite_seqc_config;
     
endfunction

task base_test::shutdown_phase(uvm_phase phase);
    phase.raise_objection(this);
        #1000;    
    phase.drop_objection(this);
endtask