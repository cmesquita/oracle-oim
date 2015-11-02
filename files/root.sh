#!/bin/sh
#!/bin/sh
#
# $Header
# $Copyright
#
#
# root.sh
#
# This script is intended to be run by root.  The script contains
# all the product installation actions that require root privileges.
#
# IMPORTANT NOTES - READ BEFORE RUNNING SCRIPT
#
# (1) ORACLE_HOME and ORACLE_OWNER can be defined in user's
#     environment to override default values defined in this script.
#
# (2) The environment variable LBIN (defined within the script) points to
#     the default local bin area.  Three executables will be moved there as
#     part of this script execution.
#
# (3) Define (if desired) LOG variable to name of log file.
#

AWK=/bin/awk
CAT=/bin/cat
CHOWN=/bin/chown
CHGRP=/bin/chgrp
CHMOD=/bin/chmod
CP=/bin/cp
ECHO=/bin/echo
GREP=/bin/grep
LBIN=/usr/local/bin
MKDIR=/bin/mkdir
ORATABLOC=/etc
ORATAB=${ORATABLOC}/oratab
RM=/bin/rm
SED=/bin/sed
TEE=/usr/bin/tee
TMPORATB=/var/tmp/oratab$$
#
# If LOG is not set, then send output to /dev/null
#

if [ x${LOG} = x ] ;then
  LOG=/dev/null
else
  $CP $LOG ${LOG}0 2>/dev/null
  $ECHO "" > $LOG
fi

#
# Display abort message on interrupt.
#

trap '$ECHO "Oracle10 root.sh execution aborted!"|tee -a $LOG;exit' 1 2 3 15

#
# Enter log message
#

$ECHO "Running Oracle10 root.sh script..."|tee -a $LOG

#
# Default values set by Installer
#

ORACLE_HOME=/u02/app/oracle/product/oas/10.1.2
ORACLE_OWNER=oracle

#
# check for root
#

RUID=`/usr/bin/id|$AWK -F\( '{print $2}'|$AWK -F\) '{print $1}'`
if [ ${RUID} != "root" ];then
  $ECHO "You must be logged in as root to run root.sh."| $TEE -a $LOG
  $ECHO "Log in as root and restart root.sh execution."| $TEE -a $LOG
  exit 1
fi

#
# Determine how to suppress newline with $ECHO command.
#

case ${N}$C in
  "") if $ECHO "\c"| $GREP c >/dev/null 2>&1;then
        N='-n'
      else
        C='\c'
      fi;;
esac

#

$ECHO "\nThe following environment variables are set as:"| $TEE -a $LOG
$ECHO "    ORACLE_OWNER= $ORACLE_OWNER"| $TEE -a $LOG
$ECHO "    ORACLE_HOME=  $ORACLE_HOME"| $TEE -a $LOG

#
# Get name of local bin directory
#

#$ECHO ""
#$ECHO $N "Enter the full pathname of the local bin directory: $C"
#DEFLT=${LBIN}; . $ORACLE_HOME/install/utl/read.sh; LBIN=$RDVAR
#if [ ! -d $LBIN ];then
#  $ECHO "Creating ${LBIN} directory..."| $TEE -a $LOG
#  $MKDIR -p ${LBIN} 2>&1| $TEE -a $LOG
#  $CHMOD 755 ${LBIN} 2>&1| $TEE -a $LOG
#fi

#
# Move files to LBIN, and set permissions
#

DBHOME=$ORACLE_HOME/bin/dbhome
ORAENV=$ORACLE_HOME/bin/oraenv
CORAENV=$ORACLE_HOME/bin/coraenv
FILES="$DBHOME $ORAENV $CORAENV"

#for f in $FILES ; do
#  if [ -f $f ] ; then
#    $CHMOD 755 $f  2>&1 2>> $LOG
#    short_f=`$ECHO $f | $SED 's;.*/;;'`
#    lbin_f=$LBIN/$short_f
#    if [ -f $lbin_f ] ; then
#      $ECHO $n "The file \"$short_f\" already exists in $LBIN.  Overwrite it? (y/n) $C"
#      DEFLT='n'; . $ORACLE_HOME/install/utl/read.sh; OVERWRITE=$RDVAR	 
#    else
#      OVERWRITE='y'; 
#    fi
#    if [ "$OVERWRITE" = "y" ] ; then
#      $CP $f $LBIN  2>&1 2>>  $LOG
#      $CHOWN $ORACLE_OWNER $LBIN/`$ECHO $f | $AWK -F/ '{print $NF}'` 2>&1 2>> $LOG
#      $ECHO "   Copying $short_f to $LBIN ..."
#    fi
#  fi
#done
#$ECHO ""


