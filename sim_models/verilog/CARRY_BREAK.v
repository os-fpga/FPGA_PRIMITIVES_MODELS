// -----------------------------------------------------------------------------
// Copyright, Rapid Silicon (Thierry Besson)
//
// This verilog module definition of 'CARRY_BREAK' describes an implementation
// of the regular CARRY module where we break the COUT -> next CIN link by
// passing it through the 'O' pin (the carry sum) of another CARRY
// 'cout_to_data'. Then this 'O' pin net drives another CARRY through the 'G'
// pin to restart a new carry chain.
// -----------------------------------------------------------------------------
module CARRY_BREAK(P, G, CIN, O, COUT);
  input CIN;
  output COUT;
  input G;
  output O;
  input P;

  wire cout;
  wire still_cout;

  // Reminder of CARRY functions: COUT and O
  //
  // assign {COUT, O} = {P ? CIN : G, P ^ CIN};

  CARRY carry_break (  // This one replaces the original CARRY cell
    .CIN(CIN),
    .COUT(cout),  // try to break this COUT net
    .G(G),
    .O(O),
    .P(P)
  );

  // We break the CI -> CO chain and pass the COUT net 'cout" through the 
  // 'O' pin (carry sum) of a new CARRY to become a regular data 'still_cout'.
  //
  CARRY cout_to_data  (
    .CIN(cout),
    .G(1'h0),
    .O(still_cout),  // still_cout = P ^ CIN = 1'h0 ^ cout = cout
    .P(1'h0)
  );

  // Carry cell 'data_to_cout' reads in the 'still_cout' data and drives it 
  // through the 'COUT' pin to restart a CO -> CI new carry chain.
  //
  CARRY data_to_cout  (
    .COUT(COUT),
    .G(still_cout),
    .P(1'h0)
  );

endmodule
