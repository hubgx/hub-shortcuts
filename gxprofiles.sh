#!/usr/bin/env bash
# description: Returns a list of the available profiles (not necessarily logged in the said profiles)
# input: None
gxctl config status 2>&1 | grep -E "Profile [a-zA-Z0-9\-]+" -o | sed 's/Profile //'