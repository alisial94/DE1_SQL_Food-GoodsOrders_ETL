# Delivery Center: Food & Goods orders in Brazil

## What is Delivery Center:
With its various operational hubs spread across Brazil, the Delivery Center is a platform that integrates retailers 
and marketplaces, creating a healthy ecosystem for sales of good (products) and food (food) in Brazilian retail. 
In, January to April 2021, the company recorded about 370,000 orders from deliveries, stores, hubs. 

## Task:
I was hired by Delivery Center to create a database to monitor progress of the company using data and make factual 
decisions for the future. Furthermore, I was also required to conduct a preliminary analysis regarding some of the 
topics they were interested in. To complete this task,  I was provided with data collected by the company which can 
be downloaded from [Kaggle](https://www.kaggle.com/nosbielcs/brazilian-delivery-center). The data provided allows 
for viewing the data from multiple dimensions, such as orders, payments, deliveries, channels, stores and hubs provided. 

To address the task above, my goal was to first create a central data warehouse using different datasets provided by 
the Delivery Center and then create data marts for my analytics. The entire process of achieving my goal has been explained 
throughout this document. Below you can find the description of the dataset.

The dataset included the following tables:

1.	Channels: This dataset has information about the sales channels (marketplaces) where the goods and food of our retailers are sold.
2.	Orders: This dataset contains information about sales processed through the Delivery Center platform.
3.	Hubs: This dataset has information about Delivery Center hubs. Understand that the Hubs are the order distribution centers and that's where deliveries come from.
4.	Stores: This dataset has information about retailers. They use the Delivery Center Platform to sell their items (good and/or food) on marketplaces.
5.	Deliveries: This dataset has information about deliveries made by our partner deliveries.
6.	Drivers: This dataset has information about partner delivery partners. They stay at our hubs and every time an order is processed, they deliver it to consumers' homes.
7.	Payments: This dataset has information about payments made to the Delivery Center.


## Operational Layer:

To begin work it was essential to understand the dynamics and constraints of the dataset. At first, I performed some 
cleaning exercises for the data in Excel. While reviewing the data in excel, [CSV files](url) provided by the client, I 
noticed that majority of the tables had blank fields which required treatment and it seemed logical to remove them at 
this stage to avoid complexity later. Also, one of the main tables  “orders” contained a lot of columns that I felt were 
unnecessary for the task at hand, therefore after consulting the client I decided to delete those as well. The columns that 
were removed are listed below:

Orders table: 
order_created_hour, order_created_minute, order_moment_accepted, order_moment_collected, order_moment_in_expedition, 
order_moment_delivering, order_moment_delivered, order_metric_collected_time, order_metric_production_time, order_metric_walking_time, 
order_metric_expediton_speed_time, order_metric_transit_time, order_metric_cycle_time

Before I began loading the data, I mapped out the existing relationships between the tables which acted as a foundation 
for further analysis. I noticed that all tables were easily joinable because each table already had a primary key and at 
least one foreign key. When loading the data, I defined both the primary key and the foreign key wherever possible. 
For a few tables, I had to reverse engineer and add join manually. I started by creating the database/schema. Inside the database, 
individual tables were created for the tables mentioned above (dataset provided by Delivery Center). Operational layer was created 
using following queries.
Please click the arrow to open the code here.

All the relationships between the tables loaded in the database are 1:n (one-to-many) due to the nature of the business. For examples, there are multiple payments for one order, in the similar way there is one driver delivering multiple orders. To better understand the relationships please review the EER Diagram below.



