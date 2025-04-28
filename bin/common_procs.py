#!/usr/bin/env python
import random
import os
import platform
import time
from datetime import datetime
from shutil import copyfile
import shutil
import glob
import subprocess
import shlex
import signal
import pexpect
import sys
import json
OS_USED = platform.system()

def get_qemu_settings_path(args):
  qemu_settings_path = ""
  if OS_USED == "Linux":
    #As per QEMU team, In windows no need to source any environment 
    if 'QEMU_COMP_PATH' in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "qemu", "environment-setup-x86_64-petalinux-linux")
    elif "QEMU_BIN_PATH" in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_BIN_PATH'), "../", "../", "../", "../", "environment-setup-x86_64-petalinux-linux")
      print("CRITICAL_WARNING: 'QEMU_BIN_PATH' is deprecated and will be removed shortly, instead use the 'QEMU_COMP_PATH' to point to local dts or QEMU binaries.")
    else:
      new_qemu_dtb_flow = os.getenv('NEW_QEMU_DTB_FLOW')
      if new_qemu_dtb_flow == "0":
        qemu_settings_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "qemu",  "environment-setup-x86_64-petalinux-linux")  
      else:
        qemu_settings_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "qemu", "environment-setup-x86_64-petalinux-linux")  
  if args.device_family == "telluride" and OS_USED == "Linux":
    if 'QEMU_COMP_PATH' in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "environment-setup-x86_64-petalinux-linux")
    elif "QEMU_BIN_PATH" in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_BIN_PATH'), "../", "../", "../", "../", "environment-setup-x86_64-petalinux-linux")
    else:
      qemu_settings_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "telluride_qemu", "environment-setup-x86_64-petalinux-linux")  

        
  return qemu_settings_path

def get_qemu_pmu_path(args):
  qemu_path = ""
  if 'QEMU_COMP_PATH' in os.environ:
    if args.device_family != "telluride":
      qemu_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
    else:
      qemu_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
  elif 'QEMU_BIN_PATH' in os.environ:
    qemu_path = os.getenv('QEMU_BIN_PATH')
  else:
    new_qemu_dtb_flow = os.getenv('NEW_QEMU_DTB_FLOW')
    # use new v5 qemu version
    # pick qemu for windows from qemu_win directory. For linux, get from unified qemu.
    if OS_USED != "Linux":
      qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu_win", "qemu") 
    else:
      if new_qemu_dtb_flow == "0":
        qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
      else:
        if args.device_family != "telluride":
          qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
        else:
          qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")

  return qemu_path

def get_qemu_risc_path():
  qemu_path = ""
  if 'QEMU_COMP_PATH' in os.environ:
    qemu_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
  elif 'QEMU_BIN_PATH' in os.environ:
    qemu_path = os.getenv('QEMU_BIN_PATH')
  else:
    new_qemu_dtb_flow = os.getenv('NEW_QEMU_DTB_FLOW')
    # use new v5 qemu version
    # pick qemu for windows from qemu_win directory. For linux, get from unified qemu.
    if OS_USED != "Linux":
      qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu_win", "qemu") 
    else:
      qemu_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "telluride_qemu", "sysroots", "x86_64-petalinux-linux", "usr", "bin")
  if device_family == "telluride" and OS_USED == "Linux":
    if 'QEMU_COMP_PATH' in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_COMP_PATH'), "comp", "telluride_qemu", "environment-setup-x86_64-petalinux-linux")
    elif "QEMU_BIN_PATH" in os.environ:
      qemu_settings_path = os.path.join(os.getenv('QEMU_BIN_PATH'), "../", "../", "../", "../", "environment-setup-x86_64-petalinux-linux")
    else:
      qemu_settings_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "qemu", "comp", "telluride_qemu", "environment-setup-x86_64-petalinux-linux")  
        
  return qemu_path

def port_open (pl_port):
  a = os.popen('netstat -na').read()
  conn = "127.0.0.1:%s" %pl_port
  
  if conn not in a:
    return 0
  else:
    return 1

def get_available_port():
  num_tries = 0
  for x in range(1):
     current_port=random.randint(7000,9999)
     #print("--current_port", current_port)
  while num_tries < 2000:
      flag = port_open(current_port)
      #print("---flag", flag)
      if flag == 1:
        for x in range(1):
          current_port=random.randint(7000,9999)
          #print ("current_port1", current_port)
        num_tries = num_tries + 1
        #print("num_tries", num_tries)
      else:
        pl_port = current_port
        return pl_port

def post_operations(device_family, pl_sim_dir, log_dir, platform_name, envdict, VIMAGE_PID):

    #delete all qemu created memory files
    for filename in glob.glob("%s/qemu-memory*"%pl_sim_dir):
      os.remove(filename)
      
    for filename in glob.glob("%s/qemu-rport*"%pl_sim_dir):
      os.remove(filename)
   
    #deleted the /tmp/cosim* socket dirs created.They are created only for zynq7000. 
    if device_family=="7series":
      if OS_USED== "Linux":
        zynq7000_unixsock_name = "qemu-cosim-%s"%VIMAGE_PID 
        my_dir = "/tmp"# enter the dir name
        for fname in os.listdir(my_dir):
          if fname.startswith(zynq7000_unixsock_name):
            my_dir_del = "/tmp/%s"%zynq7000_unixsock_name
            shutil.rmtree(my_dir_del, ignore_errors=True)
     
    #copy all the wcfg and wdb files to package temp dir
  
    #WCFG file processing
    wcfg_src_path = os.path.join(pl_sim_dir, "dr_behav.wcfg") 
    if os.path.exists(wcfg_src_path):
      shutil.copy(wcfg_src_path, os.path.join(log_dir, "%s.wcfg"%platform_name) )     
    #End of WCFG file processing
  
    #WDB file processing
    os.chdir(pl_sim_dir)
    for name in glob.glob('*_wrapper_behav.wdb'):
       shutil.copy(name, os.path.join(log_dir, "%s.wdb"%platform_name) )   
    #End of WDB file processing
  
    #unset all the envs that is set
    for key in envdict.keys():
      if key in os.environ:
        del os.environ[key]


def kill_group(pid):
    if OS_USED == "Linux":
      cmd  = "exec /bin/kill -- -%s"%pid
      time.sleep(2)
      #print("")
      os.system(cmd)  
  
def pid_exists(pid): 
    if pid < 0: return False #NOTE: pid == 0 returns True
    try:
        os.kill(pid, 0) 
    except ProcessLookupError: # errno.ESRCH
        return False # No such process
    except PermissionError: # errno.EPERM
        return True # Operation not permitted (i.e., process exists)
    else:
        return True # no error, we can send a signal to the process

