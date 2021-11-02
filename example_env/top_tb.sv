`timescale 1ns/1ps

module top_tb #(string TEST_NAME = "base_test") ();

    import uvm_pkg::*;
    import test_pkg::*; 


    bit aclk = 0;
    axi_lite_if axi_lite (aclk);
    aresetn_if aresetn (aclk);
    
    always 
        #2 aclk = ~aclk;

mem_bd_wrapper dut (
    .S_AXI_0_araddr  (axi_lite.araddr),
    .S_AXI_0_arprot  (axi_lite.arprot),
    .S_AXI_0_arready (axi_lite.arready),
    .S_AXI_0_arvalid (axi_lite.arvalid),
    .S_AXI_0_awaddr  (axi_lite.awaddr),
    .S_AXI_0_awprot  (axi_lite.awprot),
    .S_AXI_0_awready (axi_lite.awready),
    .S_AXI_0_awvalid (axi_lite.awvalid),
    .S_AXI_0_bready  (axi_lite.bready),
    .S_AXI_0_bresp   (axi_lite.bresp),
    .S_AXI_0_bvalid  (axi_lite.bvalid),
    .S_AXI_0_rdata   (axi_lite.rdata),
    .S_AXI_0_rready  (axi_lite.rready),
    .S_AXI_0_rresp   (axi_lite.rresp),
    .S_AXI_0_rvalid  (axi_lite.rvalid),
    .S_AXI_0_wdata   (axi_lite.wdata),
    .S_AXI_0_wready  (axi_lite.wready),
    .S_AXI_0_wstrb   (axi_lite.wstrb),
    .S_AXI_0_wvalid  (axi_lite.wvalid),
    .s_axi_aclk_0    (aclk),
    .s_axi_aresetn_0 (aresetn.aresetn) 
);

    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(null, "", "axi_lite", axi_lite);
        uvm_config_db #(virtual aresetn_if)::set(null, "", "aresetn", aresetn);
        run_test(TEST_NAME);
    end

endmodule