#!/usr/bin/env bash
# description: Show as much info as possible on the given box
# input: SERIAL_NUMBER [PROFILE]
UUID_REGEX="([a-zA-Z0-9]+-)+[a-zA-Z0-9]+"
IP_REGEX="([0-9]{1,3}\.){3}[0-9]{1,3}"
GBX_OPS_REPO="/Users/hm/prod/gridbox-ops"

# Show current profile
GBX_PROFILE=$(echo $2 | sed 's/ //')  # Strip blanks
if [[ "$GBX_PROFILE" == "" ]]
then
  GBX_PROFILE=$(gxctl config current-profile)
else
  CURRENT_PROFILE=$(gxctl config current-profile)
  if [[ "$GBX_PROFILE" != "$CURRENT_PROFILE" ]]
  then
    gxctl config use-profile $GBX_PROFILE
  fi
fi
echo "current_profile: " $GBX_PROFILE

# Show serial number
TARGET_GB_SN=$(echo $1 | grep -E "$GBX_SN")
echo "serial_number: " $TARGET_GB_SN

# Get and show device status
ASTERISK_STATUS=$(gxctl get device -S $TARGET_GB_SN | grep -E "$GBX_SN" | grep -Eo "^( )*\*" | grep -E "\*")
if [[ "$ASTERISK_STATUS" == "" ]]
then
  GBX_STATUS="online"
elif [[ "$ASTERISK_STATUS" == "*" ]]
then
  GBX_STATUS="offline/unavailable"
else
  GBX_STATUS="unknown_status (!)"
fi
echo "status: " $GBX_STATUS

# Get and show public ip
GBX_PUBLIC_IP=$(gxctl get device -S $TARGET_GB_SN --show-public-ip | grep -E "$IP_REGEX")
if [[ "$GBX_PUBLIC_IP" == "" ]]
then
  echo "impossible to find ip (profile might be badly configured, or not logged in)"
  echo "  ip_received: " $GBX_PUBLIC_IP
  exit 1
else
  echo "public-ip: " $GBX_PUBLIC_IP
fi

# Get and show device id
DEVICE_ID=$(gxctl get device -S $TARGET_GB_SN | grep -E "$GBX_SN" | grep -Eo "^( )*$UUID_REGEX" | grep -Eo "$UUID_REGEX")
echo "device_id: " $DEVICE_ID

# Get and show monitoring deployment id from serial number
DEP_ID=$(gxctl get deploy -S $TARGET_GB_SN | grep -Eo "^( )*$UUID_REGEX( )+monitoring" | grep -Eo "$UUID_REGEX")
echo "monitoring_deployment_id: " $DEP_ID

# Get meta data info on deployments
echo "deployment:"
GBX_OPS_MATCHES=$(grep -RE "$DEP_ID" $GBX_OPS_REPO)
if [[ "$GBX_OPS_MATCHES" == "" ]]
then
  echo "    - managed_by: custom_deployment"
else
  echo "    - managed_by: gridbox-ops"
  DEP_PATH=$(echo $GBX_OPS_MATCHES | grep -Eo "gridbox\-ops.*\.yaml")
  DEP_FILE=$(echo $DEP_PATH | grep -Eo "monitoring.*\.yaml")
  echo "    - file: $DEP_FILE"
  echo "    - path: $DEP_PATH"
fi

# Get and show image(s)
DEPLOYMENTS=$(gxctl get deploy $DEP_ID -o yaml | grep -Eo "gridbox[a-zA-Z0-9\-]+\:[a-zA-Z0-9\_\-\.]*")
echo "    - attached_images:"
for DEPLOY in $DEPLOYMENTS
do
  DEP_CAT=$(echo $DEPLOY | grep -Eo "gridbox[a-zA-Z0-9\-]*" | sed 's/gridbox\-//')
  DEP_IMAGE=$(echo $DEPLOY | sed 's/gridbox[a-zA-Z0-9\-]*://')
  echo "         - " $DEP_CAT " : " $DEP_IMAGE
done

# Show command to connect to box
TMP=$(echo $DEPLOYMENTS | grep -E "simulator")
if [[ "$TMP" == "" ]]
then
  BOX_TYPE="real"
else
  VB_GEN=$(echo $GBX_SN | grep -E "[A-Z][0-9]{3}-[0-9]" | sed 's/[A-Z][0-9]{3}\-//')
  if [[ "$VB_GEN" == "020" ]]
  then
    BOX_TYPE="virtual-new"
  else
    BOX_TYPE="virtual-old"
  fi
fi

echo "box_type: " $BOX_TYPE

if [[ "$BOX_TYPE" == "real" ]]
then
  echo "connection: ssh $TARGET_GB_SN.gridbox"
elif [[ "$BOX_TYPE" == "virtual-old" ]]
then
  echo "connection: ssh ubuntu@$GBX_PUBLIC_IP"
elif [[ "$BOX_TYPE" == "virtual-new" ]]
then
  echo "connection: see https://grid-x.atlassian.net/wiki/spaces/EMS/pages/3270770814/SSH-ing+into+a+Virtual+gridBox"
else
  echo "connection: [Don't know how to connect to a box of type: " $BOX_TYPE "]"
fi