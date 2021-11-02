class axi_lite_rd_sequence extends axi_lite_sequence;
    `uvm_object_utils(axi_lite_rd_sequence)
    function new (string name = "");
        super.new(name);
    endfunction
    
    extern task body();
    
endclass

task axi_lite_rd_sequence::body();
    repeat(trans_numb) begin
        axi_lite_data_h = axi_lite_data::type_id::create("axi_lite_data_h");
        start_item(axi_lite_data_h);
            config_item();
            assert(axi_lite_data_h.randomize());
            axi_lite_data_h.transaction_type = 1'b0;
        finish_item(axi_lite_data_h);
    end
endtask
