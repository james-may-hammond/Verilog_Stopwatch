module control (
    input clk, stop, start, pause
    output reg run = 0
    );
    always @(posedge clk) begin
        if (stop) run <= 0;
        else if (start) run <= 1;
        else if (pause) run <= 0;
    end
endmodule