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
import pexpect
from common_procs import *
from pre_processing import *

XILINX_XD = get_xilinx_path()
OS_USED = platform.system()
earlier_ld_lib_path = os.environ.get('LD_LIBRARY_PATH')

if OS_USED == "Linux":
    script_ext = "sh"
    xsim_redir = ">/dev/null"
else:
    script_ext="bat"
    xsim_redir = ">NUL"

######################################################################
# Command line parsing
from argparse import ArgumentParser,SUPPRESS
from argparse import HelpFormatter
from operator import attrgetter

class SortingHelpFormatter(HelpFormatter):
    def add_arguments(self, actions):
        actions = sorted(actions, key=attrgetter('option_strings'))
        super(SortingHelpFormatter, self).add_arguments(actions)

parser = ArgumentParser(formatter_class=SortingHelpFormatter, usage=SUPPRESS)

advOpt = parser.add_argument_group('Advanced Options')
autoPop = parser.add_argument_group('AutoPopulated by v++ in launch_hw/sw_emu.sh')

autoPop.add_argument('-device-family',
    action="store", metavar='', dest="device_family",
    help="Specify the device family (7Series/Ultrascale/Versal)", default="")

autoPop.add_argument('-t','-target',
    action="store",metavar='', dest="target_emu",
    help="Target (sw_emu / hw_emu)", default="")

advOpt.add_argument('-result-string', 
    action="store", metavar='', dest="result_stringg",
    help="Result string to look for. Seeing this string is treated as status completion", default="TEST PASSED", type=str)

advOpt.add_argument('-machine-path', 
    action="store", metavar='', dest="mcpath",
    help="", default="", type=str)

advOpt.add_argument('-login',
    action="store", metavar='', dest="login",
    help="Username to login the petalinux. PLease  ensure to use the same login username that has been provided during kernel image creation", default="petalinux", type=str)

advOpt.add_argument('-password',
    action="store", metavar='', dest="password",
    help="Password to login the petalinux. Please ensure to use the same password that has been provided during kernel image creation", default="password", type=str)

autoPop.add_argument('-qemu-args-file',
    action="store", metavar='', dest="qemu_args_file", 
    help="Specify the Qemu arguments file. These options gets used while running Qemu", default="")

autoPop.add_argument('-pmc-args-file',
    action="store", metavar='', dest="pmc_args_file",
    help="Specify the PMC arguments file. These options gets used while running PMC", default="")

autoPop.add_argument('-risc-args-file',
    action="store", metavar='', dest="risc_args_file",
    help="Specify the RISC arguments file. These options gets used while running RISC", default="")

autoPop.add_argument('-pl-sim-dir',
    action="store", metavar='', dest="pl_sim_dir",
    help="Specify the PL simulation directory.Used only for hw emu", default="")

autoPop.add_argument('-sd-card-image',
    action="store", metavar='', dest="sdimage",
    help="Specify the SD Card Image, sd_card.img", default="")

#autoPop.add_argument('-enable-prep-target',
#    action="store_true", dest="enable_prep_target",
#    help="Enables prep target", default=1)

autoPop.add_argument('-xtlm-log-state',
    action="store", metavar='', dest="XTLM_LOG_STATE",
    help="Option to mention what XTLM Log should contain WAVEFORM/LOG/BOTH.Used only for hw emu", default="WAVEFORM_AND_LOG")

parser.add_argument('-enable-debug',
    action="store_true", dest="enable_debug",
    help="Enables debug mode where 2 xterm shells are opened", default=0)

parser.add_argument('-run-app',
    action="store", metavar='', dest="app_file",
    help="Specify the application to run.Please provide full absolute path", default="")

parser.add_argument('-wdb-File', '--wdb',
    action="store", metavar='', dest="wdb_file",
    help="Specify the wdb file to load.Please provide full absolute path", default="")

autoPop.add_argument('-protoinst-File', '--protoinst',
    action="store", metavar='', dest="protoinst_file",
    help="Specify the protoinst file to load.Please provide full absolute path", default="")

autoPop.add_argument('-aie-sim-config', '-emuData',
    action="store", metavar='', dest="aie_sim_config",
    help="Specify the AIE SIMULATION CONFIGURATION file. The JSON, XPE file paths specified in this file will be used", default="")

parser.add_argument('-aie-sim-options',
    action="store", metavar='', dest="aie_sim_options",
    help="Points to the AIE sim options file has provides various AIE debug flags that are required for debugging the AIE Model.Used only for hw emu", default="")

parser.add_argument('-x86-sim-options',
    action="store", metavar='', dest="x86_sim_options",
    help="Points to the x86 sim options file which has various AIE debug flags that are required for debugging the AIE Model.Used only for sw emu", default="")

autoPop.add_argument('-noc-memory-config',
    action="store", metavar='', dest="noc_memory_config",
    help="Specify the NOC MEMORY CONFIGURATION file. This file will be used for NOC/DDR interactions with QEMU.Used only for hw emu", default="")

autoPop.add_argument('-qemu-dtb',
    action="store", metavar='',  dest="qemu_hw_dtb",
    help="V++ -package auto creates this file based on the addressing in the design and passes to the launch_emulator CLI. User can create the DTB outside the V++ env and pass it to override the defaults. Please make sure it is compatible with the noc_memory_config.txt file passed", default="")

autoPop.add_argument('-pmc-dtb',
    action="store", metavar='', dest="pmc_hw_dtb",
    help="V++ -package auto creates this file based on the addressing in the design and passes to the launch_emulator CLI. User can create the DTB outside the V++ env and pass it to override the defaults. Please make sure it is compatible with the noc_memory_config.txt file passed", default="")

autoPop.add_argument('-risc-dtb',
    action="store", metavar='', dest="risc_hw_dtb",
    help="V++ -package auto creates this file based on the addressing in the design and passes to the launch_emulator CLI. User can create the DTB outside the V++ env and pass it to override the defaults. Please make sure it is compatible with the noc_memory_config.txt file passed", default="")

parser.add_argument('-graphic-xsim', 
    action="store_true", dest="graphic_xsim_full",
    help="Start the Programmable Logic Simulator GUI.Used only for hw emu", default=0)

parser.add_argument('-g', '-sim-gui',
    action="store_true", dest="graphic_xsim",
    help="Start the Programmable Logic Simulator GUI.Used only for hw emu", default=0)

parser.add_argument('-wcfg-file-path',
    action="store", metavar='', dest="wcfg_file_path",
    help="Specify the wcfg file created by the XSIM to open during GUI simulation.Used only for hw emu", default="")
    
advOpt.add_argument('-disable-host-completion-check',
    action="store_true", dest="disable_host_check",
    help="Skip the check for host completion.Generally used when in applications where python scripts check for the completion status PASS/FAIL", default=0)


parser.add_argument('-user-pre-sim-script',
    action="store", metavar='', dest="user_pre_sim_script",
    help="Specify the simulator tcl commands like add_wave, log_wave that are to be executed before starting simulation.Used only for hw emu", default="")

