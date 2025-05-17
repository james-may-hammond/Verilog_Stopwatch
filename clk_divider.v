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