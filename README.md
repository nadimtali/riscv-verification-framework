# RISC-V Verification Framework

A SystemVerilog-based verification framework focused on validating RISC-V processor components using self-checking testbenches, automated simulation flows, waveform analysis, and scalable verification methodologies.

---

## Overview

This project is being developed as a modular verification environment for RISC-V hardware components.

The framework focuses on:

- Functional verification
- Self-checking testbenches
- Automated simulation
- Waveform-based debugging
- Verification planning
- Directed and randomized testing
- Assertion-based verification

---

## Current Status

### Implemented

- RV32I ALU RTL module
- Self-checking ALU testbench
- Automated simulation script
- VCD waveform generation
- Verification plan documentation

### Current Verification Coverage

- ADD
- SUB
- AND
- OR
- XOR
- SLL
- SRL
- SRA
- SLT
- SLTU
- Zero flag behavior

---

## Directory Structure

```text
rtl/      RTL design modules
tb/       SystemVerilog verification testbenches
scripts/  Simulation automation scripts
docs/     Verification documentation
waves/    Generated waveform files