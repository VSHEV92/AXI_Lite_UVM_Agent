class axi_lite_sequence_config extends uvm_object;
    
    `uvm_object_utils(axi_lite_sequence_config)
    function new (string name = "");
        super.new(name);
    endfunction
    
    int unsigned trans_numb = 100; // число транзакций
    
    int unsigned max_clocks_before_addr = 5; // максимальное число тактов до установки адреса
    int unsigned min_clocks_before_addr = 0; // минимальное число тактов до установки адреса
    int unsigned max_clocks_before_data = 5; // максимальное число тактов до установки данных
    int unsigned min_clocks_before_data = 0; // минимальное число тактов до установки данных
    int unsigned max_clocks_before_resp = 5; // максимальное число тактов до установки ответа на запись
    int unsigned min_clocks_before_resp = 0; // минимальное число тактов до установки ответа на запись
    
    int unsigned max_addr_value = 128;  // максимальное значение адреса
    
endclass