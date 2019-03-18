#!/bin/bash

CURRENT_DIR="$(dirname "$0")"
source "$CURRENT_DIR/ssh_env.sh"

# Funciton to get a list of keys from the HOSTS array
getEnvKeys() {
    X=1
    for index in "${ENVS[@]}" ; do
        if [ ${#ENVS[@]} -gt $X ] ; then
            COMMA=", "
        else
            COMMA=""
        fi
        KEY="${index%%|*}"
        echo -n "$KEY$COMMA"
        ((X++))
    done
}

# Funciton to get a list of keys from the HOSTS array
getHostKeys() {
    X=1
    for index in "${HOSTS[@]}" ; do
        if [ ${#HOSTS[@]} -gt $X ] ; then
            COMMA=", "
        else
            COMMA=""
        fi
        KEY="${index%%|*}"
        echo -n "$KEY$COMMA"
        ((X++))
    done
}

# Check if env was passed via the commandline or prompt if not
if [ "$1" == "" ] ; then
    echo "Please enter the env type [$(getEnvKeys), ip]: "
    read ENVTYPE
else
    ENVTYPE="$1"
fi

if [ "$ENVTYPE" == "dev" ] ; then
    HOSTS=("${DEV_HOSTS[@]}")
fi
if [ "$ENVTYPE" == "auto" ] ; then
    HOSTS=("${AUTO_HOSTS[@]}")
fi
if [ "$ENVTYPE" == "qa" ] ; then
    HOSTS=("${QA_HOSTS[@]}")
fi
if [ "$ENVTYPE" == "prod" ] ; then
    HOSTS=("${PROD_HOSTS[@]}")
fi
if [ "$ENVTYPE" == "ip" ] ; then
    IP="$2"
fi

# Check if host was passed via the commandline or prompt if not
if [ "$2" == "" ] ; then
    echo "Please enter the box type or IP address [$(getHostKeys)]: "
    read HOSTNAME
else
    HOSTNAME="$2"
fi

# Check if scp source was passed via the commandline or prompt if not
if [ "$3" == "" ] ; then
    echo "To use scp instead of ssh, enter the source here.  Leave blank to SSH: "
    read FROM
    if [ "$FROM" ] ; then
        echo "Now enter the destination here: "
        read TO 
    fi
else
    FROM="$3"
    TO="$4"
    echo "$FROM and $TO"
fi

IP="$HOSTNAME"
USER="$DEFAULT_USER"
SSH_KEY="$DEFAULT_SSH_KEY"
IFS='|'
for index in "${HOSTS[@]}" ; do
    arrIN=($index)
    if [ "$HOSTNAME" == "${arrIN[0]}" ] ; then
        IP="${arrIN[1]}"
        if [ "${arrIN[2]}" ] ; then
            USER="${arrIN[2]}"
        fi
        if [ "${arrIN[3]}" ] ; then
            SSH_KEY="${arrIN[3]}"
        fi
    fi
done
unset IFS


if [ "$IP" == "" ] ; then
    echo "Invalid box type [HOSTNAME: $HOSTNAME  --  IP: $IP]"
else 
    echo "============"
    echo "KEY: $HOSTNAME  --  ENV: $ENVTYPE  --  USER: $USER  --  IP: $IP  --  SSH_KEY: $SSH_KEY"

    # If arguments 3 and 4 are passed in, we will be doing an SCP instead of SSH
    if [ "$FROM" -a "$TO" ] ; then
        echo "scp -rpi ~/.ssh/$SSH_KEY $FROM $USER@$IP:$TO"
        echo "============"
        echo ""
        scp -rpi ~/.ssh/$SSH_KEY $FROM $USER@$IP:$TO
    else
        if [ "$COMMAND" != "" ] ; then
            echo "ssh -i ~/.ssh/$SSH_KEY $USER@$IP $COMMAND"
            echo "============"
            echo ""
            ssh -i ~/.ssh/$SSH_KEY $USER@$IP $COMMAND   
        else 
            echo "ssh -i ~/.ssh/$SSH_KEY $USER@$IP"
            echo "============"
            echo ""
            ssh -i ~/.ssh/$SSH_KEY $USER@$IP    
        fi
    fi

fi
