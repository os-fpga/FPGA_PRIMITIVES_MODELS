
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(I_P);
      pullup(I_N);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(I_P);
      pulldown(I_N);
    end
  endgenerate

  always @(I_P, I_N, EN) begin
    casez ({I_P, I_N, EN})
      3'b??0 : O = 0;      // When not enabled, output is set to zero
      3'b101 : O = 1;
      3'b011 : O = 0;
      default : begin end  // If enabled and I_P and I_N are the same, output does not change
    endcase
  end


