-- 1. Retrieve the total number of orders placed.

SELECT count(order_id) as total_order FROM ORDERS;


-- 2. Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS Total_Sale
FROM order_details JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id; 
    
    
-- 3. Identify the highest-priced pizza.

SELECT p.pizza_id, pt.name, p.price
FROM pizzas AS p
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;
    
    
-- 4. Identify the most common pizza size ordered.
    
 select pizzas.size, count(order_details.order_details_id) as order_count 
 from pizzas JOIN order_details 
 on pizzas.pizza_id = order_details.pizza_id
 group by pizzas.size 
 order by order_count desc;
 
 
-- 5. List the top 5 most ordered pizza types along with their quantities. 

select pizza_types.name, sum(order_details.quantity)  as order_count
FROM pizzas JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id 
JOIN pizza_types 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
group by pizza_types.name
order by order_count desc limit 5;


-- 7. Determine the distribution of orders by hour of the day.

select hour(order_time) as hour , count(order_id) as orders from orders
group by hour(order_time)  ; 



-- 8. Join relevant tables to find the category-wise orders of pizzas.

select pizza_types.category, count(order_details.order_id) as Orders
from pizza_types Join pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY count(order_details.order_id);



-- 9. Group the orders by date and calculate the total number of pizzas ordered per day.


SELECT (orders.order_date) as DATE , sum(order_details.quantity) as Total_Number_Pizza_per_day
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id 
GROUP BY (orders.order_date);


-- 10. Group the orders by date and calculate the avg number of pizzas ordered per day.

SELECT AVG(Total_Number_Pizza_per_day) FROM 
 (SELECT orders.order_date , sum(order_details.quantity) as Total_Number_Pizza_per_day
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id 
GROUP BY orders.order_date) as order_quantity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name , sum(pizzas.price * order_details.quantity) as TOTAL_COST_PER_ORDER
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id ;
group by pizza_types.name
ORDER BY TOTAL_COST_PER_ORDER DESC LIMIT 3;



-- 11. Calculate the percentage contribution of each pizza type to total revenue.
-- revenue /  total revenue * 100 = percentage

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
    
    
-- 12. Analyze the cumulative revenue generated over time.

SELECT order_date, sum(PER_DAY_SALE) OVER(ORDER BY order_date) AS CUM_REVENUE 
FROM 	
	(SELECT orders.order_date, ROUND(SUM(order_details.quantity * pizzas.price),0) AS PER_DAY_SALE
		FROM order_details 
			JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
			JOIN 
		orders ON order_details.order_id = orders.order_id
			GROUP BY orders.order_date) AS SALES ;
    
    
    
    
-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.


SELECT name, category, revenue , ranking 
FROM
(SELECT name, category, revenue, RANK() OVER (PARTITION BY category order by revenue DESC ) AS RANKING
FROM
(SELECT 
    pizza_types.name,
    pizza_types.category, 
    SUM(order_details.quantity * pizzas.price) AS REVENUE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name , pizza_types.category) AS a) AS b 
where RANKING <= 3 ;  


