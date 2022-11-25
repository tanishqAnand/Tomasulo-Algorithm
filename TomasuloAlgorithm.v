//We have assumed the instructions like this
// 0000 is for addition ,0001 for subtraction
// multiplication is  0010 and division is  0011
// load instruction is  0100 and  0101 is for store
// beq is 0110 and  bneq = 0111
//Instruction’s  format is func,src1,src2,rdest
//and the  ld,store, func,src1+ s2 - base address,rdest

//Start of the tmAlgo module
module tmAlgo(pc,clock1,clock2);

  input[4:0] pc;     //program counter
  input clock1,clock2;   //The clock 1 and clock2

  wire [15:0] inst; //to get the instruction from ins set wire is present

  //  stage 1
  reg [3:0] stage1_src1,stage1_src2,stage1_func,stage1_rdest;
  reg stage2_count;
  //  stage 2
  reg [3:0] stage2_src1,stage2_src2,stage2_func,stage2_rdest;
  


  // RS stage is present in stage3
  //First Scond bit we have used for the  addition and subtraction  execution  unit
  //for multiplication and division exec unit 3rd and 4th are used
  reg [3:0] stage3_exec_b;
  reg [7:0] stage3_src1data[0:3],stage3_src2data[0:3];
  reg [3:0] stage3_func[0:3],stage3_rdest[0:3];
  
  integer stage3_addcount,stage3_mulcount;

  // issue stage code

  integer add_count,mul_count,bch_count; 
 
  reg [3:0] adder_table[0:2][0:7]; //ReserveStation addition and substraction
  reg [3:0] multiplier_table[0:2][0:7]; //ReserveStation for multiplication array
  reg [15:0] ls_queue[0:3][0:7]; 
  reg [15:0] regtable[0:15][0:1]; 
  
  reg [15:0] memory[0:255]; 


instruction_set ins1(pc,clock1,inst);

always @(posedge clock2)
  begin
  $display("\nFetch stage:");
  stage1_func = inst[15:12];
  stage1_src1 = inst[11:8];
  stage1_src2 = inst[7:4];
  stage1_rdest = inst[3:0];
  $display("pc = %b, func = %b, source1 = %b, source2 = %b,  destination = %b\n\n",pc,stage1_func,stage1_src1,stage1_src2,stage1_rdest);
end

issue is1(stage1_src1, stage1_src2, stage1_rdest, stage1_func,clock1, clock2);

endmodule //end of the tmAlgo module