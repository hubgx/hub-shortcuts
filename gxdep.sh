#!/usr/bin/env bash
# Returns deployment file of said box
echo "input1:" $1
TARGET_GB_SN=$(echo $1 | grep -E "$GBX_SN")
echo "serial number:" $TARGET_GB_SN

gxctl get deploy -S $TARGET_GB_SN
echo "Received data from gxctl:" $DEP_DATA
DEP_DATA=$(gxctl get deploy -S $TARGET_GB_SN | grep -E "monitoring" | grep -E "^( )*[a-zA-Z0-9][a-zA-Z0-9\-]*" -o)
echo $DEP_DATA
