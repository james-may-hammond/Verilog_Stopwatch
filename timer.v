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