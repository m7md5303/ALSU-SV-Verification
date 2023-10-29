package pack_alsu;
localparam MAXPOS = 3;
localparam MAXNEG = -4;
localparam ZERO = 0;
typedef enum logic [2:0] {OR,XOR,ADD,MULT,SHIFT,ROTATE,INVALID_6,INVALID_7  } opcode_e;
typedef enum logic [2:0] {OR_V,XOR_V,ADD_V,MULT_V,SHIFT_V,ROTATE_V  } opcode_valid_e;
class managing_inputs;
rand logic rst,red_op_A,red_op_B,cin,direction,serial_in;
rand logic signed  [2:0] A,B;
rand opcode_e opcode_a;
rand logic bypass_A,bypass_B;
rand opcode_valid_e op_valid [10];

covergroup cvr_gp;
A_cp: coverpoint A{
    bins data_0={0};
    bins data_max={MAXPOS};
    bins data_min={MAXNEG};
    bins Data_walkingones={1,2,-4};
    bins data_default=default;
}
B_cp: coverpoint B{
    bins data_0={0};
    bins data_max={MAXPOS};
    bins data_min={MAXNEG};
    bins Data_walkingones={1,2,-4};
    bins data_default=default;
}
ALU_cp: coverpoint opcode_a{
    bins Bins_shift[] ={SHIFT,ROTATE};
    bins Bins_arith[] ={ADD,MULT};
    bins Bins_bitwise[] ={OR,XOR};
    bins Bins_invalid ={INVALID_6,INVALID_7};
    bins Bins_trans =(OR=>XOR=>ADD=>MULT=>SHIFT=>ROTATE);

}
ALSU_6: coverpoint cin{
    bins log_cin={0,1};
}
ALSU_7: coverpoint serial_in{
    bins log_serial_in={0,1};
}
ALSU_8: coverpoint direction{
    bins log_direction={0,1};
}
ALSU_9: coverpoint red_op_A{
    bins log_red_op_A={0,1};
}
ALSU_10: coverpoint red_op_B{
    bins log_red_op_B={0,1};
}
cross A_cp, B_cp, ALU_cp{
    ignore_bins req1 =!binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_0)&&binsof(B_cp.data_0)||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_0)&&binsof(B_cp.data_max))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_0)&&binsof(B_cp.data_min))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_max)&&binsof(B_cp.data_0))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_min)&&binsof(B_cp.data_0))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_max)&&binsof(B_cp.data_max))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_max)&&binsof(B_cp.data_min))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_min)&&binsof(B_cp.data_max))||
    (binsof(ALU_cp.Bins_arith)&&binsof(A_cp.data_min)&&binsof(B_cp.data_0));
    
}
cross ALU_cp,ALSU_6{
   ignore_bins req2=!binsof(ALU_cp.Bins_arith)&&binsof(ALSU_6.log_cin);
    
}
cross ALU_cp,ALSU_7{
    ignore_bins req3=!binsof(ALU_cp) intersect{SHIFT}&&binsof(ALSU_7.log_serial_in);
    
}
cross ALU_cp,ALSU_8{
   ignore_bins req4= !binsof(ALU_cp.Bins_shift)&&binsof(ALSU_8.log_direction);
   
}
cross ALU_cp,ALSU_9,A_cp,B_cp{
    ignore_bins req5=!binsof(ALU_cp.Bins_bitwise)&&binsof (ALSU_9) intersect {1}&&binsof (A_cp) intersect{1,2,-4}&&binsof(B_cp.data_0);
    
}
cross ALU_cp,ALSU_10,A_cp,B_cp{
   ignore_bins req6= !binsof(ALU_cp.Bins_bitwise)&&binsof (ALSU_10) intersect {1}&&binsof (B_cp) intersect{1,2,-4}&&binsof(A_cp.data_0);
   
}
cross ALU_cp,ALSU_9,ALSU_10{
    ignore_bins req7= !binsof(ALU_cp.Bins_bitwise)&&((binsof(ALSU_9) intersect{1})||((binsof(ALSU_10) intersect{1})));
    
}
endgroup
constraint reset_c{
    rst dist{0:=85,1:=15};
}
constraint addr_in_c{
    if((opcode_a==ADD)||(opcode_a==MULT)){
        A dist{MAXPOS:=30,
            MAXNEG:=30,
            ZERO:=30,
            [-3:-1]:=5,
            [1:2]:=5};
        B dist{MAXPOS:=30,
            MAXNEG:=30,
            ZERO:=30,
            [-3:-1]:=5,
            [1:2]:=5};
    }
}
constraint oxredA_c{
    if((opcode_a==OR)||(opcode_a==XOR)||(red_op_A)){
        A dist{-4:=25,
               2:=25,
               1:=25,
               [-3:-0]:/18,
               3:=6};
        B dist{0:=80,
        [-4:-1]:/10,
        [1:3]:/10};
    }
}
constraint oxredB_c{
    if((opcode_a==OR)||(opcode_a==XOR)||(red_op_B)){
        B dist{-4:=25,
               2:=25,
               1:=25,
               [-3:0]:/18,
               3:=6};
        A dist{0:=80,
        [-4:-1]:/10,
        [1:3]:/10};
    }
}
constraint opcode_c{
    opcode_a dist{
        [OR:ROTATE]:/80,
        [INVALID_6:INVALID_7]:/20
    };
}
constraint op_valid_c{
    foreach(op_valid[i]){
        if(i==0){
            op_valid[i] inside {[OR_V:ROTATE_V]};
        }
        else
        op_valid[i]!=op_valid[i-1];}
}

function new();
cvr_gp =new();
endfunction
endclass    
endpackage