// драйвер master
class axi_lite_driver_master extends uvm_driver #(axi_lite_data);
    `uvm_component_utils(axi_lite_driver_master)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern task run_phase (uvm_phase phase);
    
    virtual axi_lite_if intf;

    axi_tite_data trans;

endclass

task axi_lite_driver_master::run_phase (uvm_phase phase);
    bit [31:0] data;
    bit [1:0] resp;
    forever begin
        
        seq_item_port.get_next_item(trans);

        if(trans.transaction_type) begin // транзакция записи
            intf.master_write(trans.addr, trans.data, trans.strb, 3'b010, resp, trans.clocks_before_addr, trans.clocks_before_data, trans.clocks_before_resp);
            if(!resp) 
                `uvm_error("BAD RESP", "Get bad response %0b", resp)
        end 
        else begin // транзакция чтения 
            intf.master_read(trans.addr, data, 3'b010, resp, trans.clocks_before_addr, trans.clocks_before_data,);
            if(!resp) 
                `uvm_error("BAD RESP", "Get bad response %0b", resp)
                else
            `uvm_info("Read data %0h from address %0h", data, trans.addr)
        end

        seq_item_port.item_done();
        
    end
endtask



// драйвер slave
class axis_driver_slave #(int TDATA_BYTES = 1) extends uvm_driver #(axis_data);
    `uvm_component_utils(axis_driver_slave #(TDATA_BYTES))
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern task run_phase (uvm_phase phase);

    virtual axis_if #(TDATA_BYTES) axis_if_h;

    axis_data axis_data_h;
    
endclass

task axis_driver_slave::run_phase (uvm_phase phase);
    forever begin
        bit [TDATA_BYTES*8-1:0] data;
        seq_item_port.get_next_item(axis_data_h);
        axis_if_h.read(data, axis_data_h.clock_before_tready);
        seq_item_port.item_done();
    end
endtask

