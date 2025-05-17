`timescale 1ns/1ps

module sw_tb();
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
    
    sw uut (
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
        $dumpfile("sw_tb.vcd");
        $dumpvars(0, sw_tb);
        
        clr = 1;
        start = 0;
        pause = 0;
        
        #100 clr = 0;
        
        #100 start = 1;
        #50 start = 0;
        
        #500000000;
        
        pause = 1;
        #50 pause = 0;
        
        #200 start = 1;
        #50 start = 0;
        
        #100000;
        
        clr = 1;
        #100 clr = 0;
        
        #200 start = 1;
        #50 start = 0;
        
        #100000;
        
        start = 1;
        #50 start = 0;
        
        #100 pause = 1;
        #50 pause = 0;
        
        #100 pause = 1;
        #50 pause = 0;
        
        #500 clr = 1;
        #50 clr = 0;
        
        #200 start = 1;
        pause = 1;
        #50 start = 0;
        pause = 0;
        
        #100000;
        
        $finish;
    end
    
endmodule