parser.add_argument('-user-post-sim-script',
    action="store", metavar='', dest="user_post_sim_script",
    help="Specify the simulator tcl commands that are to be executed after simulation.Used only for hw emu", default="")


parser.add_argument('-xtlm-aximm-log',
    action="store_true", dest="xtlm_aximm_logging",
    help="Enables the aximm tlm transaction log, and one can see the log in the xsc_report.log file. This enables the log only for XSIM simulator.Used only for hw emu", default=0)

parser.add_argument('-xtlm-axis-log',
    action="store_true",  dest="xtlm_axis_logging",
    help="Enables the axis tlm transaction log, and one can see the log in the xsc_report.log file. This enables the log only for XSIM simulator.Used only for hw emu", default=0)

advOpt.add_argument('-ospi-image',
    action="store", metavar='', dest="ospi_img",
    help="Specify the OSPI Image", default="")

advOpt.add_argument('-qspi-image', '-image',
    action="store", metavar='', dest="qimage",
    help="Specify the QSPI Image, QSPI bin", default="")

advOpt.add_argument('-qspi-low-image',
    action="store", metavar='', dest="qimage_low",
    help="Specify the QSPI LOW Image, when using DUAL QSPI mode", default="")

advOpt.add_argument('-qspi-high-image',
    action="store", metavar='', dest="qimage_high",
    help="Specify the QSPI HIGH Image, when using DUAL QSPI mode", default="")

advOpt.add_argument('-enable-tcp-sockets',
    action="store_true", dest="enable_tcp_sockets",
    help="Enables TCP Sockets", default=0)


advOpt.add_argument('-pl-sim-args',
    action="store", metavar='', dest="pl_sim_args",
    help="Specify the PL Simulator arguments as commandline option. These options gets used while running simulation.Used only for hw emu", default="")

#advOpt.add_argument('-use-qemu-version-v4',
#    action="store", metavar='', dest="qemu_v4",
#    help="Use old qemu version 4.2", default=0)

parser.add_argument('-verbose',
    action="store_true",  dest="verbose_mode",
    help="Enable additional debug messages.", default=0)

autoPop.add_argument('-pl-sim-script',
    action="store", metavar='', dest="pl_sim_script",
    help="argparse.SUPPRESS", default="")

advOpt.add_argument('-pl-sim-args-file',
    action="store", metavar='', dest="pl_sim_args_file",
    help="Specify the pl_sim arguments file. These options gets used while running Simulation.Used only for hw emu", default="")

advOpt.add_argument('-dont-run-sim',
    action="store_true", dest="dont_run_sim",
    help="argparse.SUPPRESS", default=0)

autoPop.add_argument('-boot-bh',
    action="store", metavar='', dest="bootBHFilePath",
    help="Specify the boot BH file path", default="")

autoPop.add_argument('-pid-file',
    action="store", metavar='', dest="pid_file",
    help="Specify the file to be created to store the group PID to kill the process.", default="")

advOpt.add_argument('-qemu-args-dir',
    action="store", metavar='', dest="qemu_dir",
    help="All files required to boot QEMU will be copied to this path. Used along with -pl-sim-dir option", default="")

advOpt.add_argument('-kill-pid-file',
    action="store", metavar='', dest="kill_pid_file",
    help="Specify the file to be used to kill the process.This file stores the group PID of the process. This may have been created using -pid-file", default="")

autoPop.add_argument('-platform-name',
    action="store", metavar='', dest="platform_name",
    help="The platform name", default="")

advOpt.add_argument('-kill',
    action="store", metavar='', dest="killpid",
    help="Kill a specified emulator process", default="")


parser.add_argument('-graphic-qemu',
    action="store_true", dest="graphic_qemu",
    help="Start the Quick Emulator(QEMU) GUI", default=0)

advOpt.add_argument('-no-reboot',
    action="store_true",  dest="no_reboot",
    help="Exit QEMU instead of rebooting", default=0)

advOpt.add_argument('-nobuild',
    action="store_true",  dest="nobuild",
    help="", default=0)

advOpt.add_argument('-norun',
    action="store_true",  dest="norun",
    help="Dont run the process", default=0)

advOpt.add_argument('-run-sim-in-gdb',
    action="store_true",  dest="run_sim_in_gdb",
    help="Run simulator in GDB.Used only for hw emu ", default=0)

parser.add_argument('-pl-kernel-dbg',
    action="store", metavar='', dest="plKernelDbg",
    help="PL kernel Debug", default="false")

parser.add_argument('-kernel-dbg',
    action="store", metavar='', dest="kernelDbg",
    help="PL,AIE kernel Debug in SW_EMU.Used only for sw emu", default="false")

parser.add_argument('-timeout',
    action="store", metavar='', dest="timeout",
    help="Terminate emulation after <n> seconds", default="")

autoPop.add_argument('-gdb-port',
    action="store", metavar='', dest="gdb_port",
    help="QEMU waits for GDB connection on <port>", default="")

#parser.add_argument('-runtime',
#    action="store", metavar='', dest="runtime",
#    help="Runtime flow type c++/ocl", default="")

advOpt.add_argument('-print-qemu-version',
    action="store", metavar='', dest="print_qemu_version",
    help="prints the qemu version", default=0)

advOpt.add_argument('-qemu-args',
    action="store", metavar='', dest="qemu_args_cmdline",
    help="Specify the Qemu arguments as commandline option. These options gets used while running Qemu", default="")

advOpt.add_argument('-pmc-args',
    action="store", metavar='', dest="pmc_args_cmdline",
    help="Specify the PMC arguments as commandline option. These options gets used while running PMC", default="")

advOpt.add_argument('-risc-args',
    action="store", metavar='', dest="risc_args_cmdline",
    help="Specify the Qemu arguments as commandline option. These options gets used while running Qemu", default="")

parser.add_argument('-add-env', 
    action="append", metavar='', dest="add_env_cmd",
    help="Specify any additional Environment Variable")


autoPop.add_argument('-forward-port',
    action="append", metavar='', dest="forward_port", nargs='+',
    help="forward port")


advOpt.add_argument('-pl-deadlock-detection',
    action="store", metavar='', dest="pl_deadlock_detection",
    help="Additional deadlock messages will be dumped onto the pl_deadlock_diagnosis.txt file", default="false")

advOpt.add_argument('-enable-rp-logs',
    action="store_true", dest="enable_rp_logs",
    help="Enables qemu rp logs. This can be used for more detailed qemu debugging.", default=0)


args = parser.parse_args()

envdict = pre_processing(args)
 
if args.enable_debug == 1 and args.app_file != "":
  print("WARNING : enable-debug and -run-app switches cannot be used at the same time.Giving preference to -enable-debug switch and opening xterm shells")
  args.app_file = ""

