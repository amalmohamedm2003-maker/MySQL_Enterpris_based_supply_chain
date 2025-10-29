-- PERFORMANCE TUNING - FINAL WORKING VERSION
USE supply_chain_intelligence;

-- =============================================
-- CLEANUP EXISTING OBJECTS
-- =============================================

DROP PROCEDURE IF EXISTS OptimizeLargeTables;
DROP PROCEDURE IF EXISTS CheckIndexUsage;
DROP PROCEDURE IF EXISTS DatabaseHealthCheck;
DROP PROCEDURE IF EXISTS CollectPerformanceMetrics;
DROP PROCEDURE IF EXISTS CreateMissingIndexes;

DROP TABLE IF EXISTS performance_log;
DROP TABLE IF EXISTS performance_metrics;

DROP VIEW IF EXISTS performance_dashboard;
DROP VIEW IF EXISTS index_effectiveness;

-- =============================================
-- CREATE PERFORMANCE TABLES
-- =============================================

CREATE TABLE performance_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    operation_name VARCHAR(100),
    execution_time_ms INT,
    records_affected INT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE performance_metrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    metric_name VARCHAR(100),
    metric_value DECIMAL(15,4),
    metric_category VARCHAR(50),
    measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- SIMPLE PERFORMANCE PROCEDURES
-- =============================================

DELIMITER $$

CREATE PROCEDURE OptimizeLargeTables()
BEGIN
    DECLARE start_time BIGINT;
    
    SET start_time = UNIX_TIMESTAMP() * 1000;
    
    -- Analyze main tables (safe operation)
    ANALYZE TABLE inventory_daily;
    ANALYZE TABLE shipments;
    ANALYZE TABLE products;
    ANALYZE TABLE suppliers;
    
    INSERT INTO performance_log (operation_name, execution_time_ms, records_affected)
    VALUES ('TABLE_OPTIMIZATION', (UNIX_TIMESTAMP() * 1000 - start_time), 4);
    
    SELECT 'Table optimization completed' as result;
END$$

CREATE PROCEDURE CheckIndexUsage()
BEGIN
    -- Show index information for large tables
    SELECT 
        TABLE_NAME as 'Table',
        INDEX_NAME as 'Index', 
        INDEX_TYPE as 'Type',
        CARDINALITY as 'Rows',
        CASE 
            WHEN CARDINALITY > 10000 THEN 'EXCELLENT'
            WHEN CARDINALITY > 1000 THEN 'GOOD'
            WHEN CARDINALITY > 100 THEN 'FAIR'
            ELSE 'POOR'
        END as 'Quality'
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'supply_chain_intelligence'
    AND TABLE_NAME IN ('inventory_daily', 'shipments', 'products', 'suppliers')
    ORDER BY CARDINALITY DESC
    LIMIT 15;
END$$

CREATE PROCEDURE DatabaseHealthCheck()
BEGIN
    -- Table sizes and row counts
    SELECT 
        'TABLE_SIZES' as 'Check',
        TABLE_NAME as 'Table',
        TABLE_ROWS as 'Rows',
        ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as 'Size_MB',
        ENGINE as 'Engine'
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = 'supply_chain_intelligence'
    AND TABLE_NAME IN ('inventory_daily', 'shipments', 'products', 'suppliers', 'alert_history', 'monitoring_dashboard')
    ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;
    
    -- Index summary
    SELECT 
        'INDEX_SUMMARY' as 'Check',
        TABLE_NAME as 'Table',
        COUNT(*) as 'Index_Count',
        MAX(CARDINALITY) as 'Max_Cardinality',
        ROUND(AVG(CARDINALITY), 0) as 'Avg_Cardinality'
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'supply_chain_intelligence'
    GROUP BY TABLE_NAME
    ORDER BY Avg_Cardinality DESC;
END$$

CREATE PROCEDURE CollectPerformanceMetrics()
BEGIN
    -- Clear old metrics
    DELETE FROM performance_metrics WHERE measured_at < NOW() - INTERVAL 7 DAY;
    
    -- Table sizes
    INSERT INTO performance_metrics (metric_name, metric_value, metric_category)
    SELECT 
        CONCAT('SIZE_', TABLE_NAME),
        ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2),
        'TABLE_SIZE'
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = 'supply_chain_intelligence'
    AND TABLE_NAME IN ('inventory_daily', 'shipments', 'products', 'suppliers');
    
    -- Row counts
    INSERT INTO performance_metrics (metric_name, metric_value, metric_category)
    SELECT 
        CONCAT('ROWS_', TABLE_NAME),
        TABLE_ROWS,
        'ROW_COUNT'
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = 'supply_chain_intelligence'
    AND TABLE_NAME IN ('inventory_daily', 'shipments', 'products', 'suppliers');
    
    SELECT CONCAT('Collected ', ROW_COUNT(), ' performance metrics') as result;
