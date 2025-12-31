USE cart_abandonment;

/* Step 2: Analyzing the relation between cart behavior and cart abandonment */

#Compare revenue made to lost revenue
SELECT ROUND(SUM(p.price * f.quantity), 2) as potential_revenue,
	   ROUND(SUM(CASE WHEN f.abandonment_time IS NULL THEN p.price * f.quantity ELSE 0 END), 2) AS revenue,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) AS lost_revenue,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END) / SUM(p.price * f.quantity) * 100, 2) AS revenue_lost_percent
FROM facts f
JOIN products p ON f.product_id = p.product_id;

#Find average cart value for both abandoned and completed carts
SELECT 'Completed' as cart_status,
       ROUND(AVG(p.price * f.quantity), 2) as avg_value
FROM facts f
JOIN products p ON f.product_id = p.product_id
WHERE f.abandonment_time IS NULL
UNION ALL
SELECT 'Abandoned' as cart_status,
       ROUND(AVG(p.price * f.quantity), 2) as avg_value
FROM facts f
JOIN products p ON f.product_id = p.product_id
WHERE f.abandonment_time IS NOT NULL;

#Cart value bucketing and comparing average cart values
SELECT CASE
	   WHEN p.price * f.quantity < 500 THEN '0-500'
       WHEN p.price * f.quantity BETWEEN 500 AND 1000 THEN '500-1000'
       WHEN p.price * f.quantity BETWEEN 1000 AND 2000 THEN '1000-2000'
       WHEN p.price * f.quantity BETWEEN 2000 AND 3000 THEN '2000-3000'
       WHEN p.price * f.quantity BETWEEN 3000 AND 4000 THEN '3000-4000'
       WHEN p.price * f.quantity BETWEEN 4000 AND 5000 THEN '4000-5000'
       WHEN p.price * f.quantity > 5000 THEN '5000+'
	   END AS cart_buckets,
	   ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate,
	   ROUND(AVG(CASE WHEN f.abandonment_time IS NULL THEN p.price * f.quantity END), 2) as avg_cart_value_completed,
	   ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_cart_value_abandoned
FROM facts f
JOIN products p ON f.product_id = p.product_id
GROUP BY cart_buckets
ORDER BY MIN(p.price * f.quantity);

#Cart value analysis by quantity
SELECT f.quantity,
       ROUND(AVG(p.price * f.quantity), 2) as avg_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
GROUP BY f.quantity
ORDER BY f.quantity;

#Cart behavior analysis by day of the week
SELECT DAYOFWEEK(d.dates) as day_num,
	   DAYNAME(d.dates) as day_of_week,
       COUNT(*) as total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) as abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) as completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) as revenue_lost
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN dates d ON f.date_id = d.date_id
GROUP BY day_of_week, day_num
ORDER BY day_num;

#Cart behavior analysis by month
SELECT DATE_FORMAT(d.dates, '%Y-%m') as month,
       COUNT(*) as total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) as abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) as completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) as revenue_lost
FROM facts f
JOIN dates d ON f.date_id = d.date_id
JOIN products p ON f.product_id = p.product_id
WHERE DATE_FORMAT(d.dates, '%Y') = '2023'
GROUP BY month
ORDER BY month;

#Breaking May 2023 down by category
SELECT p.category,
       COUNT(*) AS total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) AS abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) AS completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) AS avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) AS revenue_lost
FROM facts f
JOIN dates d ON f.date_id = d.date_id
JOIN products p ON f.product_id = p.product_id
WHERE DATE_FORMAT(d.dates, '%Y-%m') = '2023-05'
GROUP BY p.category
ORDER BY abandonment_rate DESC;

#Breaking Sports & Outdoors in May 2023 down by product
SELECT p.product_name,
       COUNT(*) AS total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) AS abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) AS completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) AS avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) AS revenue_lost
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN dates d ON f.date_id = d.date_id
WHERE p.category = 'Sports & Outdoors'
  AND DATE_FORMAT(d.dates, '%Y-%m') = '2023-05'
GROUP BY p.product_name
ORDER BY abandonment_rate DESC;

#Weekday vs weekend analysis
SELECT CASE WHEN DAYOFWEEK(d.dates) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END as day_type,
       COUNT(*) as total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) as abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) as completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) as revenue_lost
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN dates d ON f.date_id = d.date_id
GROUP BY day_type;

#Day of month analysis
SELECT DAY(d.dates) as day_of_month,
       COUNT(*) as total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) as abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) as completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) as revenue_lost
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN dates d ON f.date_id = d.date_id
GROUP BY day_of_month
ORDER BY day_of_month;