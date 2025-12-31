USE cart_abandonment;

/* Step 4: Demographics and their relation to cart abandonment */

#Abandonment by age buckets
SELECT CASE WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
       WHEN c.age BETWEEN 26 AND 33 THEN '26-33'
       WHEN c.age BETWEEN 34 AND 41 THEN '34-41'
       WHEN c.age BETWEEN 42 AND 49 THEN '42-49'
       WHEN c.age BETWEEN 50 AND 57 THEN '50-57'
       WHEN c.age BETWEEN 58 AND 64 THEN '58-64'
       END AS age_ranges,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c on f.customer_id = c.customer_id
GROUP BY age_ranges
ORDER BY age_ranges;

#Top categories the each age bucket is most abandoning
WITH age_range AS (
    SELECT
        CASE
            WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
            WHEN c.age BETWEEN 26 AND 33 THEN '26-33'
            WHEN c.age BETWEEN 34 AND 41 THEN '34-41'
            WHEN c.age BETWEEN 42 AND 49 THEN '42-49'
            WHEN c.age BETWEEN 50 AND 57 THEN '50-57'
            WHEN c.age BETWEEN 58 AND 64 THEN '58-64'
        END AS age_ranges,
        p.category,
        ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
    FROM facts f
    JOIN customers c ON f.customer_id = c.customer_id
    JOIN products p ON f.product_id = p.product_id
    GROUP BY age_ranges, p.category
),
categories_ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY age_ranges ORDER BY abandonment_rate DESC) AS rownum
    FROM age_range
)
SELECT age_ranges,
	   category,
       abandonment_rate
FROM categories_ranked
WHERE rownum = 1
ORDER BY age_ranges;

#Examining apparel products and abandonment rate by younger and middle generations
SELECT CASE WHEN c.age BETWEEN 18 AND 33 THEN '18-33'
       WHEN c.age BETWEEN 34 AND 49 THEN '34-49'
       END AS age_ranges,
       p.product_name,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f 
JOIN customers c on f.customer_id = c.customer_id
JOIN products p on f.product_id = p.product_id
WHERE p.category = 'Apparel' AND c.age <= 49
GROUP BY age_ranges, p.product_name
ORDER BY age_ranges ASC;

#Examining electronic products and abandonment rate by middle generation
SELECT CASE WHEN c.age BETWEEN 34 AND 49 THEN '34-49'
       END AS age_ranges,
       p.product_name,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f 
JOIN customers c on f.customer_id = c.customer_id
JOIN products p on f.product_id = p.product_id
WHERE p.category = 'Electronics' AND c.age <= 49 AND c.age >= 34
GROUP BY age_ranges, p.product_name
ORDER BY age_ranges ASC;

#Age buckets and their cart abandonment rates per month
SELECT DATE_FORMAT(d.dates, '%Y-%m') AS range_month,
	   CASE WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
       WHEN c.age BETWEEN 26 AND 33 THEN '26-33'
       WHEN c.age BETWEEN 34 AND 41 THEN '34-41'
       WHEN c.age BETWEEN 42 AND 49 THEN '42-49'
       WHEN c.age BETWEEN 50 AND 57 THEN '50-57'
       WHEN c.age BETWEEN 58 AND 64 THEN '58-64'
       END AS age_ranges,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f 
JOIN customers c ON f.customer_id = c.customer_id
JOIN products p ON f.product_id = p.product_id
JOIN dates d ON f.date_id = d.date_id
GROUP BY range_month, age_ranges
ORDER BY range_month, age_ranges ASC;

#Gender and cart abandonment
SELECT c.gender,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
GROUP BY c.gender
ORDER BY abandonment_rate DESC;

#Categories genders are abandoning 
SELECT c.gender,
       p.category,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f 
JOIN customers c on f.customer_id = c.customer_id
JOIN products p on f.product_id = p.product_id
GROUP BY c.gender, p.category
ORDER BY c.gender, p.category ASC;

#Age ranges, gender, and cart abandonment
SELECT CASE WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
       WHEN c.age BETWEEN 26 AND 33 THEN '26-33'
       WHEN c.age BETWEEN 34 AND 41 THEN '34-41'
       WHEN c.age BETWEEN 42 AND 49 THEN '42-49'
       WHEN c.age BETWEEN 50 AND 57 THEN '50-57'
       WHEN c.age BETWEEN 58 AND 64 THEN '58-64'
       END AS age_ranges,
       c.gender,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f  
JOIN customers c on f.customer_id = c.customer_id
GROUP BY age_ranges, c.gender
ORDER BY age_ranges, c.gender DESC;

#Cities and cart abandonment
SELECT c.city,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
GROUP BY c.city;

#Cities, gender, and cart abandonment
SELECT CASE WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
       WHEN c.age BETWEEN 26 AND 33 THEN '26-33'
       WHEN c.age BETWEEN 34 AND 41 THEN '34-41'
       WHEN c.age BETWEEN 42 AND 49 THEN '42-49'
       WHEN c.age BETWEEN 50 AND 57 THEN '50-57'
       WHEN c.age BETWEEN 58 AND 64 THEN '58-64'
       END AS age_ranges,
	   c.city,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
GROUP BY age_ranges, c.city
ORDER BY age_ranges, c.city;

#Cities and middle generation and their abandonment rate for electronic products
SELECT CASE WHEN c.age BETWEEN 34 AND 49 THEN '34-49'
       END as age_ranges,
       c.city,
       p.category,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
JOIN products p ON f.product_id = p.product_id
WHERE c.age <= 49 AND c.age >= 34 AND p.category = 'Electronics'
GROUP BY age_ranges, c.city, p.category
ORDER BY age_ranges, c.city DESC;

#Cities and younger/middle generations and their abandonment rate for apparel products
SELECT CASE WHEN c.age BETWEEN 18 AND 33 THEN '18-33'
       WHEN c.age BETWEEN 34 AND 49 THEN '34-49'
       END as age_ranges,
       c.city,
       p.category,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
JOIN products p ON f.product_id = p.product_id
WHERE c.age <= 49  AND p.category = 'Apparel'
GROUP BY age_ranges, c.city, p.category
ORDER BY age_ranges, c.city DESC;

#First time vs returning customers and cart abandonment
WITH customer_types AS (
	SELECT customer_id,
    date_id,
    abandonment_time,
    CASE WHEN f.date_id = (SELECT MIN(f1.date_id) FROM facts f1 WHERE f1.customer_id = f.customer_id) THEN 'New' ELSE 'Returning' END AS type_of_customer
    FROM facts f
)
SELECT type_of_customer, 
	   COUNT(*) as total_sessions, 
	   ROUND(SUM(CASE WHEN abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM customer_types
GROUP BY type_of_customer;

#Age group, devices, and cart abandonment
SELECT CASE WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
       WHEN c.age BETWEEN 26 AND 33 THEN '26-33'
       WHEN c.age BETWEEN 34 AND 41 THEN '34-41'
       WHEN c.age BETWEEN 42 AND 49 THEN '42-49'
       WHEN c.age BETWEEN 50 AND 57 THEN '50-57'
       WHEN c.age BETWEEN 58 AND 64 THEN '58-64'
       END AS age_ranges,
       d.device_type,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f 
JOIN customers c ON f.customer_id = c.customer_id
JOIN devices d ON f.device_id = d.device_id
GROUP BY age_ranges, d.device_type
ORDER BY age_ranges ASC;