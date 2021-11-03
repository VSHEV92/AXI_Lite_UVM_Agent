class master_test extends base_test;

    `uvm_component_utils(master_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    
    virtual aresetn_if aresetn;

    master_test_env test_env_h; 
    
endclass

// --------------------------------------------------------------------
function void master_test::build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    // параметры теств
    axi_lite_seqc_config.trans_numb = 500;
    axi_lite_seqc_config.max_addr_value = 128;
    axi_lite_seqc_config.min_addr_value = 0;

    test_env_h = master_test_env::type_id::create("test_env_h", this);   

    if (!uvm_config_db #(virtual aresetn_if)::get(this, "", "aresetn", aresetn))
        `uvm_fatal("GET_DB", "Can not get aresetn interface")
     
endfunction

task master_test::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
        aresetn.aresetn <= 1'b0;
        #100;
        aresetn.aresetn <= 1'b1; 
    phase.drop_objection(this);
endtask

task master_test::main_phase(uvm_phase phase);
    phase.raise_objection(this);
        axi_lite_seqc_wr.start(test_env_h.axi_lite_agent_h.axi_lite_sequencer_h);
        axi_lite_seqc_rd.start(test_env_h.axi_lite_agent_h.axi_lite_sequencer_h);  
    phase.drop_objection(this);
endtask