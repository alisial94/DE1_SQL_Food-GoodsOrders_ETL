-- OPERTAIONAL LAYER --

 -- Creating Schema --
 
DROP SCHEMA IF EXISTS deliveries_brazil;

CREATE SCHEMA deliveries_brazil;

USE deliveries_brazil;



 -- Checking the path of the secure_file_priv to make sure it's not null and turning on the local_infile option --

SHOW VARIABLES LIKE "secure_file_priv";
SET GLOBAL local_infile= 'on';
SHOW VARIABLES LIKE "local_infile";



-- Creating Table 1 - Channels --

DROP TABLE IF EXISTS channels;

CREATE TABLE channels(
channel_id INTEGER,
channel_name VARCHAR(255),
channel_type VARCHAR(255),
PRIMARY KEY (channel_id)
);

TRUNCATE channels;

LOAD DATA INFILE '/tmp/channels.csv'
INTO TABLE channels
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(channel_id, channel_name, channel_type);


-- Creating Table 2 - Drivers --

DROP TABLE IF EXISTS drivers;

CREATE TABLE drivers(
driver_id INT,
driver_modal VARCHAR(255),
driver_type VARCHAR(255),
PRIMARY KEY (driver_id)
);

TRUNCATE drivers;

LOAD DATA INFILE '/tmp/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(driver_id, driver_modal, driver_type);


-- Creating Table 3 - Deliveries --

DROP TABLE IF EXISTS deliveries;

CREATE TABLE deliveries(
delivery_id INT,
delivery_order_id INT,
driver_id INT,
delivery_distance_meters INT,
delivery_status VARCHAR(255),
PRIMARY KEY (delivery_id),
FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

TRUNCATE deliveries;

LOAD DATA INFILE '/tmp/deliveries.csv'
INTO TABLE deliveries
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(delivery_id, delivery_order_id, driver_id, delivery_distance_meters, delivery_status);


-- Creating Table 4 - Orders --

DROP TABLE IF EXISTS orders;

CREATE TABLE orders(
order_id INT,
store_id INT,
channel_id INT,
payment_order_id INT,
delivery_order_id INT,
order_status VARCHAR(255),
order_amount INT,
order_delivery_fee INT,
order_delivery_cost INT,
order_created_day INT,
order_created_month VARCHAR(100),
order_created_year INT,
order_moment_created DATETIME,
PRIMARY KEY (order_id), 
KEY payments(payment_order_id),
KEY deliveries(delivery_order_id),
constraint orders_ibfk_1 FOREIGN KEY(channel_id) REFERENCES channels(channel_id),
KEY stores(store_id)
);

TRUNCATE orders;

LOAD DATA INFILE '/tmp/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(order_id, store_id, channel_id, payment_order_id, delivery_order_id, 
order_status, order_amount, order_delivery_fee, order_delivery_cost, 
order_created_day, order_created_month, order_created_year, 
order_moment_created);



-- Creating Table 5 - Payments --

DROP TABLE IF EXISTS payments;

CREATE TABLE payments(
payment_id INT,
payment_order_id INT,
payment_amount INT,
payment_fee INT,
payment_method VARCHAR(255),
payment_status VARCHAR(50),
PRIMARY KEY (payment_id)
);

TRUNCATE payments;

LOAD DATA INFILE '/tmp/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(payment_id, payment_order_id, payment_amount, payment_fee, payment_method, payment_status);


-- Creating Table 6 - Hubs --

DROP TABLE IF EXISTS hubs;

CREATE TABLE hubs(
hub_id INT,
hub_name VARCHAR(255),
hub_city VARCHAR(255),
hub_state VARCHAR(30),
hub_latitude INT,
hub_longitude INT,
PRIMARY KEY (hub_id)
);

TRUNCATE hubs;

LOAD DATA INFILE '/tmp/hubs.csv'
INTO TABLE hubs
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(hub_id, hub_name, hub_city, hub_state, hub_latitude, hub_longitude);


-- Creating Table 7 - Stores --

DROP TABLE IF EXISTS stores;

CREATE TABLE stores(
store_id INT,
hub_id INT,
store_name VARCHAR(255),
store_segment VARCHAR(255),
store_plan_price INT,
store_latitude INT,
store_longitude INT,
PRIMARY KEY (store_id), 
FOREIGN KEY (hub_id) REFERENCES hubs(hub_id)
);

TRUNCATE stores;

LOAD DATA INFILE '/tmp/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(store_id, hub_id, store_name, store_segment, store_plan_price, store_latitude, store_longitude);