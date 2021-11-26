class axi_lite_sequence_config extends uvm_object;
    
    `uvm_object_utils(axi_lite_sequence_config)
    function new (string name = "");
        super.new(name);
    endfunction
    
    int unsigned trans_numb = 100; // number of transactions
    
    int unsigned max_clocks_before_addr = 5; // maximum number of ticks before set address
    int unsigned min_clocks_before_addr = 0; // minimum number of ticks before set address
    int unsigned max_clocks_before_data = 5; // maximum number of ticks before set data
    int unsigned min_clocks_before_data = 0; // minimum number of ticks before set data
    int unsigned max_clocks_before_resp = 5; // maximum number of ticks before send response
    int unsigned min_clocks_before_resp = 0; // minimum number of ticks before send response
    
    int unsigned max_addr_value = 128;  // maximum address value
    int unsigned min_addr_value = 0;  // minimum address value
    
endclass