#
# Make sure an oratab file exists on this system
#

if [ ! -s ${ORATAB} ];then
  $ECHO "\nCreating ${ORATAB} file..."| $TEE -a $LOG
  if [ ! -d ${ORATABLOC} ];then
    $MKDIR -p ${ORATABLOC}
  fi

  $CAT <<!>> ${ORATAB}
#



# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by the Database Configuration Assistant when creating
# a database.

# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   \$ORACLE_SID:\$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third filed indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same \$ORACLE_SID are not allowed.
#
#
!

fi

$CHOWN $ORACLE_OWNER ${ORATAB}
$CHMOD 664 ${ORATAB}

#
# If there is an old entry with no sid and same oracle home,
# that entry will be marked as a comment.
#

FOUND_OLD=`$GREP "^*:${ORACLE_HOME}:" ${ORATAB}`
if [ -n "${FOUND_OLD}" ];then
  $SED -e "s?^*:$ORACLE_HOME:?# *:$ORACLE_HOME:?" $ORATAB > $TMPORATB
  $CAT $TMPORATB > $ORATAB
  $RM -f $TMPORATB 2>/dev/null
fi

#
# Add generic *:$ORACLE_HOME:N to oratab
#

$ECHO "Adding entry to ${ORATAB} file..."| $TEE -a $LOG
$CAT <<!>> ${ORATAB}
*:$ORACLE_HOME:N
!

$ECHO "Entries will be added to the ${ORATAB} file as needed by"| $TEE -a $LOG
$ECHO "Database Configuration Assistant when a database is created"| $TEE -a $LOG

#
# Append the dbca temporary oratab entry to oratab
# In the case of ASM and RAC install, oratab is not yet created when root.sh
# is run, so we need to check for its existence before attempting to append it.
#
if [ -f $ORACLE_HOME/install/oratab ]
then
  $CAT $ORACLE_HOME/install/oratab >> $ORATAB
fi

#
#
# Change mode to remove group write permission on Oracle home
#

$CHMOD -R g-w $ORACLE_HOME

$ECHO "Finished running generic part of root.sh script."| $TEE -a $LOG
$ECHO "Now product-specific root actions will be performed."| $TEE -a $LOG



/u02/app/oracle/product/oas/10.1.2/Apache/Apache/bin/root_sh_append.sh

# LDAP Root Installation Section
CHOWN=/bin/chown
CHMOD=/bin/chmod
CP=/bin/cp
RM=/bin/rm
ECHO=/bin/echo

$ECHO
$ECHO
$ECHO "Entering Oracle Internet Directory Root Installation Section"

if [ 1 -eq 1 ] ; then

   $ECHO 
   $ECHO "OiD Server Installation"
   $ECHO "Checking LDAP binary file protections"

   ORACLE_HOME=/u02/app/oracle/product/oas/10.1.2; export ORACLE_HOME
   cd /u02/app/oracle/product/oas/10.1.2/bin

   if [ -f oidmon ] ; then
      $ECHO "Setting oidmon file protections"
      $CHMOD 0710 oidmon         # only owner and group has execute permission
      $CHMOD u+s  oidmon
   fi

   if [ -f oidldapd ] ; then
      $ECHO "Setting oidldapd file protections"
      $CHOWN root oidldapd       # make oidldapd setuid root for security
      $CHMOD 4710 oidldapd       # only owner and group has execute permission
   fi


   if [ -f oidrepld ] ; then
      $ECHO "Setting oidrepld file protections"
      $CHMOD 0710 oidrepld       # only owner and group has execute permission
      $CHMOD u+s  oidrepld
   fi

   if [ -f oidpasswd ] ; then
      $ECHO "Setting oidpasswd file protections"
      $CHMOD 0510 oidpasswd      # Only owner & group can execute oidpasswd
   fi

   if [ -f oidsuacmgr ] ; then
      $ECHO "Setting oidsuamgr file protections"
      $CHMOD 0510 oidsuamgr      # Only owner & group can execute oidsamgr
   fi

   if [ -f oidemdpasswd ] ; then
      $ECHO "Setting oidemdpasswd file protections"
      $CHMOD 0510 oidemdpasswd   # Only owner & group can execute oidemdpasswd
   fi

   cd /u02/app/oracle/product/oas/10.1.2/ldap/admin
   if [ -f oidstats.sh ] ; then
      $ECHO "Setting oidstats.sh file protections"
      $CHMOD 0510 oidstats.sh    # Only owner & group can run oidstats.sh
   fi
	
   cd /u02/app/oracle/product/oas/10.1.2/ldap/bin
   if [ -f remtool ] ; then
      $ECHO "Setting remtool file protections"
      $CHMOD 0510 remtool        # only owner and group has execute permission
   fi

   if [ -f oiddiag ] ; then
      $ECHO "Setting oiddiag file protections"
      $CHMOD 0710 oiddiag        # only owner and group has execute permission
   fi

   if [ -f oiddt ] ; then
      $ECHO "Setting oiddt file protections"
      $CHMOD 510 oiddt       # only owner and group has execute permission
   fi


   cd /u02/app/oracle/product/oas/10.1.2/ldap/log
   $RM oid* 2>&- 

