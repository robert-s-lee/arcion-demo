-- create arcsrc for retrivial
CREATE TABLE REPLICATE_IO_CDC_HEARTBEAT(
  TIMESTAMP BIGINT NOT NULL,
  PRIMARY KEY(TIMESTAMP)
);

-- add primary keys
alter table history add id int identity primary key;

-- enable change tracking
ALTER DATABASE [${SRCDB_DB}] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

ALTER TABLE  customer ENABLE CHANGE_TRACKING;
ALTER TABLE  district ENABLE CHANGE_TRACKING;
ALTER TABLE  history ENABLE CHANGE_TRACKING;
ALTER TABLE  item    ENABLE CHANGE_TRACKING;
ALTER TABLE  new_order ENABLE CHANGE_TRACKING;
ALTER TABLE  oorder ENABLE CHANGE_TRACKING;
ALTER TABLE  order_line ENABLE CHANGE_TRACKING;
ALTER TABLE  stock ENABLE CHANGE_TRACKING;
ALTER TABLE  THEUSERTABLE ENABLE CHANGE_TRACKING;
ALTER TABLE  warehouse ENABLE CHANGE_TRACKING;
ALTER TABLE  REPLICATE_IO_CDC_HEARTBEAT ENABLE CHANGE_TRACKING;

-- cdc

CREATE TABLE replicate_io_audit_ddl(
  "CURRENT_USER" NVARCHAR(128), 
  "SCHEMA_NAME" NVARCHAR(128), 
  "TABLE_NAME" NVARCHAR(128), 
  "TYPE" NVARCHAR(30), 
  "OPERATION_TYPE" NVARCHAR(30), 
  "SQL_TXT" NVARCHAR(2000), 
  "LOGICAL_POSITION" BIGINT, 
  CONSTRAINT "arcsrc.dbo.replicate_io_audit_ddlPK" 
  PRIMARY KEY("LOGICAL_POSITION")
  );

ALTER TABLE replicate_io_audit_ddl ENABLE CHANGE_TRACKING;


CREATE TABLE replicate_io_audit_tbl_schema(
  "COLUMN_ID" BIGINT, 
  "DATA_DEFAULT" BIGINT, 
  "COLUMN_NAME" VARCHAR(128) NOT NULL, 
  "TABLE_NAME" NVARCHAR(128) NOT NULL, 
  "SCHEMA_NAME" NVARCHAR(128) NOT NULL, 
  "HIDDEN_COLUMN" NVARCHAR(3), 
  "DATA_TYPE" NVARCHAR(128), 
  "DATA_LENGTH" BIGINT, 
  "CHAR_LENGTH" BIGINT, 
  "DATA_SCALE" BIGINT, 
  "DATA_PRECISION" BIGINT, 
  "IDENTITY_COLUMN" NVARCHAR(3), 
  "VIRTUAL_COLUMN" NVARCHAR(3), 
  "NULLABLE" NVARCHAR(1), 
  "LOGICAL_POSITION" BIGINT);


CREATE TABLE replicate_io_audit_tbl_cons(
  "SCHEMA_NAME" VARCHAR(128), 
  "TABLE_NAME" VARCHAR(128), 
  "COLUMN_NAME" VARCHAR(4000), 
  "COL_POSITION" BIGINT, 
  "CONSTRAINT_NAME" VARCHAR(128), 
  "CONSTRAINT_TYPE" VARCHAR(1), 
  "LOGICAL_POSITION" BIGINT);


CREATE OR ALTER TRIGGER "replicate_io_audit_ddl_trigger"
ON DATABASE
AFTER ALTER_TABLE
AS
  SET NOCOUNT ON;
  DECLARE @data XML
  DECLARE @operation NVARCHAR(30)
  SET @data = EVENTDATA()
  SET @operation = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(30)')
BEGIN
  INSERT INTO
    replicate_io_audit_ddl
        ("CURRENT_USER", "SCHEMA_NAME", "TABLE_NAME", "TYPE", "OPERATION_TYPE", "SQL_TXT", "LOGICAL_POSITION")
        VALUES (SUSER_NAME(),CONVERT(NVARCHAR(128), CURRENT_USER),@data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(128)'),@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(30)'), @data.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(30)'), @data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(2000)'), CHANGE_TRACKING_CURRENT_VERSION())
END
go
