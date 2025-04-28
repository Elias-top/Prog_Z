#!/bin/bash
#
# COPYRIGHT NOTICE
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
#

#
# Platform options
#

trap 'case $? in
  139) echo "segfault in $RDI_PROG $@, exiting..." >&2 ;;
esac' EXIT

RDI_PLATFORM=lnx64
RDI_JAVA_PLATFORM=
RDI_JAVA_VERSION=21.0.1_12
if [ -n "$RDI_USE_JDK21" ]; then
  RDI_JAVAFXROOT=$RDI_APPROOT/tps/$RDI_PLATFORM/javafx-sdk-21.0.1
  FREETYPE_PROPERTIES=truetype:interpreter-version=35
  export FREETYPE_PROPERTIES
fi
if [ -n "$RDI_USE_JDK11" ]; then
  RDI_JAVA_VERSION=11.0.16_1
  RDI_JAVAFXROOT=$RDI_APPROOT/tps/$RDI_PLATFORM/javafx-sdk-11.0.2
  FREETYPE_PROPERTIES=truetype:interpreter-version=35
  export FREETYPE_PROPERTIES
fi
RDI_JAVACEFROOT=$RDI_APPROOT/tps/$RDI_PLATFORM/java-cef-95.0.4638.69
if [ -n "$RDI_NEED_OLD_JRE" ]; then
  RDI_JAVA_PLATFORM=amd64
  RDI_JAVA_VERSION=
fi
export RDI_PLATFORM RDI_JAVA_PLATFORM RDI_JAVA_VERSION
export RDI_OPT_EXT=.o
# Default language setting
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export TCMALLOC_LARGE_ALLOC_REPORT_THRESHOLD=4294967296

argSize=0
RDI_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -m32)
      echo 1>&2 "Warning: unsupported option: -m32."
      shift
      ;;
    -m64)
      shift
      ;;
    -version)
      RDI_INVOKE_VERSION_ONLY=1
      RDI_ARGS[$argSize]="$1"
      argSize=$(($argSize + 1))
      shift
      ;;
    -print_version)
      shift
      RDI_INVOKE_PROD_VERSION=1
      RDI_PRODVERSION_PROG=$1
      shift
      ;;
    -exec)
      #
      # We don't create an RDI_EXE_COMMANDS function and just overload the RDI_PROG variable,
      # so additional debug options can be used with -exec.
      #
      # For example:
      #  -dbg -gdb -exec foo
      #
      # Will launch the debuggable foo executable in gdb.
      #
      shift
      RDI_PROG=$1
      shift
      ;;
    *)
      RDI_ARGS[$argSize]="$1"
      argSize=$(($argSize + 1))
      shift
      ;;
  esac
done
unset RDI_NEED_OLD_JRE

if [ -z "$RDI_VERBOSE" ]; then
    RDI_VERBOSE=False
fi

# Default don't check TclDebug by
if [ -z "$XIL_CHECK_TCL_DEBUG" ]; then
  export XIL_CHECK_TCL_DEBUG=False
fi

RDI_DATADIR="$RDI_APPROOT/data"
RDI_SHARED_DATA=""

if [ $RDI_INSTALLVER == "aietools" ]; then
  if [ -d "$RDI_DATADIR/../SharedData/data" ]; then
     RDI_SHARED_DATA=$RDI_DATADIR/../SharedData/data
     cd $RDI_SHARED_DATA
     RDI_SHARED_DATA=`pwd`
     cd - > /dev/null 2>&1
  else
    RDI_SHARED_DATA="`dirname $RDI_INSTALLROOT`/SharedData/`basename $RDI_BASEROOT`/data"
      if [ ! -d $RDI_SHARED_DATA ]; then
        RDI_SHARED_DATA="`dirname $RDI_INSTALLROOT`/SharedData/data"
      fi
  fi
else
	RDI_SHARED_DATA="$RDI_INSTALLROOT/SharedData/`basename $RDI_APPROOT`/data"
	# Check for installer end
	if [ -d $RDI_SHARED_DATA ]; then
		RDI_SHARED_DATA=$RDI_SHARED_DATA
	elif [ -d "`dirname $RDI_INSTALLROOT`/SharedData" ]; then
		RDI_SHARED_DATA="`dirname $RDI_INSTALLROOT`/SharedData/data"
  	else
    	# new install-tree structure.
    		if [ -d "$RDI_DATADIR/../SharedData/data" ]; then
      			RDI_SHARED_DATA=$RDI_DATADIR/../../SharedData/data
      			cd $RDI_SHARED_DATA
      			RDI_SHARED_DATA=`pwd` 
      			cd - > /dev/null 2>&1
   		fi
	fi
