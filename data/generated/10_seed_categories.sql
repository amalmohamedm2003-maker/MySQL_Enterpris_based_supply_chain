-- SEED PRODUCT CATEGORIES
INSERT INTO product_categories (category_name, parent_category_id, risk_profile) VALUES
('Electronics', NULL, 'HIGH'),
('Computers', 1, 'HIGH'),
('Components', 1, 'MEDIUM'),
('Industrial', NULL, 'CRITICAL'),
('Consumer', NULL, 'MEDIUM');

SELECT CONCAT('✅ ', COUNT(*), ' product categories seeded') as status FROM product_categories;