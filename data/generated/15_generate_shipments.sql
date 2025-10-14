-- GENERATE 50,000 SHIPMENTS
DELIMITER $$
CREATE PROCEDURE GenerateShipments()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE ship_date DATE;
    
    WHILE i < 50000 DO
        SET ship_date = DATE('2022-01-01' + INTERVAL FLOOR(RAND() * 730) DAY);
        
        INSERT INTO shipments (supplier_id, product_id, quantity, shipped_date, estimated_delivery, actual_delivery, status, carrier) VALUES (
            FLOOR(1 + RAND() * 200),
            FLOOR(1 + RAND() * 5000),
            FLOOR(10 + RAND() * 990),
            ship_date,
            ship_date + INTERVAL (7 + FLOOR(RAND() * 21)) DAY,
            CASE WHEN RAND() < 0.8 THEN ship_date + INTERVAL (7 + FLOOR(RAND() * 28)) DAY ELSE NULL END,
            ELT(FLOOR(1 + RAND() * 4), 'pending', 'in_transit', 'delayed', 'delivered'),
            ELT(FLOOR(1 + RAND() * 4), 'UPS', 'DHL', 'FedEx', 'Maersk')
        );
        
        SET i = i + 1;
        IF i % 10000 = 0 THEN
            SELECT CONCAT('Generated ', i, ' shipments...') as progress;
        END IF;
    END WHILE;
END$$
DELIMITER ;

CALL GenerateShipments();
DROP PROCEDURE GenerateShipments;

SELECT CONCAT('✅ ', COUNT(*), ' shipments generated') as status FROM shipments;