-- Query to identify transactions with high log usage
SELECT --TOP 50
    DB_NAME(database_id) AS [Database Name],
    database_transaction_log_bytes_used / 1024.0 / 1024.0 AS [Log Space Used (MB)],
    database_transaction_log_bytes_used AS [Log Space Used (%)],
    session_id,
    CASE database_transaction_type
        WHEN 1 THEN 'Read/Write'
        WHEN 2 THEN 'Read-Only'
        WHEN 3 THEN 'System'
        WHEN 4 THEN 'Distributed'
        ELSE 'Unknown'
    END AS [Transaction Type],
    CASE database_transaction_state
        WHEN 0 THEN 'Initializing'
        WHEN 1 THEN 'Initialized but not started'
        WHEN 2 THEN 'Active'
        WHEN 3 THEN 'Ended (read-only)'
        WHEN 4 THEN 'Commit initiated'
        WHEN 5 THEN 'Prepared'
        WHEN 6 THEN 'Committed'
        WHEN 7 THEN 'Rolling back'
        WHEN 8 THEN 'Rolled back'
        ELSE 'Unknown'
    END AS [Transaction State],
    database_transaction_begin_time,
    DATEDIFF(SECOND, database_transaction_begin_time, GETDATE()) AS [Transaction Duration (seconds)]
FROM 
    sys.dm_tran_database_transactions dt
JOIN 
    sys.dm_tran_session_transactions st ON dt.transaction_id = st.transaction_id
ORDER BY 
    database_transaction_log_bytes_used DESC;
	

-- Query to identify transactions with high CPU utilization
SELECT TOP 100
    qs.execution_count AS [Execution Count],
    qs.total_worker_time AS [Total CPU Time (microseconds)],
    qs.total_worker_time / qs.execution_count AS [Avg CPU Time (microseconds)],
    qs.total_elapsed_time / qs.execution_count AS [Avg Elapsed Time (microseconds)],
    qs.total_logical_reads / qs.execution_count AS [Avg Logical Reads],
    qs.total_physical_reads / qs.execution_count AS [Avg Physical Reads],
    SUBSTRING(qt.text, (qs.statement_start_offset/2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS [Individual Query],
    qt.text AS [Parent Query],
    DB_NAME(qt.dbid) AS [Database Name],
    qp.query_plan AS [Query Plan]
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY 
    sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY 
    qs.total_worker_time DESC;
	
	
-- Query to identify active sessions with high CPU and log usage
SELECT TOP 50
    s.session_id,
    DB_NAME(r.database_id) AS [Database],
    s.login_name AS [Login],
    s.host_name AS [Host],
    s.program_name AS [Program],
    r.status AS [Request Status],
    r.cpu_time AS [CPU Time (ms)],
    r.logical_reads AS [Logical Reads],
    r.writes AS [Writes],
    dt.database_transaction_log_bytes_used / 1024.0 / 1024.0 AS [Log Space Used (MB)],
    dt.database_transaction_log_bytes_used AS [Log Space Used (%)],
    SUBSTRING(qt.text, (r.statement_start_offset/2) + 1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE r.statement_end_offset
        END - r.statement_start_offset)/2) + 1) AS [Current Statement],
    qt.text AS [Batch Text],
    DATEDIFF(SECOND, r.start_time, GETDATE()) AS [Running Time (seconds)],
    r.wait_type,
    r.wait_time,
    r.blocking_session_id
FROM 
    sys.dm_exec_sessions s
JOIN 
    sys.dm_exec_requests r ON s.session_id = r.session_id
LEFT JOIN 
    sys.dm_tran_session_transactions st ON s.session_id = st.session_id
LEFT JOIN 
    sys.dm_tran_database_transactions dt ON st.transaction_id = dt.transaction_id
CROSS APPLY 
    sys.dm_exec_sql_text(r.sql_handle) qt
WHERE 
    s.is_user_process = 1
ORDER BY 
    r.cpu_time DESC, dt.database_transaction_log_bytes_used DESC;