`timescale 1ns/1ps

module bbs_tester();
    localparam W = 16;
    reg clk;
    reg reset;
    reg [W-1:0] seed;
    wire [W-1:0] test_out;

    initial clk = 0;
    initial reset =0;
    always #(10) clk <= ~clk;

    bbs #(.W(16), .m(16'd253)) dut (.clk(clk), .reset(reset), .seed(seed), 
    .out(test_out)
    );

    reg [31:0]counter;
    always@(posedge clk) begin
        counter <= counter + 1;
        if (test_out != 0) begin
            $display("step: %d, out: %d ", counter, test_out);
        end
    end
    initial begin
        $dumpfile("bbs_top.vcd");
        $dumpvars(0, dut);
        // $dumpvars(1, gcd);
        $display("start sim");
        @(posedge clk);
        counter = 0;
        reset = 1;
        @(posedge clk);
        reset = 0;
        seed = 3;

        repeat (500) @(posedge clk);
        $finish();
    end

endmodule