fi

if [ -d $RDI_SHARED_DATA ]; then
    RDI_DATADIR="$RDI_SHARED_DATA:$RDI_DATADIR"
fi

IFS=$':'
for SUB_PATCH in $RDI_PATCHROOT; do
    if [ -d "$SUB_PATCH/data" ]; then
        RDI_DATADIR="$SUB_PATCH/data:$RDI_DATADIR"
    fi
done
IFS=$' \t\n'

RDI_JAVAROOT="$RDI_APPROOT/tps/$RDI_PLATFORM/jre$RDI_JAVA_VERSION"

#Locate RDI_JAVAROOT in patch areas.
IFS=$':'
for SUB_PATCH in $RDI_PATCHROOT; do
    if [ -d "$SUB_PATCH/tps/$RDI_PLATFORM/jre$RDI_JAVA_VERSION" ]; then
        RDI_JAVAROOT="$SUB_PATCH/tps/$RDI_PLATFORM/jre$RDI_JAVA_VERSION"
    fi
done
IFS=$' \t\n'

export RDI_DATADIR

#
# Strip /planAhead off %RDI_APPROOT% to discovery the
# common ISE installation.
#
# For separated vivado installs ISE is located under %RDI_APPROOT%/ids_lite
#
if [ "$XIL_PA_NO_XILINX_OVERRIDE" != "1" ]; then
  if [ "$XIL_PA_NO_DEFAULT_OVERRIDE" != "1" ]; then
    unset XILINX
  fi
  if [ -d "$RDI_APPROOT/ids_lite/ISE" ]; then
    XILINX="$RDI_APPROOT/ids_lite/ISE"
    export XILINX
  else
    if [ -d "$RDI_BASEROOT/ISE" ]; then
      XILINX="$RDI_BASEROOT/ISE"
      export XILINX
    fi
  fi
fi


# aietools lives under SDx so we have to fix these variables
RDI_INSTALLVERSION=`basename "$RDI_APPROOT"`
if [ "$RDI_INSTALLVERSION" == "aietools" ]; then
  RDI_INSTALLVERSION=`dirname "$RDI_APPROOT"`
  RDI_INSTALLVERSION=`basename "$RDI_INSTALLVERSION"`
fi
RDI_INSTALLROOT=`dirname "$RDI_APPROOT"`
RDI_INSTALLROOT=`dirname "$RDI_INSTALLROOT"`
if [ `basename $RDI_APPROOT` == "aietools" ]; then
  RDI_INSTALLROOT=`dirname "$RDI_INSTALLROOT"`
fi

if [ "$XIL_PA_NO_XILINX_SDK_OVERRIDE" != "1" ]; then
  if [ -d "$RDI_INSTALLROOT/Vitis/$RDI_INSTALLVER" ]; then
    XILINX_SDK="$RDI_INSTALLROOT/Vitis/$RDI_INSTALLVER"
    export XILINX_SDK
  elif [ -d "$RDI_INSTALLROOT/$RDI_INSTALLVER/Vitis" ]; then
    XILINX_SDK="$RDI_INSTALLROOT/$RDI_INSTALLVER/Vitis"
    export XILINX_SDK
  elif [ -d "$RDI_INSTALLROOT/SDK/$RDI_INSTALLVERSION" ]; then
    XILINX_SDK="$RDI_INSTALLROOT/SDK/$RDI_INSTALLVERSION"
    export XILINX_SDK
  elif [ -d "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/SDK" ]; then
    XILINX_SDK="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/SDK"
    export XILINX_SDK
  elif [ -d "$RDI_BASEROOT/SDK" ]; then
    XILINX_SDK="$RDI_BASEROOT/SDK"
    export XILINX_SDK
  fi
  if [ -z "$XILINX_VITIS" ]; then
    if [ ! -z "$XILINX_SDK" ]; then
      XILINX_VITIS=$XILINX_SDK
      export XILINX_VITIS
    fi
  fi
fi

