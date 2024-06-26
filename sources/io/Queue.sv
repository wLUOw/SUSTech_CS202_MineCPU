module Queue (
    input  logic        clk, rst,
    input  logic [7:0]  data_in,
    input  logic        ready_in,
    output logic [31:0] data_out,
    output logic [31:0] addr_out
);

    reg [31:0] data_queue = 0;
    reg [2:0] cnt = 0;
    reg [4:0] clk_cnt = 0;
    reg [31:0] addr_out_ = 0;
    wire full;

    assign data_out = data_queue;
    assign full = (cnt == 4);

    assign addr_out = addr_out_;

    always_ff @(posedge clk) begin : addr
        if (rst) begin
            addr_out_ <= 0;
        end else if (full && clk_cnt == 0) begin
            addr_out_ <= addr_out_ + 4;
        end else begin
            addr_out_ <= addr_out_;
        end
    end

    always_ff @(posedge clk) begin : cnt_for_mem
        if (rst) begin
            clk_cnt <= 0;
        end else if (clk_cnt == 15) begin
            clk_cnt <= 0;
        end else if (full) begin
            clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= clk_cnt;
        end
    end

    always_ff @(posedge clk) begin : write
        if (rst || (full && clk_cnt == 15)) begin
            cnt <= 0;
            data_queue <= 0;
        end else if (ready_in) begin
            cnt <= cnt + 1;
            data_queue <= {data_in, data_queue[31:8]};
        end else begin
            cnt <= cnt;
            data_queue <= data_queue;
        end
    end
    
endmodule
