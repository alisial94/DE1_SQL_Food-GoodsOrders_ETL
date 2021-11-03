# Delivery Center: Food & Goods orders in Brazil

## What is Delivery Center:
With its various operational hubs spread across Brazil, the Delivery Center is a platform that 
integrates retailers and marketplaces, creating a healthy ecosystem for sales of good (products) 
and food (food) in Brazilian retail. In, January to April 2021, the company recorded about 370,000 
orders from deliveries, stores, hubs.

## Task:
I was hired by Delivery Center to create a database for them to monitor progress of the company using 
data and make factual decisions for the future. Furthermore, I was also required to conduct preliminary 
analysis regarding some of the topics they were interested in. To complete this task I was provided with 
data collected by the company which can be downloaded from [Kaggle](https://www.kaggle.com/nosbielcs/brazilian-delivery-center). 
The data provided allows for viewing the data from multiple dimensions, such as orders, payments, 
deliveries, channels, stores and hubs provided.

To address the task above, my goal was to first create a central data warehouse using different datasets provided by 
Delivery Center and then create data marts for my analytics. The entire process of achieving the my goal has been 
explained in the throughout this document. Below you can find the description of the dataset.

The dataset included the following tables:

1.	Channels: This dataset has information about the sales channels (marketplaces) where the good and food of our retailers are sold.
2.	Orders: This dataset contains information about sales processed through the Delivery Center platform.
3.	Hubs: This dataset has information about Delivery Center hubs. Understand that the Hubs are the order distribution centers and that's where deliveries come from.
4.	Stores: This dataset has information about retailers. They use the Delivery Center Platform to sell their items (good and/or food) on marketplaces.
5.	Deliveries: This dataset has information about deliveries made by our partner deliveries.
6.	Drivers: This dataset has information about partner delivery partners. They stay at our hubs and every time an order is processed, they deliver it to consumers' homes.
7.	Payments: This dataset has information about payments made to the Delivery Center.

## Operational Layer:

To begin work it was essential to understand the dynamics and constraints of the dataset. At first, I performed some cleaning exercises for the data in Excel. While reviewing the data in excel, [CSV files](https://github.com/alisial94/Data-Engineering-1---SQL/tree/main/term_1/data) provided by the client, I noticed at that majority of the tables had blank fields which required treatment and it seemed logical to remove them at this stage to avoid complexity later. Also one of the main tables “orders” contained a lot of columns that I felt were unnecessary for the task at hand, therefore after consulting the client I decided to delete those as well. The columns that were removed are listed below:

Orders table: order_created_hour, order_created_minute, order_moment_accepted, order_moment_collected, order_moment_in_expedition, order_moment_delivering, order_moment_delivered, order_metric_collected_time, order_metric_production_time, order_metric_walking_time, order_metric_expediton_speed_time, order_metric_transit_time, order_metric_cycle_time

Before I begin loading the data I mapped out the existing relationships between the tables which acted as foundation for further analysis. I noticed that all tables were easily joinable because each table already had a primary and at least one foreign key. When loading the data I defined both the primary key and the foreign key wherever possible. For few tables I had to reverse engineer and add join manually. I started by creating the database/schema. Inside the database, individual tables were created for the tables mentioned above (dataset provided by Delivery Center). Operational layer was created using following [queries](https://github.com/alisial94/Data-Engineering-1---SQL/blob/main/term_1/op_layer_deliveries_brazil.sql).

 
<details>
<summary>Please click the arrow to open the code here.</summary>
<pre>-- OPERTAIONAL LAYER --

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
(store_id, hub_id, store_name, store_segment, store_plan_price, store_latitude, store_longitude);</pre>
</details>

All the relationships between the tables loaded in the database are 1:n (one-to-many) due to the nature of the business. For examples, there are multiple payments for one order, in the similar way there is one driver delivering multiple orders. To better understand the relationships please review the [EER Diagram](https://github.com/alisial94/Data-Engineering-1---SQL/blob/main/term_1/EER_Diagram.png) below.

![EER Diagram](https://github.com/alisial94/Data-Engineering-1---SQL/blob/main/term_1/EER_Diagram.png)