fi

#$ECHO "Setting odisrv file permissions"
# Change permissions on odisrv
#chmod u+s $ORACLE_HOME/bin/odisrv
$CHMOD 0710 $ORACLE_HOME/bin/odisrv

sync;sync;sync;

$ECHO "Leaving Oracle Internet Directory Root Installation Section"

cd /u02/app/oracle/product/oas/10.1.2
# End LDAP Root Installation Section
#!/bin/sh
#!/usr/bin/sh

ORACLE_HOME=/u02/app/oracle/product/oas/10.1.2
# the following commands need to run as root after installing 
# the OEM Daemon

AWK=/usr/bin/awk
CAT=/usr/bin/cat
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
CHMODR="/usr/bin/chmod -R"
CP=/usr/bin/cp
ECHO=/usr/bin/echo
MKDIR=/usr/bin/mkdir
TEE=/usr/bin/tee
RM=/bin/rm
MV=/bin/mv
GREP=/usr/bin/grep
CUT=/bin/cut
SED=/usr/bin/sed

PLATFORM=`uname`

if [ ${PLATFORM} = "Linux" ] ; then
  CAT=/bin/cat
  CHOWN=/bin/chown
  CHMOD=/bin/chmod
  CHMODR="/bin/chmod -R"
  CP=/bin/cp
  ECHO=/bin/echo
  MKDIR=/bin/mkdir
  GREP=/bin/grep
  if [ ! -f $CUT ] ; then
     CUT=/usr/bin/cut
  fi
  SED=/bin/sed
fi


#
# If LOG is not set, then send output to /dev/null
#

if [ "x${LOG}" = "x" -o "${LOG}" = "" ];then
  LOG=/dev/null
else
  $CP $LOG ${LOG}0 2>/dev/null
  $ECHO "" > $LOG
fi

# Check to make certain this is being called as root
RUID=`/usr/bin/id|$AWK -F\( '{print $2}'|$AWK -F\) '{print $1}'`
if [ ${RUID} != "root" ];then
  $ECHO "You must be logged in as root to run root.sh."| $TEE -a $LOG
  $ECHO "Log in as root and restart root.sh execution."| $TEE -a $LOG
  exit 1
fi

# change owner and permissions of the remote operations executible
$CHOWN root $ORACLE_HOME/bin/nmo
$CHMOD 6750 $ORACLE_HOME/bin/nmo

# change owner and permissions of the program that does memory computations
$CHOWN root $ORACLE_HOME/bin/nmb
$CHMOD 6750 $ORACLE_HOME/bin/nmb

# remove backup copies if they exist
if [ -f $ORACLE_HOME/bin/nmo.bak ]; then
  $RM $ORACLE_HOME/bin/nmo.bak
fi
if [ -f $ORACLE_HOME/bin/nmb.bak ]; then
  $RM $ORACLE_HOME/bin/nmb.bak
fi

#change permissions on emdctl and emagent
$CHMOD 700 $ORACLE_HOME/bin/emagent
$CHMOD 700 $ORACLE_HOME/bin/emdctl

#
# Following changes to system executables are needed for getting
# host inventory metrics on HP-UX
#
if [ ${PLATFORM} = "HP-UX" ] ; then
  $CHMOD 555 /usr/sbin/swapinfo
  $CHMOD +r /dev/rdsk/*
fi
$CHMOD -R go-rwx $ORACLE_HOME
$CHMOD -R o+rx $ORACLE_HOME/jdk
$CHMOD g+rx $ORACLE_HOME/bin/oidldapd
$CHMOD g+x $ORACLE_HOME/ldap/bin/oiddt
$CHMOD 6750 $ORACLE_HOME/Apache/Apache/bin/ssomigrate
$CHMOD 6750 $ORACLE_HOME/bin/nmb
#!/bin/sh
#!/usr/bin/sh

# the following commands need to run as root 

CHMOD="/bin/chmod"

$CHMOD 6751 $ORACLE_HOME/bin/emtgtctl2
$CHMOD 711  $ORACLE_HOME/bin/nmocat
$CHMOD 4750 $ORACLE_HOME/bin/nmo
