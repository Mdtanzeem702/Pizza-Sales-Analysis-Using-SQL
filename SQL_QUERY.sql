create database pizaa_data;
USE pizaa_data;

#--Q1: The total number of order place

SELECT COUNT(*) AS total_orders
FROM orders;

#--Q2: The total revenue generated from pizza sales

SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id;

#-- Q3: The highest priced pizza.

SELECT pizza_id, size , price
FROM pizza
ORDER BY price DESC
LIMIT 1;

#-- Q4: The most common pizza size ordered.

SELECT pizza_id, COUNT(*) AS order_count
FROM order_details
GROUP BY pizza_id
ORDER BY order_count DESC
LIMIT 1;

#-- Q5: The top 5 most ordered pizza types along their quantities.

SELECT p.name AS pizza_name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza_types p ON od.pizza_id = pizza_id
GROUP BY p.name
ORDER BY total_quantity DESC
LIMIT 5;

#-- Q6: The quantity of each pizza categories ordered.

SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

#-- Q7: The distribution of orders by hours of the day.
SELECT EXTRACT(HOUR FROM time) AS order_hour, COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

#-- Q8: The category-wise distribution of pizzas.

SELECT pt.category, COUNT(*) AS pizza_count
FROM pizza p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY pizza_count DESC;

#-- Q9: The average number of pizzas ordered per day.	

SELECT AVG(daily_pizzas) AS average_pizzas_per_day
FROM (
    SELECT date, SUM(od.quantity) AS daily_pizzas
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY date
) daily_totals;

#-- Q10: Top 3 most ordered pizza type base on revenue.

SELECT p.pizza_type_id AS pizza_name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizza p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type_id
ORDER BY total_revenue DESC
LIMIT 3;


#-- Q11: The percentage contribution of each pizza type to revenue.	

WITH pizza_revenue AS (
    SELECT p.pizza_type_id AS pizza_name, SUM(od.quantity * p.price) AS total_revenue
    FROM order_details od
    JOIN pizza p ON od.pizza_id = p.pizza_id
    GROUP BY p.pizza_type_id
),
total_revenue AS (
    SELECT SUM(total_revenue) AS overall_total_revenue
    FROM pizza_revenue
)
SELECT 
    pr.pizza_name, 
    pr.total_revenue,
    (pr.total_revenue / tr.overall_total_revenue) * 100 AS percentage_contribution
FROM 
    pizza_revenue pr,
    total_revenue tr
ORDER BY 
    percentage_contribution DESC;


#-- Q12: The cumulative revenue generated over time.

SELECT 
    o.date,
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM 
    orders o 
JOIN 
    order_details od   ON o.order_id =  od.order_id
    JOIN 
        pizza p ON p.pizza_type_id = p.pizza_type_id
GROUP BY 
    o.date
ORDER BY 
    o.date;
    
    
    

#-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category.

WITH pizza_revenue AS (
    SELECT 
        pt.category,
        p.pizza_id,
        pt.name AS pizza_name,
        SUM(od.quantity * p.price) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) As top_3_rank
    FROM 
        order_details od
    JOIN 
        pizza p ON od.pizza_id = p.pizza_id
    JOIN 
        pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY 
        pt.category, p.pizza_id, pt.name
)
SELECT 
    category,
    pizza_name,
    total_revenue
FROM 
    pizza_revenue
WHERE 
    top_3_rank <= 3
ORDER BY 
    category, total_revenue DESC;




