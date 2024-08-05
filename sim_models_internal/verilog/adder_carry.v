//
// Copyright (C) 2022 RapidSilicon
//
//------------------------------------------------------------------------------
// 1 bit adder_carry
//------------------------------------------------------------------------------
module adder_carry (p, g, cin, sumout, cout);
    input p;
    input g;
    input cin;
    output sumout;
    output cout;

    assign {cout, sumout} = {p ? cin : g, p ^ cin};
endmodule
