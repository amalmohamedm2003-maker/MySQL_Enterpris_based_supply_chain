-- SHIPPING INTELLIGENCE QUERIES

-- Shipping Performance Summary
SELECT 'SHIPPING_PERFORMANCE' as analysis_type,
       COUNT(*) as total_shipments,
       SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as delivered,
       SUM(CASE WHEN status = 'delayed' THEN 1 ELSE 0 END) as Delaye,
       SUM(CASE WHEN status = 'in_transit' THEN 1 ELSE 0 END) as in_transit,
       ROUND(SUM(CASE WHEN status = 'delayed' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as delay_percentage
FROM shipments;

-- Carrier Performance Analysis
SELECT 'CARRIER_PERFORMANCE' as analysis_type,
       carrier,
       COUNT(*) as total_shipments,
       SUM(CASE WHEN status = 'delayed' THEN 1 ELSE 0 END) as delayed_shipments,
       ROUND(SUM(CASE WHEN status = 'delayed' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as delay_rate,
       AVG(DATEDIFF(COALESCE(actual_delivery, CURDATE()), estimated_delivery)) as avg_delay_days
FROM shipments
GROUP BY carrier
HAVING total_shipments > 10
ORDER BY delay_rate DESC;