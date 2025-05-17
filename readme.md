
### Targets/Features
1. Create a functioning smartwatch with verilog
2. Display output on a 7 segment display
3. The stopwatch can count up to a day `23:59:59`
4. The stopwatch has start, stop, pause functionality

### Verilog Modules Used

#### 1. Clock Divider
- Turns a general clock module (~100 MHz) down to a second (~1 Hz)
```verilog
module clk_div (
    input clk,
    output reg clk_out
    );

    integer cnt = 0;
    always @(posedge clk) begin
        if (cnt == 50000000) begin
            cnt <= 0;
            clk_out <= ~clk_out;
        end else cnt <= cnt + 1;
    end
endmodule
```

#### 2. Control Controller
- Controls which of our functions is begin used `Start, Stop, Pause`

```verilog
module control (
    input clk, stop, start, pause,
    output reg run = 0
    );
    always @(posedge clk) begin
        if (stop) run <= 0;
        else if (start) run <= 1;
        else if (pause) run <= 0;
    end
endmodule
```

#### 3. Digit Extractor
- Takes the digit count and separates it for the seven seg display
```verilog
module digit_extractor (
        input [5:0] sec, min,
        input [4:0] hr,
        output [3:0] hr1, hr0, min1, min0, sec1, sec0
    );

    assign hr1 = hr / 10;
    assign hr0 = hr % 10;
    assign min1 = min / 10;
    assign min0 = min % 10;
    assign sec1 = sec / 10;
    assign sec0 = sec % 10;

endmodule
```

#### 4. Seven Segment Display Driver
```verilog
module seven_seg_dec (
    input [3:0] digit,
    output reg [6:0] seg
    );

    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1111110;
            4'd1: seg = 7'b0110000;
            4'd2: seg = 7'b1101101;
            4'd3: seg = 7'b1111001;
            4'd4: seg = 7'b0110011;
            4'd5: seg = 7'b1011011;
            4'd6: seg = 7'b1011111;
            4'd7: seg = 7'b1110000;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1111011;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
```

#### 5. Timer Module
```verilog
module timer (
    input clk, run, clr,
    output reg [5:0] sec = 0,
    output reg [5:0] min = 0,
    output reg [4:0] hr = 0
    );
    always @(posedge clk or posedge clr) begin
        if (clr) begin 
            sec <=0;
            min <= 0;
            hr <= 0;
        end else if (run) begin 
            if (sec == 59) begin 
                sec <= 0;
                if (min == 59) begin
                    min <=0;
                    if (hr == 23) hr <= 0;
                    else hr <= hr + 1;
                end
            else 
                min <= min + 1;
        end else 
            sec <= sec + 1;
    end
    end
endmodule
```

#### 6. Stopwatch Module
```verilog
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
    seven_seg_dec d1(sec1,seg1);
    seven_seg_dec d2(min0,seg2);
    seven_seg_dec d3(min1,seg3);
    seven_seg_dec d4(hr0,seg4);
    seven_seg_dec d5(hr1,seg5);

endmodule
    
```

### Testing and Verdict
#### 1. Full Scale Test
```verilog
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
```

#### 4. A faster Testfile
```verilog
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
```

- Why two tesbenches?
	- Simply put using a complete 1 sec clk leads to some massive test files, which I have tested but are quite impractical and absurd however, I still must have some way of showing functionality and that way is using a faster test file that sort of works around that given clock
	- And of course anyone trying this module out for themselves can always alter the testbench or make an XDC file as per their requirements.