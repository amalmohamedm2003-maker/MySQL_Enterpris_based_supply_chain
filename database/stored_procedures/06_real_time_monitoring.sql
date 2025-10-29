-- REAL-TIME MONITORING PROCEDURES
DELIMITER $$

CREATE PROCEDURE sp_DailyInventoryAlert()
BEGIN
    SELECT COUNT(*) as critical_alerts,
           COUNT(CASE WHEN i.stock_level <= p.safety_stock_level THEN 1 END) as stockout_risks,
           COUNT(CASE WHEN i.stock_level <= (p.safety_stock_level * 1.2) THEN 1 END) as low_stock_warnings
    FROM inventory_daily i
    JOIN products p ON i.product_id = p.product_id
    WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily);
END$$

CREATE PROCEDURE sp_ShippingDelays()
BEGIN
    SELECT COUNT(*) as total_delayed_shipments,
           AVG(DATEDIFF(COALESCE(actual_delivery, CURDATE()), estimated_delivery)) as avg_delay_days
    FROM shipments 
    WHERE status = 'delayed' OR (actual_delivery IS NULL AND estimated_delivery < CURDATE());
END$$

DELIMITER ;

SELECT '✅ Real-time monitoring procedures created' as status;