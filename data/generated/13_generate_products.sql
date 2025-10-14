-- GENERATE 5,000 PRODUCTS
DELIMITER $$
CREATE PROCEDURE GenerateProducts()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE cat_id INT;
    DECLARE sup_id INT;
    
    WHILE i < 5000 DO
        SELECT category_id INTO cat_id FROM product_categories ORDER BY RAND() LIMIT 1;
        SELECT supplier_id INTO sup_id FROM suppliers WHERE is_active = TRUE ORDER BY RAND() LIMIT 1;
        
        INSERT INTO products (product_sku, product_name, category_id, supplier_id, cost_price, selling_price, safety_stock_level, reorder_point, target_stock_level) VALUES (
            CONCAT('SKU-', LPAD(i+1, 8, '0')),
            CONCAT('Product ', i+1),
            cat_id,
            sup_id,
            ROUND(10 + RAND() * 990, 2),
            ROUND(15 + RAND() * 1985, 2),
            FLOOR(50 + RAND() * 450),
            FLOOR(100 + RAND() * 900),
            FLOOR(200 + RAND() * 1800)
        );
        
        SET i = i + 1;
        IF i % 1000 = 0 THEN
            SELECT CONCAT('Generated ', i, ' products...') as progress;
        END IF;
    END WHILE;
END$$
DELIMITER ;

CALL GenerateProducts();
DROP PROCEDURE GenerateProducts;

SELECT CONCAT('✅ ', COUNT(*), ' products generated') as status FROM products;