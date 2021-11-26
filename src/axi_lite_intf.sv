interface axi_lite_if
(
    input aclk
);
    // reset
    logic aresetn = 1'b1; 

    // write address interface signals
    logic [31:0] awaddr;
    logic [2:0] awprot;
    logic awvalid = 1'b0;
    logic awready = 1'b0;
    
    // write data interface signals
    logic [31:0] wdata;
    logic [3:0] wstrb; 
    logic wvalid = 1'b0;
    logic wready = 1'b0;
    
    // write response interface signals
    logic [1:0] bresp; 
    logic bvalid = 1'b0;
    logic bready = 1'b0;
    
    // read address interface signals
    logic [31:0] araddr;
    logic [2:0] arprot;
    logic arvalid = 1'b0;
    logic arready = 1'b0;
    
    // read data interface signals
    logic [31:0] rdata;
    logic [1:0] rresp; 
    logic rvalid = 1'b0;
    logic rready = 1'b0;
    
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
        input  rdata, rresp, rvalid,
        // reset
        output aresetn
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
        output rdata, rresp, rvalid,
        // reset
        output aresetn  
    );


    /*
     * reset task
     */
    task reset (input int unsigned aclk_ticks);
        aresetn <= 1'b0;

        repeat(aclk_ticks)
            @(posedge aclk);

        aresetn <= 1'b1;
        // wait for two ticks after reset release 
        repeat(2) @(posedge aclk);
    endtask

    /*
     * ready/valid handshake
     */
    task automatic handshake(ref logic in, out, input int unsigned delay);
        // initail ready delay
        repeat(delay)  
            @(posedge aclk);
        // set ready
        #0 out = 1'b1; 
        // wait for valid
        forever begin 
            @(posedge aclk);
            if (in) begin  
                #0 out = 1'b0;
                return;
            end
        end
    endtask

    /* 
     * master write transaction 
     */ 
    task master_write (input logic [31:0] addr, data, input logic [3:0] strb, input logic [2:0] prot, output logic [1:0] resp, input int unsigned addr_delay, data_delay, resp_delay);
        fork
            begin // set address
                awaddr <= addr;
                awprot <= prot;
                handshake(awready, awvalid, addr_delay);
            end
            begin // set data 
                wdata <= data;
                wstrb <= strb;
                handshake(wready, wvalid, data_delay);
            end
        join
        // get response
        handshake(bvalid, bready, resp_delay);
        resp <= bresp;
    endtask

    /* 
     * master read transaction 
     */ 
    task master_read (input logic [31:0] addr, output logic [31:0] data, input logic [2:0] prot, output logic [1:0] resp, input int unsigned addr_delay, data_delay);
        // set address
        araddr <= addr;
        arprot <= prot;
        handshake(arready, arvalid, addr_delay);

        // get data
        handshake(rvalid, rready, data_delay);
        resp <= rresp;
        data <= rdata;
    endtask

    /* 
     * slave wait transaction start
     */ 
    task slave_wait_addr (output logic [31:0] addr, output logic [2:0] prot, output logic transaction_type, input int unsigned addr_delay);
        fork
            begin // get write address
                handshake(awvalid, awready, addr_delay);
                addr = awaddr;
                prot = awprot;
                transaction_type = 1'b1;
            end
            begin // get read address
                handshake(arvalid, arready, addr_delay);
                addr = araddr;
                prot = arprot;
                transaction_type = 1'b0;
            end
        join_any

        disable fork;

        awready <= 1'b0;
        arready <= 1'b0;

    endtask

    /* 
     * slave wait write data and response
     */ 
    task slave_wait_write_data (output logic [31:0] data, output logic [3:0] strb, input logic [1:0] resp, input int unsigned data_delay, resp_delay);
        // get data
        handshake(wvalid, wready, data_delay);
        data <= wdata;
        strb <= wstrb;

        // send response
        bresp <= resp;
        handshake(bready, bvalid, resp_delay);
    endtask

    /* 
     * slave response for read transaction
     */ 
    task slave_response_read (input logic [31:0] data, input logic [1:0] resp, input int unsigned data_delay);
        // send response
        rdata <= data;
        rresp <= resp;
        handshake(rready, rvalid, data_delay);
    endtask

endinterface