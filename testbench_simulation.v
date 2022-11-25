//Simulation for tmAlgo Module  
module tmAlgo_testbench;

reg[4:0] pc;         //program counter
reg clock1,clock2;   //The clock 1 and clock2
integer  k;              //integer variable k
integer clock_cycle;       // clock cycle is a int

tmAlgo ts(
.pc(pc),
.clock1(clock1),         
.clock2(clock2)
);

initial begin
  $dumpfile("tmAlgo_testbench.vcd");
  $dumpvars(0,tmAlgo_testbench);
  clock1 = 0; clock2 = 0; pc = 0;
  clock_cycle = 1;
  repeat(14)
    begin
      $display("\n\nCLOCK CYCLE : %d",clock_cycle);
      #5 clock1 = 1; #5 clock1 = 0;
      #5 clock2 = 1; #5 clock2 = 0;
      clock_cycle += 1;
    end
end

// registers are given the values
initial begin
  for(k = 0;k < 16; k++)
      ts.regtable[k][0] = k;
  
  for(k = 0;k < 3;k++)
  begin
      ts.adder_table[k][6] = 3'b0;
      ts.multiplier_table[k][6] = 3'b0;
      ts.adder_table[k][7] = 3'b0;
      ts.multiplier_table[k][7] = 3'b0;
  end
  ts.add_count = 0;
  ts.mul_count = 0;
  
  ts.stage3_exec_b = 4'b0000;
  ts.stage3_addcount = 0;
  ts.stage3_mulcount = 0;
end

always @(posedge clock2)
begin
      pc += 4'b1;
end

endmodule   //the end of the simulation code
