USE cart_abandonment;

/* Step 3: Devices and their relation to cart abandonment */

#Abandonment rate by device type
SELECT d.device_type,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.device_type
ORDER BY abandonment_rate DESC;

#Abandonment rate by OS
SELECT d.os,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.os
ORDER BY abandonment_rate DESC;

#Abandonment rate by device running a specific OS
SELECT d.device_type,
       d.os,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.device_type, d.os
ORDER BY abandonment_rate DESC;

#Device type price buckets analysis
SELECT d.device_type,
       CASE WHEN p.price < 250 THEN '$0-$250'
	   WHEN p.price BETWEEN 250 AND 500 THEN '$250-$500'
	   WHEN p.price BETWEEN 500 AND 1000 THEN '$500-$1000'
	   ELSE '$1000+'
       END as price_range,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.device_type, price_range
ORDER BY d.device_type, 
		 CASE price_range WHEN '$0-$250' THEN 1
         WHEN '$250-$500' THEN 2
         WHEN '$500-$1000' THEN 3
         WHEN '$1000+' THEN 4 END;

#Device type and quantity
SELECT d.device_type,
       f.quantity,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.device_type, f.quantity
ORDER BY d.device_type, f.quantity;

#Device type and month
SELECT DATE_FORMAT(dt.dates, '%Y-%m') as month,
	   de.device_type,
       COUNT(*) as total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) as abandoned,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) as completed,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate,
       ROUND(AVG(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity END), 2) as avg_abandoned_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) as revenue_lost
FROM facts f
JOIN dates dt ON f.date_id = dt.date_id
JOIN devices de ON f.device_id = de.device_id
JOIN products p ON f.product_id = p.product_id
WHERE DATE_FORMAT(dt.dates, '%Y') = '2023'
GROUP BY month, de.device_type
ORDER BY month;
         
#May specific device cart abandonment analysis
SELECT de.device_type,
       de.os,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN devices de ON f.device_id = de.device_id
JOIN dates dt ON f.date_id = dt.date_id
WHERE MONTH(dt.dates) = 5
GROUP BY de.device_type, de.os
ORDER BY abandonment_rate DESC;