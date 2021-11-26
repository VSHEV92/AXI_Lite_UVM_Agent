// master driver
class axi_lite_driver_master extends uvm_driver #(axi_lite_data);
    `uvm_component_utils(axi_lite_driver_master)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern task run_phase (uvm_phase phase);
    
    virtual axi_lite_if intf;

    axi_lite_data trans;

endclass

task axi_lite_driver_master::run_phase (uvm_phase phase);
    bit [31:0] data;
    bit [1:0] resp;
    forever begin
        
        seq_item_port.get_next_item(trans);

        if(trans.transaction_type) begin // write transaction
            intf.master_write(trans.addr, trans.data, trans.strb, 3'b010, resp, trans.clocks_before_addr, trans.clocks_before_data, trans.clocks_before_resp);
            if(resp) 
                `uvm_error(get_type_name(), $sformatf("Get bad response %2b", resp))
            else
                `uvm_info(get_type_name(), $sformatf("Write %0h with strobe %4b to address %0h", trans.data, trans.strb, trans.addr), UVM_LOW)
        end 
        else begin // read transaction 
            intf.master_read(trans.addr, data, 3'b010, resp, trans.clocks_before_addr, trans.clocks_before_data);
            if(resp) 
                `uvm_error(get_type_name(), $sformatf("Get bad response %2b", resp))
            else
                `uvm_info(get_type_name(), $sformatf("Read data %0h from address %0h", data, trans.addr), UVM_LOW)
        end

        seq_item_port.item_done();
        
    end
endtask


// slave driver
class axi_lite_driver_slave extends uvm_driver #(axi_lite_data);
    `uvm_component_utils(axi_lite_driver_slave)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern task run_phase (uvm_phase phase);

    virtual axi_lite_if intf;

    axi_lite_data trans;

    typedef bit [31:0] slave_data_t; 
    slave_data_t slave_data [slave_data_t]; // associative array from stored data

    logic [2:0] prot;
    logic transaction_type;
    
endclass

task axi_lite_driver_slave::run_phase (uvm_phase phase);

    forever begin
        seq_item_port.get_next_item(trans);
        
        // wait addr for write or read
        intf.slave_wait_addr(trans.addr, prot, transaction_type, trans.clocks_before_addr);
        
        // write transaction
        if (transaction_type) begin
            `uvm_info(get_type_name(), $sformatf("Get write transaction to address %0h", trans.addr), UVM_LOW)
            intf.slave_wait_write_data(trans.data, trans.strb, 2'b00, trans.clocks_before_data, trans.clocks_before_resp);  
            
            // create new element, if it's not exist
            if (!slave_data.exists(trans.addr))
                slave_data[trans.addr] = '0;
            // update associative array   
            for (int i = 0; i < 4; i++)
                if (trans.strb[i])
                    slave_data[trans.addr][i*8 +: 8] = trans.data[i*8 +: 8];

            `uvm_info(get_type_name(), $sformatf("Write %0h with strobe %4b to address %0h", trans.data, trans.strb, trans.addr), UVM_LOW)        
        end

        // read transaction
        if (!transaction_type) begin
            `uvm_info(get_type_name(), $sformatf("Get read transaction from address %0h", trans.addr), UVM_LOW)
            // create new element, if it's not exist
            if (!slave_data.exists(trans.addr))
                slave_data[trans.addr] = '0;

            intf.slave_response_read(slave_data[trans.addr], 2'b00, trans.clocks_before_data);
            `uvm_info(get_type_name(), $sformatf("Read %0h from address %0h", trans.data, trans.addr), UVM_LOW)     
        end

        seq_item_port.item_done();
    end
endtask

