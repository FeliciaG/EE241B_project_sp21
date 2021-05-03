`timescale 1ns/1ps

module seed_val_tester();
    localparam W = 16;
    reg clk;
    reg reset;
    reg [W-1:0] seed;
    reg [W-1:0] m;

    wire res_valid;
    wire seed_valid;
    wire gcd_rdy;
    wire [W-1:0] test_out;
    initial clk = 0;
    initial reset =0;
    always #(10) clk <= ~clk;

    seed_val dut (.clk(clk), .reset(reset), .seed(seed), .m(m),
    .gcd_rdy(gcd_rdy), .test_out(test_out),
    .result_valid(res_valid), .seed_valid(seed_valid));

    initial begin
        $dumpfile("seed_val.gcd");
        $dumpvars(0, dut);
        // $dumpvars(1, gcd);
        $display("start sim");
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge gcd_rdy) begin
            seed = 3;
            m = 253;
        end
        @(posedge res_valid);
        if (seed_valid) begin
            $display("1 pass: seed_valid %x, gcd = %x", seed_valid, test_out);
        end else begin
            $display("1 fail: gcd = %x, seed_valid = %x", test_out, seed_valid);
        end

        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge gcd_rdy) begin
            seed = 3;
            m = 6;
        end
        @(posedge res_valid);
        if (~seed_valid) begin
            $display("2 pass: seed_valid %x, gcd = %x", seed_valid, test_out);
        end else begin
            $display("2 fail: gcd = %x, seed_valid = %x", test_out, seed_valid);
        end
        $finish();
    end

endmodule

// module gcd_tester();
//     localparam W = 16;
//     reg clk;
//     reg reset;
//     reg [W-1:0] seed;
//     reg [W-1:0] m;

//     wire res_valid;
//     wire seed_valid;
//     wire gcd_rdy;
//     wire [W-1:0] test_out;
//     initial clk = 0;
//     initial reset =0;
//     always #(10) clk <= ~clk;

//     gcdGCDUnit_rtl dut (.clk(clk), .reset(reset), .operands_bits_A(m), .operands_bits_B(seed), 
//     .operands_val(1'b1), .operands_rdy(gcd_rdy),
//     .result_bits_data(test_out), 
//     .result_val(res_valid), .result_rdy(1'b1));

//     initial begin
//         $dumpfile("gcd_test.vcd");
//         $dumpvars(0, dut);
//         // $dumpvars(1, gcd);
//         $display("start sim");
//         @(posedge clk);
//         reset = 1;
//         @(posedge clk);
//         reset = 0;
//         @(posedge gcd_rdy) begin
//             seed = 3;
//             m = 7;
//         end
//         @(posedge res_valid);
//         if (test_out == 3) begin
//             $display("got 3!");
//         end
//         $display("out: gcd = %x", test_out);
//         $finish();
//     end
// endmodule