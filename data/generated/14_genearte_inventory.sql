-- GENERATE 2 YEARS OF INVENTORY DATA (~1M RECORDS)
DELIMITER $$

CREATE PROCEDURE GenerateInventoryData()
BEGIN
    -- ALL DECLARE STATEMENTS MUST BE AT THE BEGINNING
    -- Avoid MySQL reserved words and built-in functions
    DECLARE v_start_date DATE DEFAULT '2022-01-01';
    DECLARE v_end_date DATE DEFAULT '2023-12-31';
    DECLARE v_current_date DATE;
    DECLARE v_product_count INT DEFAULT 5000;
    DECLARE v_warehouse_count INT DEFAULT 4;
    
    SET v_current_date = v_start_date;
    
    WHILE v_current_date <= v_end_date DO
        INSERT INTO inventory_daily (product_id, warehouse_id, stock_level, stock_value, date_recorded, day_of_week, is_weekend, month_of_year, quarter_of_year)
        SELECT 
            FLOOR(1 + RAND() * v_product_count),
            FLOOR(1 + RAND() * v_warehouse_count),
            FLOOR(RAND() * 1000),
            ROUND(RAND() * 50000, 2),
            v_current_date,
            DAYOFWEEK(v_current_date),
            DAYOFWEEK(v_current_date) IN (1,7),
            MONTH(v_current_date),
            QUARTER(v_current_date)
        LIMIT 1000; -- 1000 records per day
        
        SET v_current_date = DATE_ADD(v_current_date, INTERVAL 1 DAY);
        
        IF DAYOFWEEK(v_current_date) = 1 THEN
            SELECT CONCAT('Generated data until: ', v_current_date) as progress;
        END IF;
    END WHILE;
END$$

DELIMITER ;

CALL GenerateInventoryData();
DROP PROCEDURE GenerateInventoryData;

SELECT CONCAT('✅ ', COUNT(*), ' inventory records generated') as status FROM inventory_daily;
select * from inventory_daily;