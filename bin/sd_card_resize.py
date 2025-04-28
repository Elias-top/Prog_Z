#!/usr/bin/env python
import os
import platform
import os.path
from os.path import exists
import sys 
import time
import subprocess
import shutil
import shlex
import string
from datetime import datetime
from shutil import copyfile
import signal
import io
import glob
import math
import stat
import random

# Command line parsing


from argparse import ArgumentParser
from argparse import HelpFormatter
from operator import attrgetter

OS_USED = platform.system()

class SortingHelpFormatter(HelpFormatter):
    def add_arguments(self, actions):
        actions = sorted(actions, key=attrgetter('option_strings'))
        super(SortingHelpFormatter, self).add_arguments(actions)

parser = ArgumentParser(formatter_class=SortingHelpFormatter)


parser.add_argument('-sd-card-image', '--sdCardImage',
    action="store", dest="sdimage",
    help="Specify the SD Card Image, sd_card.img", default="")
OS_USED = platform.system()
args = parser.parse_args()
sd_card_img_path = args.sdimage

if "XILINX_XD" in os.environ:
    USER_DEFINED_XD = os.getenv('XILINX_XD')
    print ('Using user-defined path for XILINX_XD environment variable', USER_DEFINED_XD)
else:
    VITIS_EMULATOR_SCRIPT = os.path.dirname(os.path.realpath(__file__));
    from os.path import dirname as up
    #xilinx_xd path , is 3 levels above script path
    xd_path = up(up(up(__file__)))
    one_up = os.path.normpath(os.path.join(VITIS_EMULATOR_SCRIPT,'../'))
    os.environ['XILINX_XD'] = one_up
    XILINX_XD = os.getenv('XILINX_XD')
    print ("XILINX_XD", XILINX_XD)


def get_qemu_settings_path():
  qemu_settings_path = ""
  if OS_USED == "Linux":
    #As per QEMU team, In windows no need to source any environment 
    if "QEMU_COMP_PATH" in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "qemu", "environment-setup-x86_64-petalinux-linux")
    elif "QEMU_BIN_PATH" in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_BIN_PATH'), "../", "../", "../", "../", "environment-setup-x86_64-petalinux-linux")
    else:
      qemu_settings_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "qemu", "environment-setup-x86_64-petalinux-linux")  
  return qemu_settings_path


def get_qemu_pmu_path():
  qemu_path = ""
  if "QEMU_COMP_PATH" in os.environ:
    qemu_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
  elif "QEMU_BIN_PATH" in os.environ:
    qemu_path = os.getenv('QEMU_BIN_PATH')
  else:
    # use new v5 qemu version
    # pick qemu for windows from qemu_win directory. For linux, get from unified qemu.
    if OS_USED != "Linux":
      qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu_win", "qemu")
    else:
      qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")

  return qemu_path

if sd_card_img_path != "":
  global filedirname
  file_size = os.stat(sd_card_img_path)
  filedirname = os.path.dirname(sd_card_img_path)
  
  logresult = math.log(file_size.st_size)/math.log(2)
  roundresult = math.ceil(logresult)
  rounded_size = math.ceil(pow(2, roundresult))
  qemu_resize_cmd = os.path.join(get_qemu_pmu_path(), "qemu-img")
  qemu_resize_script = os.path.join(filedirname,  "qemu_resize_img.sh")
  print("qemu_resize_img script at", qemu_resize_script) 
  with open(qemu_resize_script, 'w') as fppl:
    if OS_USED == "Linux":
      fppl.write("#!/bin/bash\n")
      fppl.write('echo "sourcing qemu env script."\n')
      fppl.write("source %s\n"%(get_qemu_settings_path()))
      fppl.write('unset LD_LIBRARY_PATH\n')
      fppl.write('echo "qemu settings done."\n')
      cmd_line = "%s resize -f raw %s %s\n"%(qemu_resize_cmd, sd_card_img_path, str(rounded_size))
      fppl.write("%s"%cmd_line)
      fppl.close()
  
  child = subprocess.Popen(["bash", qemu_resize_script], stdout=subprocess.PIPE)
  streamdata = child.communicate()[0]
  if child.returncode != 0: 
    print("sd card resize failed %d %s" % (child.returncode, streamdata))
  else:
   print("resized sd card successfully")
