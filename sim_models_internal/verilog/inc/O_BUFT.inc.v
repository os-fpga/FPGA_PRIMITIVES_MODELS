
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(O);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(O);
    end
  endgenerate

  assign O = T ? I : 1'bz; 

  