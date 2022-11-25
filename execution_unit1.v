module adder_unit1(src1_data,src2_data,func,clock1,clock2,rdest,ex_b);

//source data
input [7:0]src1_data;
input [7:0]src2_data;

//opcode
input [3:0]func,rdest;
input clock1,clock2;

//check if busy
input ex_b;


integer count_as;
integer  temp, temp1;
reg[15:0] out1;


always @(posedge clock1)
begin
    if (ex_b == 1)
    begin
        count_as = 0;

        case(func)
            4'b0000:
            begin
              //store the output
                out1 <= #40 src1_data + src2_data;
                count_as <= #41 1; 
                tmAlgo.regtable[rdest][1] <= #40 16'b1000;
                tmAlgo.regtable[rdest][0] <= #40 src1_data+src2_data;

                //release reservation station
                tmAlgo.stage3_exec_b[0] <= #40 0; 
                tmAlgo.stage3_addcount <= #40 tmAlgo.stage3_addcount - 1;     //decrement exe count
                tmAlgo.add_count <= #40 tmAlgo.add_count - 1;           //decrement RS
                #42;
            end


            4'b0001:
            begin
                out1 <= #40 src1_data - src2_data;
                count_as <= #40 1; 
                tmAlgo.regtable[rdest][1] <= #40 16'b1000;
                tmAlgo.regtable[rdest][0] <= #40 src1_data - src2_data;
                
                //release reservation statio
                tmAlgo.stage3_exec_b[0] <= #40 0; 
                tmAlgo.stage3_addcount <= #40 tmAlgo.stage3_addcount - 1;       //decrement exe count
                tmAlgo.add_count <= #40 tmAlgo.add_count - 1;             //decrement RS
                #42;
            end
        endcase


        for(temp = 0; temp <3 && (count_as == 1);temp ++)
        begin

            //update reservation station
            if(tmAlgo.adder_table[temp][4] == 0)
                begin
                    if(tmAlgo.adder_table[temp][1] == rdest)
                        tmAlgo.adder_table[temp][4] = 1;
                end
            if(tmAlgo.adder_table[temp][5] == 0)
                begin
                    if(tmAlgo.adder_table[temp][2] == rdest)
                        tmAlgo.adder_table[temp][5] = 1;
                end
        end
    end
end

endmodule


module mult_unit1(src1_data,src2_data,func,clock1,clock2,rdest,ex_b);

//source data
input [7:0]src1_data;
input [7:0]src2_data;

//opcode
input [3:0]func,rdest;

input clock1,clock2,ex_b;
integer count_md, temp, temp1;

reg[15:0] out1;

always @(posedge clock1)
begin
    if (ex_b == 1)
    begin
        count_md = 0;
        case(func)
            4'b0010:
            begin
                out1 <= #60 src1_data*src2_data;
                count_md <=  #61 1;
                
                tmAlgo.regtable[rdest][1] <= #60 16'b1000;
                tmAlgo.regtable[rdest][0] <= #60 src1_data*src2_data;
                
                //release reservation station
                tmAlgo.stage3_exec_b[2] <= #60 0; 
                tmAlgo.stage3_mulcount <= #60 tmAlgo.stage3_mulcount - 1;       //decrement exe count
                tmAlgo.mul_count <= #60 tmAlgo.mul_count - 1;             //decrement RS
                #62;  
            end
            4'b0011:
            begin
                out1 <= #80 src1_data/src2_data;
                count_md <=  #81 1;
                
                tmAlgo.regtable[rdest][1] <= #80 16'b1000;
                tmAlgo.regtable[rdest][0] <= #80 src1_data/src2_data;
                
                //release reservation station
                tmAlgo.stage3_exec_b[2] <= #80 0; 
                tmAlgo.stage3_mulcount <= #80 tmAlgo.stage3_mulcount - 1;       //decrement exe count
                tmAlgo.mul_count <= #80 tmAlgo.mul_count - 1;             //decrement RS
                #82;
            end
        endcase

        

        for(temp = 0; temp <3 && (count_md == 1);temp ++)
        begin
            //update reservation station
            if(tmAlgo.multiplier_table[temp][4] == 0)
                begin
                    if(tmAlgo.multiplier_table[temp][1] == rdest)
                        tmAlgo.multiplier_table[temp][4] = 1;
                end
            if(tmAlgo.multiplier_table[temp][5] == 0)
                begin
                    if(tmAlgo.multiplier_table[temp][2] == rdest)
                        tmAlgo.multiplier_table[temp][5] = 1;
                end
        end
    end
end

endmodule