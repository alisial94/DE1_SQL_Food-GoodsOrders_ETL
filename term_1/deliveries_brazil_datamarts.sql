USE  deliveries_brazil;


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
       
       
      
    
    
