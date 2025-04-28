#!/bin/sh

xsct $XILINX_VITIS/scripts/vitis/util/buildplatform.tcl $@

RET_VAL=$?
exit $RET_VAL