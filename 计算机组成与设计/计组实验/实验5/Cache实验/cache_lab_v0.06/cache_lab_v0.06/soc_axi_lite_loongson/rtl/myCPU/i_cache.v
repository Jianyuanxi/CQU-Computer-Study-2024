// ============================================================
//  i_cache.v — 直接映射写直通指令Cache
//  INDEX_WIDTH=10, OFFSET_WIDTH=2 → 4KB, 1024 cachelines, 每line=1word
//  接口：类SRAM（cpu侧） ↔ 类SRAM（axi侧）
//  指令Cache只读，无写操作，FSM：IDLE → RM
// ============================================================
module i_cache (
    input wire clk, rst,
    // mips core 侧（类sram）
    input         cpu_inst_req     ,
    input         cpu_inst_wr      ,
    input  [1 :0] cpu_inst_size    ,
    input  [31:0] cpu_inst_addr    ,
    input  [31:0] cpu_inst_wdata   ,
    output [31:0] cpu_inst_rdata   ,
    output        cpu_inst_addr_ok ,
    output        cpu_inst_data_ok ,
    // axi interface 侧（类sram）
    output         cache_inst_req     ,
    output         cache_inst_wr      ,
    output  [1 :0] cache_inst_size    ,
    output  [31:0] cache_inst_addr    ,
    output  [31:0] cache_inst_wdata   ,
    input   [31:0] cache_inst_rdata   ,
    input          cache_inst_addr_ok ,
    input          cache_inst_data_ok
);

// ——— 参数 ———
parameter INDEX_WIDTH  = 10;
parameter OFFSET_WIDTH = 2;
localparam TAG_WIDTH   = 32 - INDEX_WIDTH - OFFSET_WIDTH; // 20
localparam CACHE_DEPTH = 1 << INDEX_WIDTH;                // 1024

// ——— Cache存储阵列（LUT-RAM） ———
reg                  cache_valid [CACHE_DEPTH-1:0];
reg [TAG_WIDTH-1:0]  cache_tag   [CACHE_DEPTH-1:0];
reg [31:0]           cache_block [CACHE_DEPTH-1:0];

// ——— 地址分解 ———
wire [OFFSET_WIDTH-1:0] offset = cpu_inst_addr[OFFSET_WIDTH-1:0];
wire [INDEX_WIDTH-1:0]  index  = cpu_inst_addr[INDEX_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
wire [TAG_WIDTH-1:0]    tag    = cpu_inst_addr[31:INDEX_WIDTH+OFFSET_WIDTH];

// ——— 当前cacheline ———
wire c_valid = cache_valid[index];
wire [TAG_WIDTH-1:0] c_tag   = cache_tag  [index];
wire [31:0]          c_block = cache_block[index];

// ——— 命中判断 ———
wire hit  = c_valid & (c_tag == tag);
wire miss = ~hit;

// ——— FSM ———
localparam IDLE = 1'b0;
localparam RM   = 1'b1;
reg state;

always @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else case (state)
        IDLE: state <= (cpu_inst_req & miss) ? RM : IDLE;
        RM  : state <= cache_inst_data_ok    ? IDLE : RM;
    endcase
end

// ——— 保存请求时的tag/index（miss期间地址可能变化） ———
reg [TAG_WIDTH-1:0]  tag_save;
reg [INDEX_WIDTH-1:0] index_save;

always @(posedge clk) begin
    tag_save   <= rst ? 0 : (cpu_inst_req ? tag   : tag_save  );
    index_save <= rst ? 0 : (cpu_inst_req ? index : index_save);
end

// ——— 向AXI发送读请求的握手辅助 ———
// read_req：state==RM时持续为1
// addr_rcv：addr_ok之后拉高，data_ok之后清零（防止重发）
wire read_req;
reg  addr_rcv;
wire read_finish;

assign read_req    = (state == RM);
assign read_finish = cache_inst_data_ok;

always @(posedge clk) begin
    addr_rcv <= rst         ? 1'b0 :
                (cache_inst_req & cache_inst_addr_ok) ? 1'b1 :
                read_finish ? 1'b0 : addr_rcv;
end

// ——— 填充Cache ———
integer t;
always @(posedge clk) begin
    if (rst) begin
        for (t = 0; t < CACHE_DEPTH; t = t+1)
            cache_valid[t] <= 1'b0;
    end else if (read_finish) begin
        cache_valid[index_save] <= 1'b1;
        cache_tag  [index_save] <= tag_save;
        cache_block[index_save] <= cache_inst_rdata;
    end
end

// ——— 输出到CPU侧 ———
assign cpu_inst_rdata   = hit ? c_block : cache_inst_rdata;
// addr_ok：hit时直接接受，miss时等AXI的addr_ok
assign cpu_inst_addr_ok = (cpu_inst_req & hit) | (cache_inst_req & cache_inst_addr_ok);
// data_ok：hit时立刻返回，miss时等data_ok
assign cpu_inst_data_ok = (cpu_inst_req & hit) | cache_inst_data_ok;

// ——— 输出到AXI侧 ———
assign cache_inst_req   = read_req & ~addr_rcv;
assign cache_inst_wr    = cpu_inst_wr;      // 指令Cache只读，wr恒为0
assign cache_inst_size  = cpu_inst_size;
assign cache_inst_addr  = cpu_inst_addr;
assign cache_inst_wdata = cpu_inst_wdata;

endmodule
