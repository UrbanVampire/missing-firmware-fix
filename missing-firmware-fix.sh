#!/bin/bash
#
# Script to download and install missing Intel kernel drivers
# Made by Jiab77 <jiab77@pm.me>, 2020
# Improved by Mikko Rantalainen <mikko.rantalainen@iki.fi>, 2020
# Automatic missing FW detection added by UrbanVampire <bgg@ngs.ru>, 2021
# Improved script colors and suggested handling missing nVidia firmware files by Jiab77 <jiab77@pm.me>, 2021
# Automagical missing nVidia firmware installation added by UrbanVampire <bgg@ngs.ru>, 2021
# Minor spellchecking and fixing, minor display fixes and credits added by Jiab77 <jiab77@pm.me>, 2021
# 32-bit architecture nVidia support and little nVidia help message added by UrbanVampire <bgg@ngs.ru>, 2021
#
# Some definitions
# Config
DEBUG=0     # Debug flag
FWTotal=0   # Total missing FWs counter
FWSuccs=0   # Succesful installed FWs counter
FWError=0   # Failed FWs
NVidiaErr=0 # nVidia Error Flag
declare -a InstalledFWs	# Array to store and check alredy installed FWs
# Colors:
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
NC="\033[0m"
NL="\n"
TAB="\t"
#
# Function to execute a comand and get it's output
function DebuggedExec(){
    #
    # Make sure that we have an parameter
    if [[ $# -eq 0 ]]; then echo -e "${NL}${RED}DebuggedExec function called w/o parameters. Something went really wrong...${NC}${NL}"; return 1; fi
        #
        OUTPUT=$(eval $1 2>&1)			# Let's execute the given command
    if [[ $? -ne 0 ]]; then			# Do we have an error?
        ((FWError++))			# Yes, we have.
        echo -e "${RED}Failed${NC}"
        if [[ $DEBUG -eq 1 ]]; then	# Are we in debugging mode?
            echo -e "${RED}Executed command was:${TAB}${YELLOW}$1${NC}"
            echo -e "${RED}Error message was:${TAB}${YELLOW}$OUTPUT${NC}"
        fi
        return 1
    fi
    return 0			# No errors, everything went fine
}
#
# Function to process single missing FW
function ProcessFirmware(){
#
    # Make sure that we have an parameter
    if [[ $# -eq 0 ]]; then echo -e "${NL}${RED}ProcessFirmware function called w/o parameters. Something went really wrong...${NC}${NL}"; return 1; fi
    if [[ $1 == '' ]]; then return 0; fi # Got an empty line, nothing to do
    #
    ((FWTotal++))		# We got a missing FW, let's count it.
    #
    # Let's extract FW name and full path:
    FWFullPath=$(echo $1 | sed -n 's/^.*firmware //p')
    FWFileName=$(echo $1 | sed -n 's/^.*firmware//p')
    #
    if [[ $FWTotal -eq 1 ]]; then	# Is it first line? If so let's calculate tabulation offset
        let TABoff=$MaxLength-${#1}+${#FWFileName}+2
    fi
    #
    # Time to check if this file alredy installed
    if [[ " ${InstalledFWs[*]} " == *"$FWFileName"* ]]; then
        ((FWSuccs++))			# Everything went Ok
        echo -e "${CYAN}Alredy installed, Skipping${NC}"
        return 0
    else
        echo -ne "${GREEN}$FWFileName${BLUE}:${TAB}${NC}\033[50D\033[${TABoff}C"
    fi	
    echo -ne "${BLUE}Downloading... ${NC}"
    local TEMPFILE="$(tempfile)"		# Get a temporary filename
    #
    # Is it nVidia?
    if [[ "$FWFileName" == *"nvidia"* ]]; then
        echo -ne "${CYAN}nVidia FW detected. ${NC}"
        #
        #   Maybe (just maybe) we could use FW files from 64-bit installer on 32-bit system.
        #   But rught now I do not know the way to extract files from 64-bit nVidia installer on 32-bit system.
        #   So right now we just try to download from "Linux-x86" if we are 32.
        #
        case $SysArch in    # What is system architecture?
            "x86_64" )
                URLBASE="https://download.nvidia.com/XFree86/Linux-x86_64";;
            "i686"|"i386"  )
                URLBASE="https://download.nvidia.com/XFree86/Linux-x86";;
            * )
                echo -e "${NL}\033[50D\033[${TABoff}C${RED}ERROR: ${YELLOW}Unknown system architecture ${CYAN}$SysArch${YELLOW}.${NC}"
                ((FWError++))
                NVidiaErr=1     # Up nVidia error flag
                return 1
                ;;
        esac
        echo -ne "${NL}\033[50D\033[${TABoff}C${CYAN}It could take some time. Please wait... ${NC}${NL}\033[50D\033[${TABoff}C"
        NVVersion=$(echo $FWFileName | sed -n 's/^.*nvidia\///p'| sed -n 's/\/.*$//p') # Extract version
        FolderNam="NVIDIA-Linux-x86_64-$NVVersion"
        RunFlName="$FolderNam.run"
        NVFWFlNme=$(echo $FWFileName | sed -n 's/^.*\///p') # Extract nV FW filename
        URL="$URLBASE/$NVVersion/$RunFlName"
        DebuggedExec "wget -nv -O \"$TEMPFILE\" $URL"
        if [[ $? -ne 0 ]]; then rm "$TEMPFILE" ; return 1; fi
        echo -ne "${BLUE}Extracting...  ${NC}"
        DebuggedExec "sh \"$TEMPFILE\" -x --target /tmp/$FolderNam"
        if [[ $? -ne 0 ]]; then rm "$TEMPFILE"; rm -drf /tmp/$FolderNam ; return 1; fi
        rm "$TEMPFILE"
        DebuggedExec "mv /tmp/$FolderNam/firmware/$NVFWFlNme \"$TEMPFILE\""
        if [[ $? -ne 0 ]]; then rm -drf /tmp/$FolderNam ; return 1; fi
        # file is extracted and ready to go
        rm -drf /tmp/$FolderNam			# Some cleanup
    else # No, this is not nVidia, let's try to download FW from git.kernel.org
        local URL="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain"
        DebuggedExec "wget -nv -O \"$TEMPFILE\" $URL$FWFileName"
        if [[ $? -ne 0 ]]; then rm "$TEMPFILE" ; return 1; fi
    fi
    # Now let's try to move downloaded file to /lib/firmware
    echo -ne "${BLUE}Installing... ${NC}"
    # First we need to check if path is exists
    DebuggedExec "mkdir -p ${FWFullPath%/*}"
    if [[ $? -ne 0 ]]; then rm "$TEMPFILE" ; return 1; fi
    # Moving the file to it's place
    DebuggedExec "mv -v \"$TEMPFILE\" $FWFullPath"
    if [[ $? -ne 0 ]]; then rm "$TEMPFILE" ; return 1; fi
    #
    ((FWSuccs++))				# Everything went Ok
    echo -e "${GREEN}Ok${NC}"
    InstalledFWs[$FWSuccs]=$FWFileName	# Store FW in list of installed FWs
    return 0
}
#
#################################
#
# Here's the main body
#
# Let's make sure that we are superuser
if [[ $EUID -ne 0 ]]; then echo -e "${NL}${RED}Must be run with superuser privileges:${NC} sudo $0 [--debug]${NC}${NL}"; exit 1; fi
#
# Is there some parameters?
if [[ $# -ne 0 ]] ; then
    if [[ $1 = "--debug" ]] ; then
        DEBUG=1; echo -e "${NL}${YELLOW}Debugging enabled.${NC}${NL}"
    else
        echo -e "${NL}${RED}Usage:${NC} sudo $0 [--debug]${NL}"; exit 1
    fi
else
    echo -e "${NL}${CYAN}Hint: ${WHITE}You can use the${GREEN} --debug ${WHITE}option for extended error info.${NC}${NL}"
fi
#
# Let's see if the system is 32 or 64 bit
SysArch=$(arch)
if [[ $DEBUG -eq 1 ]]; then
    case $SysArch in
        "x86_64" )
            echo -e "${YELLOW}DEBUG: ${BLUE}System architecture is ${CYAN}$SysArch ${BLUE}(64-bit).${NC}${NL}";;
        "i686"|"i386"  )
            echo -e "${YELLOW}DEBUG: ${BLUE}System architecture is ${CYAN}$SysArch ${BLUE}(32-bit).${NC}${NL}";;
        * )
            echo -e "${YELLOW}DEBUG WARNING: ${BLUE}Unknown system architecture ${CYAN}$SysArch${BLUE}.${NC}${NL}"
    esac
fi
# Here we call update-initramfs, grep-search it's output for "missing HW" message
echo -e "${BLUE}Detecting missing FWs. It could take some time, please wait...${NC}${NL}"
MFWs=$(update-initramfs -u 2>&1 >/dev/null | grep 'Possible missing firmware' | sed -n 's/ for.*$//p')
#
MaxLength=0	# Get longest string length - we'll need it later to calculate tabulation
while IFS= read -r line; do if [[ ${#line} -gt $MaxLength ]]; then MaxLength=${#line}; fi; done < <(echo "$MFWs")
#
# Let's process missing FWs one by one
while IFS= read -r line; do ProcessFirmware "$line"; done < <(echo "$MFWs")
#
# Did we found some missing FWs?
if [[ $FWTotal -eq 0 ]]; then echo -e "${BLUE}No missing FWs found. Nothing to do. Exiting...${NC}${NL}"; exit 0; fi
# Do we have nVidia errors?
if [[ $NVidiaErr -eq 1 ]]; then
    echo -e "${NL}${YELLOW}WARNING: ${CYAN}We got an error while processing nVidia FWs.${NC}"
    echo -e "${CYAN}Installing nVidia FWs is a bit tricky to automate.${NC}"
    echo -e "${CYAN}But You can try to do this manually. ${NC}"
    echo -e "${CYAN}Just visit ${WHITE}https://download.nvidia.com/XFree86/${NC}"
    echo -e "${CYAN}and download installer for desired architecture and FW version.${NC}"
fi
# Is there some successful FWs?
if [[ $FWSuccs -eq 0 ]]; then       # Nope, no luck
    echo -ne "${NL}${YELLOW}WARNING: No FWs found or downloaded. See messages above"
    [[ $DEBUG -eq 0 ]] && echo -ne "${NL}or try --debug option for more info"
    echo -ne ". ${NL}Exiting...${NC}${NL}${NL}"
    exit 1
fi
# Maybe ALL FWs downloaded with success?
if [[ $FWSuccs -ne $FWTotal ]]; then	# Nope
    echo -ne "${NL}${YELLOW}WARNING: Some FWs was not found or downloaded. See messages above"
    [[ $DEBUG -eq 0 ]] && echo -ne "${NL}or try --debug option for more info"
    echo -ne ". ${NL}But You still can regenerate kernels.${NC}${NL}"
fi
# Now we need to re-generate all kernels
echo -ne "${NL}${BLUE}It's time to re-generate kernels. Press ${GREEN}Enter ${BLUE}to continue or ${RED}CTRL+C ${BLUE}to skip:${NC}"
read
echo -e "${NL}${BLUE}Generating kernels. It could take some time, please wait...${NC}${NL}"
sudo update-initramfs -u -k all | grep 'Generating'
echo -e "${NL}${GREEN}Finished.${NC}${NL}"