if args.mcpath != "" and args.app_file != "":
  print("WARNING : -machine-path and -run-app switches cannot be used at the same time.Giving preference to -machine-path switch and not launching QEMU")
  args.app_file = ""

if args.graphic_xsim_full == 1:
  args.graphic_xsim = args.graphic_xsim_full
  print("GRAPHIC XSIM SELECTED: ", args.graphic_xsim)
  print("WARNING : -graphic-xsim switch is DEPRECATED.Please use the switch -g or -sim-gui to start the Programmable Logic Simulator GUI")
 
if args.graphic_xsim == 1 and args.enable_debug == 1 :
  print("INFO : \[LAUNCH_EMULATOR\] Both Graphic simulator and XTERM modes are enabled.Giving preference to Graphic simulator.")
  args.enable_debug = 0

pl_sim_args = ""
if args.pl_sim_args != "" :
  pl_sim_args = parse_pl_sim_args(args.pl_sim_args)

parse_add_env_var_and_set_envs(args.add_env_cmd)
    
#--forward-port 1140 1560
test_string = ""

#for sw_emu, pllauncher, QEMU, DEVICE PROCESS connections
target_port= get_available_port()
host_port = 1560

#if (args.device_family == "versal" or args.device_family == "ultrascale") and args.target_emu != "hw_emu":
if args.target_emu != "hw_emu":
  test_string = create_fwd_port_test_string_for_sw_emu_qemu_device_process_connection(target_port, host_port)


target = set_target_on_parsing_fwd_port_variable(args.forward_port)
host = set_host_on_parsing_fwd_port_variable(args.forward_port)
if target != "":
  print("###########################################################")
  print("QEMU is using the forward port : ", target)
  print("Please use this port to copy files")
  print("###########################################################")
test_string = parse_fwd_port_variable(args.device_family, args.target_emu, args.forward_port, test_string)

if OS_USED != "Linux":
    enable_tcp_sockets = 1
 
pl_sim_dir = ""
if args.target_emu == "sw_emu" :
    pl_sim_dir = os.getcwd()
else:
    pl_sim_dir = args.pl_sim_dir

log_dir = os.getcwd()
if os.path.exists(os.path.join(log_dir, ".run", "device_process.log")):
  os.remove(os.path.join(log_dir, ".run", "device_process.log"))
elif os.path.exists(os.path.join(log_dir, "../", ".run", "device_process.log")):
  os.remove(os.path.join(log_dir, "../", ".run", "device_process.log"))

VIMAGE_PID = ""
if args.device_family=="7series":
  if OS_USED == "Linux":
    VIMAGE_PID =  os.getpid()
 
# ##################### kill the process if pid is given ###########
# if kill is called, the first thing you want to do is kill the process and underlying subprocesses. 
# Info like deviceFamily is not needed and need not be intialised
# dont move this piece of code down or to helper files
if args.killpid != "":
  print("INFO: \[LAUNCH_EMULATOR\] Killing process %s"%args.killpid)
  post_operations(args.device_family, pl_sim_dir, log_dir, args.platform_name, envdict, VIMAGE_PID)
  kill_group(args.killpid)
  sys.exit()

# ##################### kill the process if pid file is given ###########
# if kill is called, the first thing you want to do is kill the process and underlying subprocesses. 
# Info like deviceFamily is not needed and need not be intialised
# dont move to helper files
if args.kill_pid_file != "":
  kill_pid_file = os.path.join(os.getcwd(), args.kill_pid_file)
  print("INFO: \[LAUNCH_EMULATOR\] Trying to kill process in file %s"%args.kill_pid_file)
  if os.path.exists(kill_pid_file):
    reading_file = open(kill_pid_file, "r")
    for line in reading_file:
      stripped_line = line.strip()
      post_operations(args.device_family, pl_sim_dir, log_dir, args.platform_name, envdict, VIMAGE_PID)
      kill_group(int(line))
      #os.kill(int(line), 9)
      time.sleep(3)
      if pid_exists(int(line)):
        print("Unable to kill process")
      else:
        print("Successfully killed launch_emulator process")
  else:
    print("ERROR: \[LAUNCH_EMULATOR\] %s file doesnt exist."%args.kill_pid_file)
  sys.exit()

   
##########not needed as device_family is passed in launh_hw_emu.sh via v++ -p ##### 
if args.device_family=="ultrascale":
  cpu_type = "cortex-a53"
if args.device_family == "":
 device_family = get_device_type()

pmc_port = ""
pl_port = "" #pl_port = 7000
sim_name = "xsim"

######################################################################
pl_exe_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "unified", "hw_em", "zynqu", "pllauncher")
pl_port = get_available_port()
pmc_port = get_available_port()
                
###############################################################################

os.environ["EMULATION_RUN_DIR"] = pl_sim_dir 
os.environ["EMBEDDED_PLATFORM"] = "true"
#*****HACK!! This is required for pllauncher to launch. Will remove this once we create the loader for pllauncer***** 
os.environ["RDI_DATADIR"] = os.path.join(os.getenv('XILINX_VITIS'), "data")

cur_dir = os.getcwd()


sim_name = get_simulator_name(pl_sim_dir)
#print("simulator_name : ", sim_name)

global socket_file
if args.device_family=="7series":
  if OS_USED == "Linux":
    zynq7000_unixsock_name = "/tmp/qemu-cosim-%s"%VIMAGE_PID
    socket_file = os.path.join(zynq7000_unixsock_name, "qemu-rport-_cosim@0")

# QEMU script and arguments
# create start_qemu.sh

qemu_cmd = ""
if 'QEMU_COMP_PATH' in os.environ: 
  if args.device_family != "telluride":
    qemu_cmd = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-aarch64") 
  else:
    qemu_cmd = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-aarch64") 
elif 'QEMU_BIN_PATH' in os.environ:
  qemu_cmd = os.path.join(os.getenv('QEMU_BIN_PATH'), "qemu-system-aarch64")
else:
  qemu_cmd = get_qemu_cmd(args)
if args.device_family=="telluride":
  if OS_USED == "Linux":
    qemu_cmd = get_qemu_cmd(args)
#print("qemu_cmd", qemu_cmd)


emu_dir = os.path.join(os.getcwd(), "emu_qemu_scripts")
print("Directory '%s' created" %emu_dir)
if os.path.exists(emu_dir):
    shutil.rmtree(emu_dir)
os.mkdir(emu_dir)
qemu_script = os.path.join(os.getcwd(), "emu_qemu_scripts", "start_qemu.sh")
#print("qemu_script", qemu_script)

qemuargs_hwdtb = 0
if (args.qemu_dir != ""):
  qemu_args = read_qemu_args_file(os.path.join(os.path.abspath(args.qemu_dir),"qemu_args.txt"), args.device_family, args.target_emu, target)
else:
  qemu_args = read_qemu_args_file(args.qemu_args_file, args.device_family, args.target_emu, target)
