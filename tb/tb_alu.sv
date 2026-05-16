`timescale 1ns/1ps

module tb_alu;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_op;
    logic [31:0] result;
    logic        zero;

    int tests_passed = 0;
    int tests_failed = 0;
    int add_cov  = 0;
    int sub_cov  = 0;
    int and_cov  = 0;
    int or_cov   = 0;
    int xor_cov  = 0;
    int sll_cov  = 0;
    int srl_cov  = 0;
    int sra_cov  = 0;
    int slt_cov  = 0;
    int sltu_cov = 0;

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
        input string test_name,
        input bit    verbose
    );
        begin
            a = test_a;
            b = test_b;
            alu_op = test_op;
            #1;
             case (test_op)
                4'd0: add_cov++;
                4'd1: sub_cov++;
                4'd2: and_cov++;
                4'd3: or_cov++;
                4'd4: xor_cov++;
                4'd5: sll_cov++;
                4'd6: srl_cov++;
                4'd7: sra_cov++;
                4'd8: slt_cov++;
                4'd9: sltu_cov++;
            endcase

            if (result === expected) begin
                if (verbose)
                    $display("[PASS] %s", test_name);
                tests_passed++;
            end else begin
                $display("[FAIL] %s | a=%h b=%h op=%0d expected=%h got=%h",
                         test_name, a, b, alu_op, expected, result);
                tests_failed++;
            end

            if (zero !== (result == 32'd0)) begin
                $display("[ASSERT FAIL] zero flag mismatch | result=%h zero=%b", result, zero);
                tests_failed++;
            end
        end
    endtask

    initial begin
        $dumpfile("waves/alu.vcd");
        $dumpvars(0, tb_alu);

        $display("Starting RISC-V ALU verification...");

        // Directed tests
        check(32'd10, 32'd5,  4'd0, 32'd15, "ADD basic", 1'b1);
        check(32'd10, 32'd5,  4'd1, 32'd5,  "SUB basic", 1'b1);
        check(32'hF0F0, 32'h0FF0, 4'd2, 32'h00F0, "AND basic", 1'b1);
        check(32'hF0F0, 32'h0FF0, 4'd3, 32'hFFF0, "OR basic", 1'b1);
        check(32'hAAAA, 32'h5555, 4'd4, 32'hFFFF, "XOR basic", 1'b1);

        check(32'd1,  32'd4, 4'd5, 32'd16, "SLL shift left", 1'b1);
        check(32'd16, 32'd2, 4'd6, 32'd4,  "SRL shift right", 1'b1);
        check(32'h80000000, 32'd4, 4'd7, 32'hF8000000, "SRA arithmetic shift", 1'b1);

        check(32'd3, 32'd7, 4'd8, 32'd1, "SLT signed true", 1'b1);
        check(32'd7, 32'd3, 4'd8, 32'd0, "SLT signed false", 1'b1);
        check(32'hFFFFFFFF, 32'd1, 4'd9, 32'd0, "SLTU unsigned false", 1'b1);

        check(32'd5, 32'd5, 4'd1, 32'd0, "ZERO flag case", 1'b1);

        // Randomized tests using golden model
        $display("Starting randomized ALU tests...");

        for (int i = 0; i < 100; i++) begin
            logic [31:0] rand_a;
            logic [31:0] rand_b;
            logic [3:0]  rand_op;
            logic [31:0] expected;

            rand_a = $urandom;
            rand_b = $urandom;
            rand_op = $urandom_range(0, 9);

            case (rand_op)
                4'd0: expected = rand_a + rand_b;
                4'd1: expected = rand_a - rand_b;
                4'd2: expected = rand_a & rand_b;
                4'd3: expected = rand_a | rand_b;
                4'd4: expected = rand_a ^ rand_b;
                4'd5: expected = rand_a << rand_b[4:0];
                4'd6: expected = rand_a >> rand_b[4:0];
                4'd7: expected = $signed(rand_a) >>> rand_b[4:0];
                4'd8: expected = ($signed(rand_a) < $signed(rand_b)) ? 32'd1 : 32'd0;
                4'd9: expected = (rand_a < rand_b) ? 32'd1 : 32'd0;
                default: expected = 32'd0;
            endcase

            check(rand_a, rand_b, rand_op, expected, "Random ALU test", 1'b0);
        end

        $display("--------------------------------");
        $display("Tests passed: %0d", tests_passed);
        $display("");
        $display("ALU OPERATION COVERAGE");
        $display("----------------------");
        $display("ADD   : %0d", add_cov);
        $display("SUB   : %0d", sub_cov);
        $display("AND   : %0d", and_cov);
        $display("OR    : %0d", or_cov);
        $display("XOR   : %0d", xor_cov);
        $display("SLL   : %0d", sll_cov);
        $display("SRL   : %0d", srl_cov);
        $display("SRA   : %0d", sra_cov);
        $display("SLT   : %0d", slt_cov);
        $display("SLTU  : %0d", sltu_cov);
        $display("");
        $display("Tests failed: %0d", tests_failed);
        $display("--------------------------------");

        if (tests_failed == 0)
            $display("ALU VERIFICATION PASSED");
        else
            $display("ALU VERIFICATION FAILED");

        $finish;
    end

endmodule