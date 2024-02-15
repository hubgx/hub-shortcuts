#!/usr/bin/env bash
# description: Returns deployment file of said box
# input: SERIAL_NUMBER
UUID_REGEX=([a-zA-Z0-9]+-)+[a-zA-Z0-9]+

echo "input1:" $1
TARGET_GB_SN=$(echo $1 | grep -E "$GBX_SN")
echo "serial number:" $TARGET_GB_SN

# Get monitoring deployment id from serial number
DEP_ID=$(gxctl get deploy -S $TARGET_GB_SN | grep -Eo "^( )*$UUID_REGEX( )+monitoring" | grep -Eo "$UUID_REGEX")
echo $DEP_ID
if [ $DEP_ID = "" ]
then
  echo "Empty deployment data"
  exit 1
else
  echo "deployment_id: " $DEP_ID
fi



