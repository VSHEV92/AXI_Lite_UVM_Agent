# ------------------------------------------------------
# ---- Cкрипт для автоматического создания проекта -----
#-----              для axi lite master            -----
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name axi_lite_master

# если проект с таким именем существует удаляем его
close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xcku060-ffva1156-2-e

# добавляем исходники axis_agent к проекту
add_files [glob -nocomplain -- ./src/*.svh]
add_files [glob -nocomplain -- ./src/*.sv]

# добавляем файлы тестового окружения к проекту
add_files [glob -nocomplain -- ./example_env/*.svh]
add_files ./example_env/test_pkg.sv
add_files ./example_env/reset_intf.sv
add_files -fileset sim_1 ./example_env/master_tb.sv

# -------------------------------------------------------------------------------
# создание block design для проверки axi lite master
create_bd_design "mem_bd"

# создание контроллера bram
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.ECC_TYPE {0}] [get_bd_cells axi_bram_ctrl_0]

# создание bram и подключение к контроллеру
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
connect_bd_intf_net [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]

# создание внешних интерфейсов
make_bd_intf_pins_external  [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

# установка размера памяти равным 128 байт
assign_bd_address
set_property range 128 [get_bd_addr_segs {S_AXI_0/SEG_axi_bram_ctrl_0_Mem0}]

regenerate_bd_layout
save_bd_design
close_bd_design [get_bd_designs mem_bd]
make_wrapper -files [get_files ./axi_lite_master/axi_lite_master.srcs/sources_1/bd/mem_bd/mem_bd.bd] -top
add_files -norecurse ./axi_lite_master/axi_lite_master.gen/sources_1/bd/mem_bd/hdl/mem_bd_wrapper.v
# -------------------------------------------------------------------------------

generate_target {simulation} [get_files  ./axi_lite_master/axi_lite_master.srcs/sources_1/bd/mem_bd/mem_bd.bd]

# подключение uvm библиотек к проекту
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]