`timescale 1ns/1ps

module mc_tester();
    reg clk;
    reg reset;
    reg in;

    wire [3:0] lane;
    wire out;
    initial clk = 0;
    initial reset =0;
    always #(10) clk <= ~clk;

    markov16 dut (.clk(clk), .reset(reset), .in(in),
    .lane(lane), .out(out)
    );

    initial begin
        $dumpfile("mc_test.vcd");
        $dumpvars(0, dut);
        $display("start sim");
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;

        @(posedge clk) begin
            in = 0;
        end
        #1;
        $display("in: %b, lane: %b, out: %b", in, lane, out);

        @(posedge clk) begin
            in = 0;
        end
        #1;
        $display("in: %b, lane: %b, out: %b", in, lane, out);

        @(posedge clk) begin
            in = 1;
        end
        #1;
        $display("in: %b, lane: %b, out: %b", in, lane, out);

        @(posedge clk) begin
            in = 1;
        end
        #1;
        $display("in: %b, lane: %b, out: %b", in, lane, out);

        @(posedge clk) begin
            in = 0;
        end
        #1;
        $display("in: %b, lane: %b, out: %b", in, lane, out);

        @(posedge clk) begin
            in = 1;
        end
        #1;
        $display("in: %b, lane: %b, out: %b", in, lane, out);

        $finish();
    end

endmodule