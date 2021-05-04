`timescale 1ns/1ps

module ivn_tester();
    reg clk;
    reg reset;
    reg [3:0] lane;
    reg s;
    reg s_valid;
    wire [5:0] s_vn;
    wire [5:0] s_vn_valid;

    initial clk = 0;
    initial reset =0;
    always #(10) clk <= ~clk;

    ivn_top dut (.clk(clk), .reset(reset), .lane(lane), .s(s), .s_valid(s_valid),
    .s_vn(s_vn), .s_vn_valid(s_vn_valid)
    );

    initial begin
        $dumpfile("ivn_test.vcd");
        $dumpvars(0, dut);
        $display("start sim");
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        lane = 2;
        s = 0;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 2;
        s = 1;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 2;
        s = 0;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 2;
        s = 1;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 2;
        s = 1;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 2;
        s = 0;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 4;
        s = 1;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        @(posedge clk);
        lane = 5;
        s = 1;
        s_valid = 1;
        $display("s_vn: %b, s_vn_valid: %b", s_vn, s_vn_valid);
        repeat(5)@(posedge clk);
        $finish();
    end

endmodule
