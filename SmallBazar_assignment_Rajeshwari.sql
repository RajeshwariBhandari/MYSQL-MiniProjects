use smallbazar;
drop table payment;
drop table delivery;
drop table Orders;
drop table branch_product;
drop table Product;
drop table Branch;
drop table Country;
drop table Customer;
CREATE TABLE Customer (
    cust_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    cust_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE Country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country_name VARCHAR(10)
);

CREATE TABLE Branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    location VARCHAR(10),
    branch_status VARCHAR(10),
    country_id INT,
    FOREIGN KEY (country_id)
        REFERENCES Country (country_id)
);

CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(20),
    quantity INT,
    amount DOUBLE
);

CREATE TABLE Branch_Product (
    branch_id INT,
    FOREIGN KEY (branch_id)
        REFERENCES Branch (branch_id),
    product_id INT,
    FOREIGN KEY (product_id)
        REFERENCES Product (product_id),
    cost_price DOUBLE,
    selling_price DOUBLE,
    quantity INT
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    order_date DATE,
    quantity INT,
    amount DOUBLE,
    no_of_bags INT,
    extra_charges DOUBLE,
    branch_id INT,
    FOREIGN KEY (branch_id)
        REFERENCES Branch (branch_id),
    product_id INT,
    FOREIGN KEY (product_id)
        REFERENCES Product (product_id),
    cust_id INT,
    FOREIGN KEY (cust_id)
        REFERENCES Customer (cust_id)
);

CREATE TABLE Delivery (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    delivery_option VARCHAR(20),
    charges DOUBLE,
    cust_id INT,
    FOREIGN KEY (cust_id)
        REFERENCES Customer (cust_id),
    branch_id INT,
    FOREIGN KEY (branch_id)
        REFERENCES Branch (branch_id),
    order_id INT,
    FOREIGN KEY (order_id)
        REFERENCES Orders (order_id)
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_amount DOUBLE,
    order_id INT,
    FOREIGN KEY (order_id)
        REFERENCES Orders (order_id),
    delivery_id INT,
    FOREIGN KEY (delivery_id)
        REFERENCES Delivery (delivery_id)
);

insert into Customer values('1','Rajeshwari','Ahmednagar','9975203327');
insert into Customer(cust_name,address,phone) values('Aishu','Ahmednagar','9730684242'),('Santosh','Pune','9890523327'),('Akash','Pune','9309103817');

SELECT 
    *
FROM
    Customer;

insert into Country values(11,'India');
insert into Country(country_name) values ('Germany'),('France');
SELECT 
    *
FROM
    Country;

insert into Branch values(111,'Pune','Active',11);
insert into Branch (location,branch_status,country_id) values('Ahmednagar','Active',11),('Nashik','Deactive',11),('Berlin','Deactive',12),('Hamburg','Active',12),('Paris','Deactive',13),('cannes','Active',13);
SELECT 
    *
FROM
    Branch;

insert into Product values (1111,'Soap',50,120.00);
insert into Product (product_name,quantity,amount) values('Shampoo',20,35.00),('Oil',10,20.00),('Biscuits',5,10.00),('Choclates',20,40.00);
SELECT 
    *
FROM
    Product;

insert into branch_product values (111,1112,35.00,40.00,2),(111,1113,20.00,22.00,5),(111,1114,10.00,15.00,2),
	(112,1111,120.00,123.00,5),(112,1115,40.00,45.00,10),(115,1112,35.00,35.00,3),(115,1115,40.00,45.00,8);
SELECT 
    *
FROM
    branch_product;

insert into Orders values(222,'2023-01-16',1,120.00,2,10.00,111,1113,1);
insert into Orders (order_date,quantity,amount,no_of_bags,extra_charges,branch_id,product_id,cust_id)
	values('2023-01-16',1,40.00,0,0,111,1112,1),('2022-05-23',2,80.00,0,0,112,1111,2),('2022-07-12',3,105.00,1,5.00,115,1112,4);
SELECT 
    *
FROM
    Orders;

insert into delivery values(444,'Home delivery',100.00,1,111,222);
insert into delivery (delivery_option,charges,cust_id,branch_id,order_id) values('Self-picked',0.00,2,112,224),
('Home delivery',250.00,3,115,225),('self-picked',0.00,1,111,223),('Home delivery',300.00,1,112,226);
SELECT 
    *
