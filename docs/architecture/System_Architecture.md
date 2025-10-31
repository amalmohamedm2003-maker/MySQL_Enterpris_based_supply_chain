# 🏗️ System Architecture

## Architecture Overview
The system follows a three-tier architecture with data sources feeding into MySQL database layer, which powers analytics and reporting through stored procedures and automated monitoring.

## Database Layer
Core Tables:
- suppliers: 500+ suppliers with risk scoring and performance ratings
- products: 10,000+ products with safety stock levels and pricing
- inventory_daily: 5M+ time-series records with partitioning by year
- shipments: 50,000+ shipment records with delivery tracking
- market_events: External factor tracking for supply chain disruptions

Advanced Database Features:
- Partitioning: Time-based partitioning on inventory_daily and shipments tables
- Indexing: Composite indexes on frequently queried columns
- Stored Procedures: 20+ procedures encapsulating business logic
- Constraints: Data integrity checks and foreign key relationships

## Processing Layer
Real-time Components:
- Data Validation: Automated checks for data quality and consistency
- Anomaly Detection: Statistical outlier detection using moving averages
- Risk Calculation: Dynamic supplier scoring based on performance metrics
- Alert Generation: Multi-level alert system with severity classification

Batch Processing:
- Daily Snapshots: Automated inventory tracking and stock level updates
- Weekly Analytics: Supplier performance reports and trend analysis
- Monthly Archiving: Data lifecycle management and performance optimization

## Presentation Layer
Dashboards:
- Executive Overview: Key business metrics and health indicators
- Operational Dashboard: Real-time monitoring of inventory and shipments
- Supplier Risk: Comprehensive risk assessment and scoring dashboard
- Inventory Health: Stock level monitoring with trend visualization

Alerting System:
- Multi-level Alerts: Critical, High, Medium, Low severity classification
- Automated Resolution: Alert tracking, assignment, and closure workflows
- Notification Engine: Integration points for email and system notifications