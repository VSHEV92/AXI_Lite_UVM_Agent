# ------------------------------------------------------
# ----- Cкрипт для автоматического запуска теста -------
# -----             для axi lite master          -------
# ------------------------------------------------------

# создаем проект
open_project axi_lite_master/axi_lite_master.xpr

# обновляем иерархию файлов проекта
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# устанавливаем максимальное время моделирования и имя тес
set_property -name {xsim.simulate.runtime} -value {100s} -objects [get_filesets sim_1]
set_property generic "TEST_NAME=master_test" [get_filesets sim_1]

# запуск моделирования
launch_simulation
close_sim -quiet
    