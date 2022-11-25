//start of issue module
module issue (src1, src2, rdest, func,clock1, clock2);

input [3:0] src1, src2, rdest, func;
wire [3:0] src1_data,src2_data;
input clock1, clock2;
output reg [15:0] Zout;


always @(posedge clock1)
begin
    tmAlgo.stage2_count = 0;
    
            if((tmAlgo.add_count < 3) && (func == 4'b0000 || func == 4'b0001))
                tmAlgo.stage2_count   =  1;
            else if((tmAlgo.mul_count < 3) && (func == 4'b0010 || func == 4'b0011))
                tmAlgo.stage2_count = 1;
     
    
    if (tmAlgo.stage2_count == 1)
    begin
        
        if((func == 4'b0000) || (func == 4'b0001))
            tmAlgo.add_count += 1;
        if((func == 4'b0010) || (func == 4'b0011))
            tmAlgo.mul_count += 1;
    end

    tmAlgo.stage2_src1 <= src1;
    tmAlgo.stage2_src2 <= src2;
    tmAlgo.stage2_func <= func;
    tmAlgo.stage2_rdest <= rdest;

    #2;
    $display("\nIssue stage :");
    $display("func(%b),rdest(%b),count(%b)\n\n",tmAlgo.stage2_func,tmAlgo.stage2_rdest,tmAlgo.stage2_count);
end

Rstation_append rs(tmAlgo.stage2_src1,tmAlgo.stage2_src2, tmAlgo.stage2_func,clock1,clock2,tmAlgo.stage2_rdest,tmAlgo.stage2_count);

endmodule 




//ReservationStatn Modle
module Rstation_append(src1,src2,func,clock1,clock2,rdest,count);

input count;
input[3:0] src1,src2,func,rdest;

reg src1_b,src2_b;
reg [3:0] ex_b;
input clock1,clock2;
integer temp,temp2,temp3,temp4,temp5;
integer add_index,mul_index, exec_count;

