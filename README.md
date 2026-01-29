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
- Total items added to cart, checked out, and abandoned (including and not including quantity)
- Top 12 products with the most revenue lost + abandonment rates
- Top 12 products with the highest abandonment rates
- Minimum quantity added, maximum, average, and difference (abandoned - checkout) for checkout vs abandonment

#### Category Level
- Abandonment rate by category
- Revenue lost by category

### B. Cart Behavior Analysis
#### Cart Behavior Analysis
- Compare revenue made to lost
- Average cart value for both abandoned and completed carts
- Compare average cart values
- Cart value by quantity

#### Date Analysis
- Abandonment + revenue lost by month
- Abandonment + revenue lost by day of the week
- Abandonment + revenue lost by weekday/weekend
- Abandonment + revenue lost by day of the month

### C. Device Analysis
#### Device + OS Analysis
- Abandonment rate by device type
- Abandonment rate by OS
- Abandonment rate by device + OS
- Total lost revenue by device + OS

#### Device + Category Analysis
- Each device + OS's top abandoned category and respective abandonment rate
- Each device + OS's top revenue losing category

#### Device + Cart Behavior Analysis
- Device type price bucket abandonment rates
- Device type + quantity abandonment rates

#### Device + Date Analysis
- Abandonment + revenue lost by month per device

### D. Demographic Analysis
#### Age Analysis
- Abandonment by age buckets
- Top abandoned categories per age bucket
- Revenue lost per age bucket
- Each age bucket's abandonment rate per month
- Device + age bucket's abandonment rate

#### Gender Analysis
- Each gender's abandonment rate
- Each gender's most abandoned categories
- Revenue lost per gender
- Each gender's abandonment rate per device + OS

#### Gender + Age Analysis
- Age range, gender, and abandonment rates

#### City Analysis
- Each city's abandonment rate
- Revenue lost per city
- Cities, age buckets, and abandonment rates

#### Customer Type Analysis
- First time vs returning customer abandonment rates
- First time vs returning customer revenue lost

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
