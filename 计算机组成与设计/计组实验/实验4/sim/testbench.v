`timescale 1ns / 1ps
module testbench();
    reg clk;
    reg rst;

    wire [31:0] writedata, dataadr;
    wire        memwrite;
    wire [31:0] display_data;

    top dut(clk, rst, writedata, dataadr, memwrite, display_data);

    initial begin
        rst <= 1;
        #200;
        rst <= 0;
    end

    always begin
        clk <= 1; #10;
        clk <= 0; #10;
    end

    always @(negedge clk) begin
        if (memwrite) begin
            if (dataadr === 32'd0 && writedata === 32'd5050) begin
                $display("Simulation succeeded: 1+2+...+100 = %0d (0x%h)",
                         writedata, writedata);
                $stop;
            end else if (dataadr === 32'd0) begin
                $display("Simulation Failed: expected 5050, got %0d", writedata);
                $stop;
            end
        end
    end

    initial begin
        #50000;
        $display("Timeout! display_data=%0d", display_data);
        $stop;
    end

endmodule
