-- SEED WAREHOUSES
INSERT INTO warehouses (warehouse_code, warehouse_name, location_country, location_city) VALUES
('WH-US-01', 'US Main Distribution', 'USA', 'Chicago'),
('WH-US-02', 'US West Coast Hub', 'USA', 'Los Angeles'),
('WH-EU-01', 'European Central', 'Germany', 'Frankfurt'),
('WH-ASIA-01', 'Asia Pacific Hub', 'China', 'Shanghai');

SELECT CONCAT('✅ ', COUNT(*), ' warehouses seeded') as status FROM warehouses;