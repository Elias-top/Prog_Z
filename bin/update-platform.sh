#!/bin/sh

numcols=`tput cols`

print_help () {
echo "
 USAGE
 update-platform.sh    
    -xpfm <xpfm file>
    -updatehw <New Hardware specification file (XSA)> 
    -out-dir <output directory> [OPTIONAL]    
    -verbose [OPTIONAL]
  
 If -out-dir is not specified, current working directory will be
    used as an output directory.

 This script generates the updated platform in <out-dir> 

 EXAMPLE
"

printf "\t%s\n" "update-platform.sh -xpfm ./versal_aie.xpfm -updatehw ../../../versal_aie.xsa -out-dir /tmp/ "| fold -w$numcols -s
printf  "\t%s\n\n" "Updates the platform with the new XSA. "| fold -w$numcols -s
  
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

xpfm_file=""
hw_file=""
out_dir=""
verbose=false
# arg processing
while [ $# -gt 0 ]; do
  case "$1" in
    -updatehw)
        if [ ! -f $2 ]; then
            echo "ERROR: $2 does not exist"
            exit -1
        fi
        hw_file=$(normalize_path $2)
        shift
        shift
        ;;
    -xpfm)
        if [ ! -f $2 ]; then
            echo "ERROR: $2 does not exist"
            exit -1
        fi
        xpfm_file=$(normalize_path $2)
        shift
        shift
        ;;
    -verbose)
        verbose=true
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

if [ "$xpfm_file" == "" ]; then
    echo "ERROR: xpfm option is not given."
    print_help
    exit -1
fi


if [ "$hw_file" == "" ]; then
    echo "ERROR: updatehw option is not given."
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

platout="$out_dir"


platformbase=`basename $xpfm_file`
platformdir="${platformbase%.*}"
platformdir="$out_dir/$platformdir"

if [ -d "$platformdir" ]; then
    echo "INFO: removing the platform existing in the output directory: $platformdir"
    rm -Rf ${platformdir}
fi





cmd="platform create -xpfm $xpfm_file -out $out_dir; platform config -updatehw $hw_file"

cmd="$cmd; platform generate "

if [ "$verbose" == "true" ]; then    
    printf "\n%s\n\n" "Executing the below XSCT command to update the platform."
    printf " %s\n\n" "$cmd" | fold -w$numcols -s
fi

echo $cmd | xsct

rm -Rf $platformdir/.cproject
rm -Rf $platformdir/.project

