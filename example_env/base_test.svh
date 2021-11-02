class base_test extends uvm_test;

    `uvm_component_utils(base_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task shutdown_phase(uvm_phase phase);
    
    virtual aresetn_if aresetn;

    test_env test_env_h; 

    axi_lite_wr_sequence axi_lite_seqc_wr;
    axi_lite_rd_sequence axi_lite_seqc_rd;
    
    axi_lite_sequence_config axi_lite_seqc_config;
    
endclass

// --------------------------------------------------------------------
function void base_test::build_phase(uvm_phase phase);
    
    axi_lite_seqc_wr = axi_lite_wr_sequence::type_id::create("axi_lite_seqc_wr", this);
    axi_lite_seqc_rd = axi_lite_rd_sequence::type_id::create("axi_lite_seqc_rd", this);
    
    test_env_h = test_env::type_id::create("test_env_h", this);   

    axi_lite_seqc_config = axi_lite_sequence_config::type_id::create("axi_lite_seqc_config");
    
    axi_lite_seqc_wr.axi_lite_seqc_config = axi_lite_seqc_config;
    axi_lite_seqc_rd.axi_lite_seqc_config = axi_lite_seqc_config;

    if (!uvm_config_db #(virtual aresetn_if)::get(this, "", "aresetn", aresetn))
        `uvm_fatal("GET_DB", "Can not get aresetn interface")
     
endfunction

task base_test::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
        aresetn.aresetn <= 1'b0;
        #100;
        aresetn.aresetn <= 1'b1; 
    phase.drop_objection(this);
endtask


task base_test::main_phase(uvm_phase phase);
    phase.raise_objection(this);
        axi_lite_seqc_wr.start(test_env_h.axi_lite_agent_h.axi_lite_sequencer_h);
        axi_lite_seqc_rd.start(test_env_h.axi_lite_agent_h.axi_lite_sequencer_h);  
    phase.drop_objection(this);
endtask

task base_test::shutdown_phase(uvm_phase phase);
    phase.raise_objection(this);
        #1000;    
    phase.drop_objection(this);
endtask