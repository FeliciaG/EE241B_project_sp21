`timescale 1ns/1ns

module bbs_tester();
    localparam W = 16;
    reg clk;
    reg reset;
    reg reseed;
    reg [W-1:0] seed;
    wire [W-1:0] test_out;
    wire out_valid;
    wire out_bit;
    initial clk = 0;
    initial reset =0;
    always #(1) clk <= ~clk;

    bbs_top #(.W(16), .m(16'd21209)) dut (.clk(clk), .reset(reset), .reseed(reseed), .seed(seed), 
    .out_valid(out_valid), .out_bit(out_bit), .out(test_out));

    reg [31:0]counter;
    always@(posedge clk) begin
        counter <= counter + 1;
        if (out_valid) begin
            $display("%b", out_bit);
            // $display("%d", test_out);
            // $display("step: %d, out_valid: %d, out: %d, 1out_bit: %d ", counter, out_valid, test_out, out_bit);
        end
    end
    initial begin
        $dumpfile("bbs_top.vcd");
        $dumpvars(0, dut);
        $display("start sim");
        @(posedge clk);
        counter = 0;
        reseed = 0;
        reset = 1;
        @(posedge clk);
        reset = 0;
        seed = 17827;
        // repeat (20) @(posedge clk);
        // seed = 223;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 6661;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 20051;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 18121;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 1423;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 3632;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 15679;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 2927;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 5233;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 8807;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 16477;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 19267;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 14251;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        reseed = 1;
        seed = 4547;
        @(posedge clk);
        reseed = 0;
        repeat (150) @(posedge clk);
        $finish();
    end

endmodule