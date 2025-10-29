-- SUPPLIER RISK DASHBOARD

-- Supplier Risk Summary
SELECT 'SUPPLIER_RISK_SUMMARY' as dashboard_section,
       COUNT(*) as total_suppliers,
       SUM(CASE WHEN risk_score > 0.7 THEN 1 ELSE 0 END) as high_risk_suppliers,
       SUM(CASE WHEN risk_score BETWEEN 0.4 AND 0.7 THEN 1 ELSE 0 END) as medium_risk_suppliers,
       SUM(CASE WHEN risk_score < 0.4 THEN 1 ELSE 0 END) as low_risk_suppliers,
       ROUND(AVG(risk_score), 3) as avg_risk_score
FROM suppliers
WHERE is_active = TRUE;

-- High Risk Suppliers with Performance
SELECT 'HIGH_RISK_SUPPLIERS' as dashboard_section,
       supplier_name,
       risk_score,
       performance_rating,
       location_country,
       supplier_tier,
       CASE 
           WHEN risk_score > 0.8 THEN 'CRITICAL'
           WHEN risk_score > 0.7 THEN 'HIGH'
           ELSE 'MEDIUM'
       END as risk_category
FROM suppliers
WHERE risk_score > 0.7
ORDER BY risk_score DESC
LIMIT 15;