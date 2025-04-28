//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1 (lin64) Build 5033326 Tue Apr  9 19:52:58 MDT 2024
//Date        : Wed Apr 10 17:10:48 2024
//Host        : xsjgill40x running 64-bit CentOS Linux release 7.4.1708 (Core)
//Command     : generate_target vss_axis_sink.bd
//Design      : vss_axis_sink
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "vss_axis_sink,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=vss_axis_sink,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "vss_axis_sink.hwdef" *) 
module vss_axis_sink
   (S_AXIS_tdata,
    S_AXIS_tdest,
    S_AXIS_tid,
    S_AXIS_tready,
    S_AXIS_tvalid,
    aclk,
    aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS " *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, CLK_DOMAIN vss_axis_sink_aclk_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 1, TID_WIDTH 1, TUSER_WIDTH 0" *) input [7:0]S_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS " *) input [0:0]S_AXIS_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS " *) input [0:0]S_AXIS_tid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS " *) output [0:0]S_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS " *) input [0:0]S_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF S_AXIS, ASSOCIATED_RESET aresetn, CLK_DOMAIN vss_axis_sink_aclk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;

  wire [7:0]S_AXIS_0_1_TDATA;
  wire [0:0]S_AXIS_0_1_TDEST;
  wire [0:0]S_AXIS_0_1_TID;
  wire [0:0]S_AXIS_0_1_TREADY;
  wire [0:0]S_AXIS_0_1_TVALID;
  wire aclk_0_1;
  wire aresetn_0_1;

  assign S_AXIS_0_1_TDATA = S_AXIS_tdata[7:0];
  assign S_AXIS_0_1_TDEST = S_AXIS_tdest[0];
  assign S_AXIS_0_1_TID = S_AXIS_tid[0];
  assign S_AXIS_0_1_TVALID = S_AXIS_tvalid[0];
  assign S_AXIS_tready[0] = S_AXIS_0_1_TREADY;
  assign aclk_0_1 = aclk;
  assign aresetn_0_1 = aresetn;
  vss_axis_sink_axi4stream_vip_0_0 axi4stream_vip_0
       (.aclk(aclk_0_1),
        .aresetn(aresetn_0_1),
        .s_axis_tdata(S_AXIS_0_1_TDATA),
        .s_axis_tdest(S_AXIS_0_1_TDEST),
        .s_axis_tid(S_AXIS_0_1_TID),
        .s_axis_tready(S_AXIS_0_1_TREADY),
        .s_axis_tvalid(S_AXIS_0_1_TVALID));
endmodule
