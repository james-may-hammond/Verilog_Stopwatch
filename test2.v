`timescale 1ns/1ps

// For test purposes only, create a modified version of clk_div
module clk_div_test (
    input clk,
    output reg clk_out = 0
);
    // Use a small counter value for testing
    integer cnt = 0;
    always @(posedge clk) begin
        if (cnt == 10) begin
            cnt <= 0;
            clk_out <= ~clk_out;
        end else cnt <= cnt + 1;
    end
endmodule

// Wrapper module that uses the test clock divider
module sw_test(
    input clk, clr, start, pause,
    output [6:0] seg0, seg1, seg2, seg3, seg4, seg5
);
    wire run, clk_1;
    wire [5:0] sec, min;   
    wire [4:0] hr;
    wire [3:0] hr1, hr0, min1, min0, sec1, sec0;

    clk_div_test newclk(clk, clk_1);
    control ctrl(clk_1, clr, start, pause, run);
    timer func(clk_1, run, clr, sec, min, hr);
    digit_extractor dexter(sec, min, hr, hr1, hr0, min1, min0, sec1, sec0);

    seven_seg_dec d0(sec0,seg0);
    seven_seg_dec d1(sec1,seg1);
    seven_seg_dec d2(min0,seg2);
    seven_seg_dec d3(min1,seg3);
    seven_seg_dec d4(hr0,seg4);
    seven_seg_dec d5(hr1,seg5);
endmodule

module sw_tb_fast();
    reg clk;
    reg clr;
    reg start;
    reg pause;
    
    wire [6:0] seg0, seg1, seg2, seg3, seg4, seg5;
    wire clk_1;
    wire run;
    wire [5:0] sec, min;
    wire [4:0] hr;
    wire [3:0] hr1, hr0, min1, min0, sec1, sec0;
    
    sw_test uut (
        .clk(clk),
        .clr(clr),
        .start(start),
        .pause(pause),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5)
    );
    
    assign clk_1 = uut.clk_1;
    assign run = uut.run;
    assign sec = uut.sec;
    assign min = uut.min;
    assign hr = uut.hr;
    assign sec0 = uut.sec0;
    assign sec1 = uut.sec1;
    assign min0 = uut.min0;
    assign min1 = uut.min1;
    assign hr0 = uut.hr0;
    assign hr1 = uut.hr1;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("sw_tb_fast.vcd");
        $dumpvars(0, sw_tb_fast);
        
        clr = 1;
        start = 0;
        pause = 0;
        
        #100 clr = 0;
        #50 start = 1;
        #50 start = 0;
        
        // Let it run until it reaches over a minute (61 seconds)
        // With our counter at 10, each clk_1 cycle is 22 time units
        // Each second needs 1 clk_1 cycle, so 61 seconds is 61*22 = 1342 time units + some margin
        #30000;
        
        pause = 1;
        #50 pause = 0;
        
        #500 start = 1;
        #50 start = 0;
        
        #5000;
        
        clr = 1;
        #100 clr = 0;
        
        #200 start = 1;
        #50 start = 0;
        
        #15000;
        
        pause = 1;
        #50 pause = 0;
        
        #500 start = 1;
        #50 start = 0;
        
        #7000;
        
        start = 1;
        pause = 1;
        #50 start = 0;
        pause = 0;
        
        #500;
        
        pause = 1;
        #50 pause = 0;
        
        #100 pause = 1;
        #50 pause = 0;
        
        #200 start = 1;
        #50 start = 0;
        

        #15000;
        clr = 1;
        #200 clr = 0;
        
        #500 start = 1;
        #50 start = 0;
        
        #50000;
        
        $finish;
    end
    
endmodule