# ########### read qemu args file ##############

if args.qemu_args_cmdline != "":
  qemu_args.append(args.qemu_args_cmdline)

qemu_dtb = get_qemu_dtb(args.device_family, args.target_emu)

if args.qemu_dir != "":
    extension = ".dtb"
    substring = "ps"
    filename = ""
    qemu_dir = os.path.abspath(args.qemu_dir)
    # join the directory path and extension to create the search pattern
    search_pattern = os.path.join(qemu_dir, f"*{extension}")
    # find all files with the desired extension in the directory
    files = glob.glob(search_pattern)
    print("##########search_pattern", search_pattern)
    # filter filenames to include only those that contain the desired substring
    filtered_files = [f for f in files if substring in f]
    # print the filtered filenames
    for f in filtered_files:
      file_name = f
      print("#######QEMU DTB PATH", f)
    #file_name = os.path.basename(args.qemu_hw_dtb) 
    file_path = os.path.join(os.path.abspath(args.qemu_dir), file_name)
    qemu_args.append(' -hw-dtb %s '%file_path)
    print("Using QEMU dtb from %s"%file_path)
else:
    if args.qemu_hw_dtb != "": 
      qemu_args.append(' -hw-dtb %s '%args.qemu_hw_dtb )
      print("Using QEMU dtb from %s"%args.qemu_hw_dtb)
    else:
      print("Using QEMU dtb from %s"%qemu_dtb)
      qemu_args.append(' -hw-dtb %s '%qemu_dtb )

  
#### sd card image appending to qemu args #########  
if args.qemu_dir != "":
    if args.device_family == "versal" or args.device_family == "telluride":
      file_path = find_file(os.path.abspath(args.qemu_dir), "sd_card", "img")
      qspi_path = find_file(os.path.abspath(args.qemu_dir), "qemu_qspi", "bin")
      qspi_high_path = find_file(os.path.abspath(args.qemu_dir), "qemu_qspi_low", "bin")
      qspi_low_path = find_file(os.path.abspath(args.qemu_dir), "qemu_qspi_high", "bin")
      ospi_path = find_file(os.path.abspath(args.qemu_dir), "qemu_ospi", "bin")
      #print("sd_card_image_path : ", file_path)
      if file_path is not None:
        image_file_path(qemu_args, file_path, 'format=raw,if=sd,index=1')
      if qspi_path is not None:
        image_file_path(qemu_args, qspi_path,  'format=raw,if=mtd,index=0')
      if qspi_low_path is not None and qspi_high_path is not None:
        image_file_path(qemu_args, qspi_low_path, 'format=raw,if=mtd,index=0')
        image_file_path(qemu_args, qspi_high_path, 'format=raw,if=mtd,index=3')
      if ospi_path is not None:
        image_file_path(qemu_args, ospi_path,'format=raw,if=mtd,index=4')
    elif args.device_family == "ultrascale":
        file_path = find_file(os.path.abspath(args.qemu_dir), "sd_card", "img")
        print("sd_card_image_path : ", file_path)
        if file_path is not None:
          image_file_path(qemu_args, file_path, 'if=sd,format=raw,index=1')
    elif args.device_family == "7series":
        file_path = find_file(os.path.abspath(args.qemu_dir), "sd_card", "img")
        print("sd_card_image_path : ", file_path)
        if file_path is not None:
          image_file_path(qemu_args, file_path, 'if=sd,format=raw')
else:
 if args.device_family == "versal" or args.device_family == "telluride":
  if args.sdimage != "":
    qemu_args.append(' -drive "file=%s,format=raw,if=sd,index=1" ' %args.sdimage)
  if args.qimage != "":
    qemu_args.append(' -drive "file=%s,format=raw,if=mtd,index=0" '%args.qimage)
  if args.qimage_low != "" and args.qimage_high != "":
    qemu_args.append(' -drive "file=%s,format=raw,if=mtd,index=0" ' %args.qimage_low)
    qemu_args.append('  -drive "file=%s,format=raw,if=mtd,index=3" ' %args.qimage_high)
  if args.ospi_img != "":
    qemu_args.append(' -drive "file=%s,format=raw,if=mtd,index=4" ' %args.ospi_img)
 elif args.device_family == "ultrascale":
  if args.sdimage != "":
    qemu_args.append(' -drive "file=%s,if=sd,format=raw,index=1" ' %args.sdimage)
  else:
    sdimg = os.path.join(os.getcwd(), " _vimage", "emulation", "sd_card.img")
    qemu_args.append(' -drive "file=%s,if=sd,format=raw,index=1" '%sdimg) 
 elif args.device_family == "7series":
  if args.sdimage != "":
    qemu_args.append(' -drive "file=%s,if=sd,format=raw" '%args.sdimage)
  else:
    sdimg = os.path.join(os.getcwd(), " _vimage", "emulation", "sd_card.img")
    qemu_args.append(' -drive "file=%s,if=sd,format=raw" '%sdimg)

############################################################################
#if target != "" and host != "":
  #qemu_args.append(' -net "nic,netdev=net0" -netdev "user,id=net0,hostfwd=tcp::%s-:%s"'%(target, host))
  #append qemu_args " -redir \"tcp:${target}::${host}\""
fwd_port_list = args.forward_port
if fwd_port_list is None and args.target_emu == "hw_emu":
  print("")
else:
  qemu_args.append(' -net "nic,netdev=net0" -netdev "user,id=net0,%s"'%(test_string))

  
if args.gdb_port != "":
  qemu_args.append(' -gdb "tcp:127.0.0.1:%s"'%args.gdb_port)
  qemu_args.append(" -S")


if args.no_reboot == 1:
  qemu_args.append(" -no-reboot")


if args.graphic_qemu != 1:
  qemu_args.append(' -display "none" ')

### set machine path #########
if args.device_family == "7series" and args.target_emu == "hw_emu" and OS_USED == "Linux":
  qemu_args.append(' -machine-path "%s" '%zynq7000_unixsock_name)
  os.mkdir(zynq7000_unixsock_name)
else:
  qemu_args.append(' -machine-path "." ')

##################

  
#qemu_args.append(' -sync-quantum "4000000" ')
os.environ['QEMU_AUDIO_DRV'] = "none"




####### set socket connection ###################
# zynq 7000, has only PS + PL, no PMC/PMU. for zynq 7000, we are creating unix socket for linux, and TCP socket for windows to emulate PL
# for zynq MP # PMU(zynqMP) # We are creating 2 sockets to emulate.
# for Versal we have PS + PL + PMC/PMU # PMC(versal)# We are creating 2 sockets to emulate.

