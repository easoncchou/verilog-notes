// Verilog project: Verilog code for FIFO memory
// Top level module code for FIFO Memory
// prefixes: i = input, o = output, w = internal wire, r = internal register
module fifo_mem(
    o_data, o_fifo_full, o_fifo_empty, o_fifo_threshold, o_fifo_overflow, o_fifo_underflow, 
    i_clk, i_reset_n, i_wr, i_rd, i_data
);
    input i_wr, i_rd, i_clk, i_reset_n;
    input[7:0] i_data;
    output[7:0] o_data;
    output o_fifo_full, o_fifo_empty, o_fifo_threshold, o_fifo_overflow, o_fifo_overflow;

    wire[4:0] w_wrptr, w_rdptr; 
    wire w_fifo_we, w_fifo_rd // write enable, read enable

    // place instantiations here when complete
    write_pointer top1(w_wrptr, w_fifo_we, i_wr, o_fifo_full, i_clk, i_reset_n);
    read_pointer top2(w_rdptr, w_fifo_rd, i_rd, o_fifo_empty, i_clk, i_resent_n);
    memory_array top3(o_data, i_data, i_clk, w_fifo_we, w_wrptr, w_rdptr);
    status_signal top4(
        o_fifo_full, o_fifo_empty, o_fifo_threshold, o_fifo_overflow, o_fifo_underflow
        i_wr, i_rd, w_fifo_we, w_fifo_rd, w_wrptr, w_rdptr, i_clk, i_resent_n);

endmodule

// Memory Array submodule
module memory_array(o_data, i_data, i_clk, i_fifo_we, i_wrptr, i_rdptr);
    input[7:0] i_data;
    input i_clk, i_fifo_we;
    input[4:0] i_wrptr, i_rdptr;
    output[7:0] o_data;

    reg[7:0] r_data_out2[15:0];

    always @(posedge i_clk) begin
        if(i_fifo_we)
            r_data_out2[i_wrptr[3:0]] <= i_data;
    end

    assign o_data = r_data_out2[i_rdptr[3:0]];
endmodule

// Read Pointer submodule
module read_pointer(o_rdptr, o_fifo_rd, i_rd, i_fifo_empty, i_clk, i_reset_n);
    input i_rd, i_fifo_empty, i_clk, i_reset_n;
    output reg[4:0] o_rdptr;
    output o_fifo_rd;

    assign o_fifo_rd = (~i_fifo_empty) & i_rd;

    always @(posedge clk or negedge i_reset_n) begin
        if (~i_reset_n) 
            o_rdptr <= 5'b00000;
        else if (fifo_rd)
            o_rdptr <= o_rdptr + 5'b00001;
        else
            o_rdptr <= o_rdptr;
    end
endmodule

// Status Signals submodule
module status_signal(
    o_fifo_full, o_fifo_empty, o_fifo_threshold, o_fifo_overflow, o_fifo_underflow
    i_wr, i_rd, i_fifo_we, i_fifo_rd, i_wrptr, i_rdptr, i_clk, i_reset_n
);
    input i_wr, i_rd, i_fifo_we, i_fifo_rd, i_clk, i_reset_n;
    input[4:0] i_wrptr, i_rdptr;
    output reg o_fifo_full, o_fifo_empty, o_fifo_threshold, o_fifo_overflow, o_fifo_underflow;
    wire w_fbit_comp, w_overflow_set, w_underflow_set;
    wire w_pointer_equal;
    wire[4:0] w_pointer_result;
    
    // if lower four bits equal but MSB diff, then wr lapped rd.
    assign w_fbit_compfbit_comp = i_wrptr[4] ^ i_rdptr[4]; // bitwise XOR op = 1 if diff
    assign w_pointer_equal = (i_wrptr[3:0] - i_rdptr[3:0]) ? 0 : 1;
    assign w_pointer_result = i_wrptr[4:0] - i_rdptr[4:0];
    assign w_overflow_set = o_fifo_full & i_wr;
    assign w_underflow_set = o_fifo_empty & i_rd;

    always @(*) begin
        o_fifo_full = w_fbit_comp & w_pointer_equal;
        o_fifo_empty = (~w_fbit_comp) & w_pointer_equal;
        o_fifo_threshold = (w_pointer_result[4] || w_pointer_result[3]) ? 1 : 0;
    end

    always @(posedge i_clkclk or negedge i_reset_n) begin
        if (~i_reset_n)
            o_fifo_overflow <= 0;
        else if ((w_overflow_set == 1) && (i_fifo_rd == 0)) // full, still writing, and not reading
            o_fifo_overflow <= 1;
        else if (i_fifo_rd)
            o_fifo_overflow <= 0;
        else
            o_fifo_overflow <= o_fifo_overflow;
    end

    always @(posedge i_clk or negedge i_reset_n) begin
        if (~i_reset_n)
            o_fifo_underflow <= 0;
        else if ((w_underflow_set == 1) && (i_fifo_we == 0)) // empty, still reading, and not writing
            o_fifo_underflow <= 1;
        else if (i_fifo_we)
            o_fifo_underflow <= 1;
    end
endmodule

module write_pointer(o_wrptr, o_fifo_we, i_wr, i_fifo_full, i_clk, i_reset_n);
    input i_wr, i_fifo_full, i_clk, i_reset_n;
    output reg[4:0] o_wrptr;
    output o_fifo_we;

    assign o_fifo_we = (~i_fifo_full) & i_wr;

    always @(posedge i_clk or negedge i_reset_n) begin
        if (i_reset_n)
            o_wrptr <= 5'b00000;
        else if (o_fifo_we)
            o_wrptr <= wptr + 5'b00001;
        else
            o_wrptr <= o_wrptr;
    end
endmodule


