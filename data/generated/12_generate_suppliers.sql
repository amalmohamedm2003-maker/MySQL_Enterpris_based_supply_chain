-- GENERATE 200 ENTERPRISE SUPPLIERS
DELIMITER $$
CREATE PROCEDURE GenerateSuppliers()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 200 DO
        INSERT INTO suppliers (supplier_code, supplier_name, supplier_tier, risk_score, performance_rating, location_country, location_region) VALUES (
            CONCAT('SUP', LPAD(i+1, 6, '0')),
            CONCAT('Supplier ', i+1),
            ELT(FLOOR(1 + RAND() * 3), 'TIER1', 'TIER2', 'TIER3'),
            ROUND(0.1 + RAND() * 0.8, 3),
            ROUND(0.3 + RAND() * 0.6, 3),
            ELT(FLOOR(1 + RAND() * 5), 'USA', 'China', 'Germany', 'Japan', 'Vietnam'),
            ELT(FLOOR(1 + RAND() * 4), 'NORTH_AMERICA', 'EUROPE', 'ASIA', 'OTHER')
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL GenerateSuppliers();
DROP PROCEDURE GenerateSuppliers;

SELECT CONCAT('✅ ', COUNT(*), ' suppliers generated') as status FROM suppliers;