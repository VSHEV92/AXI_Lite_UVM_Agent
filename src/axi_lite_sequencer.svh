class axi_lite_sequencer extends uvm_sequencer #(axi_lite_data);
    `uvm_component_utils(axi_lite_sequencer)
    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass