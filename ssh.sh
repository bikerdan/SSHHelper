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
        KEY="${index%%::*}"
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
        KEY="${index%%::*}"
        echo -n "$KEY$COMMA"
        ((X++))
    done
}

# Check if env was passed via the commandline or prompt if not
if [ "$1" == "" ] ; then
    echo "Please enter the env type [$(getEnvKeys)]: "
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

# Check if host was passed via the commandline or prompt if not
if [ "$2" == "" ] ; then
    echo "Please enter the box type [$(getHostKeys)]: "
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


# Find the IP for the given box
IP=""
for index in "${HOSTS[@]}" ; do
    KEY="${index%%::*}"
    if [ "$HOSTNAME" == "$KEY" ] ; then
        IP="${index##*::}"
    fi
done

if [ "$IP" == "" ] ; then
    echo "Invalid box type [$HOSTNAME]"
else 
    echo "Connecting to [$HOSTNAME] in the [$ENVTYPE] environment at [$IP]"

    # If arguments 3 and 4 are passed in, we will be doing an SCP instead of SSH
    if [ "$FROM" -a "$TO" ] ; then
        echo "scp -i ~/.ssh/$PRIVATE_SSH_KEY $FROM $USER@$IP:$TO"
        scp -i ~/.ssh/$PRIVATE_SSH_KEY $FROM $USER@$IP:$TO
    else
        echo "ssh -i ~/.ssh/$PRIVATE_SSH_KEY $USER@$IP"
        ssh -i ~/.ssh/$PRIVATE_SSH_KEY $USER@$IP    
    fi

fi
