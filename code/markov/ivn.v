module ivn_top (
    input clk,
    input reset,
    input [3:0] lane,
    input s,
    input s_valid,
    output [5:0] s_vn,
    output [5:0] s_vn_valid
);
    wire [5:0] s_store;
    wire [5:0] s_valid_store;
    wire [5:0] s_load;
    wire [5:0] s_valid_load;
    reg [3:0] reg_lane;
    // do we need an extra bit for current lane?
    reg [3:0] current_lane;
    reg wen;
    reg load;

    parameter WAIT = 2'd0;
    parameter STORE = 2'd1;
    parameter LOAD = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;
    always @(*) begin
        case(state) 
        WAIT: begin
            wen = 1'b0;
            load = 1'b0;
            if (current_lane != lane) begin
                next_state = STORE;
            end else begin
                next_state = WAIT;
            end
        end
        STORE: begin
            reg_lane = current_lane;
            wen = 1'b1;
            load = 1'b0;
            next_state = LOAD;
        end
        LOAD: begin
            reg_lane = lane;
            wen = 1'b0;
            load = 1'b1;
            next_state = WAIT;
        end
        endcase
    end
    always @(posedge clk) begin
        if (reset) begin
            state <= WAIT;
            current_lane <= 0;
        end else begin
            state <= next_state;
            if (state == LOAD) begin
                current_lane <= lane;
            end
        end 
    end 
    ivn_register ivn_reg(.clk(clk), .reset(reset), .wen(wen), .lane(reg_lane), .s_store(s_store), .s_valid_store(s_valid_store),
    .s_load(s_load), .s_valid_load(s_valid_load)
    );

    ivn_logic shared_logic(.clk(clk), .reset(reset), .load(load), .s_load(s_load), .s_valid_load(s_valid_load),
    .s(s), .s_valid(s_valid), .s_vn(s_vn), .s_vn_valid(s_vn_valid), .s_store(s_store), .s_valid_store(s_valid_store)
    );

endmodule

module ivn_register (
    input clk,
    input reset,
    input wen,
    input [3:0] lane,
    input [5:0] s_store,
    input [5:0] s_valid_store,
    output [5:0] s_load,
    output [5:0] s_valid_load
);
    reg [11:0] registers [15:0];
    assign s_load = registers[lane][5:0];
    assign s_valid_load = registers[lane][11:6];

    always@(posedge clk) begin
        if (reset) begin
            registers[0] <= 0;
            registers[1] <= 0;
            registers[2] <= 0;
            registers[3] <= 0;
            registers[4] <= 0;
            registers[5] <= 0;
            registers[6] <= 0;
            registers[7] <= 0;
            registers[8] <= 0;
            registers[9] <= 0;
            registers[10] <= 0;
            registers[11] <= 0;
            registers[12] <= 0;
            registers[13] <= 0;
            registers[14] <= 0;
            registers[15] <= 0;
        end
        if (wen) begin
            registers[lane][5:0] <= s_store;
            registers[lane][11:6] <= s_valid_store;
        end
    end
endmodule

