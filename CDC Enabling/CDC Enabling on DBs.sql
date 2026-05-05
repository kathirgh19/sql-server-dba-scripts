
--To enable CDC on a Database 
USE PLT_AI;
EXEC sys.sp_cdc_enable_db
--EXEC sys.sp_cdc_disable_db;

--To enable CDC on a Particular Table with primary key
exec sys.sp_cdc_enable_table @source_schema = 'dbo' , @source_name ='ProfileWasteCode' ,
@capture_instance = 'Abc_dbo_ProfileWasteCode_sq1',
@role_name = NULL , @filegroup_name = NULL;


--To enable CDC on a Particular Table without primary key
EXECUTE sys.sp_cdc_enable_table @source_schema = N'dbo' , @source_name = N'ProfileWasteCode' , 
@supports_net_changes = 0 , 
@role_name = NULL


--To check CDC enabled Databases/Tables
SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'PLT_AI';

SELECT * FROM sys.tables WHERE is_tracked_by_cdc = 1;

SELECT [capture_instance],[object_id],[source_object_id],[start_lsn],[end_lsn],[supports_net_changes],[has_drop_pending] FROM cdc.change_tables;


--This will list any CDC instances associated with the table.
EXEC sys.sp_cdc_help_change_data_capture  
    @source_schema = N'dbo',  
    @source_name = N'ProfileWasteCode';


--To Disable CDC on Tables
EXEC sys.sp_cdc_disable_table @source_schema = N'dbo',  
@source_name = N'ProfileWasteCode',  
@capture_instance = N'NULL';  -- Optional


--Permissions needed for doing DML operations on a CDC enabled Tables
USE master;
GRANT SELECT ON master.sys.fn_dblog TO [REPSRV\svc-IICS-Usr-qa];
GRANT VIEW SERVER STATE TO [REPSRV\svc-IICS-Usr-qa];
GRANT VIEW ANY DEFINITION TO [REPSRV\svc-IICS-Usr-qa]; 

USE PLT_AI;
EXEC sp_addrolemember 'db_owner', 'REPSRV\svc-IICS-Usr-qa';



-- Query the CDC data (dbo_ProfileWasteCode is cdc capture instance name)
SELECT * FROM cdc.dbo_ProfileWasteCode_CT

         --OR--
SELECT 
    [__$start_lsn] AS LSN,
    [__$seqval] AS SequenceNumber,
    [__$operation] AS Operation,
    [__$update_mask] AS UpdateMask,
    CASE [__$operation]
        WHEN 1 THEN 'Delete'
        WHEN 2 THEN 'Insert'
        WHEN 3 THEN 'Update (Before)'
        WHEN 4 THEN 'Update (After)'
    END AS OperationType,
    --[__$command_id] AS CommandID,
    sys.fn_cdc_map_lsn_to_time([__$start_lsn]) AS ChangeTime,
    SUSER_SNAME([__$update_mask]) AS UpdatedBy,
    -- Include other columns from your table here
    *
FROM cdc.fn_cdc_get_all_changes_dbo_ProfileWasteCode(
    sys.fn_cdc_get_min_lsn('dbo_ProfileWasteCode'),
    sys.fn_cdc_get_max_lsn(),
    N'all'
)
ORDER BY [__$start_lsn] DESC;


--To know the Retention period of cdc capture instance.
DECLARE @min_lsn binary(10) = sys.fn_cdc_get_min_lsn('dbo_InvoiceDetail');-- capture instance name.
DECLARE @max_lsn binary(10) = sys.fn_cdc_get_max_lsn();
SELECT 
    DATEDIFF(MINUTE, 
             sys.fn_cdc_map_lsn_to_time(@min_lsn), 
             sys.fn_cdc_map_lsn_to_time(@max_lsn)) AS retention_minutes;
  