def writeStartSimScriptFile(start_sim_file, sim_script, sim_dir):
  # open the start simulation script file
  with open(start_sim_file, 'w') as fp:
    # write out the start simulation script
    if OS_USED != "Linux":
      fp.write("chdir /d %s"%sim_dir)
      fp.write("call %s %*"%sim_script)
      fp.write("exit /b %errorlevel%")
    else:
      fp.write("#!/bin/bash")
      fp.write("cd %s"%sim_dir)
      fp.write("./%s \$*"%sim_script)
  
  # close the file
  fp.close()
  os.chmod(start_sim_file , 0o777)


def get_qemu_dtb(device_family, target_emu):
  global qemu_dtb 
  # for windows, pllauncher was not tested.Hence using non-cosim dtb for windows nopl case
  if 'QEMU_DTB_PATH' in os.environ:
    if device_family == "ultrascale":
      if OS_USED != "Linux" and target_emu == "sw_emu":   
        qemu_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "zynqmp-arm.dtb")
      else:
        qemu_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "zynqmp-arm-cosim.dtb")
    elif device_family == "7series":
      if OS_USED != "Linux" and target_emu == "sw_emu":   
        qemu_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "zynq", "zynq-arm.dtb")
      else:
        qemu_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "zynq-arm-cosim.dtb")
    else:
      if OS_USED != "Linux" and target_emu == "sw_emu":   
        qemu_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "versal", "board-versal-ps-virt.dtb")
      else:
        qemu_dtb = os.path.join(os.getenv('QEMU_DTB_PATH'), "board-versal-ps-cosim-vitis-vck190.dtb")
  else:
    if device_family == "ultrascale":
      if OS_USED != "Linux" and target_emu == "sw_emu":   
        qemu_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "zynqmp",  "zynqmp-arm.dtb")
      else:
        qemu_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "zynqmp", "zynqmp-arm-cosim.dtb")
    elif device_family == "7series":
      if OS_USED != "Linux" and target_emu == "sw_emu":   
        qemu_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "zynq", "zynq-arm.dtb")
      else:
        qemu_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "zynq", "zynq-arm-cosim.dtb")
    else:
      if OS_USED != "Linux" and target_emu == "sw_emu":   
        qemu_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "versal", target_emu, "board-versal-ps-virt.dtb")
      else:
        qemu_dtb = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "dtbs", "versal", target_emu, "board-versal-ps-cosim-vitis-vck190.dtb")

  return qemu_dtb   

def get_qemu_cmd(args):
  global qemu_cmd
  qemu_cmd = os.path.join(get_qemu_pmu_path(args), "qemu-system-aarch64")
  print("INFO: Using QEMU from : %s"%qemu_cmd)
  return qemu_cmd

def get_pmc_cmd(args):
  global pmc_cmd
  pmc_cmd = os.path.join(get_qemu_pmu_path(args), "qemu-system-microblazeel")
  print("INFO: Using PMC/PU from : %s"%pmc_cmd)
  return pmc_cmd

def get_risc_cmd():
  global risc_cmd
  risc_cmd = os.path.join(get_qemu_risc_path(), "qemu-system-riscv32")
  print("INFO: Using RISC from : %s"%risc_cmd)
  return risc_cmd



def createRun1nsTclScript(path):
  script = os.path.join(path, "run1ns.tcl")
  with open(script, 'w') as fp:
    fp.write("run 1ns")
  fp.close()

def write_to_pidFile(pid_file, process_id): 
    with open(pid_file, 'w') as fp:
      grp_pid = group_pid(process_id)
      fp.write(str(grp_pid)) 
    fp.close()
  
def group_pid(pid):
    pgid = os.getpgid(pid)
    return pgid



def run_pllauncher (device_family, emulation_mode, machine_path, pl_script, kernelDbg, port1):
  print("Starting PL simulation.Generating PLLauncher commandline")
  #Generate PLLauncher commandline
  pl_exe_path = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "unified", "hw_em", "zynqu", "pllauncher")
  simipaddr = "tcp:127.0.0.1:%s"%port1
  sd_path = os.path.join(machine_path, "sd_card")
  devFam = ""
  if device_family == "versal":
    devFam = "versal"
  elif device_family == "ultrascale":
    devFam = "zynqmp"
  else:
    devFam = "zynq"
  if kernelDbg == "true":
     emulation_mode = "gui"
  pllauncher_opts = '--emulation-mode "%s"  --machine-path "%s" --remote-port.chardesc "%s" --remote-port-sim.chardesc  "%s" --sd "%s" -f "%s"'%(emulation_mode, machine_path, os.getenv('COSIM_MACHINE_TCPIP_ADDRESS'), simipaddr, sd_path, devFam)
  # Write the pllauncher script
  with open(pl_script, 'w') as fppl:
    if OS_USED == "Linux":
      fppl.write("#!/bin/bash\n")
      cmd_line = "%s %s"%(pl_exe_path, pllauncher_opts)
      fppl.write("%s"%cmd_line)
  fppl.close()
  os.chmod(pl_script , 0o777)
  print("Running PLL Launcher")
  return pllauncher_opts


def dump_log_into_console(log_name, log_path):
    file_path = os.path.join(log_path, log_name)
    line_num = -5
    if os.path.exists(file_path):
      line_num = get_line_number("ERROR", file_path)
      if line_num < 1:
        line_num = get_line_number("Error:", file_path)
        if line_num < 1:
          line_num = get_line_number("FATAL_ERROR", file_path)
          if line_num < 1:
            line_num = get_line_number("Command failed", file_path)
        
      a_file = open(file_path)
      lines_to_read = []
      if line_num > 0:
        lines_to_read = [line_num-2, line_num-1, line_num, line_num+1, line_num+2]
      for position, line in enumerate(a_file):
        #Iterate over each line and its index
        if position == line_num - 1:
          print("ERROR : ",line)
        elif position in lines_to_read:
          print(line)
        

def get_simulator_name(pl_sim_dir):
  pl_sim_dir = os.path.abspath(pl_sim_dir)
  simulator_name = os.path.basename(pl_sim_dir)
  return simulator_name

def find_file(folder_name, file_name, extension):
    folder_path = os.path.abspath(folder_name)
    for file in os.listdir(folder_path):
        if file.endswith(extension) and file_name in file:
            return os.path.join(folder_path, file)
    return None
  
def image_file_path(qemu_args, file_path, drive_arg):
    if file_path != "":
        qemu_args.append(' -drive "file=%s,%s" ' %(file_path, drive_arg))
    else:
        sdimg = os.path.join(os.getcwd(), " _vimage", "emulation", "sd_card.img")
        qemu_args.append(' -drive "file=%s,%s" '%(sdimg, drive_arg))

