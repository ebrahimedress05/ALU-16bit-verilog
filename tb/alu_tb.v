// =============================================================================
// Module      : Test__bench
// Description : Self-checking-free directed testbench for the 16-bit Alu.
//               Exercises every one of the 20 supported functions, plus
//               dedicated edge/corner cases for each status flag
//               (Carry, Zero, Negative, Overflow, Parity, Auxiliary Carry).
//
// Usage       : Run on any Verilog simulator (ModelSim, Icarus Verilog,
//               EDA Playground, ...). Dump a VCD file to inspect the
//               waveforms shown in docs/waveforms/.
// =============================================================================

`timescale 1ns / 1ps

module Test__bench;

    reg  [15:0] A, B;
    reg         cin;
    reg  [4:0]  F;
    wire [15:0] Result;
    wire [5:0]  Status;

    Alu dut (
        .A      (A),
        .B      (B),
        .cin    (cin),
        .F      (F),
        .Result (Result),
        .Status (Status)
    );

    initial begin
        // Optional VCD dump for waveform viewers / EDA Playground
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, Test__bench);

        // ------------------------------------------------------------
        // ARITHMETIC OPERATIONS
        // ------------------------------------------------------------

        // INC
        A = 16'hAB8C; B = 0; cin = 0; F = 5'd1; #10;
        // INC — WORST CASE (Overflow + Carry)
        A = 16'h7FFF; B = 0; cin = 0; F = 5'd1; #10;
        // INC — ZERO RESULT
        A = 16'hFFFF; B = 0; cin = 0; F = 5'd1; #10;

        // DEC
        A = 16'hCC97; B = 0; cin = 0; F = 5'd3; #10;
        // DEC — WORST CASE (Negative + Overflow)
        A = 16'h8000; B = 0; cin = 0; F = 5'd3; #10;
        // DEC — ZERO RESULT
        A = 16'h0001; B = 0; cin = 0; F = 5'd3; #10;

        // ADD
        A = 16'h11A5; B = 16'h0517; cin = 0; F = 5'd4; #10;
        // ADD — SIGNED OVERFLOW
        A = 16'h7FFF; B = 16'h0001; cin = 0; F = 5'd4; #10;
        // ADD — AUX CARRY
        A = 16'h000F; B = 16'h0001; cin = 0; F = 5'd4; #10;
        // ADD — ZERO RESULT
        A = 16'hAAAA; B = 16'h5556; cin = 0; F = 5'd4; #10;

        // ADC — carry + overflow
        A = 16'h7FFF; B = 16'h0001; cin = 1; F = 5'd5; #10;
        // ADC — carry only
        A = 16'hFFFF; B = 16'h0000; cin = 1; F = 5'd5; #10;

        // EXTRA – carry + overflow together
        A = 16'hFFFF; B = 16'h0001; cin = 1; F = 5'd5; #10;

        // SUB
        A = 16'hAB77; B = 16'h0044; cin = 0; F = 5'd6; #10;
        // SUB — negative result
        A = 16'h0000; B = 16'h0001; cin = 0; F = 5'd6; #10;
        // SUB — ZERO result
        A = 16'h1234; B = 16'h1234; cin = 0; F = 5'd6; #10;

        // SBB — BORROW
        A = 16'h0000; B = 16'h0001; cin = 1; F = 5'd7; #10;

        // ------------------------------------------------------------
        // LOGIC OPERATIONS
        // ------------------------------------------------------------

        A = 16'hFFFF; B = 16'h0F0F; cin = 0;
        F = 5'd8;  #10; // AND
        F = 5'd9;  #10; // OR
        F = 5'd10; #10; // XOR
        F = 5'd11; #10; // NOT

        // EXTRA – ZERO & NEGATIVE cases
        A = 16'h0000; B = 16'hFFFF; F = 5'd8; #10; // AND -> ZERO
        A = 16'h8000; B = 16'h0001; F = 5'd9; #10; // OR  -> NEG

        // ------------------------------------------------------------
        // SHIFT OPERATIONS
        // ------------------------------------------------------------

        B = 0; cin = 0;

        // SHL Cases
        A = 16'h0000; F = 5'd16; #10; // ZERO RESULT
        A = 16'h8000; F = 5'd16; #10; // CARRY OUT
        A = 16'h4000; F = 5'd16; #10; // NEG RESULT
        A = 16'hAAAA; F = 5'd16; #10; // Parity (Even)
        A = 16'hAAAB; F = 5'd16; #10; // Parity (Odd)

        // SAL Cases
        A = 16'h8000; F = 5'd18; #10; // CARRY OUT
        A = 16'h4000; F = 5'd18; #10; // NEG RESULT
        A = 16'h0001; F = 5'd18; #10; // ZERO RESULT
        A = 16'hAAAA; F = 5'd18; #10; // Parity Even
        A = 16'hAAAB; F = 5'd18; #10; // Parity Odd

        // SHR Cases
        A = 16'h0001; F = 5'd17; #10; // CARRY FROM LSB
        A = 16'h0002; F = 5'd17; #10; // ZERO RESULT
        A = 16'h8002; F = 5'd17; #10; // MSB before shift

        // SAR Cases
        A = 16'h8001; F = 5'd19; #10; // NEG remains
        A = 16'h0002; F = 5'd19; #10; // ZERO RESULT
        A = 16'hFFFE; F = 5'd19; #10; // Parity check

        // ------------------------------------------------------------
        // ROTATE OPERATIONS (ROL / ROR / RCL / RCR)
        // ------------------------------------------------------------

        B = 0;

        // ROL
        A = 16'h8000; cin = 0; F = 5'd20; #10;
        A = 16'h0000; cin = 0; F = 5'd20; #10;
        A = 16'h8001; cin = 0; F = 5'd20; #10;

        // ROR
        A = 16'h0001; cin = 0; F = 5'd21; #10;
        A = 16'h8000; cin = 0; F = 5'd21; #10;
        A = 16'hAAAA; cin = 0; F = 5'd21; #10;

        // RCL
        A = 16'h0001; cin = 1; F = 5'd22; #10;
        A = 16'h8000; cin = 1; F = 5'd22; #10;
        A = 16'hFFFF; cin = 0; F = 5'd22; #10;

        // RCR
        A = 16'h8001; cin = 0; F = 5'd23; #10;
        A = 16'h0001; cin = 1; F = 5'd23; #10;
        A = 16'hAAAA; cin = 0; F = 5'd23; #10;

        $stop;
    end

endmodule
