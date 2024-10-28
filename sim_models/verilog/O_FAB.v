`timescale 1ns/1ps
`celldefine
//
// O_FAB simulation model
// Marker Buffer for fabric to periphery transition
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_FAB (
  input I, // Input
  output O // Output
);

assign O = I ;


`ifndef SYNTHESIS  
  `ifdef TIMED_SIM
    specparam T1 = 0.5;

      specify
        (I => O) = (T1);
      endspecify
  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS

endmodule
`endcelldefine
