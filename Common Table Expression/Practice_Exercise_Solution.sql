/*
*********************************************************************
MySQL practice exercises created for Medium.com technical article.
You can read all the articles here: https://medium.com/@iffatm
*********************************************************************
*/

/*
1. Customer Credit Limit Analysis
Write a query to perform a customer credit analysis using the table 'CUSTOMERS'. Calculate the average, maximum, and minimum credit limits for each country. Display the customer's name, country, credit limit, average credit limit for the country, maximum credit limit for the country, and minimum credit limit for the country. 
Hint: Use the window functions AVG(), MAX() and MIN()
*/
#cte
WITH CUSTOMERCREDITANALYSIS AS (
  SELECT 
	C.CUSTOMERNAME,
    C.COUNTRY, 
    C.CREDITLIMIT,
    AVG(C.CREDITLIMIT) OVER (PARTITION BY C.COUNTRY) AS AVG_CREDIT_LIMIT,
    MAX(C.CREDITLIMIT) OVER (PARTITION BY C.COUNTRY) AS MAX_CREDIT_LIMIT,
    MIN(C.CREDITLIMIT) OVER (PARTITION BY C.COUNTRY) AS MIN_CREDIT_LIMIT
  FROM 
    CUSTOMERS C
)

#main query
SELECT 
	*
FROM 
	CUSTOMERCREDITANALYSIS;


/*
2. Order Frequency Analysis
Write a query to examine the ordering patterns of customers, segmenting them according to order counts as follows:
If a customer has placed 10 or more orders, classify as 'High Frequency'.
For those with 5 to 9 orders, categorise as 'Medium Frequency'.
Otherwise, designate as 'Low Frequency'.
Display the customer's ID, name, order count, and order frequency category. 
Hint: Use CASE statement
*/
#cte
WITH ORDERFREQUENCY AS (
  SELECT 
    CUST.CUSTOMERID,
    CUST.CUSTOMERNAME,
    COUNT(ORD.ORDERID) AS ORDER_COUNT,
    CASE
        WHEN COUNT(ORD.ORDERID) >= 10 THEN 'High Frequency'
        WHEN COUNT(ORD.ORDERID) >= 5 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS FREQUENCYCATEGORY
  FROM 
	CUSTOMERS CUST
  LEFT JOIN 
    ORDERS ORD
  ON 
    CUST.CUSTOMERID = ORD.CUSTOMERID
  GROUP BY 
    CUST.CUSTOMERID
)

#main query
SELECT 
	*
FROM 
	ORDERFREQUENCY;


/*
3. Employee Performance Analysis
Write a query to analyse the performance of employees based on their total sales contributions. 
Display the employee ID, employee name, and total sales amount.
*/
WITH EMPLOYEEPERFORMANCE AS (
  SELECT
	EMP.EMPLOYEEID,
    EMP.EMPLOYEENAME,
    COUNT(ORD.ORDERID) AS TOTAL_ORDERS,
    SUM(ORDET.QUANTITYORDERED * ORDET.COSTPERUNIT) AS TOTAL_SALES_AMOUNT
  FROM 
	EMPLOYEES EMP
  LEFT JOIN 
	CUSTOMERS CUST
	ON EMP.EMPLOYEEID = CUST.SALESREPRESENTATIVE
  LEFT JOIN 
	ORDERS ORD
    ON CUST.CUSTOMERID = ORD.CUSTOMERID
  LEFT JOIN 
	ORDERDETAILS ORDET 
	ON ORD.ORDERID = ORDET.ORDERID
  GROUP BY 
	EMP.EMPLOYEEID, EMP.EMPLOYEENAME
)
SELECT 
  EMPLOYEEID,
  EMPLOYEENAME,
  TOTAL_ORDERS,
  TOTAL_SALES_AMOUNT,
  DENSE_RANK() OVER (ORDER BY TOTAL_SALES_AMOUNT DESC) AS SALES_RANK
FROM EMPLOYEEPERFORMANCE;

/*
Final Challenge
Find out the information about the customers who has made the highest-value orders with an order status as 'Shipped'. 
To accomplish this, you will be utilising data from the following tables: 'CUSTOMERS', 'ORDERS', 'ORDERDETAILS', and 
'EMPLOYEES'. If you're unsure, you can check the ER Diagram at the beginning of the article.
*/
WITH CUSTOMERSALESRANK AS
(
SELECT
    CUST.CUSTOMERID,
    CUST.CUSTOMERNAME,
    COUNT(DISTINCT ORD.ORDERID) AS TOTAL_NO_ORDERS,
    SUM(ORDET.QUANTITYORDERED * ORDET.COSTPERUNIT) AS TOTAL_ORDER_VALUE,
    RANK() OVER (ORDER BY SUM(ORDET.QUANTITYORDERED * ORDET.COSTPERUNIT) DESC) AS SALES_RANK,
    CUST.SALESREPRESENTATIVE
FROM 
    CUSTOMERS CUST
INNER JOIN
    ORDERS ORD
    ON CUST.CUSTOMERID = ORD.CUSTOMERID
INNER JOIN 
    DEMO_MEDIUM.ORDERDETAILS ORDET
    ON ORD.ORDERID = ORDET.ORDERID
WHERE 
	ORD.ORDERSTATUS = "Shipped"
GROUP BY 
	CUST.CUSTOMERID, CUST.CUSTOMERNAME
)

#customer with the highest value order
SELECT
    CSR.CUSTOMERID,
    CSR.CUSTOMERNAME,
    CSR.TOTAL_NO_ORDERS,
    CSR.TOTAL_ORDER_VALUE,
    CSR.SALES_RANK,
    EMPLOYEENAME AS SALEREPEMP
FROM 
    CUSTOMERSALESRANK CSR
JOIN
	EMPLOYEES EMP
	ON CSR.SALESREPRESENTATIVE = EMP.EMPLOYEEID
WHERE
	CSR.SALES_RANK = 1;