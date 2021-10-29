interface axi_lite_if
(
    input aclk
);
    // сигналы интерфейса write address
    logic [31:0] awaddr;
    logic [2:0] awprot;
    logic awvalid = 1'b0;
    logic awready = 1'b0;
    
    // сигналы интерфейса write data 
    logic [31:0] wdata;
    logic [3:0] wstrb; 
    logic wvalid = 1'b0;
    logic wready = 1'b0;
    
    // сигналы интерфейса write response
    logic [1:0] bresp; 
    logic bvalid = 1'b0;
    logic bready = 1'b0;
    
    // сигналы интерфейса read address
    logic [31:0] araddr;
    logic [2:0] arprot;
    logic arvalid = 1'b0;
    logic arready = 1'b0;
    
    // сигналы интерфейса read data 
    logic [31:0] rdata;
    logic [1:0] rresp; 
    logic rvalid = 1'b0;
    logic rready = 1'b0;
    
    // модпорты 
    modport master
    (
        // write address
        output awaddr, awprot, awvalid,
        input  awready,
        // write data
        output wdata, wstrb, wvalid, 
        input  wready,
        // write response
        output bready, 
        input  bresp, bvalid,
        // read address
        output araddr, arprot, arvalid,
        input  arready,
        // read data
        output rready,
        input  rdata, rresp, rvalid 
    );

    modport slave
    (
         // write address
        input  awaddr, awprot, awvalid,
        output awready,
        // write data
        input  wdata, wstrb, wvalid, 
        output wready,
        // write response
        input  bready, 
        output bresp, bvalid,
        // read address
        input  araddr, arprot, arvalid,
        output arready,
        // read data
        input  rready,
        output rdata, rresp, rvalid  
    );

    /*
     * реализация протокола ready-valid
     */
    task automatic handshake(ref input logic in, out, input int unsigned delay);
        // начальная задержка до установки собственной готовности
        repeat(delay)  
            @(posedge aclk);
        // устанавливаем собственную готовность
        out <= 1'b1; 
        // ожидаем готовности от другой стороны
        forever begin 
            @(posedge aclk);
            if (in) begin  
                out <= 1'b0;
                return;
            end
        end
    endtask

    /* 
     * запись со стороны master
     */ 
    task master_write (input logic [31:0] addr, data, input logic [3:0] strb, input logic [2:0] prot, output logic [1:0] resp, input int unsigned addr_delay, data_delay, resp_delay);
        fork
            begin // устанавливаем адрес
                awaddr <= addr;
                awprot <= prot;
                handshake(awready, awvalid, addr_delay);
            end
            begin // устанавливаем данные 
                wdata <= addr;
                wstrb <= strb;
                handshake(aready, avalid, data_delay);
            end
        join
        // получаем ответ о записи
        handshake(bvalid, bready, resp_delay);
        resp <= bresp;
    endtask

    /* 
     * чтение со стороны master
     */ 
    task master_read (input logic [31:0] addr, output logic [31:0] data, input logic [2:0] prot, output logic [1:0] resp, input int unsigned addr_delay, data_delay);
        // устанавливаем адрес
        araddr <= addr;
        arprot <= prot;
        handshake(arready, arvalid, addr_delay);

        // получаем данные
        handshake(rvalid, rready, data_delay);
        resp <= rresp;
        data <= rdata
    endtask

    /* 
     * ожидание записи в slave
     */ 
    task slave_wait_write (output logic [31:0] addr, data, output logic [3:0] strb, output logic [2:0] prot, input logic [1:0] resp, input int unsigned addr_delay, data_delay, resp_delay);
        fork
            begin // получаем адрес
                handshake(awvalid, awready, addr_delay);
                addr <= awaddr;
                prot <= awprot;
            end
            begin // получаем данные 
                handshake(wvalid, wready, data_delay);
                data <= wdata;
                strb <= wstrb;
            end
        join
        // отправляем ответ о записи
        bresp <= resp
        handshake(bready, bvalid, resp_delay);
    endtask

    /* 
     * ожидание чтения из slave
     */ 
    task slave_wait_read (output logic [31:0] addr, output logic [2:0] prot, input int unsigned addr_delay);
        // получаем адрес
        handshake(arvalid, arready, addr_delay);
        addr <= awaddr;
        prot <= awprot;
    endtask

    /* 
     * ответ на чтение из slave
     */ 
    task slave_response_read (input logic [31:0] data, input logic [1:0] resp, input int unsigned data_delay);
        // отправляем ответ
        rdata <= data;
        rresp <= resp;
        handshake(rready, rvalid, data_delay);
    endtask

endinterface