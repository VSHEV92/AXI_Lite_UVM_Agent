class axi_lite_sequence extends uvm_sequence #(axi_lite_data);
    `uvm_object_utils(axi_lite_sequence)
    function new (string name = "");
        super.new(name);
    endfunction
    
    extern task pre_body();
    
    extern function void config_item();

    int unsigned trans_numb;

    axi_lite_data axi_lite_data_h;

    axi_lite_sequence_config axi_lite_seqc_config;
    
endclass

// ---------------------------------------------------------------------
task axi_lite_sequence::pre_body();
    trans_numb = axi_lite_seqc_config.trans_numb;
endtask

function void axi_lite_sequence::config_item();
    axi_lite_data_h.max_clocks_before_addr = axi_lite_seqc_config.max_clocks_before_addr;
    axi_lite_data_h.min_clocks_before_addr = axi_lite_seqc_config.min_clocks_before_addr;
    axi_lite_data_h.max_clocks_before_data = axi_lite_seqc_config.max_clocks_before_data;
    axi_lite_data_h.min_clocks_before_data = axi_lite_seqc_config.min_clocks_before_data;
    axi_lite_data_h.max_clocks_before_resp = axi_lite_seqc_config.max_clocks_before_resp;
    axi_lite_data_h.min_clocks_before_resp = axi_lite_seqc_config.min_clocks_before_resp;
    axi_lite_data_h.max_addr_value = axi_lite_seqc_config.max_addr_value;
endfunction