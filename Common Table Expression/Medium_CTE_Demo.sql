/*
*********************************************************************
MySQL practice exercises created for Medium.com technical article.
You can read all the articles here: https://medium.com/@iffatm
*********************************************************************
*/

########################################### CTE ###########################################
#cte
#calculate total quantity sold and total revenue for each product
WITH PRODUCTSALES AS (
  SELECT
	PRD.PRODUCTID,
    PRD.PRODUCTNAME,
    SUM(ORDET.QUANTITYORDERED) AS TOTAL_QUANTITY_SOLD,
    SUM(ORDET.QUANTITYORDERED * PRD.BUYPRICE) AS TOTAL_REVENUE
  FROM 
    PRODUCTS PRD
  JOIN 
    ORDERDETAILS ORDET 
    ON PRD.PRODUCTID = ORDET.PRODUCTID
  GROUP BY 
    PRD.PRODUCTID, PRD.PRODUCTNAME
)

#retrieve product sales information with ranking based on total revenue
SELECT
  PRODUCTID,
  PRODUCTNAME,
  TOTAL_QUANTITY_SOLD,
  TOTAL_REVENUE,
  RANK() OVER (ORDER BY TOTAL_REVENUE DESC) AS SALES_RANK
FROM 
  PRODUCTSALES;

########################################### RECURSIVE CTE ###########################################
#cte to define a hierarchical structure in the company
WITH RECURSIVE EMPLOYEEHIERARCHY AS 
(
    #base part
    SELECT 
        EMPLOYEEID, 
        EMPLOYEENAME, 
        JOBTITLE,
        MANAGER,
        1 AS EMPHIERARCHYDEPTH
    FROM 
        EMPLOYEES
    WHERE
        EMPLOYEEID = 'EMP100'
    
    UNION ALL
    
    #recursive part
    SELECT 
        EMP.EMPLOYEEID, 
        EMP.EMPLOYEENAME,
        EMP.JOBTITLE,
        EMP.MANAGER,
        EH.EMPHIERARCHYDEPTH + 1
    FROM 
        EMPLOYEES EMP
    JOIN 
        EMPLOYEEHIERARCHY EH 
    ON 
        EMP.MANAGER = EH.EMPLOYEEID
)

#main query
SELECT 
    *
FROM 
    EMPLOYEEHIERARCHY;

########################################### CTE vs Subquery ###########################################
#using cte 
#find out total number of order qunatity placed by each customer
WITH CUSTOMERORDERSUMMARY AS (
    SELECT
        CUST.CUSTOMERID,
        CUST.CUSTOMERNAME,
        COALESCE(SUM(ORDET.QUANTITYORDERED), 0) AS TOTAL_ORDER_QUANTITY
    FROM 
		CUSTOMERS CUST
    LEFT JOIN 
		ORDERS ORD 
        ON CUST.CUSTOMERID = ORD.CUSTOMERID
    LEFT JOIN 
		ORDERDETAILS ORDET 
        ON ORD.ORDERID = ORDET.ORDERID
    GROUP BY 
		CUST.CUSTOMERID, CUST.CUSTOMERNAME
)

SELECT 	
	* 
FROM 
	CUSTOMERORDERSUMMARY;

#using subquery
SELECT
    CUST.CUSTOMERID,
    CUST.CUSTOMERNAME,
    COALESCE((
        SELECT 
			SUM(ORDET.QUANTITYORDERED)
		FROM 
			ORDERS ORD
        JOIN 
			ORDERDETAILS ORDET 
            ON ORD.ORDERID = ORDET.ORDERID
        WHERE ORD.CUSTOMERID = CUST.CUSTOMERID
    ), 0) AS TOTAL_ORDER_QUANTITY
FROM CUSTOMERS CUST;


########################################### CTE vs Derived Table ###########################################
#derived table
SELECT 
   PRD.PRODUCTNAME, 
   PRD.QUANTITYINSTOCK,
   PS.TOTAL_QUANTITY_SOLD
FROM 
   PRODUCTS PRD
JOIN (
    SELECT
        PRODUCTID,
        SUM(QUANTITYORDERED) AS TOTAL_QUANTITY_SOLD
    FROM ORDERDETAILS
    GROUP BY PRODUCTID
) AS PS
ON PRD.PRODUCTID = PS.PRODUCTID;

#cte
WITH PRODUCTSALES AS (
    SELECT
       PRODUCTID,
       SUM(QUANTITYORDERED) AS TOTAL_QUANTITY_SOLD
    FROM 
       ORDERDETAILS
    GROUP BY 
       PRODUCTID
)

#main query
SELECT 
   PRD.PRODUCTNAME, 
   PRD.QUANTITYINSTOCK,
   PS.TOTAL_QUANTITY_SOLD
FROM 
   PRODUCTS PRD
JOIN 
   PRODUCTSALES PS 
   ON PRD.PRODUCTID = PS.PRODUCTID;

########################################### CTE vs Temporary Table ###########################################
#temporary table
#create a temporary table to store intermediate results
CREATE TEMPORARY TABLE TEMPREVENUECATEGORY AS
SELECT
    PRD.PRODUCTCATEGORY,
    SUM(ORDET.QUANTITYORDERED * PRD.BUYPRICE) AS TOTAL_REVENUE
FROM
    PRODUCTS PRD
JOIN
    ORDERDETAILS ORDET ON PRD.PRODUCTID = ORDET.PRODUCTID
GROUP BY
    PRD.PRODUCTCATEGORY;

#select data from the temporary table
SELECT * FROM TEMPREVENUECATEGORY;

#cte
#use CTE to calculate total revenue by product category
WITH REVENUECATEGORY AS (
    SELECT
        PRD.PRODUCTCATEGORY,
        SUM(ORDET.QUANTITYORDERED * PRD.BUYPRICE) AS TOTAL_REVENUE
    FROM
        PRODUCTS PRD
    JOIN
        ORDERDETAILS ORDET ON PRD.PRODUCTID = ORDET.PRODUCTID
    GROUP BY
        PRD.PRODUCTCATEGORY
)
#select data from the CTE
SELECT 
	* 
FROM 
	REVENUECATEGORY;
