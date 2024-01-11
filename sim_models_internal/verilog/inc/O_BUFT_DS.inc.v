  
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(O_P);
      pullup(O_N);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(O_P);
      pulldown(O_N);
    end
  endgenerate

  assign O_P = T ? I  : 'hz;
  assign O_N = T ? ~I : 'hz;

  