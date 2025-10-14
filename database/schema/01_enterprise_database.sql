-- ENTERPRISE DATABASE WITH OPTIMIZED SETTINGS
DROP DATABASE IF EXISTS chain_intelligence;
CREATE DATABASE chain_intelligence 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE chain_intelligence;

-- Enable performance features
SET GLOBAL innodb_buffer_pool_size = 1073741824; -- 1GB buffer pool
SET GLOBAL max_connections = 200;