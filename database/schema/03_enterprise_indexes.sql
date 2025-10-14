-- PERFORMANCE INDEXES
CREATE INDEX idx_suppliers_risk ON suppliers(risk_score, performance_rating);
CREATE INDEX idx_products_pricing ON products(cost_price, selling_price);
CREATE INDEX idx_products_stock ON products(safety_stock_level, reorder_point);
CREATE FULLTEXT INDEX ft_products_name ON products(product_name);
CREATE FULLTEXT INDEX ft_suppliers_name ON suppliers(supplier_name);

SELECT '✅ Performance indexes created successfully' as status;