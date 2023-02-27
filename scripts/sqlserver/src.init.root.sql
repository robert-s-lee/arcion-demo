CREATE LOGIN ${SRCDB_ARC_USER} WITH PASSWORD = '${SRCDB_ARC_PW}';
create database ${SRCDB_ARC_USER};
use ${SRCDB_ARC_USER};
CREATE USER ${SRCDB_ARC_USER} FOR LOGIN ${SRCDB_ARC_USER} WITH DEFAULT_SCHEMA=${SRCDB_ARC_USER};
ALTER ROLE db_owner ADD MEMBER ${SRCDB_ARC_USER};
ALTER ROLE db_ddladmin ADD MEMBER ${SRCDB_ARC_USER};
alter user ${SRCDB_ARC_USER} with default_schema=dbo;
