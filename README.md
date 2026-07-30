Verification of a Memory Read/Write Controller

A constrained-random, self-checking, coverage-driven SystemVerilog testbench for a synchronous 256×8-bit memory read/write controller.

Internship-2 Project — Design Verification Using System Verilog BNM Institute of Technology

Overview

This project verifies a small but realistic synchronous memory controller (mem_ctrl) using a class-based SystemVerilog testbench. Rather than writing fixed, hand-crafted test cases, the testbench generates randomized read/write transactions, drives them into the DUT, independently predicts the correct result using a reference (shadow) memory model, and automatically reports PASS/FAIL — with no manual waveform inspection required. Functional coverage (including cross coverage) is used to confirm the test suite actually exercised the design thoroughly.

Result: 100% functional coverage achieved in 59 of 100 budgeted transactions, with zero scoreboard mismatches.

Problem Statement

Memory controllers are foundational blocks in digital systems, but even a design this small can hide subtle bugs around read/write timing, address-boundary handling, or simultaneous read/write requests. Manually simulating and inspecting waveforms for every scenario does not scale and is error-prone. This project addresses that by building an automated, self-checking verification environment that generates diverse test scenarios and validates correctness without manual intervention.

Design Under Test (DUT)

mem_ctrl is a synchronous, clock-based memory controller with:

Port	Direction	Width	Description
clk	input	1 bit	System clock
rst	input	1 bit	Synchronous reset — clears all 256 memory locations
we	input	1 bit	Write enable
re	input	1 bit	Read enable
addr	input	8 bits	Address, 0–255
wdata	input	8 bits	Write data
rdata	output	8 bits	Read data (valid one cycle after re)
rvalid	output	1 bit	Pulses high the cycle rdata is valid

Key behavioral rules:

Synchronous write: mem[addr] <= wdata when we = 1.
Synchronous read: rdata <= mem[addr], rvalid <= 1 when re = 1. Result is valid one clock cycle after re is sampled.
Write has priority over read — if we and re are both asserted in the same cycle, the write executes and the read is ignored that cycle.
On reset, all 256 memory locations are cleared to 0.
Verification Architecture

A layered, class-based testbench (conceptually similar to UVM, implemented directly in SystemVerilog):

Generator → [gen2driv mailbox] → Driver → mem_if (clocking blocks) → DUT
                                                                        │
                                                                        ▼
Scoreboard ← [mon2scb mailbox] ← Monitor ← mem_if (clocking blocks) ← DUT
    │
    └──► [mon2cov mailbox] → Functional Coverage
Component	Responsibility
Generator	Produces constrained-random transactions (op, addr, wdata)
Driver	Applies each transaction to the DUT pins via a clocking block
Interface	Bundles all DUT signals; separate drv_cb/mon_cb clocking blocks prevent race conditions
Monitor	Passively observes the bus and reconstructs completed transactions (handles the 1-cycle read latency)
Scoreboard	Independent shadow-memory reference model; compares expected vs. actual read data and reports PASS/FAIL
Coverage	Functional coverage (operation type, address regions) + cross coverage
Environment	Instantiates and connects all components; runs pre-test/test/post-test phases
Test	Top-level entry point; configures transaction count and launches the environment
Repository Structure
.
├── design.sv        # DUT: mem_ctrl memory read/write controller
├── testbench.sv      # Top-level module: clock/reset generation, DUT + interface instantiation
├── interface.sv       # mem_if: signal bundle with drv_cb / mon_cb clocking blocks and modports
├── transaction.sv    # Randomized transaction class (op, addr, wdata) with distribution constraints
├── generator.sv        # Generates and sends randomized transactions
├── driver.sv           # Drives transactions onto the DUT interface
├── monitor.sv           # Observes DUT behavior and reconstructs transactions
├── scoreboard.sv        # Self-checking reference model and PASS/FAIL reporting
├── coverage.sv           # Functional + cross coverage collection
├── environment.sv         # Wires up all components; manages test phases
├── test.sv                 # Top-level test program; sets transaction count and runs
└── README.md
Key Verification Features
Constrained-random stimulus — roughly equal WRITE/READ distribution, with address generation biased toward the boundary addresses (0x00, 0xFF) to increase the chance of catching off-by-one bugs.
Self-checking scoreboard — an independent, all-zero-initialized shadow memory predicts expected read data; every READ is automatically compared against it.
Race-free driving/sampling — separate clocking blocks (drv_cb, mon_cb) with #1 skew prevent testbench–DUT race conditions.
Functional coverage — coverpoints for operation type and six address regions (including dedicated edge bins for address 0 and 255), plus cross coverage of operation × address region to ensure every combination is exercised, not just each dimension independently.
Reset verification — DUT and reference model both start from an all-zero state, so post-reset reads are checkable from the very first transaction.
How to Run

This testbench is written in standard SystemVerilog and can be run on any SystemVerilog-capable simulator (e.g., QuestaSim, VCS, Xcelium, or EDA Playground with Icarus/Verilator + UVM support enabled).

Example (EDA Playground / command-line simulators):

bash
# Compile
vlog design.sv testbench.sv

# Run
vsim -c top -do "run -all; quit"

Waveforms are dumped to mem_ctrl.vcd (via $dumpfile/$dumpvars in testbench.sv) and can be viewed in GTKWave or a similar VCD viewer.

To change the number of generated transactions, edit repeat_count in test.sv.

Sample Output
[Scoreboard] WRITE addr=10 data=200 (model updated)
[Scoreboard] READ  addr=10 PASS (data=200)
...
=====================================================
 SCOREBOARD SUMMARY: 59 reads checked -> 59 PASS, 0 FAIL
=====================================================
 FUNCTIONAL COVERAGE: 100.00 %
=====================================================
Results
Scoreboard: All READ transactions verified against the reference model — 0 mismatches.
Coverage: 100% functional coverage (operation type × address region cross coverage) reached within 59 of 100 budgeted transactions.
Known Limitations / Future Work
The driver never asserts we and re simultaneously, so the DUT's write-priority rule is not exercised by a dedicated directed test — only implicitly.
WRITE correctness is only verified indirectly, through a later READ of the same address; a write to an address that is never subsequently read is not directly checked.
Planned extensions: SystemVerilog Assertions (SVA) for protocol/timing checks, burst read/write support, and migration to a full UVM-based environment.
Tools Used
SystemVerilog — testbench and verification environment
Verilog — RTL design
EDA Playground — simulation platform
EPWave / GTKWave — waveform analysis
Authors
Shreedhargouda Patil — 1BG24EC086
Vrushank H — 1BG24EC116
Shreyas S M — 1BG24EC089

BNM Institute of Technology — Internship-2, Design Verification Using System Verilog