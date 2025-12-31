USE cart_abandonment;
/* Step 1: Analyzing the relation between card abandonment and products */

/* Basic dataset facts */
#Total distinct items sold on website
SELECT COUNT(DISTINCT product_id) as total_items
FROM products;

#Total products sold on website by category
SELECT category, 
	   COUNT(*) as total_products
FROM products
GROUP BY category;

#Total items added to cart, checked out, and abandoned (incl. and not incl. quantity)
SELECT COUNT(*) as total_added,
	   SUM(CASE WHEN abandonment_time IS NULL THEN 1 ELSE 0 END) as total_completed,
       SUM(CASE WHEN abandonment_time IS NOT NULL THEN 1 ELSE 0 END) as total_abandoned,
       SUM(quantity) as total_added_qty,
       SUM(CASE WHEN abandonment_time IS NULL THEN quantity ELSE 0 END) as total_completed_qty, 
	   SUM(CASE WHEN abandonment_time IS NOT NULL THEN quantity ELSE 0 END) as total_abandoned_qty
FROM facts;

#Overall abandonment rate
SELECT ROUND(SUM(CASE WHEN abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate
FROM facts f;

#Products ranked from most to least expensive
SELECT product_name, 
	   category, 
       price
FROM products
ORDER BY price DESC;

#Amount of products per category above 250, 500, 1000
SELECT category, 
	   SUM(CASE WHEN price > 250 THEN 1 ELSE 0 END) as above_250,
       SUM(CASE WHEN price > 500 THEN 1 ELSE 0 END) as above_500,
       SUM(CASE WHEN price > 1000 THEN 1 ELSE 0 END) as above_1000
FROM products
GROUP BY category;

#Most common products added to cart, checked out, and abandoned (not incl. quantity)
SELECT p.product_name, 
       p.category, 
       p.price, 
       COUNT(*) as total_sessions,
       SUM(CASE WHEN f.abandonment_time IS NULL THEN 1 ELSE 0 END) AS total_checkout,
       SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) AS total_abandoned,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
GROUP BY p.product_name, p.category, p.price
ORDER BY abandonment_rate DESC;

#Minimum qty added, maximum, average, and difference (abandon - checkout) for checkout vs abandonment
WITH checkout_qty AS (
	SELECT product_id,
           MIN(quantity) AS min_checkout,
		   MAX(quantity) AS max_checkout,
           ROUND(AVG(quantity), 2) AS avg_checkout
	FROM facts
    WHERE abandonment_time IS NULL
    GROUP BY product_id
),
abandon_qty AS (
	SELECT product_id,
		   MIN(quantity) AS min_abandon,
           MAX(quantity) AS max_abandon,
           ROUND(AVG(quantity), 2) AS avg_abandon
	FROM facts
    WHERE abandonment_time IS NOT NULL
    GROUP BY product_id
)
SELECT p.product_name, p.category, p.price, c.min_checkout, c.max_checkout, c.avg_checkout, a.min_abandon, a.max_abandon, a.avg_abandon, ROUND(a.avg_abandon - c.avg_checkout, 2) AS avg_qty_difference
FROM products p
LEFT JOIN checkout_qty c ON p.product_id = c.product_id
LEFT JOIN abandon_qty a ON p.product_id = a.product_id
ORDER BY avg_qty_difference DESC;

#Revenue lost per product from cart abandonment
SELECT p.product_name, 
       p.category, 
       p.price, 
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate,
       ROUND(p.price * SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN f.quantity ELSE 0 END), 2) AS lost_revenue
FROM facts f
JOIN products p ON f.product_id = p.product_id
GROUP BY p.product_name, p.category, p.price
ORDER BY lost_revenue DESC;

#Electronics category quantity analysis
SELECT p.product_name,
       f.quantity,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
WHERE p.category = 'Electronics'
GROUP BY p.product_name, f.quantity
ORDER BY 1 DESC, 2 DESC;

#Doing the same for Dress
SELECT f.quantity AS dress_qty,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
WHERE p.product_name = 'Dress'
GROUP BY f.quantity
ORDER BY f.quantity;

#Doing the same for Jacket
SELECT f.quantity AS jacket_qty,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
WHERE p.product_name = 'Jacket'
GROUP BY f.quantity
ORDER BY f.quantity;