#!/bin/bash

mkdir -p waves

echo "Compiling ALU testbench..."
iverilog -g2012 -o build/tb_alu.out rtl/riscv_alu.sv tb/tb_alu.sv

echo "Running simulation..."
vvp build/tb_alu.out