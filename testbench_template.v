module t_DUTB_name();
  reg in_a, in_b;
  wire out_1, out_2;
  
  parameter time_out = 100; // simulation timeout
  
  // instantiate UUT
  UUT_name M1_instance_name(out_1, out_2, in_a, in_b); //UUT ports go here

  initial $monitor(out_1, out_2); // signals to be monitored and displayed as text

  initial begin // stimulus patterbs
    #10 in_a = 0; in_b = 1;
    #10 in_a = 1;
  end
  
endmodule