def get_file_path(qemu_args, args, file_arg, drive_arg):
    if file_arg != "":
        #file_name = os.path.basename(file_arg)
        file_name = file_arg
        file_path = os.path.join(os.path.abspath(args.qemu_dir), file_name)
        qemu_args.append(' -drive "file=%s,%s" ' %(file_path, drive_arg))
    else:
        sdimg = os.path.join(os.getcwd(), " _vimage", "emulation", "sd_card.img")
        qemu_args.append(' -drive "file=%s,%s" '%(sdimg, drive_arg))
        
def replace_string_in_file(filename, line_starts_with, old_string, new_string):
  reading_file = open(filename, "r")
  new_file_content = ""
  for line in reading_file:
    stripped_line = line.strip()
    if line_starts_with in stripped_line:
      new_line = stripped_line.replace(old_string, new_string)
    else:
      new_line = stripped_line
    new_file_content += new_line +"\n"
  reading_file.close()

  writing_file = open(filename, "w")
  writing_file.write(new_file_content)
  writing_file.close()

def append_string_to_a_line_in_file(filename, line_starts_with, check_if_string_exists, append_string):
  reading_file = open(filename, "r")
  new_file_content = ""
  for line in reading_file:
    stripped_line = line.strip()
    if line_starts_with in stripped_line:
      if check_if_string_exists in stripped_line:
        new_line = stripped_line
      else:
        new_line = stripped_line
        new_line += append_string
    else:
      new_line = stripped_line
    new_file_content += new_line +"\n"
  reading_file.close()

  writing_file = open(filename, "w")
  writing_file.write(new_file_content)
  writing_file.close()
  
def writeNewSimulateScriptForQuesta(pl_sim_dir):
    filename = os.path.join(pl_sim_dir, "simulate.sh")
    replace_string_in_file(filename, "vsim", "-c ", "-gui ")

def writeNewSimulateScriptForXcelium(pl_sim_dir):
    filename = os.path.join(pl_sim_dir, "simulate.sh")
    append_string_to_a_line_in_file(filename, "bin_path/xmsim", "gui ", " -gui ")

def writeNewSimulateScriptForVCS(pl_sim_dir):
    filename = os.path.join(pl_sim_dir, "simulate.sh")
    append_string_to_a_line_in_file(filename, "_sim_wrapper_simv", "gui ", " -gui ")

###
def get_pid(name):
    return subprocess.check_output(["pidof",name])

def get_pname(id):
    return os.system("ps -o cmd= {}".format(id))

def kill_process_by_name(process_name):
    process_list = subprocess.Popen(['ps', '-a'], stdout=subprocess.PIPE)
    output, error = process_list.communicate()
    for line in output.splitlines():
      if process_name in str(line):
        pid = int(line.split(None, 1)[0])
        #print(pid)
        os.kill(pid, 9)

def launch_xsct_and_copy_xrt_run_files(log_dir, target) :
      xsct_tcl = os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "scripts", "xsct.tcl")
      cleanline = "xsct %s %s"%(xsct_tcl, target)
      #print("abs path for log dir ", os.path.abspath(log_dir))
      #print("current pwd ",os.getcwd())
      print('Launching XSCT for copying back using command %s'%cleanline)
      xsct_process = pexpect.spawn('%s'%cleanline, timeout=None)
      xsct_process.logfile_read = sys.stdout.buffer
      while True:
              try:
                xsct_process.expect('\n')
                print(xsct_process.after)
              except pexpect.EOF:
                break 
      time.sleep(10)
      copy_log_files_to_pwd(os.path.abspath(log_dir),"xrt.run_summary",  os.path.abspath(os.getcwd())) 
      copy_all_run_files(log_dir)

def copy_all_run_files(log_dir) :
  # Open the run.summary file
  print("copy_all_run_files")
  with open(os.path.join(os.path.abspath(log_dir), "xrt.run_summary")) as file:
    # Load its content and make a new dictionary
    data = json.load(file)
    #print("data", data)
    # Copy each file 
    for each_file in data["files"]:
      #print("file  : ", each_file)
      #print("filename  : ", each_file["name"])
      copy_log_files_to_pwd(os.path.abspath(log_dir),each_file["name"],  os.path.abspath(os.getcwd())) 

def copy_log_files_to_pwd(log_dir, log_name, log_path):

    log_file = os.path.join(log_path, log_name)
    dest_file = os.path.join(log_dir, log_name)
    if os.path.exists(log_file):
      copyfile(log_file, dest_file)
 
def get_line_number(phrase, file_name):
    with open(file_name) as f:
        for i, line in enumerate(f, 1):
            if phrase in line:
                return i
    return -1

def get_xilinx_path():
  if "XILINX_XD" in os.environ:
    USER_DEFINED_XD = os.getenv('XILINX_XD')
    XILINX_XD = USER_DEFINED_XD
    print ('Using user-defined path for XILINX_XD environment variable', USER_DEFINED_XD)
  else:
    VITIS_EMULATOR_SCRIPT = os.path.dirname(os.path.realpath(__file__));
    from os.path import dirname as up
    #xilinx_xd path , is 3 levels above script path
    xd_path = up(up(up(__file__)))
    one_up = os.path.normpath(os.path.join(VITIS_EMULATOR_SCRIPT,'../'))
    os.environ['XILINX_XD'] = one_up
    XILINX_XD = os.getenv('XILINX_XD')
    #print ("XILINX_XD", XILINX_XD)
  return XILINX_XD

def read_log_for_error(rc, log_file, qemu_process):
  process_error = 0
  with open(log_file) as f:
      log_txt = f.read()
      errorList = ['ERROR:', 'Error:', 'FATAL_ERROR', 'Command failed']
      if any(word in log_txt for word in errorList):
        qemu_process.terminate()
        #qemu_process.kill()
        #print("killing qemu since simulator exited")
        time.sleep(2)
        process_error = 1
        
  return process_error


def read_kernel_deadlock_diag_rpt(sim_path, log_dir):
  deadlockReportFile = os.path.join(sim_path,  "kernel_deadlock_diagnosis.rpt"); 
  pldeadlockDiagFile = os.path.join(sim_path,  "pl_deadlock_diagnosis.txt");
  #dest_file = os.path.join(log_dir, "pl_deadlock_diagnosis.txt")

  if os.path.exists(deadlockReportFile):
    with open(deadlockReportFile, 'r') as f, open(pldeadlockDiagFile,'a') as pl:
      if '"start to dump deadlock path"' in f.read():
        # read content from first file
        for line in f:     
             # append content to second file
             pl.write(line)
             print(line)
    #copyfile(pldeadlockDiagFile, dest_file)

def read_simulate_log_for_error(rc, simulate_log, qemu_process):
  error_code = read_log_for_error(rc, simulate_log, qemu_process)
  if error_code == 1:
    print("ERROR: Simulator ERROR")
  return error_code

