--created table for goldusers signup

CREATE TABLE goldusers_signup(
userid integer,
gold_signup_date date
);

--inserted values into the table goldusers_signup

INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'2017-09-22'),
(3,'2017-04-21');

--created table for users

CREATE TABLE users(
userid integer,
signup_date date
);

--inserted values into the user table

INSERT INTO users(userid,signup_date)
VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

--created table sales

CREATE TABLE sales(
userid integer,
created_date date,
product_id integer
); 

--inserted data into sales table

INSERT INTO sales(
userid,
created_date,
product_id
)
VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

--created table product

CREATE TABLE product(product_id integer,product_name text,price integer); 

--inserting details in the talbe names product

INSERT INTO product(
product_id,
product_name,
price
) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1)what is the total amount of each customer spending on zomato

SELECT a.userid, SUM(b.price) total_amt_spent 
FROM sales AS a
INNER JOIN product AS b
ON a.product_id = b.product_id
GROUP BY a.userid;

--2) how many days had n individual consumer visited zomato?

SELECT userid,
COUNT(DISTINCT created_date) distinct_days
FROM sales 
GROUP BY userid;

--3)what was the first ever product bought by individual consumer?

SELECT *
FROM
(SELECT *,RANK()OVER(PARTITION BY userid ORDER BY created_date)rnk FROM sales) a
WHERE rnk = 1

--4)what was the most purchased item on the menu and how many times was it purchasd by all customers?

SELECT userid,
COUNT(product_id) cnt
FROM sales 
WHERE product_id = (SELECT product_id 
FROM sales
GROUP BY product_id
ORDER BY COUNT(product_id) DESC
LIMIT 1)
GROUP BY userid;

--5) Which itme was the most popular for each customer?

SELECT *
FROM
(SELECT *,
RANK() 
OVER(PARTITION BY userid
ORDER BY cnt DESC) rnk
FROM
(SELECT userid, product_id,
COUNT(product_id) cnt
FROM sales
GROUP BY userid, product_id)a)b
WHERE rnk = 1;

--6) which item was purchased first by the customer after they became a member?

SELECT *
FROM
(SELECT c.*,RANK()OVER(PARTITION BY userid
ORDER BY created_date)rnk 
FROM
(SELECT a.userid, a.created_date,a.product_id,b.gold_signup_date
FROM sales AS a 
INNER JOIN
goldusers_signup b
ON a.userid = b.userid 
AND created_date>=gold_signup_date) c)d 
WHERE rnk = 1;

--7)which item was purchased just before the customer became a member?

SELECT *
FROM
(SELECT c.*,RANK()OVER(PARTITION BY userid
ORDER BY created_date)rnk 
FROM
(SELECT a.userid, a.created_date,a.product_id,b.gold_signup_date
FROM sales AS a 
INNER JOIN
goldusers_signup b
ON a.userid = b.userid 
AND created_date<=gold_signup_date) c)d 
WHERE rnk = 1;

--8) what is the total orders and amount spent for each member before they became a member?

SELECT userid, COUNT(created_date) order_purchased, SUM(price) total_amt
FROM
(SELECT c.*,d.price
FROM
(SELECT a.userid, a.created_date,a.product_id,b.gold_signup_date
FROM sales AS a 
INNER JOIN
goldusers_signup b
ON a.userid = b.userid 
AND created_date<=gold_signup_date) c
INNER JOIN product d ON c.product_id = d.product_id)e
GROUP BY userid;

--9)In the first one year after a customer joins the gold programs (including their join date) irrespective of what the customer has purchased they earn 5 zomato points for every 10rs spent who earned more 1 or 3 and what their points earnings in their points earnings in thier first yr?

SELECT c.*, d.price * 0.5 AS total_points_earned
FROM (
  SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date
  FROM sales AS a 
  INNER JOIN goldusers_signup b
  ON a.userid = b.userid 
  AND a.created_date >= b.gold_signup_date 
  AND a.created_date <= b.gold_signup_date + INTERVAL '1 year'
) c
INNER JOIN product d ON c.product_id = d.product_id;

--10) rnk all the transaction of the customers

SELECT *,RANK()
OVER
(
PARTITION BY userid 
ORDER BY created_date
) rnk 
FROM sales;

--11)rank all the production for each member whenever they are a zomato gold member for every non gold member transction mark as na

WITH cte AS (
    SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date
    FROM sales AS a 
    LEFT JOIN goldusers_signup b ON a.userid = b.userid 
    AND created_date >= b.gold_signup_date
)
SELECT cte.*, 
    CASE 
        WHEN gold_signup_date IS NULL THEN 0 
        ELSE RANK() OVER (PARTITION BY userid ORDER BY created_date DESC)
    END AS rnk
FROM cte;


--