// hardcoded 3 levels, 6 pes
module ivn_logic (
    input clk,
    input reset,
    input load,
    input [5:0] s_load,
    input [5:0] s_valid_load,
    input s,
    input s_valid,
    output [5:0] s_store,
    output [5:0] s_valid_store,
    output [5:0] s_vn,
    output [5:0] s_vn_valid
);
    wire [2:0] s_xor;
    wire [2:0] s_xor_valid;
    wire [2:0] s_r;
    wire [2:0] s_r_valid;

    reg [5:0] s_in;
    reg [5:0] s_valid_in;
    always @(*) begin
        if (load) begin
            s_in = s_load;
            s_valid_in = s_valid_load;
        end else begin
            s_in[0] = s;
            s_valid_in[0] = s_valid;

            s_in[1] = s_xor[0];
            s_valid_in[1] = s_xor_valid[0];

            s_in[2] = s_r[0];
            s_valid_in[2] = s_r_valid[0];

            s_in[3] = s_xor[1];
            s_valid_in[3] = s_xor_valid[1];

            s_in[4] = s_r[1];
            s_valid_in[4] = s_r_valid[1];

            s_in[5] = s_xor[2];
            s_valid_in[5] = s_xor_valid[2];
        end
    end

    ivn_pe pe0(.clk(clk), .reset(reset), .s(s_in[0]), .s_valid(s_valid_in[0]),
    .s_vn(s_vn[0]), .s_vn_valid(s_vn_valid[0]), .s_xor(s_xor[0]), .s_xor_valid(s_xor_valid[0]),
    .s_r(s_r[0]), .s_r_valid(s_r_valid[0]), .s_store(s_store[0]), .s_valid_store(s_valid_store[0]));
    
    ivn_pe pe1(.clk(clk), .reset(reset), .s(s_in[1]), .s_valid(s_valid_in[1]),
    .s_vn(s_vn[1]), .s_vn_valid(s_vn_valid[1]), .s_xor(s_xor[1]), .s_xor_valid(s_xor_valid[1]),
    .s_r(s_r[1]), .s_r_valid(s_r_valid[1]), .s_store(s_store[1]), .s_valid_store(s_valid_store[1]));

    ivn_pe pe2(.clk(clk), .reset(reset), .s(s_in[2]), .s_valid(s_valid_in[2]),
    .s_vn(s_vn[2]), .s_vn_valid(s_vn_valid[2]), .s_xor(s_xor[2]), .s_xor_valid(s_xor_valid[2]),
    .s_r(s_r[2]), .s_r_valid(s_r_valid[2]), .s_store(s_store[2]), .s_valid_store(s_valid_store[2]));

    ivn_pe pe3(.clk(clk), .reset(reset), .s(s_in[3]), .s_valid(s_valid_in[3]),
    .s_vn(s_vn[3]), .s_vn_valid(s_vn_valid[3]), .s_xor(), .s_xor_valid(),
    .s_r(), .s_r_valid(), .s_store(s_store[3]), .s_valid_store(s_valid_store[3]));

    ivn_pe pe4(.clk(clk), .reset(reset), .s(s_in[4]), .s_valid(s_valid_in[4]),
    .s_vn(s_vn[4]), .s_vn_valid(s_vn_valid[4]), .s_xor(), .s_xor_valid(),
    .s_r(), .s_r_valid(), .s_store(s_store[4]), .s_valid_store(s_valid_store[4]));

    ivn_pe pe5(.clk(clk), .reset(reset), .s(s_in[5]), .s_valid(s_valid_in[5]),
    .s_vn(s_vn[5]), .s_vn_valid(s_vn_valid[5]), .s_xor(), .s_xor_valid(),
    .s_r(), .s_r_valid(), .s_store(s_store[5]), .s_valid_store(s_valid_store[5]));
endmodule


module ivn_pe (
    input clk,
    input reset,
    input s,
    input s_valid,
    output s_vn,
    output s_vn_valid,
    output s_xor,
    output s_xor_valid,
    output s_r,
    output s_r_valid, 
    output s_store,
    output s_valid_store
);
    reg s_reg;
    reg s_valid_reg;

    assign s_store = s_reg;
    assign s_valid_store = s_valid_reg;

    assign s_vn = s_reg;
    assign s_vn_valid = (s_valid_reg && s_valid) && (s_reg !=s);

    assign s_xor = s_reg ^ s;
    assign s_xor_valid = s_valid_reg && s_valid;

    assign s_r = s_reg;
    assign s_r_valid = (s_valid_reg && s_valid) && (s_reg ==s);

    always@(posedge clk) begin
        if (reset) begin
            s_reg <= 0;
            s_valid_reg <= 0;
        end else begin
            s_reg <= s;
            s_valid_reg <= s_valid;
        end
    end
endmodule