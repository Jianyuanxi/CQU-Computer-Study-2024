// ============================================================
//  d_cache.v — 直接映射写直通数据Cache
//  INDEX_WIDTH=10, OFFSET_WIDTH=2 → 4KB, 1024 cachelines, 每line=1word
//  接口：类SRAM（cpu侧） ↔ 类SRAM（axi侧）
//  支持：lw/sw/lb/sb/lh/sh（size=00/01/10）
//  写策略：Write Through + Non-Write Allocate
//    · store命中  → 写Cache + 写内存（直写）
//    · store缺失  → 只写内存，不分配cacheline
//  读策略：Read Miss → 从内存读入并填充Cache
//  FSM：IDLE → RM（读缺失）/ WM（写操作）
// ============================================================
module d_cache (
    input wire clk, rst,
    // mips core 侧（类sram）
    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,
    // axi interface 侧（类sram）
    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok
);

// ——— 参数 ———
parameter INDEX_WIDTH  = 10;
parameter OFFSET_WIDTH = 2;
localparam TAG_WIDTH   = 32 - INDEX_WIDTH - OFFSET_WIDTH; // 20
localparam CACHE_DEPTH = 1 << INDEX_WIDTH;                // 1024

// ——— Cache存储阵列 ———
reg                  cache_valid [CACHE_DEPTH-1:0];
reg [TAG_WIDTH-1:0]  cache_tag   [CACHE_DEPTH-1:0];
reg [31:0]           cache_block [CACHE_DEPTH-1:0];

// ——— 地址分解 ———
wire [OFFSET_WIDTH-1:0] offset = cpu_data_addr[OFFSET_WIDTH-1:0];
wire [INDEX_WIDTH-1:0]  index  = cpu_data_addr[INDEX_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH];
wire [TAG_WIDTH-1:0]    tag    = cpu_data_addr[31:INDEX_WIDTH+OFFSET_WIDTH];

// ——— 当前cacheline ———
wire c_valid = cache_valid[index];
wire [TAG_WIDTH-1:0] c_tag   = cache_tag  [index];
wire [31:0]          c_block = cache_block[index];

// ——— 命中判断 ———
wire read  = cpu_data_req & ~cpu_data_wr;
wire write = cpu_data_req &  cpu_data_wr;
wire hit   = c_valid & (c_tag == tag);
wire miss  = ~hit;

// ——— FSM ———
// IDLE：空闲
// RM  ：读缺失，等待从AXI取数据
// WM  ：写操作，等待AXI接收写请求
localparam IDLE = 2'b00;
localparam RM   = 2'b01;
localparam WM   = 2'b11;
reg [1:0] state;

always @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else case (state)
        IDLE: begin
            if      (read  & miss ) state <= RM;
            else if (write        ) state <= WM;
            else                    state <= IDLE;
            // 注意：read hit 直接完成，不需要进RM
        end
        RM  : state <= (read  & cache_data_data_ok) ? IDLE : RM;
        WM  : state <= (write & cache_data_data_ok) ? IDLE : WM;
        default: state <= IDLE;
    endcase
end

// ——— 保存请求时的tag/index ———
reg [TAG_WIDTH-1:0]   tag_save;
reg [INDEX_WIDTH-1:0] index_save;

always @(posedge clk) begin
    tag_save   <= rst ? 0 : (cpu_data_req ? tag   : tag_save  );
    index_save <= rst ? 0 : (cpu_data_req ? index : index_save);
end

// ——— 读请求握手辅助 ———
wire read_req;
reg  addr_rcv;
wire read_finish;

assign read_req    = (state == RM);
assign read_finish = read & cache_data_data_ok;

always @(posedge clk) begin
    addr_rcv <= rst ? 1'b0 :
                (read & cache_data_req & cache_data_addr_ok) ? 1'b1 :
                read_finish ? 1'b0 : addr_rcv;
end

// ——— 写请求握手辅助 ———
wire write_req;
reg  waddr_rcv;
wire write_finish;

assign write_req    = (state == WM);
assign write_finish = write & cache_data_data_ok;

always @(posedge clk) begin
    waddr_rcv <= rst ? 1'b0 :
                 (write & cache_data_req & cache_data_addr_ok) ? 1'b1 :
                 write_finish ? 1'b0 : waddr_rcv;
end

// ——— 写掩码（支持sb/sh/sw） ———
// size: 2'b00=byte, 2'b01=halfword, 2'b10=word
wire [3:0] write_mask;
assign write_mask =
    (cpu_data_size == 2'b00) ?
        (cpu_data_addr[1] ?
            (cpu_data_addr[0] ? 4'b1000 : 4'b0100) :
            (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
    (cpu_data_size == 2'b01) ?
        (cpu_data_addr[1] ? 4'b1100 : 4'b0011) :
        4'b1111;

// 合并写数据（将cpu写入的字节/半字/字合并到旧cacheline中）
wire [31:0] write_cache_data;
assign write_cache_data =
    (cache_block[index] & ~{{8{write_mask[3]}},{8{write_mask[2]}},{8{write_mask[1]}},{8{write_mask[0]}}}) |
    (cpu_data_wdata     &  {{8{write_mask[3]}},{8{write_mask[2]}},{8{write_mask[1]}},{8{write_mask[0]}}});

// ——— Cache填充与更新 ———
integer t;
always @(posedge clk) begin
    if (rst) begin
        for (t = 0; t < CACHE_DEPTH; t = t+1)
            cache_valid[t] <= 1'b0;
    end else begin
        // 读缺失时从内存填入cacheline
        if (read_finish) begin
            cache_valid[index_save] <= 1'b1;
            cache_tag  [index_save] <= tag_save;
            cache_block[index_save] <= cache_data_rdata;
        end
        // 写命中时同步更新cacheline（Write Through：也会同时写内存，见WM状态）
        else if (write & cpu_data_req & hit) begin
            cache_block[index] <= write_cache_data;
        end
    end
end

// ——— 输出到CPU侧 ———
assign cpu_data_rdata   = hit ? c_block : cache_data_rdata;
assign cpu_data_addr_ok = (read  & cpu_data_req & hit) |
                          (cache_data_req & cache_data_addr_ok);
assign cpu_data_data_ok = (read  & cpu_data_req & hit) |
                          cache_data_data_ok;

// ——— 输出到AXI侧 ———
// 读缺失发读请求，写操作（命中或缺失）都发写请求到内存
assign cache_data_req   = (read_req  & ~addr_rcv ) |
                          (write_req & ~waddr_rcv);
assign cache_data_wr    = cpu_data_wr;
assign cache_data_size  = cpu_data_size;
assign cache_data_addr  = cpu_data_addr;
assign cache_data_wdata = cpu_data_wdata;

endmodule
