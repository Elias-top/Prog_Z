#!/bin/awk -f
# usage: hls_axilite_map.awk -v accel="accel_function_name" solution/impl/drivers/accel_top_v1_00_a/src/xaccel_hw.h 
BEGIN { 
  printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" > ofile
  printf "<xd:hls_axilite_map xmlns:xd=\"http://www.xilinx.com/xidane\">\n" >> ofile
} 
NR == 1 { printf "  <xd:accFcn xd:name=\"%s\">\n", accel >> ofile }
/\/\/ 0x[0123456789abcdef]+ \: Data signal of/ && NF == 7 {printf "    <xd:arg xd:name=\"%s\" xd:offset=\"%s\"/>\n",$7, $2 >> ofile}
END {
  printf "  </xd:accFcn>\n" >> ofile
  printf "</xd:hls_axilite_map>\n" >> ofile
}
