
  always @(posedge C, negedge R)
    if (!R)
      Q <= 1'b0;
    else if (E)
      Q <= D;
