#!/bin/bash
set -e

#
# Display settings on standard out.
#

USER="nzbhydra2"

echo "nzbhydra2 settings"
echo "================"
echo
echo "  User:       ${USER}"
echo "  UID:        ${NZBHYDRA2_UID:=666}"
echo "  GID:        ${NZBHYDRA2_GID:=666}"
echo "  GID_LIST:   ${NZBHYDRA2_GID_LIST:=}"
echo
echo "  Config:     ${CONFIG:=/datadir}"

#
# Change UID / GID of RADARR user.
#

printf "Updating UID / GID... "
[[ $(id -u ${USER}) == ${NZBHYDRA2_UID} ]] || usermod  -o -u ${NZBHYDRA2_UID} ${USER}
[[ $(id -g ${USER}) == ${NZBHYDRA2_GID} ]] || groupmod -o -g ${NZBHYDRA2_GID} ${USER}
echo "[DONE]"

#
# Create groups from RADARR_GID_LIST.
#
if [[ -n ${NZBHYDRA2_GID_LIST} ]]; then
    for gid in $(echo ${NZBHYDRA2_GID_LIST} | sed "s/,/ /g")
    do
        printf "Create group $gid and add user ${USER}..."
        groupadd -g $gid "grp_$gid"
        usermod -aG grp_$gid ${USER}
        echo "[DONE]"
    done
fi

#
# Set directory permissions.
#

printf "Set permissions... "
chown -R ${USER}: /nzbhydra2
function check_permissions {
  [ "$(stat -c '%u %g' $1)" == "${NZBHYDRA2_UID} ${NZBHYDRA2_GID}" ] || chown ${USER}: $1
}
check_permissions ${CONFIG}
echo "[DONE]"


#
# Finally, start nzbhydra2.
#

echo "Starting nzbhydra2..."
exec su -pc "python3 nzbhydra2wrapperPy3.py --datafolder ${CONFIG}" ${USER}