def read_qemu_log_for_error(rc, qemu_log, qemu_process):
  error_code = read_log_for_error(rc, qemu_log, qemu_process)
  return error_code
  
  
def read_log_file(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, target_emu, app_file):
  boot_done = 0
  with open(qemu_txt_file) as f:
    if 'root@' in f.read():
      #print("INFO: Linux kernel booted successfully")
      #qemu_process.stdin.write()
      time.sleep(2)
      print("INFO: Mounting")
      qemu_process.stdin.write(b'mount /dev/mmcblk0p1 /mnt\r\n')
      qemu_process.stdin.flush()
      qemu_process.stdin.write(b'cd /mnt\r\n')
      qemu_process.stdin.flush()
      qemu_process.stdin.write(b'ls\n')
      qemu_process.stdin.flush()
      print("INFO:Running %s" %app_file)
      if target_emu != "hw_emu":
        print("QEMU_HOST_PORT : ", os.getenv("QEMU_HOST_PORT"))
      cmd_string = './%s'%app_file
      qemu_process.stdin.write(bytes(cmd_string+'\n','utf-8'))
      qemu_process.stdin.flush()
      qemu_process.stdin.write(b'\n')
      qemu_process.stdin.flush()
      boot_done = 1
        #kill_all_process(qemu_cmd, pl_exe_path)
        #sys.exit()
  return boot_done

def login_check_if_booted(qemu_process, login, password):
     index = qemu_process.expect([':~', 'login:', 'Retype new password:', 'New password:', 'Password:', 'Login incorrect', pexpect.EOF])
     booted = False	 
     if index == 1:
       qemu_process.sendline(login)
     if index == 2:
       #qemu_process.logfile_read = None
       #qemu_process.interact()
       qemu_process.sendline(password) 
     if index == 3:
       #qemu_process.logfile_read = None
       #qemu_process.interact()
       qemu_process.sendline(password)
     if index == 4:
       qemu_process.sendline(password)
     if index == 0:
       #qemu_process.sendline('mount /dev/mmcblk0p1 /mnt')
       #qemu_process.expect('~#')
       #qemu_process.sendline('cd /mnt')
       #qemu_process.expect('/mnt#')
       #qemu_process.sendline('ls') 
       booted = True
     if index == 5:
       print("\n ERROR : Login incorrect. Exiting QEMU.\n")
       os.kill(qemu_process.pid, signal.SIGTERM)
     if index == 6:
       booted=False
     return booted  

def check_for_result(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, xsim_pid, result_stringg):
    pass_string = 0
    result_string = 0
    fail_string = 0
    result_dict = {}
    with open(qemu_txt_file) as f1:
        log_file_txt = f1.read()
        passList = ['Embedded host run completed', 'TEST FAILED']
        passList.append(result_stringg)
        passList = [x.lower() for x in passList] 
        for x in range(len(passList)):
          print(passList[x])
        log_file_txt_lower = log_file_txt.lower()
        if any(word in log_file_txt_lower for word in passList):
          print(result_stringg)
          time.sleep(5)
          print("\n Exiting QEMU \n")
          if pid_exists(qemu_process.pid) and pid_exists(int(xsim_pid)):
            print("sending cntrl a")
            qemu_process.stdin.write(b'\x01')
            qemu_process.stdin.flush()
          if pid_exists(qemu_process.pid) and pid_exists(int(xsim_pid)):
            print("send x")
            qemu_process.stdin.write(b'x')
            qemu_process.stdin.flush()
          pass_string = 1
          fail_string = 0
        else:
          pass_string = 0
          if 'ERROR:' in log_file_txt:
              fail_string = 1
          else:
              fail_string = 0
    
    if pass_string == 1 or fail_string == 1:
       result_string = 1

    result_dict["result"] = result_string
    result_dict["pass"] = pass_string
    result_dict["fail"] = fail_string
    return result_dict

def run_reboot(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path):
    
          with open(qemu_txt_file) as f2:
            log_file_txt = f2.read()
            if 'Restarting system' in log_file_txt:
              
              print("INFO: Found reboot finishing string.")
              print("Emulation ran successfully")
              print("killing QEMU/PLLauncher/XSIM")
              
            else: 
             print("ERROR: Reboot failed")
             #kill_all_process(qemu_cmd, pl_exe_path)
             os.kill(qemu_process.pid, signal.SIGTERM)

            
def kill_all_process(qemu_cmd, pl_exe_path, target_emu):
              pid_num7 = get_pid(qemu_cmd)

  
              pid_num8 = pid_num7.decode("utf-8")

              os.kill(int(pid_num8), signal.SIGTERM)
              time.sleep(2)
              if pid_exists(int(pid_num8)):
                print("QEMU not killed")
              else:
                print("QEMU killed successfully")

              if target_emu == "sw_emu":
                pid_num33 = get_pid(pl_exe_path)

  
                pid_num44 = pid_num33.decode("utf-8")

                os.kill(int(pid_num44), signal.SIGTERM)
            
                time.sleep(2)

                if pid_exists(int(pid_num44)):
                  print("PLLauncher not killed")
                else:
                  print("PLLauncher exited successfully")
              
              if target_emu == "hw_emu":
                  
                pid_num2 = get_pid("xsim")
                #print("pid_num2",pid_num7)

                pid_num3 = pid_num2.decode("utf-8")
                #print("pid_num3", pid_num3)

                os.kill(int(pid_num3), signal.SIGTERM)
                time.sleep(2)

                if pid_exists(int(pid_num3)):
                  print("Simulator not killed")
                else:
                  print("Simulator exited successfully")

def set_qemu_libs():
  #Need to unset existing LD_LIBRARY_PATHS for qemu to work
  if 'LD_LIBRARY_PATH' in os.environ:
    del os.environ['LD_LIBRARY_PATH']  
 
def reset_libs(earlier_ld_lib_path):
  os.environ['LD_LIBRARY_PATH'] = earlier_ld_lib_path 
  time.sleep(1)

def read_pmc_args_file(pmc_args_file, pmc_args):
 with open(pmc_args_file) as f1:
   d = map(str.rstrip, f1.readlines())

   for i in d: 
    line = i
    if line.startswith("#"): 
      #it is a comment, if it starts with #, dont append the line to qemu_args.
      continue
    if line.startswith("-"):  
      pmc_args.append(' %s ' %line)
      if line=="-hw-dtb":
        pmcargs_hwdtb = 1
    else:
      if (OS_USED != "Linux") and (line == "/dev/null"):
        line = "null"
      linemodified = '"%s" ' %line
      pmc_args.append(linemodified)
 f1.close()

