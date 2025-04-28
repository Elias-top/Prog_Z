//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5033326 Tue Apr  9 19:52:58 MDT 2024
//Date        : Wed Apr 10 16:46:25 2024
//Host        : xsjgill40x running 64-bit CentOS Linux release 7.4.1708 (Core)
//Command     : generate_target vss_axis_source.bd
//Design      : vss_axis_source
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "vss_axis_source,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=vss_axis_source,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "vss_axis_source.hwdef" *) 
module vss_axis_source
   (M_AXIS_tdata,
    M_AXIS_tdest,
    M_AXIS_tid,
    M_AXIS_tkeep,
    M_AXIS_tlast,
    M_AXIS_tready,
    M_AXIS_tstrb,
    M_AXIS_tvalid,
    aclk,
    aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, CLK_DOMAIN vss_axis_source_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 1, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 1, TID_WIDTH 1, TUSER_WIDTH 0" *) output [7:0]M_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) output [0:0]M_AXIS_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) output [0:0]M_AXIS_tid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) output [0:0]M_AXIS_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) output [0:0]M_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) input [0:0]M_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) output [0:0]M_AXIS_tstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS " *) output [0:0]M_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF M_AXIS, ASSOCIATED_RESET aresetn, CLK_DOMAIN vss_axis_source_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;

  wire aclk_0_1;
  wire aresetn_0_1;
  wire [7:0]axi4stream_vip_0_M_AXIS_TDATA;
  wire [0:0]axi4stream_vip_0_M_AXIS_TDEST;
  wire [0:0]axi4stream_vip_0_M_AXIS_TID;
  wire [0:0]axi4stream_vip_0_M_AXIS_TKEEP;
  wire [0:0]axi4stream_vip_0_M_AXIS_TLAST;
  wire [0:0]axi4stream_vip_0_M_AXIS_TREADY;
  wire [0:0]axi4stream_vip_0_M_AXIS_TSTRB;
  wire [0:0]axi4stream_vip_0_M_AXIS_TVALID;

  assign M_AXIS_tdata[7:0] = axi4stream_vip_0_M_AXIS_TDATA;
  assign M_AXIS_tdest[0] = axi4stream_vip_0_M_AXIS_TDEST;
  assign M_AXIS_tid[0] = axi4stream_vip_0_M_AXIS_TID;
  assign M_AXIS_tkeep[0] = axi4stream_vip_0_M_AXIS_TKEEP;
  assign M_AXIS_tlast[0] = axi4stream_vip_0_M_AXIS_TLAST;
  assign M_AXIS_tstrb[0] = axi4stream_vip_0_M_AXIS_TSTRB;
  assign M_AXIS_tvalid[0] = axi4stream_vip_0_M_AXIS_TVALID;
  assign aclk_0_1 = aclk;
  assign aresetn_0_1 = aresetn;
  assign axi4stream_vip_0_M_AXIS_TREADY = M_AXIS_tready[0];
  vss_axis_source_axi4stream_vip_0_0 axi4stream_vip_0
       (.aclk(aclk_0_1),
        .aresetn(aresetn_0_1),
        .m_axis_tdata(axi4stream_vip_0_M_AXIS_TDATA),
        .m_axis_tdest(axi4stream_vip_0_M_AXIS_TDEST),
        .m_axis_tid(axi4stream_vip_0_M_AXIS_TID),
        .m_axis_tkeep(axi4stream_vip_0_M_AXIS_TKEEP),
        .m_axis_tlast(axi4stream_vip_0_M_AXIS_TLAST),
        .m_axis_tready(axi4stream_vip_0_M_AXIS_TREADY),
        .m_axis_tstrb(axi4stream_vip_0_M_AXIS_TSTRB),
        .m_axis_tvalid(axi4stream_vip_0_M_AXIS_TVALID));
endmodule