FROM
    delivery;

insert into Payment values(555,230.00,222,444);
insert into payment (payment_amount,order_id,delivery_id) values(40.00,223,444),(110.00,224,445);
SELECT 
    *
FROM
    payment;


/*
1. The CEO of ‘Small Bazar’ wants to check the profitability of the Branches. Create a View
for his use which will show monthly Profit of all Branches for the current year.*/


#It shows branch location with profit for each month of current year using curdate() here it is for 2023

drop view BranchProfit;
CREATE VIEW BranchProfit AS
    SELECT 
        branch_product.branch_id,
        branch.location,
        SUM((selling_price - cost_price) * orders.quantity) AS profit,
        MONTHNAME(orders.order_date) AS months
    FROM
        branch_product
            JOIN
        Orders ON branch_product.branch_id = Orders.branch_id and branch_product.product_id = orders.product_id
            JOIN
        branch ON branch_product.branch_id = branch.branch_id
    WHERE
        YEAR(orders.order_date) = YEAR(CURDATE())
    GROUP BY months , branch_product.branch_id;
 
 select * from BranchProfit;

/*
2. Create a stored procedure having countryName, FromDate and ToDate as Parameter,
which will return Sitewise, Item Wise and Date Wise the number of items sold in the
given Date range as separate resultsets. Create appropriate Indexes on the tables.
*/

# It shows quantity which is sold branch wise between date passed country name which you passed

drop procedure DisplayItemsSold;
DELIMITER //
CREATE PROCEDURE `DisplayItemsSold` (in new_country_name varchar(20), in from_date date,in to_date date )
BEGIN

SELECT 
    SUM(orders.quantity) AS quantity_sold, branch.location
FROM
    orders
        JOIN
    branch ON branch.branch_id = orders.branch_id
        JOIN
    country ON branch.country_id = country.country_id
WHERE
    orders.order_date BETWEEN from_date AND to_date
        AND country.country_name = new_country_name
GROUP BY orders.branch_id;


SELECT 
    SUM(orders.quantity) AS quantity_sold, orders.product_id
FROM
    orders
        JOIN
    branch ON orders.branch_id = branch.branch_id
        JOIN
    country ON branch.country_id = country.country_id
WHERE
    orders.order_date BETWEEN from_date AND to_date
        AND country.country_name = new_country_name
GROUP BY orders.product_id;

SELECT 
    SUM(orders.quantity) AS quantity_sold, orders.order_date
FROM
    orders
        JOIN
    branch ON orders.branch_id = branch.branch_id
        JOIN
    country ON branch.country_id = country.country_id
WHERE
    orders.order_date BETWEEN from_date AND to_date
        AND country.country_name = new_country_name
GROUP BY orders.order_date;

END;//
select * from orders;

call DisplayItemsSold('India','2022-01-01','2023-01-20');
call DisplayItemsSold('Germany','2022-01-01','2023-01-01');


/*3. Create a stored procedure which will calculate the total bill for any order. Bill should
have details like:
CustomerName,
orderId,
OrderDate,
Branch,
ProductName,
Price per Unit,
No. Of Units,
Total Cost of that product,
Total Bill Amount,
Additional Charges (0 if none),
Delivery Option (‘Home Delivery&#39; or ‘self-Pickup’).
*/

select * from orders;
select * from delivery;
SELECT 
    customer.cust_name,
    orders.order_id,
    orders.order_date,
    branch.location,
    product.product_name,
    branch_product.selling_price,
    orders.quantity,
    (branch_product.selling_price * orders.quantity) AS TotalProductCost,
    orders.extra_charges,
    (branch_product.selling_price * orders.quantity) + extra_Charges AS BillAmount,
    delivery.delivery_option
FROM
    orders
        JOIN
    branch_product ON orders.product_id = branch_product.product_id
        AND orders.branch_id = branch_product.branch_id
        JOIN
    product ON orders.product_id = product.product_id
        JOIN
    branch ON branch.branch_id = branch_product.branch_id
        JOIN
    customer ON customer.cust_id = orders.cust_id
		JOIN
	delivery on delivery.order_id = orders.order_id ;