if args.device_family == "7series":
  if (OS_USED == "Linux") and (args.target_emu == "hw_emu"):
    #VIMAGE_PID =  os. getpid()
    #print("1414 VIMAGE_PID", VIMAGE_PID)
    zynq7000_unixsock_name = "/tmp/qemu-cosim-%s/"%VIMAGE_PID
    os.environ['COSIM_MACHINE_PATH'] = zynq7000_unixsock_name
    print("COSIM_MACHINE_PATH",os.getenv('COSIM_MACHINE_PATH'))
  else:
    qemu_args.append(' -global "remote-port.chardesc=tcp:127.0.0.1:%s,server=on,wait"'%pl_port) 
    os.environ['COSIM_MACHINE_TCPIP_ADDRESS']= "tcp:127.0.0.1:%s"%pl_port


###PMC/PMU Socket
if args.device_family == "versal":
  if args.enable_tcp_sockets == 1:
    qemu_args.append(' -chardev "socket,id=ps-pmc-rp,host=127.0.0.1,port=%s,server=on" '%pmc_port)
  else:
    qemu_args.append(' -chardev "socket,path=./qemu-rport-_pmc@0,server=on,id=ps-pmc-rp" ')
elif args.device_family == "telluride":
    qemu_args.append(' -chardev "socket,path=./qemu-rport-_pmc@0,server=on,id=ps-pmc-rp" ')
    qemu_args.append(' -chardev "socket,path=./qemu-rport-_asu@0,server=on,id=ps-asu-rp" ')
elif args.device_family == "ultrascale":
  if args.enable_tcp_sockets == 1:
    qemu_args.append(' -chardev "socket,id=pmu-apu-rp,host=127.0.0.1,port=%s,server=on" '%pmc_port)
  else:
    qemu_args.append(' -chardev "socket,path=./qemu-rport-_pmu@0,server=on,id=pmu-apu-rp" ')

#PL Socket
# append pl socket only for linux , or if pl is really present
# No need of appending pl socket as we are using non cosim dtb for windows sw_emu case
if args.device_family == "ultrascale" or args.device_family == "versal" or args.device_family == "telluride":
  if (args.target_emu == "hw_emu") or (OS_USED == "Linux"):
    if (args.target_emu == "hw_emu"):
        if args.mcpath != "" :
          qemu_args.append(' -chardev "socket,path=%s/qemu-rport-_pl@0,server=on,id=pl-rp" '%os.path.abspath(args.mcpath))
          os.environ['COSIM_MACHINE_PATH'] = "unix:%s/qemu-rport-_pl@0" %os.path.abspath(args.mcpath)
          print("PS COSIM_MACHINE_PATH",os.getenv('COSIM_MACHINE_PATH'))
        else :
          qemu_args.append(' -chardev "socket,path=./qemu-rport-_pl@0,server=on,id=pl-rp" ')
          os.environ['COSIM_MACHINE_PATH'] = "unix:./qemu-rport-_pl@0"
          print("PS COSIM_MACHINE_PATH",os.getenv('COSIM_MACHINE_PATH'))
    else:
      qemu_args.append(' -chardev "socket,id=pl-rp,host=127.0.0.1,port=%s,server=on" ' %pl_port)
      os.environ['COSIM_MACHINE_TCPIP_ADDRESS'] = "tcp:127.0.0.1:%s" %pl_port

create_start_qemu_script(qemu_script, pl_sim_dir, qemu_cmd, qemu_args, args.qemu_dir,args)


os.chmod(qemu_script , 0o777)
######################################################################
# PMC script and arguments
# create start_pmu.sh
if args.device_family != "7series":
  pmcargs_microblaze_set = 0
  pmc_args = []
  pmcargs_hwdtb = 0
  global pmc_cmd
  pmc_cmd = ""
  pmc_script = os.path.join(os.getcwd(), "emu_qemu_scripts", "start_pmc.sh")
  global pmc_dtb
  #print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
  if 'QEMU_COMP_PATH' in os.environ:
    if args.device_family != "telluride":
      pmc_cmd = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-microblazeel")
    else:
      pmc_cmd = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-microblazeel")
  elif 'QEMU_BIN_PATH' in os.environ:
    pmc_cmd = os.path.join(os.getenv('QEMU_BIN_PATH'), "qemu-system-microblazeel")
  else:
    #pmc_cmd = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "unified_qemu_v4_2", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-microblazeel")
    pmc_cmd = get_pmc_cmd(args)
  
  if args.device_family == "versal":
    if 'QEMU_DTB_PATH' in os.environ:
      pmc_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "board-versal-pmc-virt.dtb")
    else:
      if args.target_emu == "sw_emu":
        pmc_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "versal", "sw_emu", "board-versal-pmc-virt.dtb")
      else:
        pmc_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "versal", "hw_emu", "board-versal-pmc-virt.dtb")
  elif args.device_family == "ultrascale":
    if 'QEMU_DTB_PATH' in os.environ:
      pmc_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "zynqmp-pmu.dtb")
    else:
      pmc_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "zynqmp", "zynqmp-pmu.dtb")
  
  if args.qemu_dir != "":
      extension = ".dtb"
      substring = "pmc"
      filename = ""
      qemu_dir = os.path.abspath(args.qemu_dir)
      # join the directory path and extension to create the search pattern
      search_pattern = os.path.join(qemu_dir, f"*{extension}")
      # find all files with the desired extension in the directory
      print("search_pattern", search_pattern)
      files = glob.glob(search_pattern)
      # filter filenames to include only those that contain the desired substring
      filtered_files = [f for f in files if substring in f]
      # print the filtered filenames
      for f in filtered_files:
        file_name = f
        print("#######PMC DTB PATH", f)
      #file_name = os.path.basename(args.pmc_hw_dtb) 
      file_path = os.path.join(os.path.abspath(args.qemu_dir), file_name)
      pmc_args.append(' -hw-dtb %s '%file_path)
  else:
      if args.pmc_hw_dtb != "":
        pmc_args.append(' -hw-dtb "%s" ' %args.pmc_hw_dtb)
      else:
        pmc_args.append(' -hw-dtb "%s"' %pmc_dtb)

  if args.device_family=="ultrascale":
    pmc_rom = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "zynqmp", "pmu_rom_qemu_sha3.elf")
    pmc_args.append(" -kernel %s " %pmc_rom)

  if args.device_family=="versal" or args.device_family=="telluride":
    pmc_args.append(' -machine-path "."')

  if args.device_family=="versal" or args.device_family=="telluride":
    if args.enable_tcp_sockets == 1:
      pmc_args.append(' -chardev "socket,id=ps-pmc-rp,host=127.0.0.1,port=%s"'%pmc_port)
    else :
      pmc_args.append(' -chardev "socket,path=./qemu-rport-_pmc@0,id=ps-pmc-rp" ')
  elif args.device_family=="ultrascale":
    if args.enable_tcp_sockets == 1:
      pmc_args.append(' -chardev "socket,id=pmu-apu-rp,host=127.0.0.1,port=%s"'%pmc_port)
    else:
      pmc_args.append(' -chardev "socket,path=./qemu-rport-_pmu@0,id=pmu-apu-rp" ')

  if args.qemu_dir != "":
    read_pmc_args_file(os.path.join(os.path.abspath(args.qemu_dir),"pmc_args.txt"), pmc_args)
  else:
    read_pmc_args_file(args.pmc_args_file, pmc_args)
 
  if pmcargs_hwdtb == 1:
    pmc_args.append(' -hw-dtb "%s" '%pmc_dtb)

  if args.pmc_args_cmdline != "":
    pmc_args.append(args.pmc_args_cmdline)
  pmc_cmd1 = pmc_cmd
  
  create_start_pmc_script(pmc_script, pl_sim_dir, pmc_cmd, pmc_args, args.qemu_dir, args)

