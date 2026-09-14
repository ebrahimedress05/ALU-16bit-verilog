// =============================================================================
// Module      : Alu
// Description : 16-bit combinational Arithmetic Logic Unit (ALU).
//               Implements 20 arithmetic, logic, shift and rotate functions
//               selected by the 5-bit function code F[4:0], and generates a
//               6-bit status/flag register.
//
// Status[5:0] = { A , P , V , N , Z , C }
//               A -> Status[5] : Auxiliary Carry flag (nibble carry, bit3->bit4)
//               P -> Status[4] : Parity flag           (1 = even number of 1's)
//               V -> Status[3] : Overflow flag          (signed overflow)
//               N -> Status[2] : Negative flag          (Result[15])
//               Z -> Status[1] : Zero flag               (Result == 0)
//               C -> Status[0] : Carry / Borrow flag     (or shifted/rotated bit)
//
// Author      : Ibrahim Sami Abdel Raouf Idris (91240054)
//               Youssef Talaat Farouk Ahmed El-Sayed (91240881)
// Project     : Microprocessor Project - 16-bit ALU
// =============================================================================

module Alu (
    input  [15:0] A, B,
    input         cin,
    input  [4:0]  F,
    output reg [15:0] Result,
    output reg [5:0]  Status
);

    reg        Co14;
    reg [14:0] part_Result;
    reg [3:0]  BCD_Result;
    reg        Co3;

    always @(*) begin
        case (F)

            5'd1: begin
                // INC : Result = A + 1
                {Status[0], Result} = A + 1;
                Status[3] = (A == 16'h7fff);      // overflow flag
                Status[5] = (A[3:0] == 4'b1111);  // Aux flag
            end

            5'd3: begin
                // DEC : Result = A - 1
                {Status[0], Result} = A - 1;
                Status[3] = (A == 16'h8000);      // overflow flag
                Status[5] = (A[3:0] == 4'b0000);  // Aux flag
            end

            5'd4: begin
                // ADD : Result = A + B
                {Status[0], Result} = A + B;
                {Co14, part_Result} = A[14:0] + B[14:0];
                Status[3] = Co14 ^ Status[0];      // overflow flag
                {Co3, BCD_Result} = A[3:0] + B[3:0];
                Status[5] = Co3;                   // Aux flag
            end

            5'd5: begin
                // ADC : Result = A + B + cin
                {Status[0], Result} = A + B + {15'b0, cin};
                {Co14, part_Result} = A[14:0] + B[14:0] + {14'b0, cin};
                Status[3] = Co14 ^ Status[0];      // overflow flag
                {Co3, BCD_Result} = A[3:0] + B[3:0] + {3'b0, cin};
                Status[5] = Co3;                   // Aux flag
            end

            5'd6: begin
                // SUB : Result = A - B
                {Status[0], Result} = A - B;
                {Co14, part_Result} = A[14:0] - B[14:0];
                Status[3] = Co14 ^ Status[0];      // overflow flag
                {Co3, BCD_Result} = A[3:0] - B[3:0];
                Status[5] = Co3;                   // Aux flag
            end

            5'd7: begin
                // SBB : Result = A - B - cin
                {Status[0], Result} = A - B - {15'b0, cin};
                {Co14, part_Result} = A[14:0] - B[14:0] - {14'b0, cin};
                Status[3] = Co14 ^ Status[0];      // overflow flag
                {Co3, BCD_Result} = A[3:0] - B[3:0] - {3'b0, cin};
                Status[5] = Co3;                   // Aux flag
            end

            5'd8: begin
                // AND
                Result    = A & B;
                Status[0] = 0; // carry flag
                Status[3] = 0; // overflow flag
                Status[5] = 0; // Aux flag
            end

            5'd9: begin
                // OR
                Result    = A | B;
                Status[0] = 0; // carry flag
                Status[3] = 0; // overflow flag
                Status[5] = 0; // Aux flag
            end

            5'd10: begin
                // XOR
                Result    = A ^ B;
                Status[0] = 0; // carry flag
                Status[3] = 0; // overflow flag
                Status[5] = 0; // Aux flag
            end

            5'd11: begin
                // NOT
                Result    = ~A;
                Status[0] = 0; // carry flag
                Status[3] = 0; // overflow flag
                Status[5] = 0; // Aux flag
            end

            5'd16: begin
                // SHL : logical shift left
                Result    = A << 1;
                Status[0] = A[15]; // Carry flag
                Status[3] = 0;     // overflow flag
                Status[5] = 0;     // Aux flag
            end

            5'd17: begin
                // SHR : logical shift right
                Result    = A >> 1;
                Status[0] = A[0];  // Carry flag
                Status[3] = 0;     // overflow flag
                Status[5] = 0;     // Aux flag
            end

            5'd18: begin
                // SAL : arithmetic shift left (== SHL)
                Result    = A << 1;
                Status[0] = A[15]; // Carry flag
                Status[3] = 0;     // overflow flag
                Status[5] = 0;     // Aux flag
            end

            5'd19: begin
                // SAR : arithmetic shift right (sign-extended)
                Result     = A >> 1;
                Result[15] = A[15];
                Status[0]  = A[0]; // Carry flag
                Status[3]  = 0;    // overflow flag
                Status[5]  = 0;    // Aux flag
            end

            5'd20: begin
                // ROL : rotate left
                Result    = A << 1;
                Result[0] = A[15];
                Status[0] = A[15]; // Carry flag
                Status[3] = 0;     // overflow flag
                Status[5] = 0;     // Aux flag
            end

            5'd21: begin
                // ROR : rotate right
                Result     = A >> 1;
                Result[15] = A[0];
                Status[0]  = A[0]; // Carry flag
                Status[3]  = 0;    // overflow flag
                Status[5]  = 0;    // Aux flag
            end

            5'd22: begin
                // RCL : rotate left through carry
                Result    = {A[14:0], cin};
                Status[0] = A[15]; // Carry flag
                Status[3] = 0;     // overflow flag
                Status[5] = 0;     // Aux flag
            end

            5'd23: begin
                // RCR : rotate right through carry
                Result    = {cin, A[15:1]};
                Status[0] = A[0];  // Carry flag
                Status[3] = 0;     // overflow flag
                Status[5] = 0;     // Aux flag
            end

            default: begin
                Result = 16'b0;
                Status = 6'b0;
            end

        endcase

        Status[1] = ~|Result;  // Zero flag
        Status[2] = Result[15]; // Negative flag
        Status[4] = ~^Result;  // Parity flag (even parity)
    end

endmodule
