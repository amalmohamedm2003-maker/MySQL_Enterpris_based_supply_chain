-- ADVANCED ANALYTICS PROCEDURES
DELIMITER $$

CREATE PROCEDURE sp_InventoryTrendAnalysis(IN product_id_param INT)
BEGIN
    SELECT 
        date_recorded,
        stock_level,
        AVG(stock_level) OVER (ORDER BY date_recorded ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) as moving_avg_7d,
        LAG(stock_level, 7) OVER (ORDER BY date_recorded) as level_7d_ago
    FROM inventory_daily 
    WHERE product_id = product_id_param 
    AND date_recorded >= CURDATE() - INTERVAL 30 DAY
    ORDER BY date_recorded DESC
    LIMIT 30;
END$$

CREATE PROCEDURE sp_SupplierRiskAnalysis()
BEGIN
    SELECT 
        s.supplier_name,
        s.risk_score,
        COUNT(sh.shipment_id) as total_shipments,
        SUM(CASE WHEN sh.status = 'delayed' THEN 1 ELSE 0 END) as delayed_shipments,
        ROUND(SUM(CASE WHEN sh.status = 'delayed' THEN 1 ELSE 0 END) / COUNT(sh.shipment_id) * 100, 2) as delay_percentage
    FROM suppliers s
    LEFT JOIN shipments sh ON s.supplier_id = sh.supplier_id
    GROUP BY s.supplier_id, s.supplier_name, s.risk_score
    ORDER BY s.risk_score DESC
    LIMIT 15;
END$$

DELIMITER ;

SELECT '✅ Advanced analytics procedures created' as status;