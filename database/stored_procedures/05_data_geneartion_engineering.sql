-- DATA GENERATION STORED PROCEDURES
DELIMITER $$

CREATE PROCEDURE sp_GetInventoryAnomalies()
BEGIN
    SELECT 
        p.product_name,
        i.stock_level,
        p.safety_stock_level,
        i.date_recorded,
        CASE 
            WHEN i.stock_level <= p.safety_stock_level THEN 'CRITICAL'
            WHEN i.stock_level <= (p.safety_stock_level * 1.2) THEN 'WARNING'
            ELSE 'NORMAL'
        END as status
    FROM inventory_daily i
    JOIN products p ON i.product_id = p.product_id
    WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)
    HAVING status != 'NORMAL'
    LIMIT 10;
END$$

CREATE PROCEDURE sp_GetSupplierPerformance()
BEGIN
    SELECT 
        supplier_name,
        risk_score,
        performance_rating,
        CASE 
            WHEN risk_score > 0.7 THEN 'HIGH_RISK'
            WHEN risk_score > 0.4 THEN 'MEDIUM_RISK' 
            ELSE 'LOW_RISK'
        END as risk_category
    FROM suppliers
    ORDER BY risk_score DESC
    LIMIT 10;
END$$

DELIMITER ;

SELECT '✅ Data generation procedures created' as status;