class master_test_env extends uvm_env;
    `uvm_component_utils(master_test_env)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    virtual axi_lite_if axi_lite;
    
    axi_lite_agent axi_lite_agent_h;
    
    test_scoreboard test_scoreboard_h;

endclass

function void master_test_env::build_phase(uvm_phase phase);
    
    // получение интерфейсов из базы данных
    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axi_lite", axi_lite))
        `uvm_fatal("GET_DB", "Can not get axi_lite interface")
       
    // создание scoreboard
    test_scoreboard_h = test_scoreboard::type_id::create("test_scoreboard_h", this);

    // создание агентов
    axi_lite_agent_h = axi_lite_agent::type_id::create("axi_lite_agent_h", this);
    
    // выбор типов агентов
    axi_lite_agent_h.agent_type = MASTER;
    
    // соединение интерфейсов
    axi_lite_agent_h.axi_lite_if_h = this.axi_lite;
    
endfunction

function void master_test_env::connect_phase(uvm_phase phase);
    axi_lite_agent_h.axi_lite_monitor_h.analysis_port_h.connect(test_scoreboard_h.analysis_port_master);
endfunction