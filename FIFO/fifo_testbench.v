module FIFO_tb();

    reg clk;
    reg reset;
    reg write_enable;
    reg read_enable;
    reg [7:0] IN;
    wire [7:0] OUT;
    wire full;
    wire empty;
    integer i;

    FIFO dut(
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .IN(IN),
        .OUT(OUT),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fifo_test.vcd");
        $dumpvars(0, FIFO_tb);

        clk = 0;
        reset = 1;
        write_enable = 0;
        read_enable = 0;
        IN = 8'b0;

        // Release reset
        #10;
        reset = 0;

        // Test 1: Fill and read back
        write_enable = 1;
        for (i = 0; i < 8; i = i + 1) begin
            IN = i;
            #10;
        end
        write_enable = 0;

        #10;
        read_enable = 1;
        for (i = 0; i < 8; i = i + 1) begin
            #10;
            $display("Test1 Read[%0d]: %0d", i, OUT);
        end
        read_enable = 0;

        // Test 2: Write when full 
        #10;
        write_enable = 1;
        for (i = 0; i < 10; i = i + 1) begin
            IN = i + 10;
            #10;
        end
        $display("Full flag: %0b (expect 1)", full);
        write_enable = 0;

        #10;
        read_enable = 1;
        for (i = 0; i < 8; i = i + 1) begin
            #10;
            $display("Test2 Read[%0d]: %0d", i, OUT);
        end
        read_enable = 0;

        // Test 3: Read when empty
        #10;
        $display("Empty flag: %0b (expect 1)", empty);
        read_enable = 1;
        #10;
        #10;
        read_enable = 0;
        $display("Empty after read attempt: %0b (expect 1)", empty);

        // Test 4: Simultaneous read and write
        #10;
        write_enable = 1;
        IN = 8'hAA;
        #10;
        IN = 8'hBB;
        #10;
        IN = 8'hCC;
        #10;
        write_enable = 0;

        #10;
        write_enable = 1;
        read_enable = 1;
        IN = 8'hDD;
        #10;
        $display("Simul r/w - OUT: %h (expect AA)", OUT);
        IN = 8'hEE;
        #10;
        $display("Simul r/w - OUT: %h (expect BB)", OUT);
        write_enable = 0;
        read_enable = 0;

        // Test 5: Reset mid-operation 
        #10;
        write_enable = 1;
        IN = 8'hFF;
        #10;
        reset = 1;
        #10;
        reset = 0;
        write_enable = 0;
        $display("After reset - empty: %0b (expect 1), full: %0b (expect 0)", empty, full);

        $display("All tests complete.");
        $finish;
    end

endmodule