END$$

CREATE PROCEDURE CreateMissingIndexes()
BEGIN
    -- Check and create index for inventory_daily if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = 'supply_chain_intelligence' 
        AND TABLE_NAME = 'inventory_daily' 
        AND INDEX_NAME = 'idx_inventory_date_product'
    ) THEN
        CREATE INDEX idx_inventory_date_product ON inventory_daily (date_recorded, product_id);
        SELECT 'Created index: idx_inventory_date_product' as action_taken;
    ELSE
        SELECT 'Index already exists: idx_inventory_date_product' as status;
    END IF;
    
    -- Check and create index for shipments if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = 'supply_chain_intelligence' 
        AND TABLE_NAME = 'shipments' 
        AND INDEX_NAME = 'idx_shipments_status_date'
    ) THEN
        CREATE INDEX idx_shipments_status_date ON shipments (status, shipped_date);
        SELECT 'Created index: idx_shipments_status_date' as action_taken;
    ELSE
        SELECT 'Index already exists: idx_shipments_status_date' as status;
    END IF;
END$$

DELIMITER ;

-- =============================================
-- CREATE PERFORMANCE VIEWS
-- =============================================

CREATE VIEW performance_dashboard AS
SELECT 
    metric_category as 'Category',
    metric_name as 'Metric',
    ROUND(AVG(metric_value), 2) as 'Avg_Value',
    ROUND(MAX(metric_value), 2) as 'Max_Value',
    COUNT(*) as 'Measurements',
    MAX(measured_at) as 'Last_Measured'
FROM performance_metrics
WHERE measured_at >= NOW() - INTERVAL 7 DAY
GROUP BY metric_category, metric_name
ORDER BY metric_category, Avg_Value DESC;

CREATE VIEW index_effectiveness AS
SELECT 
    TABLE_NAME as 'Table',
    INDEX_NAME as 'Index',
    INDEX_TYPE as 'Type',
    CARDINALITY as 'Rows',
    CASE 
        WHEN CARDINALITY > 10000 THEN '🟢 EXCELLENT'
        WHEN CARDINALITY > 1000 THEN '🟡 GOOD'
        WHEN CARDINALITY > 100 THEN '🟠 FAIR'
        ELSE '🔴 POOR'
    END as 'Quality'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'supply_chain_intelligence'
AND TABLE_NAME IN ('inventory_daily', 'shipments', 'products', 'suppliers')
ORDER BY CARDINALITY DESC;

-- =============================================
-- EXECUTE PERFORMANCE TUNING
-- =============================================

SELECT '🔄 STARTING PERFORMANCE TUNING...' as status;

-- Run optimizations
CALL OptimizeLargeTables();
CALL CreateMissingIndexes();
CALL CollectPerformanceMetrics();

-- =============================================
-- SHOW PERFORMANCE RESULTS
-- =============================================

SELECT '📊 PERFORMANCE OPTIMIZATION COMPLETED' as '';

-- Show performance log
SELECT '🔧 RECENT OPERATIONS:' as '';
SELECT 
    operation_name as 'Operation',
    execution_time_ms as 'Time_MS',
    records_affected as 'Records',
    executed_at as 'When'
FROM performance_log
ORDER BY executed_at DESC
LIMIT 5;

-- Show current performance metrics
SELECT '📈 PERFORMANCE METRICS:' as '';
SELECT * FROM performance_dashboard;

-- Show index effectiveness
SELECT '🏷️ INDEX EFFECTIVENESS:' as '';
SELECT * FROM index_effectiveness
LIMIT 10;

-- Database health check
SELECT '🏥 DATABASE HEALTH CHECK:' as '';
CALL DatabaseHealthCheck();

-- Final summary
SELECT '✅ PERFORMANCE TUNING COMPLETED SUCCESSFULLY' as final_status;

SELECT '📋 CREATED OBJECTS:' as '';
SELECT 
    'Procedures' as 'Type',
    COUNT(*) as 'Count'
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'supply_chain_intelligence' 
AND ROUTINE_NAME IN ('OptimizeLargeTables', 'CheckIndexUsage', 'DatabaseHealthCheck', 'CollectPerformanceMetrics', 'CreateMissingIndexes')
UNION ALL
SELECT 
    'Tables' as 'Type',
    COUNT(*) as 'Count'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'supply_chain_intelligence' 
AND TABLE_NAME IN ('performance_log', 'performance_metrics')
UNION ALL
SELECT 
    'Views' as 'Type',
    COUNT(*) as 'Count'
FROM information_schema.VIEWS 
WHERE TABLE_SCHEMA = 'supply_chain_intelligence' 
AND TABLE_NAME IN ('performance_dashboard', 'index_effectiveness');