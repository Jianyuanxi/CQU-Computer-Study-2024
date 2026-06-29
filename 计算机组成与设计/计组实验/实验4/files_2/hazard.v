// hazard.v - 严格按指导书Listing 5/6/7/8实现
module hazard(
    input  wire [4:0] rsD, rtD, rsE, rtE,
    input  wire [4:0] writeregE, writeregM, writeregW,
    input  wire       regwriteE, regwriteM, regwriteW,
    input  wire       memtoregE, memtoregM,
    input  wire       branchD,
    output reg  [1:0] forwardAE, forwardBE,
    output reg        forwardAD, forwardBD,
    output wire       stallF, stallD, flushE
);
    // EX前推（Listing 5）
    always @(*) begin
        if      (rsE!=5'd0 && rsE==writeregM && regwriteM) forwardAE=2'b10;
        else if (rsE!=5'd0 && rsE==writeregW && regwriteW) forwardAE=2'b01;
        else                                                forwardAE=2'b00;

        if      (rtE!=5'd0 && rtE==writeregM && regwriteM) forwardBE=2'b10;
        else if (rtE!=5'd0 && rtE==writeregW && regwriteW) forwardBE=2'b01;
        else                                                forwardBE=2'b00;
    end

    // ID分支前推（Listing 7）
    always @(*) begin
        forwardAD = (rsD!=5'd0) && (rsD==writeregM) && regwriteM;
        forwardBD = (rtD!=5'd0) && (rtD==writeregM) && regwriteM;
    end

    // lw-use暂停（Listing 6）
    wire lwstall = ((rsD==rtE)||(rtD==rtE)) && memtoregE;

    // 控制冒险暂停（Listing 8）
    wire branchstall =
        (branchD && regwriteE  && (writeregE==rsD || writeregE==rtD)) ||
        (branchD && memtoregM  && (writeregM==rsD || writeregM==rtD));

    assign stallF = lwstall || branchstall;
    assign stallD = lwstall || branchstall;
    assign flushE = lwstall || branchstall;

endmodule
