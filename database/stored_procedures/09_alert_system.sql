-- ALERT SYSTEM PROCEDURES
DELIMITER $$

CREATE PROCEDURE sp_GenerateDailyAlerts()
BEGIN
    -- Stockout Alerts
    SELECT 'STOCKOUT_RISK' as alert_type,
           p.product_name,
           i.stock_level,
           p.safety_stock_level,
           i.date_recorded,
           'CRITICAL' as severity
    FROM inventory_daily i
    JOIN products p ON i.product_id = p.product_id
    WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)
    AND i.stock_level <= p.safety_stock_level
    LIMIT 10;
    
    -- Supplier Risk Alerts
    SELECT 'HIGH_RISK_SUPPLIER' as alert_type,
           supplier_name,
           risk_score,
           'HIGH' as severity
    FROM suppliers
    WHERE risk_score > 0.8
    LIMIT 10;
    
    -- Shipping Delay Alerts
    SELECT 'SHIPPING_DELAY' as alert_type,
           s.shipment_id,
           DATEDIFF(CURDATE(), sh.estimated_delivery) as days_delayed,
           'MEDIUM' as severity
    FROM shipments s
    WHERE s.status = 'delayed' 
    OR (s.actual_delivery IS NULL AND s.estimated_delivery < CURDATE() - INTERVAL 3 DAY)
    LIMIT 10;
END$$

DELIMITER ;

SELECT '✅ Alert system procedures created' as status;