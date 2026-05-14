`timescale 1ns/1ps

module tb_alu;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_op;
    logic [31:0] result;
    logic        zero;

    int tests_passed = 0;
    int tests_failed = 0;

    riscv_alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    task check(
        input [31:0] test_a,
        input [31:0] test_b,
        input [3:0]  test_op,
        input [31:0] expected,
        input string test_name
    );
        begin
            a = test_a;
            b = test_b;
            alu_op = test_op;
            #1;

            if (result === expected) begin
                $display("[PASS] %s", test_name);
                tests_passed++;
            end else begin
                $display("[FAIL] %s | a=%h b=%h op=%0d expected=%h got=%h",
                         test_name, a, b, alu_op, expected, result);
                tests_failed++;
            end
        end
    endtask

    initial begin
        $dumpfile("waves/alu.vcd");
        $dumpvars(0, tb_alu);

        $display("Starting RISC-V ALU verification...");

        check(32'd10, 32'd5,  4'd0, 32'd15, "ADD basic");
        check(32'd10, 32'd5,  4'd1, 32'd5,  "SUB basic");
        check(32'hF0F0, 32'h0FF0, 4'd2, 32'h00F0, "AND basic");
        check(32'hF0F0, 32'h0FF0, 4'd3, 32'hFFF0, "OR basic");
        check(32'hAAAA, 32'h5555, 4'd4, 32'hFFFF, "XOR basic");

        check(32'd1, 32'd4, 4'd5, 32'd16, "SLL shift left");
        check(32'd16, 32'd2, 4'd6, 32'd4, "SRL shift right");
        check(32'h80000000, 32'd4, 4'd7, 32'hF8000000, "SRA arithmetic shift");

        check(32'd3, 32'd7, 4'd8, 32'd1, "SLT signed true");
        check(32'd7, 32'd3, 4'd8, 32'd0, "SLT signed false");
        check(32'hFFFFFFFF, 32'd1, 4'd9, 32'd0, "SLTU unsigned false");

        check(32'd5, 32'd5, 4'd1, 32'd0, "ZERO flag case");

        if (zero !== 1'b1) begin
            $display("[FAIL] zero flag should be 1");
            tests_failed++;
        end else begin
            $display("[PASS] zero flag works");
            tests_passed++;
        end

        $display("--------------------------------");
        $display("Tests passed: %0d", tests_passed);
        $display("Tests failed: %0d", tests_failed);
        $display("--------------------------------");

        if (tests_failed == 0)
            $display("ALU VERIFICATION PASSED");
        else
            $display("ALU VERIFICATION FAILED");

        $finish;
    end

endmodule