if args.device_family == "telluride":
  riscargs_microblaze_set = 0
  risc_args = []
  riscargs_hwdtb = 0
  global risc_cmd
  risc_cmd = ""
  risc_script = os.path.join(os.getcwd(), "emu_qemu_scripts", "start_risc.sh")
  global risc_dtb
  #print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
  if 'QEMU_COMP_PATH' in os.environ:
    risc_cmd = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-riscv32")
  elif 'QEMU_BIN_PATH' in os.environ:
    risc_cmd = os.path.join(os.getenv('QEMU_BIN_PATH'), "qemu-system-riscv32")
  else:
    #risc_cmd = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "unified_qemu_v4_2", "sysroots", "x86_64-petalinux-linux", "usr", "bin", "qemu-system-microblazeel")
    risc_cmd = get_risc_cmd()
  
  if args.qemu_dir != "":
      extension = ".dtb"
      substring = "risc"
      filename = ""
      qemu_dir = os.path.abspath(args.qemu_dir)
      # join the directory path and extension to create the search pattern
      search_pattern = os.path.join(qemu_dir, f"*{extension}")
      # find all files with the desired extension in the directory
      print("search_pattern", search_pattern)
      files = glob.glob(search_pattern)
      # filter filenames to include only those that contain the desired substring
      filtered_files = [f for f in files if substring in f]
      # print the filtered filenames
      for f in filtered_files:
        file_name = f
        print("#######PMC DTB PATH", f)
      #file_name = os.path.basename(args.risc_hw_dtb) 
      file_path = os.path.join(os.path.abspath(args.qemu_dir), file_name)
      risc_args.append(' -hw-dtb %s '%file_path)
  else:
      if args.risc_hw_dtb != "":
        risc_args.append(' -hw-dtb "%s" ' %args.risc_hw_dtb)
      #else:
      #  risc_args.append(' -hw-dtb "%s"' %risc_dtb)

  if args.device_family=="telluride":
    risc_args.append(' -machine-path "."')

  if args.qemu_dir != "":
    read_risc_args_file(os.path.join(os.path.abspath(args.qemu_dir),"risc_args.txt"), risc_args)
  else:
    read_risc_args_file(args.risc_args_file, risc_args)
 
  if riscargs_hwdtb == 1:
    risc_args.append(' -hw-dtb "%s" '%risc_dtb)

  if args.risc_args_cmdline != "":
    risc_args.append(args.risc_args_cmdline)
  risc_cmd1 = risc_cmd
     
  risc_args.append(' -chardev "socket,path=./qemu-rport-_asu@0,id=ps-asu-rp" ')
  
  create_start_risc_script(risc_script, pl_sim_dir, risc_cmd, risc_args, args.qemu_dir,args)
  
########
        #xsim script
if args.pl_sim_script == "":
  if args.pl_sim_args_file != "" and os.path.exists(args.pl_sim_args_file):
     pl_sim_args = read_pl_sim_args_file(args.pl_sim_args_file, pl_sim_args)
           
  xsim_script = ""
  protoinst_file = ""
  wcfg_file = ""
  wdb_file = ""
  #pl_sim_args = []
  if args.target_emu == "hw_emu":
      xsim_script = os.path.join(pl_sim_dir, "simulate.%s"%script_ext)
      sim_log_path = os.path.join(pl_sim_dir, "simulate.log")
      protoinst_file = os.path.join(pl_sim_dir, "dr_behav.protoinst")
      wcfg_file = os.path.join(pl_sim_dir, "dr_behav.wcfg")
      if (args.wdb_file != "") :
        wdb_file = os.path.join(pl_sim_dir, args.wdb_file)

  throw_error_if_no_xsim_script(args.target_emu, xsim_script)
    
  if args.graphic_xsim == 1:
    createRun1nsTclScript(pl_sim_dir)
    pl_sim_args = add_gui_option_and_set_env(sim_name, pl_sim_args, protoinst_file, wcfg_file, wdb_file)  
  else:
    pl_sim_args = add_non_gui_option_and_set_env(sim_name, pl_sim_args, protoinst_file, wcfg_file, wdb_file)
else:
  pl_sim_dir_specified = 1
  sim_log_dir = create_start_simulation_script(pl_sim_dir_specified, args.pl_sim_script, pl_sim_dir, args.graphic_xsim)
  sim_log_path = os.path.join(sim_log_dir, "simulate.log")
  xsim_script = os.path.join(pl_sim_dir, "start_simulation.%s"%script_ext)

#print("---------------------------aa", pl_sim_args[0])
###################################33
cleanline = create_clean_line(qemu_script,args)

## used by cases non v++ -p test cases -
sd_card_generation(args.device_family, args.nobuild, args.sdimage)



########################################################################   
     
global qemu_process
global pmc_process
global xsim_process
global pllauncher_process
global xsim_pid
global pl_pid

if args.target_emu == "hw_emu":
   pllauncher_process = 0
   pl_pid = 0
else:
   xsim_pid = 0

