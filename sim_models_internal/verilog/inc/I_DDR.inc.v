
  always @(negedge R)
    Q <= 2'b00;

  always @(C)
    if (!R)
      Q <= 2'b00;
    else if (E) 
      if (C)
        Q[0] <= D;
      else
        Q[1] <= D;
