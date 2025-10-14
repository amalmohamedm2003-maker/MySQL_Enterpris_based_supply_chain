-- CORE TABLES WITHOUT PARTITIONING FOREIGN KEYS

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_code VARCHAR(20) UNIQUE NOT NULL,
    supplier_name VARCHAR(255) NOT NULL,
    supplier_tier ENUM('TIER1', 'TIER2', 'TIER3') DEFAULT 'TIER2',
    risk_score DECIMAL(4,3) DEFAULT 0.5,
    performance_rating DECIMAL(4,3) DEFAULT 0.0,
    location_country VARCHAR(100),
    location_region ENUM('NORTH_AMERICA', 'EUROPE', 'ASIA', 'SOUTH_AMERICA', 'OTHER'),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    risk_profile ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM'
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_sku VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category_id INT,
    supplier_id INT,
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    safety_stock_level INT,
    reorder_point INT,
    target_stock_level INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_code VARCHAR(20) UNIQUE NOT NULL,
    warehouse_name VARCHAR(255) NOT NULL,
    location_country VARCHAR(100),
    location_city VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

-- Market events table
CREATE TABLE market_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_type ENUM('PANDEMIC', 'WEATHER', 'POLITICAL', 'ECONOMIC', 'TRANSPORT_STRIKE'),
    event_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE,
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'SEVERE') DEFAULT 'MEDIUM'
);

SELECT '✅ Core enterprise tables created successfully' as status;