def read_risc_args_file(risc_args_file, risc_args):
 with open(risc_args_file) as f1:
   d = map(str.rstrip, f1.readlines())

   for i in d: 
    line = i
    if line.startswith("#"): 
      #it is a comment, if it starts with #, dont append the line to qemu_args.
      continue
    if line.startswith("-"):  
      risc_args.append(' %s ' %line)
      if line=="-hw-dtb":
        riscargs_hwdtb = 1
    else:
      if (OS_USED != "Linux") and (line == "/dev/null"):
        line = "null"
      linemodified = '"%s" ' %line
      risc_args.append(linemodified)
 f1.close()

def read_pl_sim_args_file(pl_sim_args_file, pl_sim_args):
     reading_file = open(pl_sim_args_file, "r")
     for line in reading_file:
       stripped_line = line.strip()
       if stripped_line.startswith("-"):
         pl_sim_args += " %s"%line
       else:
        if OS_USED != "Linux" and line == "/dev/null":
         line = "null" 
        pl_sim_args += ' "%s"'%line
     return pl_sim_args

def add_gui_option_and_set_env(sim_name, pl_sim_args, protoinst_file, wcfg_file, wdb_file):
    if sim_name == "xsim":
      pl_sim_args += " -g"
      if protoinst_file != "":
        pl_sim_args += " --protoinst %s"%protoinst_file
      if wdb_file != "":
        pl_sim_args += " --wdb %s"%wdb_file
        os.environ['VITIS_WAVEFORM_WDB_FILENAME'] = wdb_file
      if wcfg_file != "":
        os.environ['VITIS_WAVEFORM'] = wcfg_file  
      
    elif sim_name == "questa":
       pl_sim_args += " gui"
    elif sim_name == "xcelium":
      pl_sim_args += " gui"
    else:
      pl_sim_args += " gui"
    if 'VITIS_LAUNCH_WAVEFORM_BATCH' in os.environ:
      del os.environ['VITIS_LAUNCH_WAVEFORM_BATCH']
    os.environ['VITIS_LAUNCH_WAVEFORM_GUI'] = '1' 
    return pl_sim_args

def add_non_gui_option_and_set_env(sim_name, pl_sim_args, protoinst_file, wcfg_file, wdb_file):
    if sim_name == "xsim":
      pl_sim_args += " -R"
      if wcfg_file != "":
        os.environ['VITIS_WAVEFORM'] = wcfg_file    
      if protoinst_file != "":
        pl_sim_args += " --protoinst %s"%protoinst_file
      if wdb_file != "":
        pl_sim_args += " --wdb %s"%wdb_file
        os.environ['VITIS_WAVEFORM_WDB_FILENAME'] = wdb_file
    
    if 'VITIS_LAUNCH_WAVEFORM_GUI'  in os.environ:
      del os.environ['VITIS_LAUNCH_WAVEFORM_GUI']
    os.environ['VITIS_LAUNCH_WAVEFORM_BATCH'] = '1'
    return pl_sim_args

def throw_error_if_no_xsim_script(target_emu, xsim_script):
  if target_emu == "sw_emu":
    # no need of xsim_script for sw_emu as there is no PL to simulate.It is PS only deisgn.
    print("")
  else:
    if os.path.exists(xsim_script):
      print("")
    else:
      print("ERROR: \[LAUNCH_EMULATOR\] Missing expected simulation script: %s"%xsim_script)
      sys.exit()

def skip_host_execution_result_check(target_emu, xsim_pid, qemu_process, log_dir):
    print("Skipping host execution checks!!")
    if target_emu == "hw_emu":
      for x in range(25):
        if pid_exists(int(xsim_pid)):
          time.sleep(10)
          #print("")
        else:
          qemu_process.terminate()
          break
    else:
      time.sleep(50)
      tmp_src_path = os.path.join(log_dir, "../", ".run", "device_process.log")  
      print("Checking for device_process.log at ", tmp_src_path) 
      for x in range(50):
        #print("checking x ", x)
        if os.path.exists(tmp_src_path):
          print("device_process.log exists")
          with open(tmp_src_path) as f:
            if 'received request to end simulation from connected initiator.' in f.read():
              print("Received request to end simulation from connected initiator. Quitting qemu")
              qemu_process.terminate()
              break
            else:
              time.sleep(10)
        elif os.path.exists(os.path.join(log_dir, ".run", "device_process.log")):
          print("device_process.log exists")
          with open(os.path.join(log_dir, ".run", "device_process.log")) as f:
            if 'received request to end simulation from connected initiator.' in f.read():
              print("Received request to end simulation from connected initiator. Quitting qemu")
              qemu_process.terminate()
              break
            else:
              time.sleep(10)
        else:
          #print("device process log file not found")
          time.sleep(10)
          continue

def read_qemu_args_file(qemu_args_file, device_family, target_emu, target):
 qemu_args = []
 if qemu_args_file != "" and os.path.exists(qemu_args_file): 
  if device_family == "ultrascale" and (target != "" or target_emu == "sw_emu"):
   with open(qemu_args_file) as f1:
    d = map(str.rstrip, f1.readlines())
    global net_count
    net_count = 0
    for i in d: 
      line = i
      #print(line)
      if line.startswith("#"): 
        #it is a comment, if it starts with #, dont append the line to qemu_args.
        continue
      if line.startswith("-"):
          if line=="-net":
              net_count += 1
              if net_count < 4:
                qemu_args.append(" ") 
                qemu_args.append(line)
          else:
              qemu_args.append(" ") 
              qemu_args.append(line)
          if line=="-hw-dtb":
            qemuargs_hwdtb = 1
      else:
        if (OS_USED != "Linux") and (line == "/dev/null"):
          line = "null"
        if (net_count > 3) and (line == "nic" or line == "user"):
          print("")
          
        else:
          linemodified = '"%s" ' %line
          qemu_args.append(" ") 
          qemu_args.append(linemodified)          
   f1.close()
  else:
    with open(qemu_args_file) as f1:
      d = map(str.rstrip, f1.readlines())
    for i in d: 
      line = i
      if line.startswith("#"): 
        #it is a comment, if it starts with #, dont append the line to qemu_args.
        continue
      if line.startswith("-"):  
        qemu_args.append(' %s ' %line)
        if line=="-hw-dtb":
          qemuargs_hwdtb = 1
      else:
        if (OS_USED != "Linux") and (line == "/dev/null"):
          line = "null"
        linemodified = '"%s" ' %line
        qemu_args.append(linemodified)
    f1.close()
  return qemu_args

