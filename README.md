# E-Commerce Cart Abandonment Analysis

**By Kyle Czerniawski**

**Dataset used for analysis:** [Kaggle Dataset](https://www.kaggle.com/datasets/dynamo21/cart-abandonment/data)

This repository contains my analysis work done on the dataset linked above. It includes various SQL files (one containing construction of the tables, the others containing analysis pertaining to a specific segment), all datasets used, and a Tableau file containing the dashboard (along with pictures of both the overview dashboard and the demographic-specific dashboard).

## 1. Project Overview

Cart abandonment happens when a potential customer exits a website after filling their cart with product(s). This could occur by the customer due to many different reasons, such as a UI issue, unexpected costs (shipping or taxes), negative reviews, lack of payment options, overly complicated checkout process, requiring an account to check out, and much more. Factors that are out of a business's control could even have an impact on abandonment rates as well, such as a customer not having enough money at the time, technical issues, real-world distractions, or even just a customer being indecisive. Overall, there are many reasons why a customer could abandon their cart. 

To investigate this issue, businesses tend to look at many different factors, such as the customer's device type, demographic, products of interest, time of day, and much more. A business will also evaluate the cart abandonment rate, which is the percentage of users who create a cart and leave the website without checking out. This formula is measured by a simple function:

Cart abandonment rate = (Total number of carts abandoned / Total number of carts created) * 100.0

An average cart abandonment rate should be around 70% on most websites. As mentioned before, this percentage seems significantly high, but is quite common with e-commerce websites. This average can fluctuate anywhere between 60-80% with some outliers, depending on the industry the business is in, with some higher cost businesses (such as travel and luxury) seeing a higher abandonment rate than lower cost businesses (like fast fashion and retail).

## 2. Objective

I posed a couple of questions to be answered:

- **What are some key areas of concern found throughout the year that contribute to the overall abandonment rate and revenue lost?**
- **What demographics contribute the most to the high abandonment rates?**
- **How can we improve the overall abandonment rate and recover lost revenue?**

The goal for this project is to conduct in-depth analysis of all tables provided (customers, devices, facts, and products) and answer these questions by providing potential solutions. To highlight those areas identified during analysis, a dashboard will be built to convey those concerns, and produce potential solutions to bring the abandonment rate down to where it should be on average.

Tools used:
- **SQL (MySQL):** To conduct in-depth analysis on four main segments: Product-specific details, cart behavior, devices, and demographics.
- **Tableau:** To visualize findings in an easy-to-understand manner using simple graphs and other visuals.

## 3. Database Setup & Cleaning

A database was constructed using MySQL to be able to easily analyze all five datasets. See cart_abandonment_create for the full setup of the database. Two datasets contained dates that were in improper format, so they were turned into the standardized YYYY-MM-DD format as such:

```
UPDATE dates
SET dates = STR_TO_DATE(dates, '%m/%d/%Y')
WHERE dates IS NOT NULL AND dates != '';

UPDATE facts
SET abandonment_time = NULL
WHERE abandonment_time = '' OR abandonment_time IS NULL;

UPDATE facts
SET abandonment_time = STR_TO_DATE(abandonment_time, '%m/%d/%Y')
WHERE abandonment_time IS NOT NULL AND abandonment_time != '';

ALTER TABLE dates 
MODIFY COLUMN dates DATE NULL;

ALTER TABLE facts 
MODIFY COLUMN abandonment_time DATE NULL;
```

Notes: 
1. An issue surfaced upon peeking at the data where 'date_id' in the facts table pointed to a date that could occur before or after 'abandonment_time'. As it makes no sense to have a cart session created after it is abandoned, I decided that it would be best for this scenario to assume that all carts were created the same day that they were abandoned (like we typically see in the real world). This did not impact any of my results that I found but needed to be done to avoid issues in Tableau and with analyzing days/months/etc. This was done in Excel using date and if functions.
2. In this dataset, a session is deemed abandoned if 'abandonment_time' is not null. If this value is null, a checkout was completed.

## 4. Analysis

Each point within each section on this README is a query used in its respective file. As mentioned before, all SQL files are attached to this repository.

### A. Product and Category Analysis
#### Basic Dataset Facts
- Total distinct items sold on the website
- Total products sold on the website by category
- Overall abandonment rate
- Total items added to cart, checked out, and abandoned (including and not including quantity)
- Amount of products per category above 250, 500, and 1000

#### Product Level
- 

### B. Cart Behavior Analysis

- I identified the total amount of revenue lost during the fiscal year strictly due to cart abandonment, which was $6,176,481.95.
```
SELECT ROUND(SUM(p.price * f.quantity), 2) as potential_revenue,
	   ROUND(SUM(CASE WHEN f.abandonment_time IS NULL THEN p.price * f.quantity ELSE 0 END), 2) AS revenue,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END), 2) AS lost_revenue,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN p.price * f.quantity ELSE 0 END) / SUM(p.price * f.quantity) * 100, 2) AS revenue_lost_percent
FROM facts f
JOIN products p ON f.product_id = p.product_id;
```
- I checked the average cart value for abandoned and completed sessions for any discrepancies.
```
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
```
- I grouped sessions into price buckets and compared their abandonment rates along with the difference between abandoned and completed sessions.
```
SELECT CASE WHEN p.price * f.quantity < 500 THEN '0-500'
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
```
- Similar to what was done in A, I checked this time to see if cart-level quantity was an issue instead of product-level quantity.
```
SELECT f.quantity,
       ROUND(AVG(p.price * f.quantity), 2) as avg_cart_value,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
GROUP BY f.quantity
ORDER BY f.quantity;
```
- I then began conducting analysis by time, analyzing cart behavior by day of the week, month, weekday vs weekend, and day of the month. Attached is one query used to assess by month.
```
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
```
- The month of May was assessed along with the Sports & Outdoors category in May due to findings found from the query above.

### C. Device Analysis

- Abandonment rates were assessed for device types, OS, and device types running a specific OS. Attached is the query used to assess device types running a specific OS.
```
SELECT d.device_type,
       d.os,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN products p ON f.product_id = p.product_id
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.device_type, d.os
ORDER BY abandonment_rate DESC;
```
- I analyzed the abandonment rates for device types with product prices in buckets.
```
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
```
- I checked for a correlation between device type and quantity.
```
SELECT d.device_type,
       f.quantity,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN devices d ON f.device_id = d.device_id
GROUP BY d.device_type, f.quantity
ORDER BY d.device_type, f.quantity;
```
- I checked for peaks in abandonment rates by device type per month.
```
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
```
- Again, I drilled down in May to see if device types or a specific OS may have contributed to the rate being high.
```
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
```

### D. Demographic Analysis

- I analyzed abandonment rates by generations to determine if certain ages are abandoning more than others. All customers ages ranged from 18-64, so I was able to split them into 6 parts.
```
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
```
- I also checked each age range and the categories they are abandoning the most.
```
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
```
- I drilled down into areas of concern with specific age ranges to determine what exactly is causing the rate to be the way it is for certain products, categories, and the month of May.
- I assessed the correlation between gender and cart abandonment
```
SELECT c.gender,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
GROUP BY c.gender
ORDER BY abandonment_rate DESC;
```
- Similarly with categories and gender
```
SELECT c.gender,
       p.category,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f 
JOIN customers c on f.customer_id = c.customer_id
JOIN products p on f.product_id = p.product_id
GROUP BY c.gender, p.category
ORDER BY c.gender, p.category ASC;
```
- I checked for a correlation between age ranges, gender, and cart abandonment rates.
```
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
```
- Moving on, I analyzed city-based rates.
```
SELECT c.city,
       ROUND(SUM(CASE WHEN f.abandonment_time IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) as abandonment_rate
FROM facts f
JOIN customers c ON f.customer_id = c.customer_id
GROUP BY c.city;
```
- Drilling down further, I compared cities x age.
```
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
```
- I drilled down into certain generations and their related cities as rates were seemingly off for them.
- I checked to see if first-time users abandoned their carts more or less than returning customers did.
```
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
```
- Lastly, I compared ages x device types.
```
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
```

## 5. Notable findings

### A. Product-specific analysis
- All electronics had an above-average abandonment rate.
- The more expensive products should be a primary focus as most revenue loss comes from those products being abandoned.

### B. Cart behavior analysis

- Completed sessions had a higher average value than abandoned sessions.
- May saw a 5% increase in abandonment rate compared to April.
- May has two problematic categories, with Sports & Outdoors having a 67% abandonment rate and Beauty & Personal Care having a 62% abandonment rate.
- Yoga Mats had an 85% abandonment rate and Dumbbells had a 72% abandonment rate in May.
- Fridays are seemingly a problematic day, with the lowest amount of overall sessions but has the highest average abandoned cart value.

### C. Device analysis

- Mobile phones had a 58% average abandonment rate in May, 4% higher than desktop and 6% higher than tablets.

### D. Demographic analysis

- The middle generation (34-49) seems to be behind the heightened rates for electronics, especially in Mumbai and London.
- Both the younger (18-33) and middle generation are behind the heightened apparel abandonment rates, especially in London and Berlin for younger customers, and Berlin and Sydney for the middle-aged customers.

## 6. Recommendations
- Implement automated cart recovery emails within 24 hours of abandonment, with personalized product reminders and potentially a free shipping discount code
- Consider a buy-one-get-one at a certain percentage off campaign to assist with healing quantity-level abandonment rates
- Add a more visible warranty/return policy on electronics product pages, especially for items of high value
- Consider launching a marketing campaign in late spring involving Sports & Outdoors products to prevent another repeated issue with May
- Showcase size guides for apparel with regional conversions (US, UK, EU), especially for Berlin and London markets where apparel abandonment is elevated
- Display shipping costs upfront on product pages

## 7. Tableau Dashboard
I also constructed a Tableau dashboard to convey my general findings to an audience. The goal of this dashboard was to promote targeted marketing for specific demographics and to highlight areas of concern, including certain customer segments and costly products/categories. In total, there was one filter (Month) and 5 charts/tables built:
- **Top 8 Revenue Loss Contributors Chart**: To break the data into segments to identify key risk segments regardless of abandonment rates
- **Top 8 Revenue Lost and Abandonment Rate per Product Bar Graph**: To assess the top products losing revenue due to cart abandonment
- **Abandonment Rate per Month Line Chart**: To view how the abandonment rate changes by month
- **Gender-Specific Abandonment Rates by Category Bar Graph**: To identify if gender has an influence on certain categories
- **Age Range and City Abandonment Rates Heat Map**: To highlight key cells within the matrix that have spiked abandonment rates based on categories or a category

Overall, these five charts along with the metrics attached convey what is needed for a successful dashboard to answer the problem at hand.

## 8. Conclusion

This project was done not just to display my analysis skills within SQL and creativity and storytelling skills using Tableau, but also to be able to understand the thought process behind decision-making with e-commerce stores using KPIs and trends within given data.  Thank you for your support by viewing my project. :-)
