//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1.0 (lin64) Build 4066809 Tue Nov 28 03:15:59 MST 2023
//Date        : Wed Nov 29 18:02:36 2023
//Host        : xsjgill40x running 64-bit CentOS Linux release 7.4.1708 (Core)
//Command     : generate_target aie_trace_anchor.bd
//Design      : aie_trace_anchor
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "aie_trace_anchor,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=aie_trace_anchor,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "aie_trace_anchor.hwdef" *) 
module aie_trace_anchor
   (M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arlen,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awlen,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wvalid,
    S_AXIS_tdata,
    S_AXIS_tkeep,
    S_AXIS_tlast,
    S_AXIS_tready,
    S_AXIS_tstrb,
    S_AXIS_tvalid,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wvalid,
    m_axi_aclk,
    m_axi_aresetn,
    s_axi_aclk,
    s_axi_aresetn,
    s_axis_aclk,
    s_axis_aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI, ADDR_WIDTH 64, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN aie_trace_anchor_aclk_2, DATA_WIDTH 64, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 0, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [63:0]M_AXI_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARBURST" *) output [1:0]M_AXI_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARLEN" *) output [7:0]M_AXI_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *) input M_AXI_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *) output M_AXI_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *) output [63:0]M_AXI_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWBURST" *) output [1:0]M_AXI_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *) output [7:0]M_AXI_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *) input M_AXI_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *) output M_AXI_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *) output M_AXI_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *) input [1:0]M_AXI_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *) input M_AXI_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RDATA" *) input [63:0]M_AXI_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RLAST" *) input M_AXI_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *) output M_AXI_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *) input [1:0]M_AXI_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *) input M_AXI_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *) output [63:0]M_AXI_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WLAST" *) output M_AXI_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *) input M_AXI_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *) output M_AXI_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, CLK_DOMAIN aie_trace_anchor_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 1, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [63:0]S_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TKEEP" *) input [7:0]S_AXIS_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *) input [0:0]S_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output [0:0]S_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TSTRB" *) input [7:0]S_AXIS_tstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input [0:0]S_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, ADDR_WIDTH 16, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN aie_trace_anchor_aclk_1, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 0, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [5:0]S_AXI_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output S_AXI_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input S_AXI_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input [5:0]S_AXI_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output S_AXI_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input S_AXI_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input S_AXI_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output [1:0]S_AXI_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output S_AXI_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output [31:0]S_AXI_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input S_AXI_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output [1:0]S_AXI_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output S_AXI_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input [31:0]S_AXI_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) output S_AXI_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI " *) input S_AXI_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.M_AXI_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.M_AXI_ACLK, ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET m_axi_aresetn, CLK_DOMAIN aie_trace_anchor_aclk_2, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input m_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.M_AXI_ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.M_AXI_ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input m_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXI_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXI_ACLK, ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET s_axi_aresetn, CLK_DOMAIN aie_trace_anchor_aclk_1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input s_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.S_AXI_ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.S_AXI_ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input s_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXIS_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXIS_ACLK, ASSOCIATED_BUSIF S_AXIS, ASSOCIATED_RESET s_axis_aresetn, CLK_DOMAIN aie_trace_anchor_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input s_axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.S_AXIS_ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.S_AXIS_ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input s_axis_aresetn;

  wire [63:0]S_AXIS_0_1_TDATA;
  wire [7:0]S_AXIS_0_1_TKEEP;
  wire [0:0]S_AXIS_0_1_TLAST;
  wire [0:0]S_AXIS_0_1_TREADY;
  wire [7:0]S_AXIS_0_1_TSTRB;
  wire [0:0]S_AXIS_0_1_TVALID;
  wire [5:0]S_AXI_0_1_ARADDR;
  wire S_AXI_0_1_ARREADY;
  wire S_AXI_0_1_ARVALID;
  wire [5:0]S_AXI_0_1_AWADDR;
  wire S_AXI_0_1_AWREADY;
  wire S_AXI_0_1_AWVALID;
  wire S_AXI_0_1_BREADY;
  wire [1:0]S_AXI_0_1_BRESP;
  wire S_AXI_0_1_BVALID;
  wire [31:0]S_AXI_0_1_RDATA;
  wire S_AXI_0_1_RREADY;
  wire [1:0]S_AXI_0_1_RRESP;
  wire S_AXI_0_1_RVALID;
  wire [31:0]S_AXI_0_1_WDATA;
  wire S_AXI_0_1_WREADY;
  wire S_AXI_0_1_WVALID;
  wire aclk_0_1;
  wire aclk_1_1;
  wire aclk_2_1;
  wire aresetn_0_1;
  wire aresetn_1_1;
  wire aresetn_2_1;
  wire [63:0]m_axi_vip_M_AXI_ARADDR;
  wire [1:0]m_axi_vip_M_AXI_ARBURST;
  wire [7:0]m_axi_vip_M_AXI_ARLEN;
  wire m_axi_vip_M_AXI_ARREADY;
  wire m_axi_vip_M_AXI_ARVALID;
  wire [63:0]m_axi_vip_M_AXI_AWADDR;
  wire [1:0]m_axi_vip_M_AXI_AWBURST;
  wire [7:0]m_axi_vip_M_AXI_AWLEN;
  wire m_axi_vip_M_AXI_AWREADY;
  wire m_axi_vip_M_AXI_AWVALID;
  wire m_axi_vip_M_AXI_BREADY;
  wire [1:0]m_axi_vip_M_AXI_BRESP;
  wire m_axi_vip_M_AXI_BVALID;
  wire [63:0]m_axi_vip_M_AXI_RDATA;
  wire m_axi_vip_M_AXI_RLAST;
  wire m_axi_vip_M_AXI_RREADY;
  wire [1:0]m_axi_vip_M_AXI_RRESP;
  wire m_axi_vip_M_AXI_RVALID;
  wire [63:0]m_axi_vip_M_AXI_WDATA;
  wire m_axi_vip_M_AXI_WLAST;
  wire m_axi_vip_M_AXI_WREADY;
  wire m_axi_vip_M_AXI_WVALID;

  assign M_AXI_araddr[63:0] = m_axi_vip_M_AXI_ARADDR;
  assign M_AXI_arburst[1:0] = m_axi_vip_M_AXI_ARBURST;
  assign M_AXI_arlen[7:0] = m_axi_vip_M_AXI_ARLEN;
  assign M_AXI_arvalid = m_axi_vip_M_AXI_ARVALID;
  assign M_AXI_awaddr[63:0] = m_axi_vip_M_AXI_AWADDR;
  assign M_AXI_awburst[1:0] = m_axi_vip_M_AXI_AWBURST;
  assign M_AXI_awlen[7:0] = m_axi_vip_M_AXI_AWLEN;
  assign M_AXI_awvalid = m_axi_vip_M_AXI_AWVALID;
  assign M_AXI_bready = m_axi_vip_M_AXI_BREADY;
  assign M_AXI_rready = m_axi_vip_M_AXI_RREADY;
  assign M_AXI_wdata[63:0] = m_axi_vip_M_AXI_WDATA;
  assign M_AXI_wlast = m_axi_vip_M_AXI_WLAST;
  assign M_AXI_wvalid = m_axi_vip_M_AXI_WVALID;
  assign S_AXIS_0_1_TDATA = S_AXIS_tdata[63:0];
  assign S_AXIS_0_1_TKEEP = S_AXIS_tkeep[7:0];
  assign S_AXIS_0_1_TLAST = S_AXIS_tlast[0];
  assign S_AXIS_0_1_TSTRB = S_AXIS_tstrb[7:0];
  assign S_AXIS_0_1_TVALID = S_AXIS_tvalid[0];
  assign S_AXIS_tready[0] = S_AXIS_0_1_TREADY;
  assign S_AXI_0_1_ARADDR = S_AXI_araddr[5:0];
  assign S_AXI_0_1_ARVALID = S_AXI_arvalid;
  assign S_AXI_0_1_AWADDR = S_AXI_awaddr[5:0];
  assign S_AXI_0_1_AWVALID = S_AXI_awvalid;
  assign S_AXI_0_1_BREADY = S_AXI_bready;
  assign S_AXI_0_1_RREADY = S_AXI_rready;
  assign S_AXI_0_1_WDATA = S_AXI_wdata[31:0];
  assign S_AXI_0_1_WVALID = S_AXI_wvalid;
  assign S_AXI_arready = S_AXI_0_1_ARREADY;
  assign S_AXI_awready = S_AXI_0_1_AWREADY;
  assign S_AXI_bresp[1:0] = S_AXI_0_1_BRESP;
  assign S_AXI_bvalid = S_AXI_0_1_BVALID;
  assign S_AXI_rdata[31:0] = S_AXI_0_1_RDATA;
  assign S_AXI_rresp[1:0] = S_AXI_0_1_RRESP;
  assign S_AXI_rvalid = S_AXI_0_1_RVALID;
  assign S_AXI_wready = S_AXI_0_1_WREADY;
  assign aclk_0_1 = s_axis_aclk;
  assign aclk_1_1 = s_axi_aclk;
  assign aclk_2_1 = m_axi_aclk;
  assign aresetn_0_1 = s_axis_aresetn;
  assign aresetn_1_1 = m_axi_aresetn;
  assign aresetn_2_1 = s_axi_aresetn;
  assign m_axi_vip_M_AXI_ARREADY = M_AXI_arready;
  assign m_axi_vip_M_AXI_AWREADY = M_AXI_awready;
  assign m_axi_vip_M_AXI_BRESP = M_AXI_bresp[1:0];
  assign m_axi_vip_M_AXI_BVALID = M_AXI_bvalid;
  assign m_axi_vip_M_AXI_RDATA = M_AXI_rdata[63:0];
  assign m_axi_vip_M_AXI_RLAST = M_AXI_rlast;
  assign m_axi_vip_M_AXI_RRESP = M_AXI_rresp[1:0];
  assign m_axi_vip_M_AXI_RVALID = M_AXI_rvalid;
  assign m_axi_vip_M_AXI_WREADY = M_AXI_wready;
  aie_trace_anchor_axi_vip_0_0 m_axi_vip
       (.aclk(aclk_2_1),
        .aresetn(aresetn_1_1),
        .m_axi_araddr(m_axi_vip_M_AXI_ARADDR),
        .m_axi_arburst(m_axi_vip_M_AXI_ARBURST),
        .m_axi_arlen(m_axi_vip_M_AXI_ARLEN),
        .m_axi_arready(m_axi_vip_M_AXI_ARREADY),
        .m_axi_arvalid(m_axi_vip_M_AXI_ARVALID),
        .m_axi_awaddr(m_axi_vip_M_AXI_AWADDR),
        .m_axi_awburst(m_axi_vip_M_AXI_AWBURST),
        .m_axi_awlen(m_axi_vip_M_AXI_AWLEN),
        .m_axi_awready(m_axi_vip_M_AXI_AWREADY),
        .m_axi_awvalid(m_axi_vip_M_AXI_AWVALID),
        .m_axi_bready(m_axi_vip_M_AXI_BREADY),
        .m_axi_bresp(m_axi_vip_M_AXI_BRESP),
        .m_axi_bvalid(m_axi_vip_M_AXI_BVALID),
        .m_axi_rdata(m_axi_vip_M_AXI_RDATA),
        .m_axi_rlast(m_axi_vip_M_AXI_RLAST),
        .m_axi_rready(m_axi_vip_M_AXI_RREADY),
        .m_axi_rresp(m_axi_vip_M_AXI_RRESP),
        .m_axi_rvalid(m_axi_vip_M_AXI_RVALID),
        .m_axi_wdata(m_axi_vip_M_AXI_WDATA),
        .m_axi_wlast(m_axi_vip_M_AXI_WLAST),
        .m_axi_wready(m_axi_vip_M_AXI_WREADY),
        .m_axi_wvalid(m_axi_vip_M_AXI_WVALID));
  aie_trace_anchor_axi_vip_1_0 s_axi_vip
       (.aclk(aclk_1_1),
        .aresetn(aresetn_2_1),
        .s_axi_araddr(S_AXI_0_1_ARADDR),
        .s_axi_arready(S_AXI_0_1_ARREADY),
        .s_axi_arvalid(S_AXI_0_1_ARVALID),
        .s_axi_awaddr(S_AXI_0_1_AWADDR),
        .s_axi_awready(S_AXI_0_1_AWREADY),
        .s_axi_awvalid(S_AXI_0_1_AWVALID),
        .s_axi_bready(S_AXI_0_1_BREADY),
        .s_axi_bresp(S_AXI_0_1_BRESP),
        .s_axi_bvalid(S_AXI_0_1_BVALID),
        .s_axi_rdata(S_AXI_0_1_RDATA),
        .s_axi_rready(S_AXI_0_1_RREADY),
        .s_axi_rresp(S_AXI_0_1_RRESP),
        .s_axi_rvalid(S_AXI_0_1_RVALID),
        .s_axi_wdata(S_AXI_0_1_WDATA),
        .s_axi_wready(S_AXI_0_1_WREADY),
        .s_axi_wvalid(S_AXI_0_1_WVALID));
  aie_trace_anchor_axi4stream_vip_0_0 s_axis_vip
       (.aclk(aclk_0_1),
        .aresetn(aresetn_0_1),
        .s_axis_tdata(S_AXIS_0_1_TDATA),
        .s_axis_tkeep(S_AXIS_0_1_TKEEP),
        .s_axis_tlast(S_AXIS_0_1_TLAST),
        .s_axis_tready(S_AXIS_0_1_TREADY),
        .s_axis_tstrb(S_AXIS_0_1_TSTRB),
        .s_axis_tvalid(S_AXIS_0_1_TVALID));
endmodule