def clean_all_process(done, pl_sim_dir, qemu_process, pmc_process, xsim_pid, pllauncher_process, device_family, target_emu):
 if pid_exists(qemu_process.pid):
    if done == 1:
      now = datetime.now()
      current_time = now.strftime("%H:%M:%S")
      print("\[LAUNCH_EMULATOR\] INFO: %s : Trying to kill PS-QEMU"%current_time)
    if done == 0:
      now = datetime.now()
      current_time = now.strftime("%H:%M:%S")
      print("\[LAUNCH_EMULATOR\] INFO: %s: Trying to kill PS-QEMU"%current_time)
      
    #kill_process(qemu_process.pid)
    qemu_process.terminate()
    qemu_process.kill()
    qemu_process.wait()
    
    if pid_exists(qemu_process.pid):
      print("\[LAUNCH_EMULATOR\] INFO: %s : Unable to kill QEMU process"%current_time)
      print("")
    else:
      now = datetime.now()
      current_time = now.strftime("%H:%M:%S")
      print("\[LAUNCH_EMULATOR\] INFO: %s : PS-QEMU exited"%current_time)

 else:
    now = datetime.now()
    current_time = now.strftime("%H:%M:%S")
    print("\[LAUNCH_EMULATOR\] INFO: %s : PS-QEMU exited"%current_time)

 if device_family == "versal" or device_family == "ultrascale":
    # PMU / PMC exists only for zynqMP and verbose
    if pid_exists(pmc_process.pid):
      if done == 1:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s Trying to kill PMU/PMC-QEMU because timeout is reached"%current_time)
      if done == 0:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : Trying to kill PMU/PMC-QEMU"%current_time)
      #kill_process(pmc_process.pid)
      pmc_process.terminate()
      pmc_process.kill()
      pmc_process.wait()
      if pid_exists(pmc_process.pid):
        print("\[LAUNCH_EMULATOR\] INFO: %s : Unable to kill PMU/PMC-QEMU process"%current_time)
        print("")
      else:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : PMU/PMC-QEMU exited"%current_time)
 else:
      now = datetime.now()
      current_time = now.strftime("%H:%M:%S")
      print("\[LAUNCH_EMULATOR\] INFO: %s : PMU/PMC-QEMU exited"%current_time)

 if target_emu == "hw_emu":
    if pid_exists(int(xsim_pid)):
      if done == 1:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s Trying to kill simulation because timeout is reached"%current_time)
      if done == 0:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : Trying to kill simulation process"%current_time)
      os.kill(int(xsim_pid), 9)
      time.sleep(5)
      if pid_exists(int(xsim_pid)):
        #print("xsim pid is", xsim_pid) 
        #print("\[LAUNCH_EMULATOR\] INFO: %s : Unable to kill xsim process"%current_time)
        #os.kill(int(xsim_pid), 9)
        os.killpg(os.getpgid(int(xsim_pid)), 15)
        time.sleep(5)
        if pid_exists(int(xsim_pid)):
          print("\[LAUNCH_EMULATOR\] INFO: %s : Unable to kill xsim process"%current_time)
        print("")
      else:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : Simulation process exited"%current_time)
    else:
      now = datetime.now()
      current_time = now.strftime("%H:%M:%S")
      print("\[LAUNCH_EMULATOR\] INFO: %s : Simulation exited"%current_time)
 else:
    if pid_exists(pllauncher_process.pid):
      if done == 1:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : Trying to kill PLLauncher because timeout is reached"%current_time)
      if done == 0:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : Trying to kill PLLauncher"%current_time)
      pllauncher_process.terminate()
      pllauncher_process.kill();
      pllauncher_process.wait()
      if pid_exists(pllauncher_process.pid):
        print("")
        print("\[LAUNCH_EMULATOR\] INFO: %s : Unable to kill PLLauncher"%current_time)
      else:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : PLLauncher exited"%current_time)
    else:
      now = datetime.now()
      current_time = now.strftime("%H:%M:%S")
      print("\[LAUNCH_EMULATOR\] INFO: %s : PLLauncher exited"%current_time)
 
 # Read <process>_time.txt from pl_sim_dir, print on terminal, erase files
 filename = pl_sim_dir + "/qemu_time.txt"
 if os.path.exists(filename):
    with open(filename, 'r') as file:
      print("QEMU process run time:")
      print(file.read())
    os.remove(filename)

 filename = pl_sim_dir + "/pmc_time.txt"
 if os.path.exists(filename):
    with open(filename, 'r') as file:
      print("PMC process run time:")
      print(file.read())
    os.remove(filename)

 filename = pl_sim_dir + "/xsim_time.txt"
 if os.path.exists(filename):
    with open(filename, 'r') as file:
      print("XSIM process run time:")
      print(file.read())
    os.remove(filename)

 filename = pl_sim_dir + "/xsim_nohup_time.txt"
 if os.path.exists(filename):
    with open(filename, 'r') as file:
      print("XSIM process with nohup run time:")
      print(file.read())
    os.remove(filename)
 

def get_device_type():
  device_family = ""
  #Read emulation xml file
  xml_file = os.path.join(os.getcwd(), "_vimage", "emulation", "emulation.xml")
  #cpu_type =  [::vimage::utils::xpath_get_value $xml_file $xpath]
  if cpu_type == "cortex-a9":
      device_family = "7series"
  if cpu_type == "cortex-a53":
      device_family = "ultrascale"
  if cpu_type ==  "x86":
      device_family = "versal"
  else:
      print("ERROR: UnIdentified Device Family.Please provide a valid device Family like 7series / Ultrascale / Versal")
      sys.exit()
  return device_family



def sd_card_generation(device_family, nobuild, sdimage):
  ######################################################################
  # SD card image
  if device_family != "versal":
    if nobuild == "":
        if sdimage == "":
          save_dir = os.getcwd()
          sd_card_dir = os.path.join(save_dir, "_vimage", "emulation")
          os.chdir(sd_card_dir)
          if os.path.exists("sd_card"):
            shutil.rmtree(os.path.join(sd_card_dir), "sd_card")
          if os.path.exists(os.path.join(sd_card_dir), "sd_card.img"):
            os.remove(os.path.join(sd_card_dir), "sd_card.img")
          os.mkdir(sd_card)
          with open('sd_card.manifest', 'r') as fp:
              for line in fp:
                shutil.copy(line, sd_card)
          os.mkdir(os.path.join(sd_card), "data", "emulation", "unified")
          shutil.copy(os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "unified"), os.path.join(sd_card, "data", "emulation", "unified"))
          sd_card_size = 500000
          #exec(mkfatimg os.path.join(os.getcwd(), sd_card) os.path.join(os.getcwd(), sd_card.img) sd_card_size > mkfatimg.log)
          os.chdir(save_dir)
        else:
          if os.path.isdir(sdimage):
            save_dir = os.getcwd()
            os.chdir(sdimage)
            if os.path.isdir(sdimage):
              shutil.rmtree(os.path.join(sd_card_dir), "sd_card") 
            if os.path.isfile(sd_card.img):
              os.remove(os.path.join(sd_card_dir), "sd_card.img")
            with open('sd_card.manifest', 'r') as fp:
              for line in fp:
                shutil.copy(line, sd_card)
            os.mkdir(os.path.join(sd_card), "data", "emulation", "unified")
            shutil.copy(os.path.join(os.getenv('XILINX_XD'), "data", "emulation", "unified"), os.path.join(sd_card, "data", "emulation", "unified"))
            sd_card_size = 500000
            #exec mkfatimg os.path.join(os.getcwd(), sd_card) os.path.join(os.getcwd(), sd_card.img) sd_card_size > mkfatimg.log 
            os.chdir(save_dir)
          else:
            print("picking sd_card image file from path specified.Not recreating the sd_Card image")
              
 
          
