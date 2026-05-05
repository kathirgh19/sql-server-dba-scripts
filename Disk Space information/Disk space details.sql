/* Drive Information */
SELECT DISTINCT getdate() as TDate, 
vs.volume_mount_point as Drive,
CONVERT(DECIMAL(18,2), vs.total_bytes/1073741824.0) AS [TotalSizeGB],
CONVERT(DECIMAL(18,2), vs.available_bytes/1073741824.0) AS [FreeSizeGB],  
CONVERT(DECIMAL(18,2), vs.available_bytes * 1. / vs.total_bytes * 100.) AS [FreeSize %]
FROM sys.master_files AS f WITH (NOLOCK)
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS vs 
ORDER BY vs.volume_mount_point OPTION (RECOMPILE);


/* Drive Latency */
SELECT tab.[Drive], tab.volume_mount_point AS [Volume Mount Point], 
    CASE 
        WHEN num_of_reads = 0 THEN 0 
        ELSE (io_stall_read_ms/num_of_reads) 
    END AS [Read Latency],
    CASE 
        WHEN num_of_writes = 0 THEN 0 
        ELSE (io_stall_write_ms/num_of_writes) 
    END AS [Write Latency],
    CASE 
        WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 
        ELSE (io_stall/(num_of_reads + num_of_writes)) 
    END AS [Overall Latency]
FROM (SELECT LEFT(UPPER(mf.physical_name), 2) AS Drive, SUM(num_of_reads) AS num_of_reads,
             SUM(io_stall_read_ms) AS io_stall_read_ms, SUM(num_of_writes) AS num_of_writes,
             SUM(io_stall_write_ms) AS io_stall_write_ms, SUM(num_of_bytes_read) AS num_of_bytes_read,
             SUM(num_of_bytes_written) AS num_of_bytes_written, SUM(io_stall) AS io_stall, vs.volume_mount_point 
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
      INNER JOIN sys.master_files AS mf WITH (NOLOCK)
      ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
      CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs 
      GROUP BY LEFT(UPPER(mf.physical_name), 2), vs.volume_mount_point) AS tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);


/* DB file size*/
SELECT getdate() as TDate, DB_NAME([database_id]) AS [Database Name], 
       [name], [type_desc], CONVERT(bigint, size/128.0) AS [TotalSizeinMB]
FROM sys.master_files WITH (NOLOCK)
ORDER BY DB_NAME([database_id]), [file_id] OPTION (RECOMPILE);


/* DB Backup */
SELECT 
[DBName]    =    database_name
, [Year]    =    DATEPART(year,[backup_start_date])
, [Month]    =    DATEPART(month,[backup_start_date])
, [Week] = DATEPART(WEEK,[backup_start_date])
, [Backup Size GB] = CONVERT(DECIMAL(10,2),ROUND(AVG([backup_size]/1024/1024/1024),4))
, [Compressed Backup Size GB] = CONVERT(DECIMAL(10,2),ROUND(AVG([compressed_backup_size]/1024/1024/1024),4))
FROM
msdb.dbo.backupset
WHERE
[database_name]    not in ('master','model','msdb','ReportServer','ReportServerTempDB')
and [type] = 'D'
AND backup_start_date BETWEEN DATEADD(ww, - 1, GETDATE()) AND GETDATE()
GROUP BY
[database_name]
, DATEPART(yyyy,[backup_start_date])
, DATEPART(mm, [backup_start_date])
, DATEPART(WEEK,[backup_start_date])
ORDER BY [database_name],[Year],[Month],[Week]

