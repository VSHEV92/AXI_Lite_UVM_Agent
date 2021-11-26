# ------------------------------------------------------
# ---- Cкрипт для автоматического создания проекта -----
#-----              для axi lite slave            -----
# ------------------------------------------------------

# -----------------------------------------------------------
set Project_Name axi_lite_slave

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
add_files -fileset sim_1 ./example_env/slave_tb.sv

# подключение uvm библиотек к проекту
set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]