if args.device_family=="7series":
  #delete_file(socket_file)
  pmc_process = 0
  if args.target_emu == "hw_emu":
    # for zynq 7000 hw_emu ONLY , always enable PL simulation first else, it will give qemu warning
    # for rest all cases ZYNQ 7000 sw_emu / zynqmp/versal cases, enable qemu first and then start PL simulation/pllauncher 
    print("HW EMU Starting PL simulation")
    print("INFO: Running simulation script")
    os.chdir(pl_sim_dir)
    print("----------", pl_sim_dir)
    time.sleep(5)
    #xsim_process = launch_xsim_process(args.enable_debug, xsim_script, pl_sim_args)
    print("Path of the simulation directory : ", pl_sim_dir)
    xsim_pid = launch_xsim_process_with_nohup(args.enable_debug, xsim_script, pl_sim_args)
    xsim_pid = xsim_process.pid  
    print("Simulation Started. pl_pid=%s" %xsim_pid) 
    print("Waiting for PL simulation to start")
    chk_if_sim_started_successfully(socket_file, xsim_pid)    
          
    if args.pid_file != "":
      write_to_pidFile(args.pid_file, xsim_process.pid)   
     
    qemu_process = launch_qemu_process(cur_dir, args.enable_debug, args.app_file, cleanline, qemu_script) 
    print("QEMU started. qemu_pid=", qemu_process.pid)
    reset_libs(earlier_ld_lib_path)
    if args.pid_file != "":
      write_to_pidFile(args.pid_file, qemu_process.pid)

  elif args.target_emu == "sw_emu":
    qemu_process = launch_qemu_process(cur_dir,args.enable_debug, args.app_file, cleanline, qemu_script)                 
    qemu_pid2 = qemu_process.pid
    print("QEMU started. qemu_pid=", qemu_pid2)
    print("pl_port : ", pl_port)
    print("Waiting for QEMU to start")
    chk_if_qemu_started_on_port(pl_port, qemu_process)         
    reset_libs(earlier_ld_lib_path)
    if args.pid_file != "":
      write_to_pidFile(args.pid_file, qemu_process.pid)       
    time.sleep(3)
    print("SW_EMU Starting PL simulation") 
    machine_path = os.getcwd()
    emulation_mode = "batch"        
    pl_script =  os.path.join(machine_path, "pl_script.sh")    
    pllauncher_opts = run_pllauncher(args.device_family, emulation_mode, machine_path, pl_script, args.kernelDbg, target_port)
    #cmd_line = "%s %s"%(pl_exe_path, pllauncher_opts)
    pllauncher_process = launch_pllauncher_process(args.enable_debug, pl_script)         
    pl_pid = pllauncher_process.pid
    print("pllauncher started %s"%pl_pid)
    if args.pid_file != "":
      write_to_pidFile(args.pid_file, pllauncher_process.pid)
      write_to_pidFile(args.pid_file, qemu_process.pid)
else :
  # for zynq MP and Versal      
  #log_dir = os.path.normpath(os.path.join(emu_dir,'../'))
  time.sleep(2)
  os.chdir(pl_sim_dir)
  if args.mcpath != "" :
      print("QEMU is Not launched, Only simulation is runing with unix socket set which is created in directory passed as -machine-path")
      xsim_pid = launch_xsim_process_with_nohup(args.enable_debug, xsim_script, pl_sim_args)          
      print("Simulator started. simulator_pid %s"%xsim_pid)
  else :
    qemu_process = launch_qemu_process(cur_dir, args.enable_debug, args.app_file, cleanline, qemu_script)
    print("Waiting for QEMU to start. ")
    # Now wait until the QEMU port is open before continuing          
    if args.enable_tcp_sockets == 1:
      chk_if_qemu_started_on_port(pmc_port, qemu_process) 
    if pid_exists(qemu_process.pid):
      qemu_pidd = qemu_process.pid
      print("QEMU started. qemu_pid=%s" %qemu_pidd)
    reset_libs(earlier_ld_lib_path)
    print("Waiting for PMU to start. ")
    time.sleep(2)  
    pmc_pidd = ""
    if args.target_emu == "hw_emu":
      # run  pmc emulation, and pl emulation
      with open('pmc_output.log', 'w') as output_file:
        pmc_process = subprocess.Popen(["bash", pmc_script], stdout=output_file, preexec_fn=os.setsid)    
        if args.device_family == "telluride":
          time.sleep(2)  
          subprocess.Popen(["bash", risc_script], stdout=output_file, preexec_fn=os.setsid)    
      if args.enable_tcp_sockets == 1:
        chk_if_qemu_started_on_port(pl_port, pmc_process)
        print("ERROR: \[LAUNCH_EMULATOR\] launch_emulator exited because of an issue in launching MICROBLAZEEL QEMU")
      pmc_pidd = pmc_process.pid        
      print("PMC started. pmc_pid=%s" %pmc_pidd)
      time.sleep(3)
      os.chdir(pl_sim_dir)
      #xsim_process = launch_xsim_process(args.enable_debug, xsim_script, pl_sim_args)
      print("Path of the simulation directory : ", pl_sim_dir)
      if args.dont_run_sim == 1:
        print("**********Launch_emulator is launched with -dont-run-sim option. Hence simulation is not being run. User is expected to launch simulation explicitly.**********")
      else:
        xsim_pid = launch_xsim_process_with_nohup(args.enable_debug, xsim_script, pl_sim_args)          
        print("Simulator started. simulator_pid %s"%xsim_pid)
        if args.pid_file != "":
            write_to_pidFile(args.pid_file, int(xsim_pid))
        time.sleep(5)  
    elif args.target_emu == "sw_emu":
       with open('pmc_output.log', 'w') as output_file:
          pmc_process = subprocess.Popen(["bash", pmc_script], stdout=output_file, preexec_fn=os.setsid)  
       time.sleep(3)
       pmc_pidd = pmc_process.pid
       print("PMC started. pmc_pid=%s" %pmc_pidd)
       machine_path = pl_sim_dir
       emulation_mode = "batch"
       pl_script = os.path.join(machine_path, "pl_script.sh")
       pllauncher_opts = run_pllauncher(args.device_family, emulation_mode, machine_path, pl_script, args.kernelDbg, target_port)          
       #cmd_line = "%s %s"%(pl_exe_path, pllauncher_opts)
       pllauncher_process = launch_pllauncher_process(args.enable_debug, pl_script)
       pl_pid = pllauncher_process.pid
       print("pllauncher started %s"%pl_pid)    
       if args.pid_file != "":
            write_to_pidFile(args.pid_file, pllauncher_process.pid)
     
          
##### Wait for qemu to boot and run the app file if exists else wait for user to provide inputs

#time.sleep(30)
#if args.device_family == "versal":
    #time.sleep(150)
#elif args.device_family == "ultrascale":
    #time.sleep(100)
done = 0
#if timeout mentioned wait for timeout
if args.timeout != "":
    if ((args.result_stringg != "") and (args.enable_debug != 1)) :
      index = qemu_process.expect([args.result_stringg])
      if index == 0:
        print("\nINFO: Embedded host run completed.")
        done = 1
    else :       
      time.sleep(int(args.timeout))
      done = 1
      timeout_mentioned = args.timeout
      print("Mentioned timeout of %s done - terminating the qemu and simulation process"%timeout_mentioned)
    if done == 1:
      qemu_process.terminate()
      if args.target_emu == "hw_emu" and args.dont_run_sim != 1:
        if pid_exists(int(xsim_pid)):
          os.kill(int(xsim_pid), 9)
      elif args.target_emu == "sw_emu":
        if pid_exists(int(pl_pid)):
          os.kill(int(pl_pid),9)
          print("exiting pllauncher beause of timeout")
      qemu_process.terminate()
    else:
      qemu_process.wait()
