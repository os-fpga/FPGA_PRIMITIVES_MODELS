
  always @(negedge R)
    Q <= 1'b0;

  always @(C)
    if (!R)
      Q <= 1'b0;
    else if (E) 
      if (C)
        Q <= D[0];
      else
        Q <= D[1];