/*4. Create a (function) Procedure having a parameter as country name, which displays all
the branches available in the country that are active.*/

#shows active branch for passed country name

drop procedure DisplayActiveBranch;
DELIMITER //
CREATE PROCEDURE `DisplayActiveBranch` (in new_country_name varchar(20) )
BEGIN
SELECT 
    location
FROM
    Branch
        JOIN
    country ON branch.country_id = country.country_id
WHERE
    branch_Status = 'Active'
        AND country_name = new_country_name;
END;//

call DisplayActiveBranch('India');


/*5. The CEO of ‘Small Bazar’ wants to check the profitability of the Branches. Create a
stored procedure that shows the branch profit if profit is below a certain threshold flag
that branch as below par performance.
*/

#Gives branch location with profit he gains in ascending order so you can have less profit having low performance

drop procedure LowPerformance;
DELIMITER //
CREATE PROCEDURE `LowPerformance` ()
BEGIN
SELECT 
    branch.location, SUM((selling_price - cost_price) * orders.quantity) AS profit
FROM
      branch_product
            JOIN
        Orders ON branch_product.branch_id = Orders.branch_id and branch_product.product_id = orders.product_id
            JOIN
        branch ON branch_product.branch_id = branch.branch_id
GROUP BY branch_product.branch_id order by profit;

END;//

call LowPerformance();


/*6.find out country where people are using least plastic bag while they are shopping.*/

#Shows country name with number of plastic bags are used in that country

SELECT 
    country_name, sum(no_of_bags) AS no_of_plastic_bags
FROM
    Country
        JOIN
    branch ON country.country_id = branch.country_id
        JOIN
    Orders ON orders.branch_id = branch.branch_id
GROUP BY country_name order by no_of_plastic_bags;


/*7. Many business owners focus only on customer acquisition, but customer retention can
also drive loyalty, word of mouth marketing, and higher order values. But CEO want to know if
when a customer shops if he is new customer or old customer, if old customer keep count of
that customer visited small bazar regardless or branch, city, country
If customer shops more than 10 times
Give me privilege customer category*/

#gives customer name who shops more than twice instead of 2 we can take here 10 for 10 times
SELECT 
    cust_name, COUNT(Orders.cust_id) AS Times
FROM
    customer
        JOIN
    orders ON customer.cust_id = orders.cust_id
GROUP BY Orders.cust_id
HAVING Times >= 2;


/*Write a Trigger which will reduce the stock of some product whenever an order is confirmed by
the number of that product in the order. E.g. If an order with 10 Oranges is confirmed from
Nagpur branch, Stock of Oranges from Nagpur branch must be reduced by 10.*/

drop trigger ReduceStock;
DELIMITER //  
CREATE TRIGGER ReduceStock after INSERT  
ON Orders FOR EACH ROW  
BEGIN  
if (select quantity from branch_product where branch_product.product_id = new.product_id )< new.quantity then
	signal sqlstate '45000' 
    set message_text ='Stock is not available';
else
   update branch_product set quantity = quantity - new.quantity where branch_product.product_id = new.product_id;
end if;
END;// 


#valid entry
insert into Orders (order_date,quantity,amount,no_of_bags,extra_charges,branch_id,product_id,cust_id)
	values('2023-03-23',2,90.00,0,0,112,1115,1);

#stock is not available
insert into Orders (order_date,quantity,amount,no_of_bags,extra_charges,branch_id,product_id,cust_id)
	values('2023-03-23',3,45.00,0,0,111,1114,3);

select * from branch_product;
select * from orders;


/*Create a trigger which will be invoked on adding a new item in the Item entity and insert that
new item in another table with date and time when the item is added so that we can have date
and time when an item was added.*/

drop trigger lastUpdatedProduct;
DELIMITER //  
CREATE TRIGGER lastUpdatedProduct before INSERT  
ON Product FOR EACH ROW  
BEGIN  
declare updated_time datetime;
declare last_update datetime;
	set updated_time = current_timestamp();
   set new.last_update = updated_time;

END;// 

insert into Product (product_name,quantity,amount) values('Sugar',100,50.00);

alter table product add last_update datetime;
