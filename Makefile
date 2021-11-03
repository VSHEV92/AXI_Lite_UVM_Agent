all:
	make test_master | tee master_log.txt
	make check

test_master: axi_lite_master
	vivado -mode batch -source tcl/run_master_test.tcl

axi_lite_master:
	vivado -mode batch -source tcl/create_project_master.tcl

check:
	cat master_log.txt | grep "TEST RESULT"
	#cat slave_log.txt | grep "TEST RESULT"

clean:
	rm -Rf axi_lite_master .Xil
	rm *.jou *.log *.txt	 