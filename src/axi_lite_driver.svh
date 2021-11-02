// драйвер master
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
class axi_lite_driver_slave extends uvm_driver #(axi_lite_data);
    `uvm_component_utils(axi_lite_driver_slave)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern task run_phase (uvm_phase phase);

    virtual axi_lite_if intf;

    axi_lite_data trans;

    typedef bit [31:0] slave_data_t; 
    slave_data_t slave_data [slave_data_t]; // ассоциативный массив для хранения данных

    logic [2:0] prot;
    logic transaction_type;
    
endclass

task axi_lite_driver_slave::run_phase (uvm_phase phase);

    forever begin
        seq_item_port.get_next_item(trans);
        
        // ожидание адреса чтения или записи
        slave_wait_addr(trans.addr, prot, transaction_type, trans.addr_delay);
        
        // транзакция записи
        if (transaction_type) begin
            `uvm_info("Get write transaction to address %0h", trans.addr)
            slave_wait_write_data(trans.data, trans.strb, 2'b00, trans.data_delay, trans.resp_delay);  
            
            // создание новой записи в массиве, если такой элемент отсутствует
            if (slave_data.exist(trans.addr))
                slave_data[trans.addr] = '0;
            // обновление данных в массиве   

            for (int i = 0; i < 4; i++)
                if (trans.strb[i])
                    slave_data[trans.addr][i*8 +: 8] = trans.data[i*8 +: 8];

            `uvm_info("Write %0h with strobe %0b to address %0h", trans.data, trans.strb, trans.addr)        
        end

        // транзакция чтения
        if (!transaction_type) begin
            `uvm_info("Get read transaction from address %0h", trans.addr)
            // создание новой записи в массиве, если такой элемент отсутствует
            if (slave_data.exist(trans.addr))
                slave_data[trans.addr] = '0;

            slave_response_read(slave_data[trans.addr], 2'b00, trans.data_delay);
            `uvm_info("Read %0h from address %0h", trans.data, trans.addr)       
        end

        seq_item_port.item_done();
    end
endtask

