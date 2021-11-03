#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2021.1 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Wed Nov 03 06:29:05 EDT 2021
# SW Build 3247384 on Thu Jun 10 19:36:07 MDT 2021
#
# IP Build 3246043 on Fri Jun 11 00:30:35 MDT 2021
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# elaborate design
echo "xelab -wto b9d05c9fafb74453a801661943d617c7 --incr --debug typical --relax --mt 8 -generic_top "TEST_NAME=slave_test" -L xil_defaultlib -L uvm -L unisims_ver -L unimacro_ver -L secureip --snapshot slave_tb_behav xil_defaultlib.slave_tb xil_defaultlib.glbl -log elaborate.log -L uvm"
xelab -wto b9d05c9fafb74453a801661943d617c7 --incr --debug typical --relax --mt 8 -generic_top "TEST_NAME=slave_test" -L xil_defaultlib -L uvm -L unisims_ver -L unimacro_ver -L secureip --snapshot slave_tb_behav xil_defaultlib.slave_tb xil_defaultlib.glbl -log elaborate.log -L uvm
