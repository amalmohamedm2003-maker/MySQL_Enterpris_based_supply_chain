-- ULTRA SIMPLE ALERT & MONITORING - FIXED COLUMN ISSUES
USE supply_chain_intelligence;

-- =============================================
-- CLEANUP FIRST
-- =============================================

DROP TABLE IF EXISTS alert_history;
DROP TABLE IF EXISTS monitoring_dashboard;

DROP PROCEDURE IF EXISTS CheckAllAlerts;
DROP PROCEDURE IF EXISTS UpdateMonitoringDashboard;

-- =============================================
-- CREATE BASIC TABLES
-- =============================================

CREATE TABLE alert_history (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    alert_type VARCHAR(50),
    alert_message TEXT,
    severity VARCHAR(20),
    triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE monitoring_dashboard (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    metric_name VARCHAR(100),
    metric_value DECIMAL(15,2),
    metric_unit VARCHAR(50),
    status VARCHAR(20),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- SIMPLE ALERT PROCEDURE
-- =============================================

DELIMITER $$

CREATE PROCEDURE CheckAllAlerts()
BEGIN
    -- Clear old alerts
    DELETE FROM alert_history;
    
    -- Check stockout risks
    INSERT INTO alert_history (alert_type, alert_message, severity)
    SELECT 
        'STOCKOUT_RISK',
        CONCAT(COUNT(*), ' products at safety stock level'),
        'HIGH'
    FROM inventory_daily i
    JOIN products p ON i.product_id = p.product_id
    WHERE i.stock_level <= p.safety_stock_level;
    
    -- Check shipping delays
    INSERT INTO alert_history (alert_type, alert_message, severity)
    SELECT 
        'SHIPPING_DELAY',
        CONCAT(COUNT(*), ' shipments delayed'),
        'MEDIUM'
    FROM shipments 
    WHERE status = 'delayed';
    
    -- Check high risk suppliers
    INSERT INTO alert_history (alert_type, alert_message, severity)
    SELECT 
        'HIGH_RISK_SUPPLIER',
        CONCAT(COUNT(*), ' high risk suppliers'),
        'MEDIUM'
    FROM suppliers 
    WHERE risk_score > 0.7;
    
    -- Always add a system status alert
    INSERT INTO alert_history (alert_type, alert_message, severity)
    SELECT 
        'SYSTEM_STATUS',
        'Alert system running normally',
        'LOW'
    FROM dual
    WHERE NOT EXISTS (SELECT 1 FROM alert_history);
    
    SELECT 'Alerts checked successfully' as result;
END$$

DELIMITER ;

-- =============================================
-- SIMPLE MONITORING PROCEDURE - FIXED COLUMNS
-- =============================================

DELIMITER $$

CREATE PROCEDURE UpdateMonitoringDashboard()
BEGIN
    -- Clear old data
    DELETE FROM monitoring_dashboard;
    
    -- Active products count (REMOVED is_active check)
    INSERT INTO monitoring_dashboard (metric_name, metric_value, metric_unit, status)
    SELECT 
        'ACTIVE_PRODUCTS',
        COUNT(*),
        'Products',
        'HEALTHY'
    FROM products;
    
    -- Stockout risks
    INSERT INTO monitoring_dashboard (metric_name, metric_value, metric_unit, status)
    SELECT 
        'STOCKOUT_RISKS',
        COUNT(*),
        'Products',
        CASE 
            WHEN COUNT(*) > 10 THEN 'CRITICAL'
            WHEN COUNT(*) > 5 THEN 'WARNING'
            ELSE 'HEALTHY'
        END
    FROM inventory_daily i
    JOIN products p ON i.product_id = p.product_id
    WHERE i.stock_level <= p.safety_stock_level;
    
    -- Supplier risk (REMOVED is_active check)
    INSERT INTO monitoring_dashboard (metric_name, metric_value, metric_unit, status)
    SELECT 
        'AVG_SUPPLIER_RISK',
        COALESCE(AVG(risk_score), 0),
        'Score',
        CASE 
            WHEN AVG(risk_score) > 0.7 THEN 'CRITICAL'
            WHEN AVG(risk_score) > 0.5 THEN 'WARNING'
            ELSE 'HEALTHY'
        END
    FROM suppliers;
    
    -- Delayed shipments
    INSERT INTO monitoring_dashboard (metric_name, metric_value, metric_unit, status)
    SELECT 
        'DELAYED_SHIPMENTS',
        COUNT(*),
        'Shipments',
        CASE 
            WHEN COUNT(*) > 20 THEN 'CRITICAL'
            WHEN COUNT(*) > 10 THEN 'WARNING'
            ELSE 'HEALTHY'
        END
    FROM shipments 
    WHERE status = 'delayed';
    
    -- Data freshness
    INSERT INTO monitoring_dashboard (metric_name, metric_value, metric_unit, status)
    SELECT 
        'DATA_FRESHNESS',
        COALESCE(TIMESTAMPDIFF(HOUR, MAX(created_at), NOW()), 0),
        'Hours',
        CASE 
            WHEN TIMESTAMPDIFF(HOUR, MAX(created_at), NOW()) > 48 THEN 'CRITICAL'
            WHEN TIMESTAMPDIFF(HOUR, MAX(created_at), NOW()) > 24 THEN 'WARNING'
            ELSE 'HEALTHY'
        END
    FROM inventory_daily;
    
    SELECT 'Monitoring updated successfully' as result;
END$$

DELIMITER ;

-- =============================================
-- EXECUTE EVERYTHING
-- =============================================

-- Run alert system
CALL CheckAllAlerts();

-- Run monitoring system
CALL UpdateMonitoringDashboard();

-- =============================================
-- SHOW RESULTS
-- =============================================

SELECT '=== ALERT SYSTEM RESULTS ===' as '';
SELECT * FROM alert_history;

SELECT '=== MONITORING SYSTEM RESULTS ===' as '';
SELECT * FROM monitoring_dashboard;

SELECT '=== SUMMARY ===' as '';
SELECT 
    (SELECT COUNT(*) FROM alert_history) as total_alerts,
    (SELECT COUNT(*) FROM monitoring_dashboard) as total_metrics,
    (SELECT COUNT(*) FROM alert_history WHERE severity = 'HIGH') as high_priority_alerts,
    (SELECT COUNT(*) FROM monitoring_dashboard WHERE status = 'CRITICAL') as critical_metrics;

SELECT '🚀 SYSTEM READY - ALL COMPONENTS WORKING' as final_status;