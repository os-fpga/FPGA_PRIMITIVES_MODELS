  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(I);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(I);
    end
  endgenerate

  assign O = EN ? I : 1'b0;


