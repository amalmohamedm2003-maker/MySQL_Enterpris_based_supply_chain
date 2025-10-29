-- EXECUTIVE DASHBOARD - COMPREHENSIVE OVERVIEW

-- Key Performance Indicators
SELECT 'KPI_SUMMARY' as dashboard_section,
       (SELECT COUNT(*) FROM products WHERE is_active = TRUE) as active_products,
       (SELECT COUNT(*) FROM suppliers WHERE is_active = TRUE) as active_suppliers,
       (SELECT COUNT(*) FROM inventory_daily WHERE date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)) as daily_inventory_records,
       (SELECT COUNT(*) FROM shipments) as total_shipments,
       (SELECT SUM(stock_value) FROM inventory_daily WHERE date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)) as total_inventory_value;

-- Critical Alerts Summary
SELECT 'CRITICAL_ALERTS' as dashboard_section,
       (SELECT COUNT(*) FROM inventory_daily i JOIN products p ON i.product_id = p.product_id 
        WHERE i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily) 
        AND i.stock_level <= p.safety_stock_level) as stockout_alerts,
       (SELECT COUNT(*) FROM suppliers WHERE risk_score > 0.8) as high_risk_suppliers,
       (SELECT COUNT(*) FROM shipments WHERE status = 'delayed' OR (actual_delivery IS NULL AND estimated_delivery < CURDATE())) as delayed_shipments;

-- Risk Exposure by Category
SELECT 'RISK_EXPOSURE' as dashboard_section,
       c.category_name,
       COUNT(p.product_id) as product_count,
       AVG(s.risk_score) as avg_supplier_risk,
       SUM(CASE WHEN i.stock_level <= p.safety_stock_level THEN 1 ELSE 0 END) as current_stockouts
FROM product_categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN inventory_daily i ON p.product_id = i.product_id AND i.date_recorded = (SELECT MAX(date_recorded) FROM inventory_daily)
GROUP BY c.category_id, c.category_name
ORDER BY avg_supplier_risk DESC;