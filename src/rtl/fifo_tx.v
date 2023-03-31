module fifo_tx (
    input   wire    clk,
    input   wire    rst_n,

    input   wire    wr_en,
    input   wire    rd_en,

    input   wire    [53*8-1:0]  data_in,
    output  reg     [53*8-1:0]  data_out,

    output  wire    fifo_empty,
    output  wire    fifo_full
);

    reg [3:0] front, rear;

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) 
            front   <= 4'b0; 
        else if ((~fifo_empty) & rd_en)
            front   <= front + 1'b1;
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) 
            rear    <= 4'b0; 
        else if ((~fifo_full) & wr_en)
            rear    <= rear + 1'b1;
    end

    assign fifo_empty   = (front == rear);
    assign fifo_full    = ((front - rear) == 4'b1);

    reg [53*8-1:0] Mem[0:15];
    integer i;
    
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            for (i = 0; i < 16; i = i + 1)
                Mem[i] <= 'b0;
        end
        else if ((!fifo_full) & wr_en)
            Mem[rear] <= data_in; 
    end

    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            data_out <= 'b0;
        end
        else if ((!fifo_empty) & rd_en)
            data_out <= Mem[front]; 
    end

endmodule