always @(posedge clock2)
  begin
  
      if(tmAlgo.regtable[src1][1] < 16'b1000)
          src1_b = 0;
      else
          src1_b = 1;

      if(tmAlgo.regtable[src2][1] < 16'b1000)
          src2_b = 0;
      else
          src2_b = 1;


      for(temp4 = 0; temp4 <= 2; temp4++)
      begin
        if((func == 4'b0000)||(func == 4'b0001))
        begin
          if(tmAlgo.adder_table[temp4][6] == 0)
          begin
                add_index = temp4;
                temp4 = 5;
              end
          end
        else if((func == 4'b0010)||(func == 4'b0011))
        begin
          if(tmAlgo.multiplier_table[temp4][6] == 0)
          begin
                mul_index = temp4;
                temp4 = 5;
          end
        end
      end
      if (count == 1)
      begin
        
        if ((func == 4'b0000)||(func == 4'b0001))
        begin
           //for add and sub
            tmAlgo.adder_table[add_index][0] <= func;
            tmAlgo.adder_table[add_index][1] <= src1;
            tmAlgo.adder_table[add_index][2] <= src2;
            
            tmAlgo.adder_table[add_index][4] <= src1_b;
            tmAlgo.adder_table[add_index][5] <= src2_b;
            tmAlgo.adder_table[add_index][6] <= 1;
            tmAlgo.adder_table[add_index][7] <= 0;
        end
        // for mult and div
        else if ((func == 4'b0010)||(func == 4'b0011))
        begin
            tmAlgo.multiplier_table[mul_index][0] <= func;
            tmAlgo.multiplier_table[mul_index][1] <= src1;
            tmAlgo.multiplier_table[mul_index][2] <= src2;
            
            tmAlgo.multiplier_table[mul_index][4] <= src1_b;
            tmAlgo.multiplier_table[mul_index][5] <= src2_b;
            tmAlgo.multiplier_table[mul_index][6] <= 1;
            tmAlgo.multiplier_table[mul_index][7] <= 0;
        end
       
      end
  end

always @(posedge clock2)
  begin
    ex_b = 4'b0000;   //intitially all are busy

    //For add & mult exec 
    for(temp2 = 0; temp2 < 3; temp2++)
    begin
   
      if((tmAlgo.adder_table[temp2][4] == 3'b1) && (tmAlgo.adder_table[temp2][5] == 3'b1) && (tmAlgo.adder_table[temp2][6] == 1) && (tmAlgo.stage3_addcount < 2) && (tmAlgo.adder_table[temp2][7] == 0))
      begin
        if(tmAlgo.stage3_exec_b[0] == 0)
        begin
            
            tmAlgo.stage3_src1data[0] <= tmAlgo.regtable[tmAlgo.adder_table[temp2][1]][0];
            tmAlgo.stage3_src2data[0] <= tmAlgo.regtable[tmAlgo.adder_table[temp2][2]][0];
            tmAlgo.stage3_func[0] <=  tmAlgo.adder_table[temp2][0];
            
            
            tmAlgo.adder_table[temp2][7] <= 1; //To know that the inst is in exec stage
            ex_b[0] <= 1;
            tmAlgo.stage3_exec_b[0] <= 1;
            tmAlgo.stage3_addcount += 1;
        end
        else if(tmAlgo.stage3_exec_b[1] == 0)
        begin
            
            tmAlgo.stage3_src1data[1] <= tmAlgo.regtable[tmAlgo.adder_table[temp2][1]][0];
            tmAlgo.stage3_src2data[1] <= tmAlgo.regtable[tmAlgo.adder_table[temp2][2]][0];
            tmAlgo.stage3_func[1] <=  tmAlgo.adder_table[temp2][0];
            
           
            tmAlgo.adder_table[temp2][7] <= 1; //To know that the instruction is in exec stage
            ex_b[1] <= 1;
            tmAlgo.stage3_exec_b[1] <= 1;
            tmAlgo.stage3_addcount += 1;
        end
      end
    end
    
    //For multi and div exec units
    for(temp3 = 0; temp3 < 3; temp3++)
    begin
      if((tmAlgo.multiplier_table[temp3][4] == 3'b1) && (tmAlgo.multiplier_table[temp3][5] == 3'b1) && (tmAlgo.multiplier_table[temp3][6] == 1) && (tmAlgo.stage3_mulcount < 2) && (tmAlgo.multiplier_table[temp3][7] == 0))
      begin
        if(tmAlgo.stage3_exec_b[2] == 0)
          begin
            
            tmAlgo.stage3_src1data[2] <= tmAlgo.regtable[tmAlgo.multiplier_table[temp3][1]][0];
            tmAlgo.stage3_src2data[2] <= tmAlgo.regtable[tmAlgo.multiplier_table[temp3][2]][0];
            tmAlgo.stage3_func[2] <=  tmAlgo.multiplier_table[temp3][0];
           
        
            tmAlgo.multiplier_table[temp3][7] <= 1;
            ex_b[2] <= 1;
            tmAlgo.stage3_exec_b[2] <= 1;
            tmAlgo.stage3_mulcount += 1;
          end
        else if(tmAlgo.stage3_exec_b[3] == 0)
          begin
            
            tmAlgo.stage3_src1data[3] <= tmAlgo.regtable[tmAlgo.multiplier_table[temp3][1]][0];
            tmAlgo.stage3_src2data[3] <= tmAlgo.regtable[tmAlgo.multiplier_table[temp3][2]][0];
            tmAlgo.stage3_func[3] <=  tmAlgo.multiplier_table[temp3][0];
           
            tmAlgo.multiplier_table[temp3][7] <= 1;
            ex_b[3] <= 1;
            tmAlgo.stage3_exec_b[3] <= 1;
            tmAlgo.stage3_mulcount += 1;
          end
      end
    end

  //Reservation Stations  cols are : func,src1,src2,src1b,src2b,busy here
  #3;
  $display("Reservation Station: ");
 
  $display("\nMultiplication and Division RS");
  for(temp = 0;temp <= 2;temp++)
    $display("Opcode = %b, src1_b = %b src2_b = %b, busy = %b, RS = %b",tmAlgo.multiplier_table[temp][0],tmAlgo.multiplier_table[temp][4],tmAlgo.multiplier_table[temp][5],tmAlgo.multiplier_table[temp][6],tmAlgo.multiplier_table[temp][7]);
    
  $display("\nAddition and Subtraction RS");
  for(temp = 0;temp <= 2;temp++)
    $display("Opcode = %b, src1_b = %b src2_b = %b, busy = %b,  RS = %b",tmAlgo.adder_table[temp][0],tmAlgo.adder_table[temp][4],tmAlgo.adder_table[temp][5],tmAlgo.adder_table[temp][6],tmAlgo.adder_table[temp][7]);

  end

adder_unit1 ex1(tmAlgo.stage3_src1data[0],tmAlgo.stage3_src2data[0],tmAlgo.stage3_func[0],clock1,clock2,tmAlgo.stage3_rdest[0],ex_b[0]);
adder_unit2 ex2(tmAlgo.stage3_src1data[1],tmAlgo.stage3_src2data[1],tmAlgo.stage3_func[1],clock1,clock2,tmAlgo.stage3_rdest[1],ex_b[1]);
mult_unit1 ex3(tmAlgo.stage3_src1data[2],tmAlgo.stage3_src2data[2],tmAlgo.stage3_func[2],clock1,clock2,tmAlgo.stage3_rdest[2],ex_b[2]);
mult_unit2 ex4(tmAlgo.stage3_src1data[3],tmAlgo.stage3_src2data[3],tmAlgo.stage3_func[3],clock1,clock2,tmAlgo.stage3_rdest[3],ex_b[3]);
endmodule


