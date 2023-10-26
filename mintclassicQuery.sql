-- Displays each table
SHOW TABLES ;

SELECT *
FROM warehouses ;
SELECT *
FROM products;
SELECT *
FROM productlines;
SELECT *
FROM orderdetails;
SELECT *
FROM payments;
SELECT *
FROM customers;
SELECT *
FROM orders;
SELECT *
FROM employees;
SELECT *
FROM offices;


-- Get total stock in each warehouse
SELECT warehouseName , sum(quantityInStock) AS TotalStock
FROM products
INNER JOIN warehouses ON warehouses.warehouseCode = products.warehouseCode
GROUP BY warehouseName
ORDER BY TotalStock DESC;

-- Get total stock for each Product line
SELECT warehouseName , productLine, sum(quantityInStock) AS TotalStock
FROM products
INNER JOIN warehouses ON warehouses.warehouseCode = products.warehouseCode
GROUP BY productLine
ORDER BY warehouseName, TotalStock DESC;

-- Get total stock for each product
SELECT productCode ,productName, quantityInStock AS totalStock
FROM products
GROUP BY productName
ORDER BY totalStock DESC;

-- Get comparative data between total stock & total order
SELECT productName, quantityInStock, sum(quantityOrdered) AS totalOrdered, ( quantityInStock - sum(quantityOrdered) ) AS currentInventory
FROM products
LEFT JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY productName
ORDER BY currentInventory DESC; 

-- Get total orders by time
SELECT orderDate, totalOrder
FROM orders AS o
LEFT JOIN ( SELECT
			orderNumber,
            sum(quantityOrdered) AS totalOrder
            FROM orderdetails
            GROUP BY orderNumber) od
ON o.orderNumber = od.orderNumber
ORDER BY orderDate;

-- Get the total revenue for each warehouse
SELECT warehouseName AS warehouse , sum(quantityOrdered) AS totalOrder , sum(quantityOrdered * priceEach) AS totalRevenue
FROM (products  
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode) 
RIGHT JOIN warehouses ON warehouses.warehouseCode = products.warehouseCode
GROUP BY warehouse
ORDER BY totalRevenue DESC;

-- Get the total revenue for each warehouse + stock
SELECT w.warehouseName, sum(quantityInstock) AS totalStock , sum(totalOrdered) , sum(totalRevenue) 
FROM ((SELECT 
        warehouseCode,
		warehouseName
        FROM warehouses) w
RIGHT JOIN
( SELECT
		productCode,
        warehouseCode,
        quantityInStock
        FROM products
        GROUP BY productCode) p
ON w.warehouseCode = p.warehouseCode
LEFT JOIN (
		SELECT
        productCode,
        sum(quantityOrdered) AS totalOrdered,
        sum(quantityOrdered * priceEach) AS totalRevenue
        FROM orderdetails
        GROUP BY productCode) od
ON p.productCode = od.productCode) 
GROUP BY warehouseName
ORDER BY totalRevenue;
    
-- Get the total revenue for each product line
SELECT productLine, sum(quantityOrdered) AS totalOrdered, sum(quantityOrdered * priceEach) AS totalRevenue
FROM products
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY productLine
ORDER BY totalRevenue;

-- Get the total revenue for each product
SELECT productName, quantityInStock, buyPrice, priceEach, sum(quantityOrdered) AS totalOrder, sum(quantityOrdered * priceEach) AS totalRevenue
FROM products
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY productName
ORDER BY totalRevenue ;

-- Get customer profile data including orders and payments
SELECT  c.customerNumber, c.customerName, c.country, c.creditLimit, totalOrder, totalPayment, (totalPayment - c.creditLimit) AS creditLimitdiff
FROM (SELECT
		customerNumber,
        customerName,
        country,
        creditLimit
	FROM customers) c
LEFT JOIN 
	 (SELECT
     customerNumber,
     sum(amount) AS totalPayment
     FROM payments
     GROUP BY customerNumber) p
ON c.customerNumber = p.customerNumber
LEFT JOIN
	(SELECT
    customerNumber,
    count(orderNumber) AS totalOrder
    FROM orders
    GROUP BY  customerNumber) o
ON c.customerNumber = o.customerNumber
GROUP BY customerNumber
ORDER BY totalPayment DESC;

-- Get data on the number of employees in each office
SELECT  o.officeCode,
		o.city,
		o.country,
		count(employeeNumber) AS totalEmployees
FROM offices AS o
LEFT JOIN employees AS e ON o.officeCode = e.officeCode
GROUP BY city
ORDER BY totalEmployees DESC;

-- Get employee performance data
SELECT e.employeeNumber, 
		e.firstName, 
        e.lastName,
        e.jobTitle,
        count(o.orderNumber) AS totalSales
FROM employees AS e
LEFT JOIN customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN orders AS o ON c.customerNumber = o.customerNumber
GROUP BY employeeNumber
ORDER BY totalSales DESC;
        



    
