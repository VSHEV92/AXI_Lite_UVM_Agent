class slave_test_env extends uvm_env;
    `uvm_component_utils(slave_test_env)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    virtual axi_lite_if axi_lite_master;
    virtual axi_lite_if axi_lite_slave;
    
    axi_lite_agent axi_lite_agent_master;
    axi_lite_agent axi_lite_agent_slave;
    
    test_scoreboard test_scoreboard_h;

endclass

function void slave_test_env::build_phase(uvm_phase phase);
    
    // getting interfaces from a database
    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axi_lite_master", axi_lite_master))
        `uvm_fatal("GET_DB", "Can not get axi_lite_master interface")

    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axi_lite_slave", axi_lite_slave))
        `uvm_fatal("GET_DB", "Can not get axi_lite_slave interface")    
       
    // create scoreboard
    test_scoreboard_h = test_scoreboard::type_id::create("test_scoreboard_h", this);

    // create agents
    axi_lite_agent_master = axi_lite_agent::type_id::create("axi_lite_agent_master", this);
    axi_lite_agent_slave = axi_lite_agent::type_id::create("axi_lite_agent_slave", this);
    
    // set agent's types
    axi_lite_agent_master.agent_type = MASTER;
    axi_lite_agent_slave.agent_type = SLAVE;
    
    // connect interfaces
    axi_lite_agent_master.axi_lite_if_h = this.axi_lite_master;
    axi_lite_agent_slave.axi_lite_if_h = this.axi_lite_slave;
    
endfunction

function void slave_test_env::connect_phase(uvm_phase phase);
    axi_lite_agent_master.axi_lite_monitor_h.analysis_port_h.connect(test_scoreboard_h.analysis_port_master);
    axi_lite_agent_slave.axi_lite_monitor_h.analysis_port_h.connect(test_scoreboard_h.analysis_port_slave);
endfunction