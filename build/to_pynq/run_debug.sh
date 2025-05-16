#!/bin/bash
cd /tmp/ece320_to_pynq
sudo -p "***** Please enter the password (by default it is xilinx) *****:" -S python3 run.py $1 $2
