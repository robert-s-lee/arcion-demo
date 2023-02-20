-- arcion user
CREATE USER IF NOT EXISTS '${DSTDB_ARC_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${DSTDB_ARC_PW}';
CREATE USER IF NOT EXISTS '${DSTDB_ARC_USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DSTDB_ARC_PW}';

GRANT ALL ON ${DSTDB_ARC_USER}.* to '${DSTDB_ARC_USER}'@'%';
GRANT ALL ON ${DSTDB_ARC_USER}.* to '${DSTDB_ARC_USER}'@'localhost';

GRANT ALL ON io_replicate.* to '${DSTDB_ARC_USER}'@'%';
GRANT ALL ON io_replicate.* to '${DSTDB_ARC_USER}'@'localhost';

-- prevent SELECT command denied to user '${DSTDB_ARC_USER}'@'172.18.0.3' for table 'user'
GRANT SELECT ON mysql.user TO '${DSTDB_ARC_USER}'@'%';
GRANT SELECT ON mysql.user TO '${DSTDB_ARC_USER}'@'localhost';

GRANT SELECT ON performance_schema.* TO '${DSTDB_ARC_USER}'@'%';
GRANT SELECT ON performance_schema.* TO '${DSTDB_ARC_USER}'@'localhost';

-- arcion database
create database IF NOT EXISTS ${DSTDB_ARC_USER};
create database IF NOT EXISTS io_replicate;

-- if source has catalog.scham support
GRANT ALL ON ${DSTDB_ARC_USER}_public.* to '${DSTDB_ARC_USER}'@'%';
GRANT ALL ON ${DSTDB_ARC_USER}_public.* to '${DSTDB_ARC_USER}'@'localhost';
