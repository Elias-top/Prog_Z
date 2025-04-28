#!/usr/bin/env python
import os
import shutil

def pre_processing(args):
 envdict = {} 
 if args.x86_sim_options != "":
  if args.target_emu == "hw_emu":
    print("CRITICAL WARNING: x86_sim_options switch is only valid for sw emu.")
  if args.x86_sim_options.startswith("aie_sim_options"):
    print("CRITICAL WARNING: Please use x86_sim_ptions file instead of the aie-sim-options file provided")
  if args.target_emu == "sw_emu":
    if os.path.exists(args.x86_sim_options):
      x86_sim_options_file = os.path.abspath(args.x86_sim_options)
      print("Setting env X86SIM_OPTIONSPATH to ", x86_sim_options_file)
      os.environ['X86SIM_OPTIONSPATH'] = x86_sim_options_file
    else:
      print("ERROR:File provided to -x86-sim-options doesn't exist")
      sys.exit()

 enable_rp_logs_enabled = str(args.enable_rp_logs)
 if args.enable_rp_logs != "":
  os.environ['ENABLE_RP_LOGS'] = enable_rp_logs_enabled


 if args.XTLM_LOG_STATE != "":
  os.environ['XTLM_LOG_STATE'] = args.XTLM_LOG_STATE

 if args.aie_sim_config != "" and os.path.exists(args.aie_sim_config):
  #print ('aie config file:', args.aie_sim_config)
  aie_sim_config = os.path.abspath(args.aie_sim_config)
  #print("aie_sim_config:", aie_sim_config)
  os.environ['AIESIM_CONFIG'] = aie_sim_config
  envdict['AIESIM_CONFIG'] = aie_sim_config
  
 if args.aie_sim_options != "":
  if os.path.exists(args.aie_sim_options):
    aie_sim_options = os.path.abspath(args.aie_sim_options)
    print("Setting env AIESIM_OPTIONS to :", aie_sim_options)
    os.environ['AIESIM_OPTIONS'] = aie_sim_options
    envdict['AIESIM_OPTIONS'] = aie_sim_options
  else:
    print("ERROR: File provided to -aie-sim-options doesn't exist")
    sys.exit()

 if args.qemu_dir != "":
    noc_memory_config = os.path.join(os.path.abspath(args.qemu_dir), "noc_memory_config.txt")
    print("****************noc_memory_config :", noc_memory_config)
    os.environ['NOCSIM_MULTI_DRAM_FILE'] = noc_memory_config
 else: 
    if args.noc_memory_config != "" and  os.path.exists(args.noc_memory_config):
        if args.mcpath != "" :
            #cp args.noc_memory_config to args.mcpath
            if os.path.exists(args.noc_memory_config):
                shutil.copy(os.path.abspath(args.noc_memory_config),os.path.abspath(args.mcpath))
                noc_memfile_name = "noc_memory_config.txt"
                os.environ['QEMU_MACHINE_PATH'] = os.path.abspath(args.mcpath)
                os.environ['NOCSIM_MULTI_DRAM_FILE'] = os.path.join(os.path.abspath(args.mcpath),noc_memfile_name)
        else :
            print ('NOC MEM CONFIG:', args.noc_memory_config)
            noc_memory_config = os.path.abspath(args.noc_memory_config)
            os.environ['NOCSIM_MULTI_DRAM_FILE'] = noc_memory_config
            #print("**************** Setting NOCSIM_MULTI_DRAM_FILE :", noc_memory_config)
    elif args.device_family == "versal":
      envVal = "qemu-memory-_ddr@0x00000000"
      os.environ['NOCSIM_DRAM_FILE'] = envVal
  
 if args.user_pre_sim_script != "":
  os.environ['USER_PRE_SIM_SCRIPT'] = args.user_pre_sim_script
  envdict['USER_PRE_SIM_SCRIPT'] = args.user_pre_sim_script

 if args.user_post_sim_script != "":
  os.environ['USER_POST_SIM_SCRIPT'] = args.user_post_sim_script
  envdict['USER_POST_SIM_SCRIPT'] = args.user_post_sim_script

 if "USER_PRE_SIM_SCRIPT" in os.environ and os.path.exists(args.wcfg_file_path) :
  print("WARNING : \[LAUNCH_EMULATOR\] Both -user-pre-sim-script and -wcfg-file-path are provided. Either one of the option is accepted. Giving predence for -wcfg-file-path")

    
 if args.wcfg_file_path != ""  and os.path.exists(args.wcfg_file_path) :
    wcfg_cmd_str = "open_wave_config %s"%args.wcfg_file_path
    pre_sim_script = "pre_sim_script.tcl"
    
    with open(os.path.join(os.getcwd(), pre_sim_script), 'w') as f:
      f.write("%s"%wcfg_cmd_str)
    f.close()   
    pre_sim_script_file_path = os.path.join(os.getcwd(), pre_sim_script)
    os.environ['USER_PRE_SIM_SCRIPT'] = pre_sim_script_file_path
    
 elif args.wcfg_file_path != "":
    print("WARNING : Invalid WCFG file path provided. Please provide the valid WCFG file to get the Custom Signals viewed in the waveform")

 xtlm_aximm_log_enabled = str(args.xtlm_aximm_logging)
 xtlm_axis_log_enabled = str(args.xtlm_axis_logging)
 os.environ['ENABLE_XTLM_AXIMM_LOG'] = xtlm_aximm_log_enabled
 os.environ['ENABLE_XTLM_AXIS_LOG'] = xtlm_axis_log_enabled


 return envdict


