// Code your design here


interface P4_if #(parameter NBIT = 16);

    /* INTERFACE SIGNALS */
    logic  clock; 
    logic               cin;
    logic               cout;
    logic [NBIT-1:0]  A;
    logic [NBIT-1:0]  B;
    logic [NBIT-1:0]  S;
  
    /* Interface port at P4 side (DUT) */
    modport P4_port (
        input   cin,
        output   cout,
        input   A,
        input   B,
        output  S
    );
   

endinterface


module P4_wrap #(parameter NBIT=16)
                (P4_if.P4_port p); 
  
  
    
    P4_ADDER #(NBIT) P4_u (
        .A      (p.A),
        .B    (p.B),
        .Cin   (p.cin),
        .S    (p.S),
        .Cout    (p.cout)
    );



endmodule


    //dummy module
    // module P4_ADDER 
    // #(parameter N = 32)
    // (
    //     input logic Cin, 
    //     input logic [N-1:0] A, 
    //     input logic [N-1:0] B,
    //     output logic Cout, 
    //     output logic [N-1:0] S 
    // );
    //   always @(A,B,Cin)
    //  begin
    //     S = A + B + Cin; 
    //  end
      
      
      
    // endmodule