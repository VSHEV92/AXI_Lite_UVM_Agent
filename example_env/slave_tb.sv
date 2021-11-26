`timescale 1ns/1ps

module slave_tb #(string TEST_NAME) ();

    import uvm_pkg::*;
    import test_pkg::*; 


    bit aclk = 0;
    axi_lite_if axi_lite_master (aclk);
    axi_lite_if axi_lite_slave (aclk);
    
    always 
        #2 aclk = ~aclk;

    assign axi_lite_slave.araddr = axi_lite_master.araddr;
    assign axi_lite_slave.arprot = axi_lite_master.arprot;
    assign axi_lite_master.arready = axi_lite_slave.arready;
    assign axi_lite_slave.arvalid = axi_lite_master.arvalid;

    assign axi_lite_slave.awaddr = axi_lite_master.awaddr;
    assign axi_lite_slave.awprot = axi_lite_master.awprot;
    assign axi_lite_master.awready = axi_lite_slave.awready;
    assign axi_lite_slave.awvalid = axi_lite_master.awvalid;

    assign axi_lite_slave.bready = axi_lite_master.bready;
    assign axi_lite_master.bresp = axi_lite_slave.bresp;
    assign axi_lite_master.bvalid = axi_lite_slave.bvalid;

    assign axi_lite_master.rdata = axi_lite_slave.rdata; 
    assign axi_lite_slave.rready = axi_lite_master.rready;
    assign axi_lite_master.rresp = axi_lite_slave.rresp;
    assign axi_lite_master.rvalid = axi_lite_slave.rvalid;

    assign axi_lite_slave.wdata = axi_lite_master.wdata; 
    assign axi_lite_master.wready = axi_lite_slave.wready;
    assign axi_lite_slave.wstrb = axi_lite_master.wstrb;
    assign axi_lite_slave.wvalid = axi_lite_master.wvalid;

    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(null, "", "axi_lite_master", axi_lite_master);
        uvm_config_db #(virtual axi_lite_if)::set(null, "", "axi_lite_slave", axi_lite_slave);
        
        run_test(TEST_NAME);
    end

endmodule