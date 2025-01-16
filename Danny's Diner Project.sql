

-- Database has been created in SQL Command Client. Creating tables.ACCESSIBLE

CREATE TABLE Sales (
    Customer_id VARCHAR(1),
    Order_date DATE,
    product_id INT
);

CREATE TABLE Members (
    Customer_id VARCHAR(1),
    Join_date TIMESTAMP
);

CREATE TABLE Menu (
    Product_id INT,
    Product_name VARCHAR(5),
    Price INT
);

-- Insert data into table

INSERT INTO Sales VALUES 
    ('A', '2021-01-01', 1),
    ('A', '2021-01-01', 2),
    ('A', '2021-01-07', 2),
    ('A', '2021-01-10', 3),
    ('A', '2021-01-11', 3),
    ('A', '2021-01-11', 3),
    ('B', '2021-01-01', 2),
    ('B', '2021-01-02', 2),
    ('B', '2021-01-04', 1),
    ('B', '2021-01-11', 1),
    ('B', '2021-01-16', 3),
    ('B', '2021-02-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-01', 3),
    ('C', '2021-01-07', 3);

INSERT INTO Menu VALUES(
    1, 'Sushi', 10),
    (2, 'Curry', 15),
    (3, 'Ramen', 12);
 
INSERT INTO Members VALUES
    ('A', '2021-01-07'),
    ('B', '2021-01-09');

SELECT * FROM Sales;
SELECT * FROM Members;
SELECT * FROM Menu;



-- QUESTIONS
--#1. What is the total amount each customer spent at the restaurant

SELECT sales.customer_id, SUM(menu.price)
FROM Menu
JOIN Sales ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

--#2. How many days has each customer visited the restaurant

SELECT customer_id, COUNT(DISTINCT order_date) AS Number_of_Visits
FROM Sales
GROUP BY Customer_id;

--#3. What was the first item from the menu purchased by each customer

WITH CTE AS (
    SELECT s.customer_id, m.product_name, s.order_date,
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY order_date) Rownum
FROM sales s
JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name FROM CTE
WHERE Rownum = 1;


--#4 What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT menu.product_name, COUNT(sales.product_id) AS Number_of_times_purchased
FROM sales
JOIN Menu ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY COUNT(sales.product_id) DESC
LIMIT 1;

--#5. What item was the most popular for each customer

WITH CTE AS (
SELECT sales.customer_id, menu.product_name, COUNT(sales.product_id) Number_of_orders,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) as rnk
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name
)
SELECT customer_id, product_name
FROM CTE
WHERE rnk = 1;

--#6. Which item was purchased first by the customer after they became a member?

WITH CTE AS(
SELECT s.customer_id, m.product_name, s.order_date,
RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) rnk
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mm ON s.customer_id = mm.customer_id
WHERE s.order_date >= mm.join_date
GROUP BY s.customer_id, s.order_date, m.product_name)
SELECT customer_id, product_name
FROM CTE
WHERE rnk = 1;


--#7. Which item was purchased just before the customer became a member?

WITH CTE AS (
SELECT s.customer_id, m.product_name, s.order_date,
RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) rnk
FROM sales s
JOIN menu m ON s.product_id = m.product_id
RIGHT JOIN members mm ON s.customer_id = mm.customer_id
WHERE s.order_date < mm.join_date
GROUP BY s.customer_id, s.order_date, m.product_name)
SELECT customer_id, product_name
FROM CTE
WHERE rnk = 1;


--#8. What is the total itmes and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) AS Items_purchased, SUM(m.price) As Total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mm ON s.customer_id = mm.customer_id
WHERE s.order_date < mm.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;


--#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

SELECT s.customer_id, SUM(
CASE
    WHEN m.product_name = 'sushi' THEN m.price *10*2
    ELSE m.price*10
    END) AS Points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;


--#10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just 
-- sushi - how many points to customer A and B have at the end of January?

WITH CTE AS(
SELECT s.customer_id, m.product_name, mm.join_date, s.order_date, m.price,
CASE
    WHEN m.product_name = 'sushi' THEN m.price *10*2
    WHEN s.order_date BETWEEN mm.join_date AND DATE_ADD(mm.join_date, INTERVAL 7 DAY) THEN m.price *10*2
    ELSE m.price*10
    END AS Points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mm ON s.customer_id = mm.customer_id
ORDER BY s.customer_id, mm.join_date, s.order_date)
SELECT customer_id, SUM(points)
FROM CTE
WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY customer_id
ORDER BY customer_id;


-- BONUS
--#11. Determine the name and price of the product ordered by each customer on all order dates and find out whether the 
--customer was a member on the order date or not

SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE
    WHEN s.order_date >= mm.join_date THEN 'Y'
    ELSE 'N'
    END AS member
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mm ON s.customer_id = mm.customer_id
ORDER BY s.customer_id, s.order_date, m.product_name;

--#12. Rank the previous output from #11 based on the order_date for each customer. Display NULL if customer
--was not a member when dish was ordered.

WITH CTE AS(
SELECT s.customer_id, s.order_date, m.product_name, m.price,
CASE
    WHEN s.order_date >= mm.join_date THEN 'Y'
    ELSE 'N'
    END AS member
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mm ON s.customer_id = mm.customer_id
ORDER BY s.customer_id, s.order_date, m.product_name)
SELECT *,
CASE
    WHEN member = 'Y' THEN RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
    ELSE 'null'
    END AS ranking
FROM CTE;

