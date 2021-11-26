class slave_test extends base_test;

    `uvm_component_utils(slave_test)
    function new(string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    
    slave_test_env test_env_h; 

    axi_lite_wr_sequence axi_lite_seqc_slave;
    axi_lite_sequence_config axi_lite_seqc_config_slave;
    
endclass

// --------------------------------------------------------------------
function void slave_test::build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    axi_lite_seqc_config_slave = axi_lite_sequence_config::type_id::create("axi_lite_seqc_config_slave");
    axi_lite_seqc_config_slave.trans_numb = 1000;

    axi_lite_seqc_slave = axi_lite_wr_sequence::type_id::create("axi_lite_seqc_slave", this);
    axi_lite_seqc_slave.axi_lite_seqc_config = axi_lite_seqc_config_slave;

    // test settings
    axi_lite_seqc_config.trans_numb = 500;
    axi_lite_seqc_config.max_addr_value = 128;
    axi_lite_seqc_config.min_addr_value = 0;

    test_env_h = slave_test_env::type_id::create("test_env_h", this);   
    
endfunction

task slave_test::main_phase(uvm_phase phase);
    phase.raise_objection(this);
        fork 
            begin
                axi_lite_seqc_wr.start(test_env_h.axi_lite_agent_master.axi_lite_sequencer_h);
                axi_lite_seqc_rd.start(test_env_h.axi_lite_agent_master.axi_lite_sequencer_h);
            end
            begin
                axi_lite_seqc_slave.start(test_env_h.axi_lite_agent_slave.axi_lite_sequencer_h);
            end
        join       
    phase.drop_objection(this);
endtask