module FIFO(
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire read_enable,
    input wire [7:0] IN,
    output reg [7:0] OUT,
    output wire full,
    output wire empty
);

    reg [7:0] mem [0:7];
    reg [2:0] write_ptr;
    reg [2:0] read_ptr;
    reg [3:0] count;

    assign full  = (count == 8);
    assign empty = (count == 0);

    always @(posedge clk) begin
        if (reset) begin
            write_ptr <= 3'b0;
            read_ptr  <= 3'b0;
            count     <= 4'b0;
        end
        else begin
            if (write_enable && !full && read_enable && !empty) begin
                // both operations at the same time
                mem[write_ptr] <= IN;
                write_ptr <= write_ptr + 1;
                OUT <= mem[read_ptr];
                read_ptr <= read_ptr + 1;
                // count does not increase.
            end
            else if (write_enable && !full) begin
                mem[write_ptr] <= IN;
                write_ptr <= write_ptr + 1;
                count <= count + 1;
            end
            else if (read_enable && !empty) begin
                OUT <= mem[read_ptr];
                read_ptr <= read_ptr + 1;
                count <= count - 1;
            end
        end
    end

endmodule