def parse_add_env_var_and_set_envs(env_list):
 if env_list is None:
  print("")
 else:
  for i in env_list:
    name = i.split("=", 1)[0] 
    value = i.split("=", 1)[1]
    #Fix for CR 1113549
    if name=="AIE_COMPILER_WORKDIR":
      if os.path.exists(value):
        value = os.path.abspath(value)
        os.environ[name] = value
        print("Setting the env %s with value %s"%(name, value))
      else:
        print("ERROR: PATH %s mentioned for env AIE_COMPILER_WORKDIR is invalid"%value)
        sys.exit()
    else:
      os.environ[name] = value    

def parse_pl_sim_args(pl_sim_args_name):
  plsimdict = {}
  pl_sim_args = ""
  sim_option = ""

  if "=" in pl_sim_args_name:
    count = pl_sim_args_name.count("=") + 1
    if  count == 2:
      name = pl_sim_args_name.split("=", 1)[0] 
      value = pl_sim_args_name.split("=", 1)[1] 
      plsimdict[name] = value
      #os.environ[name] = value
      print("INFO: \[LAUNCH_EMULATOR\] Setting simulator option %s to %s"%(name, value))
    else:
      print('WARNING: \[LAUNCH_EMULATOR\] multiple "=" found in pl-sim-args option.( Ignoring %s )'%pl_sim_args_name)
  else:
    pl_sim_args += sim_option
    print("INFO: \[LAUNCH_EMULATOR\] Setting simulator option %s.Please ensure it is a valid option"%sim_option)

  for key in plsimdict:
    pl_sim_args += " -"
    pl_sim_args += key
    pl_sim_args += " "
    pl_sim_args += '"'
    value = plsimdict[key]
    pl_sim_args += value
    pl_sim_args += '"'

  return pl_sim_args

def create_fwd_port_test_string_for_sw_emu_qemu_device_process_connection(target_port1, host_port1):
  test_string = ""
  #print("----in host fwd")
  test_string += "hostfwd=tcp::"
  test_string += str(target_port1)
  test_string += "-:"
  test_string += str(host_port1)
  os.environ["QEMU_HOST_PORT"] = str(target_port1)
  os.environ["QEMU_GUEST_PORT"] = str(host_port1)
  return test_string


def set_target_on_parsing_fwd_port_variable(fwd_port_list):
  target = ""
  if fwd_port_list is None:
   print("")
  else:
    for i in fwd_port_list:
      target = i[0] 
  return target

def set_host_on_parsing_fwd_port_variable(fwd_port_list):
  host = ""
  if fwd_port_list is None:
   print("")
  else:
    for i in fwd_port_list:
      host = i[1] 
  return host

def parse_fwd_port_variable(device_family, target_emu, fwd_port_list, test_string):
  if fwd_port_list is None:
    print("")
  else:
    for i in fwd_port_list:
      #if (args.device_family == "versal" or args.device_family == "ultrascale") and args.target_emu != "hw_emu":
      if target_emu != "hw_emu":
        test_string += ","
      target = i[0] 
      host = i[1]
      test_string += "hostfwd=tcp::"
      test_string += target
      test_string += "-:"
      test_string += host
      test_string += ","

    test_string = test_string[:-1]
  return test_string

