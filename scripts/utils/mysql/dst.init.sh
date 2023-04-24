#!/usr/bin/env bash

. $SCRIPTS_DIR/lib/ycsb_jdbc.sh
. $SCRIPTS_DIR/lib/ping_utils.sh

# should be set by menu.sh before coming here
[ -z "${LOG_ID}" ] && LOG_DIR="$$" && echo "Warning: LOG_DIR assumed"
[ -z "${CFG_DIR}" ] && CFG_DIR="/tmp/arcion/${LOG_ID}" && echo "Warning: CFG_DIR assumed"

# wait for dst db to be ready to connect
declare -A EXISTING_DBS
ping_db EXISTING_DBS dst

# setup database permissions
if [ -z "${EXISTING_DBS[${DSTDB_DB:-${DSTDB_SCHEMA}}]}" ]; then
  echo "dst db ${DSTDB_ROOT}: ${DSTDB_DB} setup"

  for f in ${CFG_DIR}/dst.init.root*sql; do
    # the root has no DB except Oracle that has SID
    if [ "${DSTDB_GRP}" = "oracle" ]; then
      cat ${f} | jsqsh --driver="${DSTDB_JSQSH_DRIVER}" --user="${DSTDB_ROOT}" --password="${DSTDB_PW}" --server="${DSTDB_HOST}" --port=${DSTDB_PORT} --database="${DSTDB_SID:-${DSTDB_DB}}"
    else
      cat ${f} | jsqsh --driver="${DSTDB_JSQSH_DRIVER}" --user="${DSTDB_ROOT}" --password="${DSTDB_PW}" --server="${DSTDB_HOST}" --port=${DSTDB_PORT}
    fi  
  done
else
  echo "dst db ${DSTDB_DB} already setup. skipping db setup"
fi

# run if table needs to be created
if [ "${DSTDB_DB:-${DSTDB_SCHEMA}}" = "${DSTDB_ARC_USER}" ] && [ ! -z "${DSTDB_INIT_USER}" ]; then
  echo "dst db ${DSTDB_ARC_USER}: ${DSTDB_DB} setup"

  for f in ${CFG_DIR}/dst.init.user*sql; do
    cat ${f} | jsqsh --driver="${DSTDB_JSQSH_DRIVER}" --user="${DSTDB_ARC_USER}" --password="${DSTDB_ARC_PW}" --server="${DSTDB_HOST}" --port=${DSTDB_PORT} --database="${DSTDB_SID:-${DSTDB_DB}}"
  done

else
  echo "dst db ${DSTDB_ARC_USER} ${DSTDB_DB:-${DSTDB_SCHEMA}} ${DSTDB_INIT_USER} and skipping user setup"
fi