else: 
#if timeout is not mentioned,poll and check if booting successful
  booted = False
  booting_timeout = time.time() + 60*70   # 70 minutes from now 
  while True :
   if args.mcpath == "" :
    if (pid_exists(qemu_process.pid)):
      if (booted):
        #if booting is successfull, mount  
        if args.app_file != "":
          qemu_process.sendline('mount /dev/mmcblk0p1 /mnt')
          index = qemu_process.expect(['~#', "must be superuser to use mount"])
          if index == 0:
            #qemu_process.sendline('mount /dev/mmcblk0p1 /mnt')
            #qemu_process.expect('~#')
            qemu_process.sendline('cd /mnt')
            qemu_process.expect('/mnt#')
            qemu_process.sendline('ls')
          if index == 1:
            qemu_process.sendline('sudo su')
            qemu_process.expect("Password:")
            qemu_process.sendline(args.password)
            qemu_process.expect(':')
            qemu_process.sendline('mount /dev/mmcblk0p1 /mnt')
            qemu_process.expect('#')
            qemu_process.sendline('cd /mnt')
            qemu_process.expect('/mnt#')
            qemu_process.sendline('ls')
          # if run-app is mentioned, run the application file
          print("INFO:Running %s" %args.app_file)
          if args.target_emu != "hw_emu":
            print("QEMU_HOST_PORT : ", os.getenv("QEMU_HOST_PORT"))
          cmd_string = './%s \n'%args.app_file
          qemu_process.sendline(cmd_string)
          print("Run app command sent to console")
          time.sleep(20)
          if (args.disable_host_check == 1) :
            if args.dont_run_sim != 1:
              skip_host_execution_result_check(args.target_emu, xsim_pid, qemu_process, log_dir)
              break
          else:
            index = qemu_process.expect(['Embedded host run completed', 'TEST FAILED', args.result_stringg])
            if index == 0:
              print("\nINFO: Embedded host run completed.") 
            if index == 2:
              print("\nINFO: Embedded host run completed.")
            if index == 1:
              print("\nERROR: Embedded host run failed.")
            time.sleep(20)
            print("\nINFO: Exiting QEMU\n")
            #qemu_process.sendline('\x01')
            qemu_process.sendcontrol('a')
            #print("send x")
            qemu_process.sendline('x')
            time.sleep(30)
            break
        else:
          # run normal flow , without -run-app, give control to user so that he can give his commands
          #print("normal flow boot suucessfull")
          if args.device_family == "telluride":
            qemu_process.logfile_read = None
            qemu_process.interact()
          else:
            qemu_process.sendline('mount /dev/mmcblk0p1 /mnt')
            index = qemu_process.expect(['~#', "must be superuser to use mount"])
            if index == 0:
              
              qemu_process.sendline('cd /mnt')
              qemu_process.expect('/mnt#')
              qemu_process.sendline('ls')
            if index == 1:   
              qemu_process.sendline('sudo su')
              qemu_process.expect("Password:")
              qemu_process.sendline(args.password)
              qemu_process.expect(':')
              qemu_process.sendline('mount /dev/mmcblk0p1 /mnt')
              qemu_process.expect('#')
              qemu_process.sendline('cd /mnt')
              qemu_process.expect('/mnt#')
              qemu_process.sendline('ls')
            qemu_process.logfile_read = None
            qemu_process.interact() 
            break       
      else:
        #if booting is not successfull, check  if you see there is a simulation error, else recheck if booted now after some time
        sim_process_error = 0
        if args.target_emu == "hw_emu":
          sim_process_error = read_simulate_log_for_error(1, os.path.join(pl_sim_dir, "simulate.log"), qemu_process)
          if args.pl_deadlock_detection:
            read_kernel_deadlock_diag_rpt(pl_sim_dir, log_dir)
        if sim_process_error != 1:
          if args.enable_debug != 1:
            booted = login_check_if_booted(qemu_process, args.login, args.password)
          
    else:
      print("Exiting QEMU!!")
      break         
                     

    
time.sleep(2)

# Cleanup
 #Adding 2 second delay, because XSIM is taking some time to quit after qemu quits.
 #If this dalay is not added , during cleanup, we are trying to kill xsim process using the PID present..
 #When we are checking for xsim pid, it  exists.But, by the time we give kill command, it gets killed , and kill command cannot find xsim pid. and we are seeing terminate issues because of this.

#get group pid of pllauncher process;kill genericpcieprocess, which has same grouppid as pllauncher
global plgpid
if args.target_emu == "sw_emu" : 
  plgpid = os.getpgid(pllauncher_process.pid)

if (args.dont_run_sim != 1 and args.mcpath == ""):
  poll_to_check_if_any_process_exited(done, qemu_process, pmc_process, xsim_pid, pllauncher_process, args.device_family, args.target_emu)

 
if os.path.exists(os.path.join(os.path.abspath(pl_sim_dir), "runSummaryMetadata.json")):    
    run_genaiesummary()

time.sleep(2)

if args.dont_run_sim != 1:
  clean_all_process(done, pl_sim_dir, qemu_process, pmc_process, xsim_pid, pllauncher_process, args.device_family, args.target_emu)

## seeing corner case issues while killing generic pcie mode .If 2 testcases are running in parallel
#handle in next release

if args.target_emu == "sw_emu":
    kill_process_by_name(pl_exe_path)
    time.sleep(2)

if args.target_emu == "hw_emu":    
 if os.path.exists(os.path.join(os.path.abspath(pl_sim_dir), "qemu_output.log")):    
  copy_log_files_to_pwd(os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../"), "qemu_output.log", os.path.abspath(pl_sim_dir))
  print("copying qemu output file from %s to %s"%(os.path.abspath(log_dir), os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../")))      

if args.target_emu == "hw_emu":
  copy_log_files_to_pwd(os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../"), "xsc.log", os.path.abspath(pl_sim_dir))
  print("copying xsc files from %s to %s"%(os.path.abspath(log_dir), os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../")))
  dump_log_into_console("xsc.log", os.path.abspath(pl_sim_dir))

  copy_log_files_to_pwd (os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../"),"simulate.log", os.path.abspath(pl_sim_dir))
  print("copying simulate files from %s to %s"%(os.path.abspath(log_dir), os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../")))
  dump_log_into_console("simulate.log", os.path.abspath(pl_sim_dir))


if args.pl_deadlock_detection == True:
 if args.target_emu == "hw_emu":
  copy_log_files_to_pwd (os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../"),"kernel_deadlock_diagnosis.rpt", os.path.abspath(pl_sim_dir))
  print("copying deadlock log files from %s to %s"%(os.path.abspath(log_dir), os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../")))
  old_file = os.path.join(os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../"), "kernel_deadlock_diagnosis.rpt")
  new_file = os.path.join(os.path.join(os.path.abspath(pl_sim_dir), "../", "../", "../"), "pl_deadlock_diagnosis.txt")
  os.rename(old_file, new_file)
  
 
post_operations(args.device_family, pl_sim_dir, log_dir, args.platform_name, envdict, VIMAGE_PID)

#print("DONE")

if args.target_emu == "sw_emu":
  print("INFO:Exiting launch_sw_emu.sh")
else:
  print("INFO: Exiting launch_hw_emu.sh")
sys.exit()
