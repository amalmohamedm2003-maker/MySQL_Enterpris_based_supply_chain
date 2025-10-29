-- BUSINESS INTELLIGENCE PROCEDURES
DELIMITER $$

CREATE PROCEDURE sp_InventoryValueByWarehouse()
BEGIN
    SELECT 
        w.warehouse_name,
        COUNT(DISTINCT i.product_id) as unique_products,
        SUM(i.stock_level) as total_units,
        ROUND(SUM(i.stock_value), 2) as total_value,
        ROUND(AVG(i.stock_value), 2) as avg_product_value
    FROM inventory_daily i
    JOIN warehouses w ON i.warehouse_id = w.warehouse_id
    WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)
    GROUP BY w.warehouse_id, w.warehouse_name
    ORDER BY total_value DESC;
END$$

CREATE PROCEDURE sp_ProductPerformance()
BEGIN
    SELECT 
        p.product_name,
        p.product_sku,
        c.category_name,
        COUNT(i.inventory_id) as days_tracked,
        AVG(i.stock_level) as avg_stock_level,
        p.safety_stock_level,
        ROUND(AVG(i.stock_level) / p.safety_stock_level * 100, 2) as stock_health_percentage
    FROM products p
    JOIN product_categories c ON p.category_id = c.category_id
    JOIN inventory_daily i ON p.product_id = i.product_id
    WHERE i.date_recorded >= CURDATE() - INTERVAL 30 DAY
    GROUP BY p.product_id, p.product_name, p.product_sku, c.category_name, p.safety_stock_level
    HAVING stock_health_percentage < 80 OR stock_health_percentage > 150
    ORDER BY stock_health_percentage
    LIMIT 20;
END$$

DELIMITER ;

SELECT '✅ Business intelligence procedures created' as status;