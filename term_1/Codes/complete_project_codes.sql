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

#######################################

-- Creating the Analytical Layer (date warehouse) -- 

DROP PROCEDURE IF EXISTS CreateSalesDatawarehouse_Deliveries_Brazil;

DELIMITER //

CREATE PROCEDURE CreateSalesDatawarehouse_Deliveries_Brazil()
BEGIN

DROP TABLE IF EXISTS sales_details;

		CREATE TABLE sales_details AS
					select 
					o.order_id,
					o.order_amount,
					o.order_status,
					o.order_delivery_fee,
					o.order_delivery_cost,
                    order_delivery_fee - order_delivery_cost AS delivery_profit,
					o.order_created_day,
					o.order_created_month,
					s.store_id,
					s.store_name,
					s.store_segment,
					c.channel_id,
					c.channel_name,
					c.channel_type,
					p.payment_id,
					p.payment_amount,
					p.payment_status,
					d.delivery_id,
					d.delivery_order_id,
					d.delivery_status,
					dr.driver_id,
					dr.driver_modal,
					dr.driver_type,
                    h.hub_name,
                    h.hub_city,
                    h.hub_state
					FROM orders o
					JOIN stores s
					USING (store_id)
					JOIN channels c
					USING (channel_id)
					JOIN payments p
					USING (payment_order_id)
					JOIN deliveries d
					USING (delivery_order_id)
					JOIN drivers dr
					USING (driver_id)
                    JOIN hubs h
                    USING (hub_id);

END //
DELIMITER ;

CALL CreateSalesDatawarehouse_Deliveries_Brazil();


########################################################


-- CREATING VIEW 1 - Monthly Sales Report By Store Segments --

DROP VIEW IF EXISTS `Monthly_Sales_Report_By_Store_Segments`;

CREATE VIEW `Monthly_Sales_Report_By_Store_Segments` AS
SELECT 
		order_created_day AS day,
        order_created_month AS month,
        store_segment,
        ROUND((SELECT (SUM(payment_amount)/(COUNT(DISTINCT(order_id))))),2) AS price_per_unit,
        COUNT(DISTINCT(order_id)) AS total_orders,
        SUM(payment_amount) AS total_sales
FROM sales_details
GROUP BY month, day, store_segment;


DROP PROCEDURE IF EXISTS Montly_Sales_Report;

DELIMITER ??

		CREATE PROCEDURE Montly_Sales_Report(
			sales_month VARCHAR(15)
		)
		BEGIN

			SELECT * FROM Monthly_Sales_Report_By_Store_Segments
			WHERE month = sales_month;

END ??
DELIMITER ;

CALL Montly_Sales_Report('March');

-- END --


-- CREATING VIEW 2 - Top 10 Stores by Share Of Total Sales -- 

DROP VIEW IF EXISTS `Top_10_Stores_by_TotalSales`;

CREATE VIEW `Top_10_Stores_by_TotalSales` AS
SELECT 
		store_id AS ID,
        store_name AS Name,
        hub_name AS Hub,
        hub_city AS City,
        hub_state AS State,
        SUM(payment_amount) AS Total_Sales,
		CONCAT(
				CAST(SUM(payment_amount)/(SELECT SUM(payment_amount) 
                FROM sales_details)*100 AS DECIMAL (14,2)),' %') 
                AS Share_of_Total_Sales
FROM sales_details
GROUP BY ID, Name, Hub, City, State
ORDER BY Total_Sales DESC LIMIT 10;
        

-- END --


-- CREATING VIEW 3 - Top 10 Delivery Drivers -- 


DROP VIEW IF EXISTS `Top_10_Delivery_Drivers`;

CREATE VIEW `Top_10_Delivery_Drivers` AS
SELECT 
		driver_id AS ID,
        driver_modal AS Vehicle,
        driver_type AS Type_of_Service,
        COUNT(DISTINCT(order_id)) AS Total_Orders,
		SUM(order_delivery_cost-order_delivery_fee) AS Total_Driver_Cost,
        ROUND((SELECT (SUM(order_delivery_cost-order_delivery_fee)/(COUNT(order_id)))),2) AS avg_price_per_delivery
FROM sales_details
GROUP BY ID, Vehicle , Type_of_Service
ORDER BY Total_Orders DESC LIMIT 10;


-- END --


-- CREATING VIEW 4 - Performance of Channels by Order & Share of Sales -- 

DROP VIEW IF EXISTS `Performance_of_Channels_by_Order&ShareofSales`;

CREATE VIEW `Performance_of_Channels_by_Order&ShareofSales` AS
SELECT 
	   channel_id AS ID,
       channel_name AS Name,
       channel_type AS Type_of_Channel,
       COUNT(DISTINCT(order_id)) AS Total_Orders,
       CONCAT(
				CAST(SUM(payment_amount)/(SELECT SUM(payment_amount) 
                FROM sales_details)*100 AS DECIMAL (14,2)),' %') 
                AS Share_of_Total_Sales
FROM sales_details
GROUP BY ID, Name , Type_of_Channel
ORDER BY Total_Orders DESC;

-- END --