######################################################################   

def create_clean_line(qemu_script,args):
  with open(qemu_script) as f1:
    d = map(str.rstrip, f1.readlines())
    #print (d)
    for i in d: 
      line = i
      #print(line)
      qemu_cmd_line_path = get_qemu_pmu_path(args)
      #print("qemu_cmd_line_path",qemu_cmd_line_path)
      if qemu_cmd_line_path in line:
        #print("888888888888888888888")
        #print(line)
        line = line.replace('$PWD', os.getcwd())
        specials = '"' #etc
        trans = str.maketrans(specials, '\"'*len(specials))
        global cleanline
        cleanline = line.translate(trans)
        #print(cleanline)
  return cleanline

def replace_between_words(input_string, start_word, end_word, replace_with):
    start_index = input_string.find(start_word) + len(start_word)
    end_index = input_string.find(end_word, start_index)
    if start_index != -1 and end_index != -1:
        new_string = input_string[:start_index] + replace_with + input_string[end_index:]
        return new_string
    else:
        return input_string

def find_between_words(input_string, start_word, end_word):
    start_index = input_string.find(start_word) + len(start_word)
    end_index = input_string.find(end_word, start_index)
    if start_index != -1 and end_index != -1:
        return input_string[start_index:end_index]
    else:
        return None


def create_start_qemu_script(qemu_script, pl_sim_dir, qemu_cmd, qemu_args, qemu_dir,args):
  f=open(qemu_script, "a+")
  if OS_USED == "Linux":
    f.write("#!/bin/bash\n")
    f.write("cd %s\n"%pl_sim_dir)
    f.write("source %s\n"%(get_qemu_settings_path(args))) 
    f.write('unset LD_LIBRARY_PATH\n')
    f.write("echo $LD_LIBRARY_PATH\n")
    f.write("/usr/bin/time -p -o qemu_time.txt ")
    f.write(qemu_cmd)
    for item in qemu_args:
      if "loader,file=$PWD" in item:
        if qemu_dir != "":
          file_path = find_between_words(item, "file,",",addr" )
          file_name = os.path.basename(file_path)
          item = replace_between_words(item,"file=", ",addr", os.path.join(os.path.abspath(qemu_dir), file_name))  
      f.write(item) 
  f.close()
  os.chmod(qemu_script, 0o777)

def create_start_pmc_script(pmc_script, pl_sim_dir, pmc_cmd, pmc_args, qemu_dir,args):
  f=open(pmc_script, "a+")
  if OS_USED == "Linux":
    f.write("#!/bin/bash\n")
    f.write("cd %s\n"%pl_sim_dir)
    f.write("source %s\n"%(get_qemu_settings_path(args))) 
    f.write('unset LD_LIBRARY_PATH\n')
    f.write("/usr/bin/time -p -o pmc_time.txt ")
    f.write(pmc_cmd)
    for item in pmc_args:
      #item1 = map(lambda s: s.strip(), item)
      if "loader,file=$PWD" in item:
        if qemu_dir != "":
          file_path = find_between_words(item, "file,",",addr" )
          file_name = os.path.basename(file_path)
          item = replace_between_words(item,"file=",",addr", os.path.join(os.path.abspath(qemu_dir), file_name))  
      f.write(item)
  f.close()
  os.chmod(pmc_script , 0o777)

def create_start_risc_script(risc_script, pl_sim_dir, risc_cmd, risc_args, qemu_dir,args):
  f=open(risc_script, "a+")
  if OS_USED == "Linux":
    f.write("#!/bin/bash\n")
    f.write("cd %s\n"%pl_sim_dir)
    f.write("source %s\n"%(get_qemu_settings_path(args))) 
    f.write('unset LD_LIBRARY_PATH\n')
    f.write("/usr/bin/time -p -o risc_time.txt ")
    f.write(risc_cmd)
    for item in risc_args:
      #item1 = map(lambda s: s.strip(), item)
      if "loader,file=$PWD" in item:
        if qemu_dir != "":
          file_path = find_between_words(item, "file,",",addr" )
          file_name = os.path.basename(file_path)
          item = replace_between_words(item,"file=",",addr", os.path.join(os.path.abspath(qemu_dir), file_name))  
      f.write(item)
  f.close()
  os.chmod(risc_script , 0o777)

def poll_to_check_if_any_process_exited(done, qemu_process, pmc_process, xsim_pid, pllauncher_process, device_family, target_emu):
 while done != 1:
    if (qemu_process.isalive()):
      # qemu subprocess is alive
      print("")
    else:
      if pid_exists(qemu_process.pid):
        print("")
      else:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("\[LAUNCH_EMULATOR\] INFO: %s : PS-QEMU exited"%current_time)
        break

    if device_family == "versal" or device_family == "ultrascale":
      poll2 = pmc_process.poll()
      if poll2 is None:
        # microblaze subprocess is alive
        print("")
      else:
        if pid_exists(pmc_process.pid):
          print("")
        else:
          now = datetime.now()
          current_time = now.strftime("%H:%M:%S")
          print("\[LAUNCH_EMULATOR\] INFO: %s : PMU/PMC-QEMU exited"%current_time)
          break

   
    
    if target_emu == "hw_emu" : 
      print("")
      if pid_exists(int(xsim_pid)):
          print("")
      else:
          now = datetime.now()
          current_time = now.strftime("%H:%M:%S")
          print("\[LAUNCH_EMULATOR\] INFO: %s : Simulation exited"%current_time)
          break
                
    else:
      poll4 = pllauncher_process.poll() 
      if poll4 is None:
        #plllauncher subprocess is alive
        print("")
      else:
        if pid_exists(pllauncher_process.pid):
          print("")
        else:
          now = datetime.now()
          current_time = now.strftime("%H:%M:%S")
          print("\[LAUNCH_EMULATOR\] INFO: %s : PLLauncher exited"%current_time)  
          break
 