IFS=$':'
for DEPENDENCY in $RDI_DEPENDENCY; do
  case "$DEPENDENCY" in
    VITIS_HLS_SETUP)
      if [ `basename $RDI_PROG` != "hls_tee" ]; then
        if [ -z "$XILINX_VITIS" ]; then
          if [ -e "$HDI_APPROOT/bin/vitis-run" ]; then
            export XILINX_VITIS=$HDI_APPROOT
          elif [ -d "$RDI_BASEROOT/vitis/bin" ]; then
            export XILINX_VITIS="$RDI_BASEROOT/vitis"
          elif [ -d "$RDI_INSTALLROOT/Vitis/$RDI_INSTALLVERSION/bin" ]; then
            export XILINX_VITIS="$RDI_INSTALLROOT/Vitis/$RDI_INSTALLVERSION"
          elif [ -d "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis/bin" ]; then
            export XILINX_VITIS="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis"
          elif [ -d "$RDI_BASEROOT/Vitis/bin" ]; then
            export XILINX_VITIS="$RDI_BASEROOT/Vitis"
          else
            echo "WARNING: Default location for XILINX_VITIS not found"
          fi
        fi
        if [ -z "$XILINX_VCXX" ]; then
          if [ -d "$HDI_APPROOT/vcxx/bin" ]; then
            export XILINX_VCXX=$HDI_APPROOT/vcxx
          elif [ -d "$XILINX_VITIS/vcxx/bin" ]; then
            export XILINX_VCXX=$XILINX_VITIS/vcxx
          fi
        fi

        installed_vivado=""
        if [ -f "$RDI_BASEROOT/vivado/bin/vivado" ]; then
          installed_vivado="$RDI_BASEROOT/vivado"
        elif [ -f "$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION/bin/vivado" ]; then
          # parallel install
          installed_vivado="$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION"
        elif [ -f "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado/bin/vivado" ]; then
          # parallel install
          installed_vivado="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado"
        elif [ -f "$RDI_BASEROOT/Vivado/bin/vivado" ]; then
          installed_vivado="$RDI_BASEROOT/Vivado"
        fi

        if [ -z "$XILINX_VIVADO" ]; then
          if [ -n "$installed_vivado" ]; then
            export XILINX_VIVADO=$installed_vivado
          else
            echo "WARNING: Default location for XILINX_VIVADO not found"
          fi
        fi

        # Put XILINX_VIVADO at end of path
        if [ -n "$XILINX_VIVADO" ]; then
          export PATH=${PATH}:$XILINX_VIVADO/bin
          [ "$RDI_VERBOSE" = "True" ] && echo "INFO: using XILINX_VIVADO $XILINX_VIVADO"
          [ -d "$XILINX_VIVADO" ] || echo "WARNING: XILINX_VIVADO location does not exist: $XILINX_VIVADO"
        fi

        # Set XILINX_HLS_DEVICE_DATADIR if empty
        parts_file="parts/arch.xml"
        if [ -n "$XILINX_HLS_DEVICE_DATADIR" ]; then
          if [ ! -f "$XILINX_HLS_DEVICE_DATADIR/$parts_file" ]; then
            echo "WARNING: could not find parts data in XILINX_HLS_DEVICE_DATADIR: $XILINX_HLS_DEVICE_DATADIR/$parts_file"
          fi
          part_data_desc="XILINX_HLS_DEVICE_DATADIR"
        elif [ -f "$XILINX_VIVADO/data/$parts_file" ]; then
          XILINX_HLS_DEVICE_DATADIR="$XILINX_VIVADO/data"
          part_data_desc="XILINX_VIVADO/data"
        elif [ -f "$installed_vivado/data/$parts_file" ]; then
          XILINX_HLS_DEVICE_DATADIR="$installed_vivado/data"
          part_data_desc="installed Vivado"
        elif [ -f "$XILINX_VITIS/data/$parts_file" ]; then
          XILINX_HLS_DEVICE_DATADIR="$XILINX_VITIS/data"
          part_data_desc="XILINX_VITIS/data"
        else
          echo "ERROR: cannot find parts data in Vivado nor Vitis: data/$parts_file"
          exit 2
        fi
        [ "$RDI_VERBOSE" = "True" ] && echo "INFO: using $part_data_desc part data: $XILINX_HLS_DEVICE_DATADIR"
        [ -n "$XILINX_HLS_DEVICE_DATADIR" ] && export RDI_DATADIR=${XILINX_HLS_DEVICE_DATADIR}:$RDI_DATADIR

        # Allow override of XILINX_HLS_DEVICE_LIBPATH
        [ -n "$XILINX_HLS_DEVICE_LIBPATH" ] && export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${XILINX_HLS_DEVICE_LIBPATH}"
      fi
      ;;

    XILINX_VIVADO)
      if [ -z "$XILINX_VIVADO" ]; then
        # locate parallel install
        if [ -d "$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION" ]; then
          XILINX_VIVADO="$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION"
          export XILINX_VIVADO
          PATH=$XILINX_VIVADO/bin:$PATH
          export PATH
        elif [ -d "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado" ]; then
          XILINX_VIVADO="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado"
          export XILINX_VIVADO
          PATH=$XILINX_VIVADO/bin:$PATH
          export PATH
        # locate parallel install
        elif [ -f "$RDI_BASEROOT/Vivado/bin/vivado" ]; then
          XILINX_VIVADO="$RDI_BASEROOT/Vivado"
          export XILINX_VIVADO
          PATH=$XILINX_VIVADO/bin:$PATH
          export PATH
        else
          echo "WARNING: XILINX_VIVADO not set"
        fi
      fi
      ;;
    XILINX_HLS)
      if [ -z "$XILINX_HLS" ]; then
        if [ -n "$XILINX_VITIS" ] && [ -e "$XILINX_VITIS/data/hls" ]; then
          export XILINX_HLS=$XILINX_VITIS
          export PATH=$XILINX_HLS/bin:$PATH
        elif [ -e "$RDI_INSTALLROOT/Vitis/$RDI_INSTALLVERSION/data/hls" ]; then
          export XILINX_HLS="$RDI_INSTALLROOT/Vitis/$RDI_INSTALLVERSION"
          export PATH=$XILINX_HLS/bin:$PATH
        elif [ -e "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis/data/hls" ]; then
          export XILINX_HLS="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis"
          export PATH=$XILINX_HLS/bin:$PATH
        elif [ -e "$RDI_BASEROOT/Vitis/data/hls" ]; then
          export XILINX_HLS="$RDI_BASEROOT/Vitis"
          export PATH=$XILINX_HLS/bin:$PATH
        elif [ -e "$RDI_INSTALLROOT/Vitis_HLS/$RDI_INSTALLVERSION/data/hls" ]; then
          export XILINX_HLS="$RDI_INSTALLROOT/Vitis_HLS/$RDI_INSTALLVERSION"
          export PATH=$XILINX_HLS/bin:$PATH
        elif [ -e "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis_HLS/data/hls" ]; then
          export XILINX_HLS="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis_HLS"
          export PATH=$XILINX_HLS/bin:$PATH
        elif [ -e "$RDI_BASEROOT/Vitis_HLS/data/hls" ]; then
          export XILINX_HLS="$RDI_BASEROOT/Vitis_HLS"
          export PATH=$XILINX_HLS/bin:$PATH
        else
          echo "WARNING: Default location for XILINX_HLS not found"
        fi
        # Add vitis_hls location to the PATH
        if [ -e "$RDI_INSTALLROOT/Vitis_HLS/$RDI_INSTALLVERSION/bin/vitis_hls" ]; then
          export PATH=$RDI_INSTALLROOT/Vitis_HLS/$RDI_INSTALLVERSION/bin/:$PATH
        elif [ -e "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis_HLS/bin/vitis_hls" ]; then
          export PATH=$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vitis_HLS/bin/:$PATH
        elif [ -e "$RDI_BASEROOT/Vitis_HLS/bin/vitis_hls" ]; then
          export PATH=$RDI_BASEROOT/Vitis_HLS/bin:$PATH
        fi
      fi
      ;;
  esac
