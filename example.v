//Start of instn set module

module instruction_set(PC,clock1,output_instruction);

input [4:0] PC;    //programcounter
input clock1;           //clock input
output reg [15:0] output_instruction;       //instrn out
integer num;

//our instns are following

initial begin   

    tmAlgo.memory[0] = 16'b0010000100100011;
    tmAlgo.memory[1] = 16'b0000001101000101;
    tmAlgo.memory[2] = 16'b0000100010011010;
    tmAlgo.memory[3] = 16'b0010011110101011;
    tmAlgo.memory[4] = 16'b0011011000111000;
    tmAlgo.memory[5] = 16'b0001101101010110;

end

always@(posedge clock1)
  begin
    num = PC;
    output_instruction = tmAlgo.memory[num];  //instn assign happening
  end


endmodule //end of instn set module