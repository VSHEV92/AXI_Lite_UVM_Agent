class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern function void build_phase (uvm_phase phase);
    extern task run_phase (uvm_phase phase);
    extern task monitor_write();
    extern task monitor_read();
    extern task get_addr (output bit [31:0] addr, input bit transaction_type);
    extern task get_data (output bit [31:0] data, output bit [3:0] strb, input bit transaction_type);
    
    virtual axi_lite_if intf;

    axi_lite_data wtrans, rtrans;

    uvm_analysis_port #(axi_lite_data) analysis_port_h; 

endclass

// ---------------------------------------------------------------------
function void axi_lite_monitor::build_phase (uvm_phase phase);
    analysis_port_h = new("analysis_port_h", this);
endfunction


task axi_lite_monitor::run_phase (uvm_phase phase);
    fork
        begin // мониторим интерфейс записи
            monitor_write();
        end
        begin // мониторим интерфейс чтения
            monitor_read();
        end
    join 
endtask

// мониторинг интерфейса записи
task axi_lite_monitor::monitor_write();
    forever begin
        wtrans = axi_lite_data::type_id::create("wtrans");
        wtrans.transaction_type = 1'b1;
        fork
            begin // мониторим адрес
                get_addr(wtrans.addr, wtrans.transaction_type);
                `uvm_info(get_type_name(), $sformatf("Get write transaction address %0h", wtrans.addr), UVM_LOW)
            end
            begin // мониторим данные
                get_data(wtrans.data, wtrans.strb, wtrans.transaction_type);
                `uvm_info(get_type_name(), $sformatf("Get write data %0h with strob %0b", wtrans.data, wtrans.strb), UVM_LOW)
            end
        join
        analysis_port_h.write(wtrans);
    end
endtask

// мониторинг интерфейса чтения
task axi_lite_monitor::monitor_read();
    forever begin
        rtrans = axi_lite_data::type_id::create("rtrans");
        rtrans.transaction_type = 1'b0;
        fork
            begin // мониторим адрес
                get_addr(rtrans.addr, rtrans.transaction_type);
                `uvm_info(get_type_name(), $sformatf("Get read transaction address %0h", rtrans.addr), UVM_LOW)
            end
            begin // мониторим данные
                get_data(rtrans.data, rtrans.strb, rtrans.transaction_type);
                `uvm_info(get_type_name(), $sformatf("Get read data %0h", rtrans.data), UVM_LOW)
            end
        join
        analysis_port_h.write(rtrans);
    end
endtask

// получить адрес транзакции 
task axi_lite_monitor::get_addr (output bit [31:0] addr, input bit transaction_type);
    forever begin
        @(posedge intf.aclk)
        // адрес записи
        if (intf.awvalid && intf.awready && transaction_type) begin
            addr = intf.awaddr;
            return;
        end
        // адрес чтения
        if (intf.arvalid && intf.arready && !transaction_type) begin
            addr = intf.araddr;
            return;
        end
    end
endtask

// получить данные транзакции
task axi_lite_monitor::get_data (output bit [31:0] data, output bit [3:0] strb, input bit transaction_type);
    forever begin
        @(posedge intf.aclk)
        // адрес записи
        if (intf.wvalid && intf.wready && transaction_type) begin
            data = intf.wdata;
            strb = intf.wstrb;
            return;
        end
        // адрес чтения
        if (intf.rvalid && intf.rready && !transaction_type) begin
            data = intf.rdata;
            strb = 4'b1111;
            return;
        end
    end
endtask