done

for DEPENDENCY in $RDI_DATA_DEPENDENCY; do
  case "$DEPENDENCY" in
    XILINX_VIVADO)
      if [ -z "$XILINX_VIVADO" ]; then
        # locate parallel install
        if [ -d "$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION" ]; then
          XILINX_VIVADO="$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION"
          export XILINX_VIVADO
          RDI_DATADIR=$RDI_DATADIR:$XILINX_VIVADO/data
          export RDI_DATADIR
        elif [ -d "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado" ]; then
          XILINX_VIVADO="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado"
          export XILINX_VIVADO
          RDI_DATADIR=$RDI_DATADIR:$XILINX_VIVADO/data
          export RDI_DATADIR
        # locate parallel install
        elif [ -f "$RDI_BASEROOT/Vivado/bin/vivado" ]; then
          XILINX_VIVADO="$RDI_BASEROOT/Vivado"
          export XILINX_VIVADO
          RDI_DATADIR=$RDI_DATADIR:$XILINX_VIVADO/data
          export RDI_DATADIR
        else
          echo "WARNING: Default location for XILINX_VIVADO not found"
        fi
      else
	if [ -z "${RDI_SHARED_DATA}" -a -d "$XILINX_VIVADO/../SharedData/data" ]; then
          RDI_DATADIR=$RDI_DATADIR:$XILINX_VIVADO/data:$XILINX_VIVADO/../SharedData/data
          export RDI_DATADIR
	elif [ -z "${RDI_SHARED_DATA}" -a -d "$XILINX_VIVADO/../../SharedData/`basename $XILINX_VIVADO`" ]; then
          RDI_DATADIR=$RDI_DATADIR:$XILINX_VIVADO/data:$XILINX_VIVADO/../../SharedData/`basename $XILINX_VIVADO`/data
          export RDI_DATADIR
	else
          RDI_DATADIR=$RDI_DATADIR:$XILINX_VIVADO/data
          export RDI_DATADIR
	fi
      fi
    ;;
  esac
