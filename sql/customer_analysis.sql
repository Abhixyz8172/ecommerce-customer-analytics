-- E-Commerce Customer Analytics | PostgreSQL
-- Import data/ecommerce_orders.csv as ecommerce_orders.
-- Completed orders only are used for revenue KPIs.

SELECT SUM(order_value) AS completed_revenue,
       COUNT(DISTINCT order_id) AS completed_orders,
       COUNT(DISTINCT customer_id) AS purchasing_customers,
       ROUND(SUM(order_value) / NULLIF(COUNT(DISTINCT order_id),0), 2) AS average_order_value
FROM ecommerce_orders WHERE order_status = 'Completed';

SELECT DATE_TRUNC('month', order_date::date) AS month,
       SUM(order_value) AS revenue, COUNT(DISTINCT order_id) AS orders
FROM ecommerce_orders WHERE order_status = 'Completed'
GROUP BY 1 ORDER BY 1;

SELECT category, SUM(order_value) AS revenue,
       COUNT(DISTINCT order_id) AS orders
FROM ecommerce_orders WHERE order_status = 'Completed'
GROUP BY category ORDER BY revenue DESC;

SELECT customer_id, COUNT(DISTINCT order_id) AS order_count,
       SUM(order_value) AS customer_revenue
FROM ecommerce_orders WHERE order_status = 'Completed'
GROUP BY customer_id HAVING COUNT(DISTINCT order_id) > 1
ORDER BY customer_revenue DESC;

WITH completed AS (
 SELECT * FROM ecommerce_orders WHERE order_status = 'Completed'
), rfm AS (
 SELECT customer_id, MAX(order_date::date) AS last_order_date,
        COUNT(DISTINCT order_id) AS frequency, SUM(order_value) AS monetary
 FROM completed GROUP BY customer_id
), anchor AS (
 SELECT MAX(order_date::date) AS snapshot_date FROM completed
)
SELECT r.customer_id, (a.snapshot_date-r.last_order_date) AS recency_days,
       r.frequency, r.monetary
FROM rfm r CROSS JOIN anchor a ORDER BY monetary DESC;

SELECT order_status, COUNT(*) AS order_lines, SUM(order_value) AS order_value
FROM ecommerce_orders GROUP BY order_status ORDER BY order_lines DESC;
