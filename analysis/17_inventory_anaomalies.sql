-- INVENTORY ANOMALY DETECTION QUERIES

-- Current Critical Stock Levels
SELECT 'CURRENT_CRITICAL_STOCK' as analysis_type,
       p.product_name,
       i.stock_level,
       p.safety_stock_level,
       i.date_recorded,
       ROUND((p.safety_stock_level - i.stock_level) / p.safety_stock_level * 100, 2) as shortage_percentage
FROM inventory_daily i
JOIN products p ON i.product_id = p.product_id
WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)
AND i.stock_level <= p.safety_stock_level
ORDER BY shortage_percentage DESC
LIMIT 15;

-- Stock Level Trends (Last 7 days vs Historical)
SELECT 'STOCK_TREND_ANALYSIS' as analysis_type,
       p.product_name,
       MAX(i.date_recorded) as latest_date,
       (SELECT stock_level FROM inventory_daily WHERE product_id = p.product_id AND date_recorded = MAX(i.date_recorded)) as current_stock,
       (SELECT AVG(stock_level) FROM inventory_daily WHERE product_id = p.product_id AND date_recorded >= CURDATE() - INTERVAL 7 DAY) as avg_7day,
       (SELECT AVG(stock_level) FROM inventory_daily WHERE product_id = p.product_id) as avg_historical
FROM inventory_daily i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING current_stock < avg_7day * 0.5 OR current_stock > avg_historical * 2
LIMIT 15;