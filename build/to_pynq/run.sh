#!/bin/bash
cd /tmp/ece320_to_pynq
echo xilinx | sudo -p "Running..." -S python3 run.py $1 $2
