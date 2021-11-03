`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)

class test_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(test_scoreboard)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase (uvm_phase phase);
    extern function void final_phase (uvm_phase phase);
    
    extern virtual function void write_master (axi_lite_data axi_lite_data_h);
    extern virtual function void write_slave (axi_lite_data axi_lite_data_h);
    
    uvm_analysis_imp_master #(axi_lite_data, test_scoreboard) analysis_port_master;
    uvm_analysis_imp_slave #(axi_lite_data, test_scoreboard) analysis_port_slave;
    
    axi_lite_data axi_lite_queue_master[$]; // очередь для транзакция от master
    axi_lite_data axi_lite_queue_slave[$]; // очередь для транзакция от slave

    typedef bit [31:0] slave_data_t; 
    slave_data_t slave_data [slave_data_t]; // ассоциативный массив для хранения данных

    bit test_result = 1'b1;

endclass

// -------------------------------------------------------------------
function void test_scoreboard::build_phase (uvm_phase phase);
    analysis_port_master = new("analysis_port_master", this);
    analysis_port_slave = new("analysis_port_slave", this);
endfunction

function void test_scoreboard::final_phase (uvm_phase phase);
    axi_lite_data master_trans, slave_trans;
    
    while (axi_lite_queue_slave.size()) begin
        master_trans = axi_lite_queue_master.pop_front();
        slave_trans = axi_lite_queue_slave.pop_front();
        // сравниваем транзакции slave и master
        if (slave_trans.compare(master_trans))
            `uvm_info("PASS", slave_trans.convert2string(), UVM_LOW)
        else begin
            `uvm_error(
                get_type_name(), {"Transaction mismatch! \n",
                                "Slave: ", slave_trans.convert2string(), "\n",
                                "Master: ", master_trans.convert2string()}
            )
            test_result = 1'b0;
        end    
    end

    if (test_result)
        `uvm_info("RESULT", "TEST RESULT: PASS", UVM_LOW)
    else
        `uvm_info("RESULT", "TEST RESULT: FAIL", UVM_LOW)
endfunction

function void test_scoreboard::write_master (axi_lite_data axi_lite_data_h);
    axi_lite_data master_trans = axi_lite_data::type_id::create("master_trans");
    master_trans.copy(axi_lite_data_h);
    axi_lite_queue_master.push_back(master_trans);

    // если получена транзакция записи, то сохраняем данные
    if (axi_lite_data_h.transaction_type) begin
        `uvm_info(get_type_name(), $sformatf("Write %0h with strobe %4b to address %0h", axi_lite_data_h.data, axi_lite_data_h.strb, axi_lite_data_h.addr), UVM_LOW)
            
        // создание новой записи в массиве, если такой элемент отсутствует
        if (!slave_data.exists(axi_lite_data_h.addr))
            slave_data[axi_lite_data_h.addr] = '0;
        // обновление данных в массиве   

        for (int i = 0; i < 4; i++) 
            if (axi_lite_data_h.strb[i]) 
                slave_data[axi_lite_data_h.addr][i*8 +: 8] = axi_lite_data_h.data[i*8 +: 8];
        
        `uvm_info(get_type_name(), $sformatf("Gold data in address %0h is %0h", axi_lite_data_h.addr, slave_data[axi_lite_data_h.addr]), UVM_LOW)        
    end

    // если получена транзакция чтения, то сравниваем полученные данные
    if (!axi_lite_data_h.transaction_type) begin
        `uvm_info(get_type_name(), $sformatf("Read %0h from address %0h", axi_lite_data_h.data, axi_lite_data_h.addr), UVM_LOW)
        
        // создание новой записи в массиве, если такой элемент отсутствует
        if (!slave_data.exists(axi_lite_data_h.addr))
            slave_data[axi_lite_data_h.addr] = '0;

        // сравнение данных
        if (slave_data[axi_lite_data_h.addr] != axi_lite_data_h.data) begin
            `uvm_error(get_type_name(), $sformatf("Data mismatch! Addr:%0h, Read: %0h, Gold: %0h", axi_lite_data_h.addr, axi_lite_data_h.data, slave_data[axi_lite_data_h.addr]))    
            test_result = 1'b0;
        end
        else
            `uvm_info("PASS", axi_lite_data_h.convert2string(), UVM_LOW)
    end

endfunction

function void test_scoreboard::write_slave (axi_lite_data axi_lite_data_h);
    axi_lite_data slave_trans = axi_lite_data::type_id::create("slave_trans");
    slave_trans.copy(axi_lite_data_h);
    axi_lite_queue_slave.push_back(slave_trans);

endfunction
