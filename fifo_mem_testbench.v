`include "fifo_mem.v"
// timescale directive: time unit / time precision for simulations
`timescale 10 ps / 10 ps
// preprocessor directive
`define DELAY 10 // define micro with value 10 as a parameter

module tb_fifo_32;

// parameter definitions
parameter ENDTIME = 40000;

// DUT Input Regs
reg r_clk;
reg r_rst_n;
reg r_wr;
reg r_rd;
reg [7:0] r_data_in;

// DUT Output Wires
wire [7:0] w_data_out;
wire w_fifo_empty;
wire w_fifo_full;
wire w_fifo_threshold;
wire w_fifo_overflow;
wire w_fifo_underflow
integer i;

// DUT Instantiation
fifo_mem tb(
    // outputs
    w_data_out, w_fifo_full, w_fifo_empty, w_fifo_threshold, w_fifo_overflow, w_fifo_underflow,
    // inputs
    r_clk, r_rst_n, r_wr, r_rd, r_data_in
);

// Initial Conditions
initial begin
    r_clk = 1'b0;
    r_rst_n = 1'b0;
    r_wr = 1'b0;
    r_rd = 1'b0;
    r_data_in = 8'd0;
end

// Generating Test Vectors
initial begin
    main;
end

task main;
    fork
        clock_generator;
        reset_generator;
        operation_process;
        debug_fifo;
        endsimulation;
    join
endtask

task clock_generator;
    begin
        forever #`DELAY clk = !clk;
    end
endtask

task reset_generator;
    begin
        task reset_generator;
            #(`DELAY * 2) rst_n = 1'b1; // De-assert reset after 2 cycles
            #7.9 rst_n = 1'b0;          // Re-assert reset briefly
            #7.09 rst_n = 1'b1;         // Finally release reset
        endtask
    end
endtask;

task operation_process;
    for (i = 0; i < 17; i = i + 1) begin
        #(`DELAY * 5) wr = 1'b1;
        data_in = data_in + 8'd1;
        #(`DELAY * 2) wr = 1'b0;
    end
    #(`DELAY)
    for (i = 0; i < 17; i = i + 1) begin
        #(`DELAY * 2) rd = 1'b1;
        #(`DELAY * 2) rd = 1'b0;
    end
endtask

// Debug FIFO
task debug_fifo; 
    begin
        $display("----------------------------------------------");  
        $display("------------------   -----------------------");  
        $display("----------- SIMULATION RESULT ----------------");  
        $display("--------------       -------------------");  
        $display("----------------     ---------------------");  
        $display("----------------------------------------------");  
        $monitor("TIME = %d, wr = %b, rd = %b, data_in = %h",$time, wr, rd, data_in);
    end
endtask

// Self-Checking
reg [5:0] r_waddr, r_raddr;
reg [7:0] r_mem[64:0];
always @ (posedge clk) begin
    if (~r_rst_n) begin
        waddr <= 6'd0;
    end
    else if (r_wr) begin
        r_mem[r_waddr] <= r_data_in;
        r_waddr <= r_waddr + 1;
    end
    $display("TIME = %d, data_out = %d, mem = %d",$time, data_out, r_mem[r_raddr]);
    if (~rst_n) raddr <= 6'd0;
    else if (r_rd & (~w_fifo_empty)) r_raddr <= r_raddr + 1;
    if (r_rd & (~w_fifo_empty)) begin
        if (r_mem[r_raddr] == w_data_out) begin  
            $display("=== PASS ===== PASS ==== PASS ==== PASS ===");  
            if (raddr == 16) $finish;  
        end  
        else begin  
            $display ("=== FAIL ==== FAIL ==== FAIL ==== FAIL ===");  
            $display("-------------- THE SIMUALTION FINISHED ------------");  
            $finish;  
        end
    end
end


// Determine the simulation limit
task endsimulation;  
    begin  
        #ENDTIME  
        $display("-------------- THE SIMUALTION FINISHED ------------");  
        $finish;  
    end  
endtask 

endmodule