DROP DATABASE IF EXISTS cart_abandonment;
CREATE DATABASE cart_abandonment;
USE cart_abandonment;

CREATE TABLE customers (
customer_id int primary key,
customer_name varchar(50),
age int,
gender varchar(20),
city varchar(50)
);

CREATE TABLE dates (
date_id int primary key,
dates varchar(10)
);

CREATE TABLE devices (
device_id int primary key,
device_type varchar(10),
os varchar(10)
);

CREATE TABLE products (
product_id int primary key,
product_name varchar(50),
category varchar(50),
price decimal(10, 2)
);

CREATE TABLE facts (
session_id int,
customer_id int,
product_id int,
device_id int,
date_id int,
quantity int,
abandonment_time varchar(10),
foreign key (customer_id) references customers(customer_id),
foreign key (product_id) references products(product_id),
foreign key (device_id) references devices(device_id),
foreign key (date_id) references dates(date_id)
);

/* Date handling */

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