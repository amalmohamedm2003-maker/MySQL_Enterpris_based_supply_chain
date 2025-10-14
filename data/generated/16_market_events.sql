-- ADD MARKET EVENTS
INSERT INTO market_events (event_type, event_name, start_date, end_date, severity) VALUES
('PANDEMIC', 'Global Supply Chain Disruption', '2022-03-01', '2022-09-01', 'SEVERE'),
('WEATHER', 'Hurricane Logistics Impact', '2022-08-15', '2022-08-30', 'HIGH'),
('POLITICAL', 'Trade Agreement Changes', '2023-01-01', '2023-03-01', 'MEDIUM'),
('ECONOMIC', 'Inflation Impact', '2023-05-01', NULL, 'HIGH'),
('TRANSPORT_STRIKE', 'Port Worker Strike', '2023-07-01', '2023-07-15', 'HIGH');

SELECT CONCAT('✅ ', COUNT(*), ' market events added') as status FROM market_events;