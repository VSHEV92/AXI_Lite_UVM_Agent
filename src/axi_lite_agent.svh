typedef enum {MASTER, SLAVE} agent_type_t;

class axi_lite_agent extends uvm_agent;

    `uvm_component_utils(axi_lite_agent)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase (uvm_phase phase);
    extern function void connect_phase (uvm_phase phase);
    
    agent_type_t agent_type = MASTER; 

    virtual axi_lite_if axi_lite_if_h;

    axi_lite_sequencer axi_lite_sequencer_h;
    axi_lite_driver_master axi_lite_driver_m_h;
    axi_lite_driver_slave axi_lite_driver_s_h;
    axi_lite_monitor axi_lite_monitor_h;

endclass 

// ---------------------------------------------------------------------
function void axi_lite_agent::build_phase (uvm_phase phase);

    axi_lite_sequencer_h = axi_lite_sequencer::type_id::create("axi_lite_sequencer_h", this); 

    axi_lite_monitor_h = axi_lite_monitor #(TDATA_BYTES)::type_id::create("axi_lite_monitor_h", this);
    axi_lite_monitor_h.axi_lite_if_h = this.axi_lite_if_h;
    
    if (agent_type == MASTER) begin 
        axi_lite_driver_m_h = axi_lite_driver_master #(TDATA_BYTES)::type_id::create("axi_lite_driver_m_h", this);
        axi_lite_driver_m_h.axi_lite_if_h = this.axi_lite_if_h;
    end 
    else begin
        axi_lite_driver_s_h = axi_lite_driver_slave #(TDATA_BYTES)::type_id::create("axi_lite_driver_s_h", this);
        axi_lite_driver_s_h.axi_lite_if_h = this.axi_lite_if_h;
    end

endfunction

function void axi_lite_agent::connect_phase (uvm_phase phase);
    if (agent_type == MASTER)
        axi_lite_driver_m_h.seq_item_port.connect(axi_lite_sequencer_h.seq_item_export);
    else
        axi_lite_driver_s_h.seq_item_port.connect(axi_lite_sequencer_h.seq_item_export);
endfunction
