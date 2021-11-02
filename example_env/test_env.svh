class test_env extends uvm_env;
    `uvm_component_utils(test_env)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    virtual axi_lite_if axi_lite;
    virtual aresetn_if aresetn;

    axi_lite_agent axi_lite_agent_h;
    
    //test_scoreboard #(TDATA_BYTES_IN) test_scoreboard_h;

endclass

function void test_env::build_phase(uvm_phase phase);
    
    // получение интерфейсов из базы данных
    if (!uvm_config_db #(virtual axi_lite_if)::get(this, "", "axis_lite", axis_lite))
        `uvm_fatal("GET_DB", "Can not get axi_lite interface")

    if (!uvm_config_db #(virtual aresetn_if)::get(this, "", "aresetn", aresetn))
        `uvm_fatal("GET_DB", "Can not get aresetn interface")
       
    // создание scoreboard
    //test_scoreboard_h = test_scoreboard #(TDATA_BYTES_IN)::type_id::create("test_scoreboard_h", this);

    // создание агентов
    axi_lite_agent_h = axi_lite_agent::type_id::create("axi_lite_agent_h", this);
    
    // выбор типов агентов
    axi_lite_agent_h.agent_type = MASTER;
    
    // соединение интерфейсов
    axi_lite_agent_h.axi_lite_if_h = this.axi_lite;
    
endfunction

function void test_env::connect_phase(uvm_phase phase);

  //  axis_agent_in_1.axis_monitor_h.analysis_port_h.connect(test_scoreboard_h.analysis_port_in_1);
  //  axis_agent_in_2.axis_monitor_h.analysis_port_h.connect(test_scoreboard_h.analysis_port_in_2);
  //  axis_agent_out.axis_monitor_h.analysis_port_h.connect(test_scoreboard_h.analysis_port_out);

endfunction