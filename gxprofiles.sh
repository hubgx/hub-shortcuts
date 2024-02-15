#!/usr/bin/env bash
# Returns a list of the available profiles (not necessarily logged in the said profiles)
gxctl config status 2>&1 | grep -E "Profile [a-zA-Z0-9\-]+" -o | sed 's/Profile //'