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