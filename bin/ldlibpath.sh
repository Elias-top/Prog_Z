#! /bin/bash -

# Given an arg, P, where P is a suitable lib-dir, the scripts prints:
#
#   P/$distro:P
#
# $distro is Rhel, SuSE, Ubuntu, or Default (at present, only RHel, SuSE, and
# Ubuntu require customized installations). The above path combo may be used
# in the definition of LD_LIBRARY_PATH.
#
# If no arg is supplied, the script prints $distro.

# Ensure that Xilinx's updates to LD_LIBRARY_PATH don't cause this script
# to malfunction.
unset LD_LIBRARY_PATH

getlsbdata () {
  lsb_release $1 2>/dev/null | sed 's/^.*:[ 	]*//' | tr '[:upper:]' '[:lower:]'
}

if [ ! "$(type -p lsb_release)" ]; then
  id="`grep -o '^ID="*[^"]*' /etc/os-release | sed 's/ID="*//g;s/rhel/redhat/g'`"
  rl="`grep -o '^VERSION_ID="[^"]*' /etc/os-release | sed 's/VERSION_ID="//g;s/.0//g'`"
else
  id="$(getlsbdata -i)"
  rl="$(getlsbdata -r)"
fi
distro=Default
distrover=

case "$id" in
  *centos*) ;;
  *debian*) ;;
  *fedora*) ;;
  *almalinux*)
    distro=Rhel
    case "$rl" in
      8*) distrover=8 ;;
      9*) distrover=9 ;;
      *) distrover= ;;
    esac
    ;;
  *redhat*)
    distro=Rhel
    case "$rl" in
      8*) distrover=8 ;;
      9*) distrover=9 ;;
      *) distrover= ;;
    esac
    ;;
  *suse*)   distro=SuSE ;;
  *ubuntu*)
    distro=Ubuntu
    case "$rl" in
      18*) distrover=18 ;;
      20*) distrover=20 ;;
      22*) distrover=22 ;;
      24*) distrover=24 ;;
      *) distrover= ;;
    esac
    ;;
  *)        ;;
esac

if [ $# -eq 0 ]; then
  echo $distro $distrover
elif [ -n "$distrover" ]; then
  echo "$1/$distro/$distrover":"$1/$distro":"$1"
else
  echo "$1/$distro":"$1"
fi