done

IFS=$' \t\n'
unset RDI_DEPENDENCY
unset RDI_DATA_DEPENDENCY

if [ -d "$RDI_BASEROOT/common" ]; then
  XILINX_COMMON_TOOLS="$RDI_BASEROOT/common"
  export XILINX_COMMON_TOOLS
fi

if [ -z "$XIL_TPS_ROOT" ]; then
  if [ -d "$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION/tps/$RDI_PLATFORM" ]; then
    RDI_TPS_ROOT="$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION/tps/$RDI_PLATFORM"
  elif [ -d "$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado/tps/$RDI_PLATFORM" ]; then
    RDI_TPS_ROOT="$RDI_INSTALLROOT/$RDI_INSTALLVERSION/Vivado/tps/$RDI_PLATFORM"
  fi
else
  RDI_TPS_ROOT=$XIL_TPS_ROOT
fi
export RDI_TPS_ROOT

RDI_EXEC_COMMANDS() {
  if [ -f $RDI_PROG ]; then
    "$RDI_PROG" "$@"
  fi
  return
}

RDI_JAVA_COMMANDS() {
  IFS=$':'
  if [ -z "$RDI_EXECCLASS" ]; then
    RDI_EXECCLASS="ui/PlanAhead"
  fi
  if [ -z "$RDI_JAVAARGS" ]; then
    RDI_JAVAARGS="-Dsun.java2d.pmoffscreen=false -Xms128m -Xmx3072m -Xss5m"
  fi
  for SUB_ROOT in $RDI_APPROOT; do
    if [ -d "$SUB_ROOT/lib/classes" ]; then
      if [ -z "$RDI_CLASSPATH" ]; then
        RDI_CLASSPATH="$SUB_ROOT/lib/classes/*"
      else
        RDI_CLASSPATH="$RDI_CLASSPATH:$SUB_ROOT/lib/classes/*"
      fi
      LINUX_JAR_DIR="$SUB_ROOT/lib/classes/linux"
      if [ -d "$LINUX_JAR_DIR" ]; then
        RDI_CLASSPATH="$RDI_CLASSPATH:$LINUX_JAR_DIR/*"
      fi
    fi
  done
  IFS=$' \t\n'
  if [ "$RDI_VERBOSE" = "True" ]; then
    echo "\"$RDI_JAVAROOT/bin/java\" $RDI_JAVAARGS -classpath \"$RDI_CLASSPATH\" $RDI_EXECCLASS $@"
  fi
  RDI_START_FROM_JAVA=True
  export RDI_START_FROM_JAVA
  "$RDI_JAVAROOT/bin/java" $RDI_JAVAARGS -classpath "$RDI_CLASSPATH" "$RDI_EXECCLASS" "$@"
  return
}