def chk_if_sim_started_successfully(socket_file, xsim_pid):
    #if simulation started successfully, then socket_file will be created
    emulation_live = 0
    while emulation_live == 0:
      time.sleep(5)
      print(".")
      #flush stdout
      if os.path.exists(socket_file):
        emulation_live = 1
        print(" PL simulation started!") 
        if pid_exists(xsim_pid):
          print("")
        else:
          print(" PL simulation failed to start. Aborting!")
          exit_val = 1
          sys.exit()

def chk_if_qemu_started_on_port(pl_port, process_name):
    emulation_live = 0
    while emulation_live == 0:
      time.sleep(5)
      print(".")
      #flush stdout
      check_pl_port = port_open(pl_port)
      if check_pl_port:
        emulation_live = 1
        print("QEMU started!")
      else:
        if pid_exists(process_name.pid):
          print("")
        else:
          print("Failed to start QEMU. Aborting!")
          print("ERROR: \[LAUNCH_EMULATOR\] launch_emulator exited because of an issue in launching QEMU")
          exit_val = 1
          sys.exit()

def create_pllauncher_cmd_line(pl_script):
   with open(pl_script) as f1:
      d = map(str.rstrip, f1.readlines())
      for i in d: 
        line = i
        if "pllauncher" in line:
          specials = '"' #etc
          trans = str.maketrans(specials, '\"'*len(specials))
          cleanline = line.translate(trans)
   return cleanline

def launch_xsim_process(enable_debug, xsim_script, pl_sim_args):
    if enable_debug == 1:
        xsim_process = subprocess.Popen(["/usr/bin/time", "-p", "-o", "xsim_time.txt", "xterm", '-l', '-lf',  'xsim.txt', '-hold', '-e', xsim_script], stdout=subprocess.PIPE)
    else:
        cmd = "/usr/bin/time -p -o xsim_time.txt ./simulate.sh %s"%pl_sim_args 
        xsim_process = subprocess.Popen(shlex.split(cmd), stdin=subprocess.PIPE, stdout=subprocess.PIPE, preexec_fn=os.setsid)
    return xsim_process

def launch_xsim_process_with_nohup(enable_debug, xsim_script, pl_sim_args):
    xsim_pid = ""
    if enable_debug == 1:
        xsim_process = subprocess.Popen(["/usr/bin/time", "-p", "-o", "xsim_nohup_time.txt", "xterm", '-l', '-lf',  'xsim.txt', '-hold', '-e', xsim_script], stdout=subprocess.PIPE)
        xsim_pid = xsim_process.pid
    else:
        exec_cmd = '/usr/bin/time -p -o xsim_nohup_time.txt nohup ./simulate.sh %s & echo $! > pidFile.txt' %pl_sim_args
        os.system(exec_cmd)
        if os.path.exists('pidFile.txt'): 
          with open('pidFile.txt','r') as file:
            xsim_pid = file.read()
    return xsim_pid

def launch_qemu_process(cur_dir, enable_debug, app_file, cleanline, qemu_script):
   print("Starting QEMU")
   print(" - Press <Ctrl-a h> for help ") 
   with open(os.path.join(cur_dir, "qemu_output.log"), 'wb') as output_file:
      if enable_debug == 1:
        cmd = "xterm -hold -e %s | tee qemu_xterm_log.txt &"%qemu_script
        qemu_process = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
      else: 
        set_qemu_libs()
        print('Launching QEMU using command "%s"'%cleanline)
        qemu_process = pexpect.spawn('%s'%cleanline, timeout=None)
        qemu_process.logfile_read = sys.stdout.buffer
        #print("------after spawning-----------")     
   return qemu_process

def run_genaiesummary():
    cmd = "genaiesummary runSummaryMetadata.json"
    subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)



def launch_pllauncher_process(enable_debug, pl_script):
  if enable_debug == 1:
          cmd = "xterm -hold -e %s"%pl_script
          pllauncher_process = subprocess.Popen(shlex.split(cmd), stderr=subprocess.STDOUT)
  else:
          cleanline = create_pllauncher_cmd_line(pl_script)
          pllauncher_process = subprocess.Popen(shlex.split(cleanline))
  return pllauncher_process
         
def check_if_booting_successfull(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, target_emu, app_file):
  booting_done  = read_log_file(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, target_emu, app_file)
  # wait for 420 seconds to check if booting successfull...check every 20 seconds
  for x in range(21): 
     if booting_done == 1: break
     else:
       time.sleep(20)
       booting_done = read_log_file(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, target_emu, app_file)
  return booting_done
       
  
def throw_kernel_boot_error_and_dump_qemu_log_to_console(qemu_process, qemu_txt_file):
  with open(qemu_txt_file) as f:
       print(f.read())	
       print("ERROR: Linux kernel boot failed\n")
       exit_val = 1
       os.kill(qemu_process.pid, signal.SIGTERM)


def check_result_and_dump_qemu_log_to_console(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, pl_pid, xsim_pid, result_stringg, timeout, target_emu, log_dir):
    print("checking result")
    time.sleep(5)
    result_str = 0
    pass_str = 5
    fail_str = 0
    pl_process_pid = ""
    if target_emu == "sw_emu":
      pl_process_pid = pl_pid
    else:
      pl_process_pid = xsim_pid
    ## check for any immediate error
    result_string_dict = check_for_result(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, pl_process_pid, result_stringg)
    result_str = result_string_dict["result"]

    result_str = result_string_dict["result"]
    pass_str = result_string_dict["pass"]
    fail_str = result_string_dict["fail"]
    timeout_period = 40
    if (timeout != ""):
      timeout_period = int(int(timeout) / 100 )
      print("timeout : ", timeout) 
      ## else check every 100 sec
    for x in range(timeout_period): 
      if result_str == 1: break
      else:
        time.sleep(100)
        result_string_dict = check_for_result(qemu_txt_file, qemu_process, qemu_cmd, pl_exe_path, pl_process_pid, result_stringg)
        result_str = result_string_dict["result"]
        pass_str = result_string_dict["pass"]
        fail_str = result_string_dict["fail"]

    if pass_str == 0 or fail_str == 1:
      with open(qemu_txt_file) as f:
        print(f.read())
      if read_qemu_log_for_error(1, os.path.join(log_dir, "qemu_output.log"), qemu_process):
        dump_log_into_console("qemu_output.log", log_dir)
        exit_val = 1
      else:
        print("ERROR: Host application did not complete - pass/end string not found. Exiting as a failure\n")
        exit_val = 1
        os.kill(qemu_process.pid, signal.SIGTERM)
    else:     
      print("")
      time.sleep(30)
      with open(qemu_txt_file) as f:
        print(f.read())

  


