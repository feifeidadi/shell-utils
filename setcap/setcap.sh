#!/bin/bash

SETCAP_BINARY="/usr/sbin/setcap"
CONFIG_FILE=""

function set_capabilities()
{
    IFS=:
    while read programName caps
    do
    	$SETCAP_BINARY $caps=ep $programName
        if [ $? -ne 0 ] ; then
            echo "setcap capabilities for $programName failed!"
        else
            echo "setcap capabilities for $programName successfully!"
        fi

        echo -e "`getcap $programName`\n"
    done < $CONFIG_FILE
}

function usage() 
{
    echo "Usage: $0 -c CONFIG_FILE"
    exit
}

function get_opts()
{
    while getopts ":c:" o; do
        case "${o}" in
            c)
                CONFIG_FILE=${OPTARG}
                ;;
            *)
                usage
                ;;
        esac
    done
    shift $((OPTIND-1))
}

if [ $UID -ne 0 ] ; then
    echo "Need root privilege to execute this script!"
    exit 0
fi

if [ ! -x $SETCAP_BINARY ] ; then
    echo "$SETCAP_BINARY is not available, please install it via 'yum install libcap'"
    exit
fi

get_opts $*

if [ ! -z "$CONFIG_FILE" ] ; then
    set_capabilities
else
    usage
fi

