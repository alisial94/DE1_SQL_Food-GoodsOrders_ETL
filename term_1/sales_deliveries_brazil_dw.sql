-- Creating the Analytical Layer (data warehouse) --


USE deliveries_brazil;


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