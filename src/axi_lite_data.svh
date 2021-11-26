class axi_lite_data extends uvm_sequence_item;

    `uvm_object_utils(axi_lite_data)
    function new (string name = "");
        super.new(name);
    endfunction

    int unsigned max_clocks_before_addr;
    int unsigned min_clocks_before_addr;
    int unsigned max_clocks_before_data;
    int unsigned min_clocks_before_data;
    int unsigned max_clocks_before_resp;
    int unsigned min_clocks_before_resp;

    int unsigned max_addr_value;
    int unsigned min_addr_value;

    rand bit [31:0] data;
    rand bit [31:0] addr;
    rand bit [3:0] strb;
    rand bit transaction_type; // (0 - Read, 1 - Write)

    rand int unsigned clocks_before_addr; // number of ticks before address handshake
    rand int unsigned clocks_before_data; // number of ticks before data handshake
    rand int unsigned clocks_before_resp; // number of ticks before response handshake

    constraint addr_const {
        addr >= min_addr_value && addr <= (max_addr_value - 4) && (addr % 4) == 0;
    }
    constraint clock_before_addr_const {
       clocks_before_addr inside{[min_clocks_before_addr:max_clocks_before_addr]};
    }
    constraint clock_before_data_const {
        clocks_before_data inside{[min_clocks_before_data:max_clocks_before_data]};
    }
    constraint clock_before_resp_const {
        clocks_before_resp inside{[min_clocks_before_resp:max_clocks_before_resp]};
    }

    extern function string convert2string();
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function void do_copy(uvm_object rhs);

endclass

// ------------------------------------------------------------------------------
function string axi_lite_data::convert2string();
    if (transaction_type)
        return $sformatf("type = Write, data = %0h, addr = %0h, strb = %4b", data, addr, strb);
    else
        return $sformatf("type = Read, data = %0h, addr = %0h, strb = %4b", data, addr, strb);   
endfunction

function void axi_lite_data::do_copy(uvm_object rhs);
    axi_lite_data RHS;
    super.do_copy(rhs);
    $cast(RHS, rhs);
    data = RHS.data;
    addr = RHS.addr;
    strb = RHS.strb;
    transaction_type = RHS.transaction_type;  
endfunction


function bit axi_lite_data::do_compare(uvm_object rhs, uvm_comparer comparer);
    axi_lite_data RHS;
    bit same;
    same = super.do_compare(rhs, comparer);
    $cast(RHS, rhs);
    same = (data == RHS.data) && (addr == RHS.addr) && (strb == RHS.strb) && (transaction_type == RHS.transaction_type) && same;
    return same;
endfunction