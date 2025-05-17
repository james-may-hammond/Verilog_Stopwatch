`include "clk_divider.v"
`include "control.v"
`include "seven_seg_dec.v"
`include "timer.v"
`include "digit_extractor.v"
module sw(
    input clk, clr, start, pause,
    output [6:0] seg0, seg1, seg2, seg3, seg4, seg5
    );

    // Helper Wires
    wire run, clk_1;
    wire [5:0] sec, min;   
    wire [4:0] hr;
    wire [3:0] hr1, hr0, min1, min0, sec1, sec0;

    // Main Function module network
    clk_div newclk(clk, clk_1);
    control ctrl(clk_1, clr, start, pause, run);
    timer func(clk_1, run, clr, sec, min, hr);
    digit_extractor dexter(sec, min, hr, hr1, hr0, min1, min0, sec1, sec0);

    // Display
    seven_seg_dec d0(sec0,seg0);
    seven_seg_dec d0(sec1,seg1);
    seven_seg_dec d0(min0,seg2);
    seven_seg_dec d0(min1,seg3);
    seven_seg_dec d0(hr0,seg4);
    seven_seg_dec d0(hr1,seg5);

endmodule
    