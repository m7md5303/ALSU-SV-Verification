import pack_alsu:: *;
module alsu_tb();
managing_inputs m1;
logic cin,serial_in,direction,red_op_A,red_op_B,bypass_A,bypass_B,clk,rst;
logic signed   [2:0] A,B;
logic [2:0] opcode;
logic  signed [5:0] out,out_golden;
logic [15:0]leds,leds_golden;
int error_counter,correct_counter;
//internal signal for determining the sampling start
logic sample_state;
ALSU dut(A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction, leds, out);    
ALSUg golden (clk,rst,A,B,cin,serial_in,red_op_A,red_op_B,opcode,bypass_A,bypass_B,direction,leds_golden,out_golden);
assign sample_state=((rst)||(bypass_A)||(bypass_B));
//initialising the clock
initial begin
    clk=0;
    forever begin
        #30 clk=~clk;
    end
end
//implementing the first loop
initial begin
    m1=new();
m1.constraint_mode(1);
m1.op_valid_c.constraint_mode(0);
repeat(20000) begin
    assert(m1.randomize());
    A=m1.A;
    B=m1.B;
    opcode=m1.opcode_a;
    bypass_A=m1.bypass_A;
    bypass_B=m1.bypass_B;
    direction=m1.direction;
    serial_in=m1.serial_in;
    cin=m1.cin;
    red_op_A=m1.red_op_A;
    red_op_B=m1.red_op_B;
    rst=m1.rst;
    golden_model;
end
//implementing the second loop
m1.constraint_mode(0);
m1.bypass_A.rand_mode(0);
m1.bypass_B.rand_mode(0);
m1.red_op_A.rand_mode(0);
m1.red_op_B.rand_mode(0);
bypass_A=0;
bypass_B=0;
red_op_A=0;
red_op_B=0;
m1.op_valid_c.constraint_mode(1);
repeat(20000) begin
    assert(m1.randomize());
    A=m1.A;
    B=m1.B; 
    direction=m1.direction;
    serial_in=m1.serial_in;
    cin=m1.cin;
    rst=m1.rst;
    for (int i =0 ;i<6 ;i++ ) begin
        opcode=m1.op_valid[i];
        golden_model;
    end    
end
bypass_A=0;
bypass_B=0;
rst=0;
m1.constraint_mode(1);
@(negedge clk);
repeat(25000)begin
    m1.opcode_a=OR;
@(negedge clk);
for (int i =0 ;i<6 ; i++) begin
    opcode=m1.opcode_a;
    m1.opcode_a=m1.opcode_a.next(1);
    @(negedge clk);
end
end
#1;$stop;
end






task golden_model();
    repeat(2)@(negedge clk);
    if((out!==out_golden)||(leds!==leds_golden)) begin
        $display("error at %t",$time);
        error_counter++;
    end
    else begin
        correct_counter++;
    end
endtask
//starting the sampling
always @(posedge clk ) begin
    m1.cvr_gp.sample();
end
//stopping and starting the sampling at  the required conditions
always @(*) begin
    if(sample_state)begin
        m1.cvr_gp.stop();
    end
    else begin
        m1.cvr_gp.start();
    end
end

endmodule