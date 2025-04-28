#!/bin/bash

numcols=`tput cols`

print_help () {
echo "
 USAGE
 generate-platform.sh
    -name <platform name>
    -hw <Hardware specification file (XSA)> 
    -domain <processor:OS details, ex. ai_engine:aie_runtime. For multiple
            domains need to repeat this for multiple times>[OPTIONAL]
            If no domain specified then it creates two domains: 
	    ai_engine:aie_runtime and psv_cortexa72_0:standalone
            If DSA doesn't contain AIE IP then it creates a domain
            psv_cortexa72_0:standalone
            If DSA doesn't contain PS IP and contains AIE IP, it creates
            a domain ai_engine:aie_runtime
    -out-dir <output directory> [OPTIONAL]
    -samples <samples directory> [OPTIONAL]
    -verbose [OPTIONAL]
  
 If -out-dir is not specified, current working directory will be
    used as an output directory.

 This script generates a platform in <out-dir>
 Note: It supports only Versal DSAs with AIE IP.

 EXAMPLE
"

printf "\t%s\n" "generate-platform.sh -name versal_aie -hw ./versal_aie.xsa -domain ai_engine:aie_runtime" | fold -w$numcols -s
printf  "\t%s\n\n" "Generates the platform with aie_runtime domain. "| fold -w$numcols -s
printf  "\t%s\n" "generate-platform.sh -name versal_aie -hw ./versal_aie.xsa -domain ai_engine:aie_runtime -domain psv_cortexa72_0:standalone" | fold -w$numcols -s
printf  "\t%s\n\n" "Generates the platform with aie_runtime and standalone domain. "| fold -w$numcols -s
printf  "\t%s\n" "generate-platform.sh -name versal_aie -hw ./versal_aie.xsa -domain ai_engine:aie_runtime -out-dir ./output" | fold -w$numcols -s
printf  "\t%s\n\n" "Generates the platform with aie_runtime in the given output directory. "| fold -w$numcols -s
printf  "\t%s\n" "generate-platform.sh -name versal_aie -hw ./versal_aie.xsa -domain ai_engine:aie_runtime -samples ./samples" | fold -w$numcols -s
printf  "\t%s\n\n" "Generates the platform with aie_runtime passing the samples. "| fold -w$numcols -s

  
}
normalize_path () {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}


`which xsct  > /dev/null 2>&1`
if [ $? -ne 0 ]; then
    echo "ERROR: xsct is not available in PATH, please make sure xsct is available in PATH."
    exit 1
fi

if [ $# == 0 ]; then    
    echo "error: invalid command line, expecting arguments."
    print_help
    exit -1
fi

hw_file=""
out_dir=""
name=""
domains=""
samples=""
verbose=false
# arg processing
while [ $# -gt 0 ]; do
  case "$1" in
    -hw)
        if [ ! -f $2 ]; then
            echo "ERROR: $2 does not exist"
            exit -1
        fi
        hw_file=$(normalize_path $2)
        shift
        shift
        ;;
    -verbose)
        verbose=true
        shift
        ;;
    -name)
        if [ "$2" == "" ]; then
            echo "ERROR: Empty name value"
            exit -1
        fi
        name="$2"
        shift
        shift
        ;;
    -domain)
        if [ "$2" == "" ]; then
            echo "ERROR: Empty domain value"
            exit -1
        fi
        if [ "$domains" == "" ]; then
            domains="$2"          
        else
            domains="$domains|$2"            
        fi
        shift
        shift
        ;;
    -out-dir)
        out_dir="$2"
        if [ ! -d ${out_dir} ]; then
            echo "INFO: creating output directory: $out_dir"
            mkdir -p ${out_dir}
        fi
        shift
        shift
        ;;
    -samples)
        samples="$2"
        if [ ! -d ${samples} ]; then
            echo "ERROR: Directory pointed by samples '$samples' is not existing."
            exit -1
        fi
        shift
        shift
        ;;
    -help)
        print_help
        exit 0
        ;;
    *)
        echo "ERROR: unexpected arguments: $@"
        exit -1
        ;;
   esac
done

if [ "$name" == "" ]; then
    echo "ERROR: name option is not given."
    print_help
    exit -1
fi


if [ "$hw_file" == "" ]; then
    echo "ERROR: hw option is not given."
    print_help
    exit -1
fi

if [ "$out_dir" == "" ];then
    echo "Using the current working dir for out-dir."
    out_dir=`pwd`
    echo "user -out-dir option to give a output directory."
    echo "Generating the platform at $out_dir"
fi

if [ ! -w "$out_dir" ]; then
    echo ""
    echo "ERROR: The output directory '$out_dir' do not have write permissions."
    exit -1
fi

platout="$out_dir/$name"
if [ -d "$platout" ]; then
    echo "INFO: removing the platform existing in the output directory: $platout"
    rm -Rf ${platout}
fi


checkcmd="if {  [string compare [ dict get  [::hsi::utils::get_design_properties  $hw_file ] family ]  "versal"] != "0"  } { puts \"\nERROR: Only versal based dsa is supported.\n\" ;  exit -1 }"


if [ "$domains" == "" ]; then    
    defdomaincmd="if { [hsi get_cells -filter { IP_NAME == ai_engine }] != \"\"  && [hsi get_cells -filter { IP_NAME == psv_cortexa72  }] != \"\"  } { puts \"\nDefaulting the Domains to 'ai_engine:aie_runtime' and 'psv_cortexa72_0:standalone' \n\";  platform create -name $name -hw $hw_file -proc ai_engine -os aie_runtime -out $out_dir ; domain create -name standalone_domain -proc psv_cortexa72_0 -os standalone; } elseif { [hsi get_cells -filter { IP_NAME == ai_engine }] != \"\" } { puts  \"\nDefaulting the Domains to 'ai_engine:aie_runtime' \n\" ;platform create -name $name -hw $hw_file -proc ai_engine -os aie_runtime -out $out_dir } elseif { [hsi get_cells -filter { IP_NAME == psv_cortexa72 }] != \"\" } { puts  \"\nDefaulting the Domains to 'psv_cortexa72_0:standalone' \n\" ;platform create -name $name -hw $hw_file -proc psv_cortexa72_0 -os standalone -out $out_dir };"
    cmd="$checkcmd; $defdomaincmd"
else
    domArray=(${domains//|/ })

    firstDom="${domArray[0]}"
    domDetail=(${firstDom//:/ })

    proc="${domDetail[0]}"
    os="${domDetail[1]}"
    cmd="$checkcmd ; platform create -name $name -hw $hw_file -proc $proc -os $os -out $out_dir"
    index=0
    for i in "${domArray[@]}"
    do
        if [ "$index" == "0" ]; then    
            index=$(( $index + 1 ))
            continue
        fi
        nextDom=$i
        domDetail=(${nextDom//:/ })
        
        proc="${domDetail[0]}"
        os="${domDetail[1]}"
        domname="$os"_domain
        
        cmd="$cmd; domain create -name $domname -proc $proc -os $os"
    done
fi

if [ "$samples" != "" ]; then
    cmd="$cmd; platform config -samples $samples"
fi

cmd="$cmd; platform generate "

if [ "$verbose" == "true" ]; then
    
    printf "\n%s\n\n" "Executing the below XSCT command to generate the platform."
    printf " %s\n\n" "$cmd" | fold -w$numcols -s
fi
echo $cmd | xsct

