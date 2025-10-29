-- FINANCIAL IMPACT ANALYSIS

-- Inventory Value Analysis
SELECT 'INVENTORY_VALUE_ANALYSIS' as analysis_type,
       SUM(stock_value) as total_inventory_value,
       COUNT(DISTINCT product_id) as unique_products,
       COUNT(*) as total_records,
       ROUND(AVG(stock_value), 2) as avg_stock_value,
       MAX(date_recorded) as latest_snapshot_date
FROM inventory_daily
WHERE date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily);

-- Stockout Financial Impact Estimation
SELECT 'STOCKOUT_IMPACT' as analysis_type,
       COUNT(*) as potential_stockouts,
       SUM(p.selling_price * (p.safety_stock_level - i.stock_level)) as estimated_revenue_loss,
       AVG(p.selling_price * (p.safety_stock_level - i.stock_level)) as avg_product_loss
FROM inventory_daily i
JOIN products p ON i.product_id = p.product_id
WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)
AND i.stock_level <= p.safety_stock_level;