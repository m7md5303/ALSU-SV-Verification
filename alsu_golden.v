module ALSUg (clk,rst,A,B,cin,serial_in,red_op_A,red_op_B,opcode,bypass_A,bypass_B,direction,leds,out);
parameter INPUT_PRIORITY="A";
parameter FULL_ADDER="ON";
input clk,rst,cin,serial_in,red_op_A,red_op_B,bypass_A,bypass_B,direction;
input [2:0] A,B,opcode;
output [15:0] leds;
output [5:0] out;
reg cin_ff,serial_in_ff,red_op_A_ff,red_op_B_ff,bypass_A_ff,bypass_B_ff,direction_ff;
reg [2:0] A_ff,B_ff,opcode_ff;
reg [15:0] leds_tmp;
reg [5:0] out_tmp;
//creating the DFFs for the inputs:
always @(posedge clk or posedge rst) begin
    if(rst) begin
    A_ff<=0;
    end 
    else begin
    A_ff<=A;
    end
end  
always @(posedge clk or posedge rst) begin
     if(rst) begin
    B_ff<=0;
    end 
    else begin
    B_ff<=B;
    end
end 
always @(posedge clk or posedge rst ) begin
     if(rst) begin
    opcode_ff<=0;
    end 
    else begin
    opcode_ff<=opcode;
    end
end 
always @(posedge clk or posedge rst) begin
    if(rst) begin
    cin_ff<=0;
    end 
    else begin
    cin_ff<=cin;
    end
end 
always @(posedge clk or posedge rst) begin
     if(rst) begin
    serial_in_ff<=0;
    end 
    else begin
    serial_in_ff<=serial_in;
    end
end 
always @(posedge clk or posedge rst) begin
     if(rst) begin
    red_op_A_ff<=0;
    end 
    else begin
    red_op_A_ff<=red_op_A;
    end
end 
always @(posedge clk or posedge rst) begin
     if(rst) begin
    red_op_B_ff<=0;
    end 
    else begin
    red_op_B_ff<=red_op_B;
    end
end 
always @(posedge clk or posedge rst) begin
     if(rst) begin
   bypass_A_ff<=0;
    end 
    else begin
    bypass_A_ff<=bypass_A;
    end
end 
always @(posedge clk or posedge rst) begin
     if(rst) begin
    bypass_B_ff<=0;
    end 
    else begin
    bypass_B_ff<=bypass_B;
    end
end 
always @(posedge clk or posedge rst) begin
    if(rst) begin
    direction_ff<=0;
    end 
    else begin
    direction_ff<=direction;
    end
end 
////////////////////////////////////////////////
always @(posedge clk or posedge rst) begin
    if(rst)begin
        out_tmp<=0;
        leds_tmp<=0;
    end
    else if((bypass_A_ff&&!bypass_B_ff)||(bypass_A_ff&&(INPUT_PRIORITY=="A")))begin
        out_tmp<=A_ff;
        leds_tmp<=0;
    end 
    else if((bypass_B_ff&&!bypass_A_ff)||(bypass_B_ff&&(INPUT_PRIORITY=="B")))begin
        out_tmp<=B_ff;
        leds_tmp<=0;
    end
    else if(((red_op_A_ff | red_op_B_ff) & ((opcode_ff[1] | opcode_ff[2])))||(opcode_ff==3'b110)||(opcode_ff==3'b111)) begin
        out_tmp<=0;
        leds_tmp<=(~(leds_tmp));
    end
    else begin
        casex ({opcode_ff,red_op_A_ff,red_op_B_ff})
        5'b00000:begin
            out_tmp<=A_ff|B_ff;
            leds_tmp<=0;
        end
        5'b00010:begin
            out_tmp<=|A_ff;
            leds_tmp<=0;
        end
        5'b00001:begin
            out_tmp<=|B_ff;
            leds_tmp<=0;
        end
        5'b00011:begin
            if(INPUT_PRIORITY=="A")begin
                out_tmp<=|A_ff;
                leds_tmp<=0;
            end
            else if(INPUT_PRIORITY=="B") begin
                out_tmp<=|B_ff;
                leds_tmp<=0; 
            end
        end
        5'b00100:begin
            out_tmp<=A_ff^B_ff;
            leds_tmp<=0;
        end
        5'b00110:begin
            out_tmp<=^A_ff;
            leds_tmp<=0;
        end
        5'b00101:begin
            out_tmp<=^B_ff;
            leds_tmp<=0;
        end
        5'b00111:begin
             if(INPUT_PRIORITY=="A")begin
                out_tmp<=^A_ff;
                leds_tmp<=0;
            end
            else if(INPUT_PRIORITY=="B") begin
                out_tmp<=^B_ff;
                leds_tmp<=0; 
            end
        end
        5'b010xx:begin
            if(FULL_ADDER=="ON") begin
                out_tmp<=A_ff+B_ff+cin_ff;
            end
            else if (FULL_ADDER=="OFF") begin
                out_tmp<=A_ff+B_ff;
            end
            leds_tmp<=0;
        end
        5'b011xx:begin
            out_tmp<=A_ff*B_ff;
            leds_tmp<=0;
        end
        5'b100xx:begin
            if(direction_ff)begin
                out_tmp<={out_tmp[4:0],serial_in_ff};
            end
            else begin
                out_tmp<={serial_in_ff,out_tmp[5:1]};
            end
            leds_tmp<=0;
        end
        5'b101xx:begin
            if(direction_ff)begin
                out_tmp<={out_tmp[4:0],out_tmp[5]};
            end
            else begin
                out_tmp<={out_tmp[0],out_tmp[5:1]};
            end
            leds_tmp<=0;
        end
        endcase
    end
end
assign out=out_tmp;
assign leds=leds_tmp;
endmodule 
