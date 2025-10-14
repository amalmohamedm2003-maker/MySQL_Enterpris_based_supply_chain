-- PARTITIONED TABLES WITHOUT FOREIGN KEYS - CORRECTED FOR MYSQL REQUIREMENTS

DROP TABLE IF EXISTS inventory_daily;

CREATE TABLE inventory_daily (
    inventory_id BIGINT AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    stock_level INT NOT NULL,
    stock_value DECIMAL(12,2),
    date_recorded DATE NOT NULL,
    day_of_week TINYINT,
    is_weekend BOOLEAN,
    month_of_year TINYINT,
    quarter_of_year TINYINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- PRIMARY KEY must include partitioning column (date_recorded)
    PRIMARY KEY (inventory_id, date_recorded),
    
    UNIQUE KEY uk_inventory_unique (product_id, warehouse_id, date_recorded),
    INDEX idx_inventory_date (date_recorded),
    INDEX idx_inventory_product (product_id),
    INDEX idx_inventory_warehouse (warehouse_id),
    INDEX idx_inventory_comprehensive (date_recorded, product_id, warehouse_id)
)
PARTITION BY RANGE (YEAR(date_recorded)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Shipments table (also needs partitioning column in primary key)
DROP TABLE IF EXISTS shipments;

CREATE TABLE shipments (
    shipment_id BIGINT AUTO_INCREMENT,
    supplier_id INT,
    product_id INT,
    quantity INT,
    shipped_date DATE,
    estimated_delivery DATE,
    actual_delivery DATE,
    status ENUM('pending', 'in_transit', 'delayed', 'delivered'),
    carrier VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- PRIMARY KEY must include partitioning column (shipped_date)
    PRIMARY KEY (shipment_id, shipped_date),
    
    INDEX idx_shipment_dates (shipped_date, estimated_delivery),
    INDEX idx_shipment_status (status),
    INDEX idx_shipment_supplier (supplier_id, shipped_date)
)
PARTITION BY RANGE (YEAR(shipped_date)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Create a separate validation table for data integrity (non-partitioned)
CREATE TABLE IF NOT EXISTS inventory_data_quality (
    quality_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_id BIGINT,
    product_id INT,
    warehouse_id INT,
    date_recorded DATE,
    issue_type ENUM('MISSING_PRODUCT', 'MISSING_WAREHOUSE', 'INVALID_STOCK_LEVEL'),
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'),
    description TEXT,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    
    INDEX idx_quality_product (product_id),
    INDEX idx_quality_warehouse (warehouse_id),
    INDEX idx_quality_date (date_recorded),
    INDEX idx_quality_issue (issue_type, severity)
);

SELECT '✅ Partitioned tables created successfully (corrected for MySQL primary key requirements)' as status;