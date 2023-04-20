drop table Payment;
drop table Orders;
drop table Bill;
drop table Product;
drop table Doctor;
drop table Customer;
CREATE TABLE Customer (
    cust_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    cust_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);
  
 CREATE TABLE Doctor (
    doc_id VARCHAR(5) NOT NULL PRIMARY KEY,
    doc_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE Product (
    product_id VARCHAR(5) PRIMARY KEY,
    product_Type VARCHAR(20),
    product_name VARCHAR(50) NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    curr_price DOUBLE NOT NULL,
    quantity INT NOT NULL,
    expiry_date DATE
);
  
CREATE TABLE Bill (
    bill_id VARCHAR(20) PRIMARY KEY,
    bill_date DATE,
    amount DOUBLE,
    cust_id INT,
    FOREIGN KEY (cust_id)
        REFERENCES Customer (cust_id),
    doc_id VARCHAR(5),
    FOREIGN KEY (doc_id)
        REFERENCES Doctor (doc_id)
);

CREATE TABLE Orders (
    bill_id VARCHAR(20),
    FOREIGN KEY (bill_id)
        REFERENCES Bill (bill_id),
    product_id VARCHAR(5),
    FOREIGN KEY (product_id)
        REFERENCES Product (product_id),
    pro_quantity INT,
    sold_price DOUBLE
);
    
CREATE TABLE Payment (
    payment_id VARCHAR(5) PRIMARY KEY,
    payment_mode VARCHAR(20),
    bill_id VARCHAR(20),
    FOREIGN KEY (bill_id)
        REFERENCES Bill (bill_id)
);

INSERT INTO Customer VALUES(1,'Rajeshwari','Ahmednagar','9890523327');
INSERT INTO Customer(cust_name,address,phone) VALUES('Raghu','Pune','9975203327'),('Pranav','Ahmendnagar','9527731056'),('Aishu','Nashik','9730684242'),('Santosh','Pali','9309103817');

SELECT * FROM Customer;

INSERT INTO Doctor VALUES('D1','smita','Ahmednagar','9987654208');
INSERT INTO Doctor VALUES('D2','Ram','Ahmednagar','9987654345'),('D3','Ramesh','Pune','9987654123');

SELECT * FROM Doctor;

INSERT INTO Product VALUES ('P1','Tablet','Montar-LC','Cipla',20.00,30,'2025-04-20'), ('P2','Tablet','Cifixime','JSK',40.00,20,'2023-04-20'),
('P3','Syrup','cough-syrup','Cipla',150.00,10,'2024-04-20'),('P4','Tablet','Crocine','JSK',10.00,5,'2023-10-20'),
('P5','Syrup','Broxovic','Vibcare',240.00,20,'2023-06-20');
INSERT INTO Product VALUES('P6','Tablet','cifixime','JSK',40.00,10,'2023-02-10');

SELECT * FROM Product;

INSERT INTO Bill VALUES ('BIL/20230110/0001','2023-01-10',200.00,1,'D1'),
	('BIL/20230108/0001','2023-01-08',150.00,1,'D2'),('BIL/20230110/0002','2023-01-10',50.00,2,'D2');

SELECT * FROM Bill;

INSERT INTO Orders VALUES ('BIL/20230110/0001','P1',4,20.00), ('BIL/20230110/0001','P2',3,40.00), ('BIL/20230108/0001','P3',1,150.00), ('BIL/20230110/0002','P4',1,10.00),('BIL/20230110/0002','P2',1,40.00);

SELECT * FROM Orders;

INSERT INTO Payment VALUES ('PA101','cash','BIL/20230110/0001'),('PA102','Credit card','BIL/20230108/0001'),('PA103','UPI','BIL/20230110/0002');

SELECT * FROM payment;


/*1. Create SP to insert Customer Data if not exists. Customer existence should be based on 
mobile no. Returns customer id (auto-generated).*/

drop procedure CustomerInsert;
DELIMITER //
CREATE PROCEDURE `CustomerInsert` (in new_name varchar(30), in new_address varchar(30), in new_phone varchar(10))
BEGIN
if new_phone not in (select phone from Customer)
then
insert into Customer(cust_name,address,phone) values(new_name,new_address,new_phone);
end if;
select cust_id from Customer where new_phone = phone;
END;//

call CustomerInsert('Amit','Shrigondha','9921012725');
call CustomerInsert('Rajeshwari','Ahmednagar','9890523327');
SELECT * FROM Customer;


/*2. Create a function to return Bill No to be used. BIL/YYYYMMDD/xxxx (where xxxx is 0001 to 9999).*/

drop procedure DisplayBillNO;
DELIMITER //
CREATE PROCEDURE `DisplayBillNO` ( in new_billDate date)
BEGIN
	declare sub int default 0; 
    
     if(select bill_id from Bill where amount is null and bill_date = new_billDate)is not null then
	set sub = substr((select max(bill_id) from Bill where bill_date = new_billDate),-1,4);
	
    else
    set sub = (select coalesce(max(substr(bill_id,-1,4)),0)+1 from Bill where bill_date=new_billDate);
      insert into Bill(bill_id,bill_date) values((select concat('BIL/',date_format(new_billDate,'%Y%m%d'),'/',lpad(sub,4,0))),new_billDate);

   end if;

    select * from Bill where amount is NULL and bill_date = new_billDate;
END;//
call DisplayBillNO('2023-01-10'); 
select * from Bill;


/*
drop procedure BillDtl2;
DELIMITER //
CREATE PROCEDURE `BillDtl2` ( in new_billDate date)
BEGIN
	declare sub int default 0; 
    
    if( select bill_id from Bill where amount is null and bill_date = new_billDate ) is null then
	set sub = sub +1;
	insert into Bill(bill_id,bill_date) values((select concat('BIL/',date_format(new_billDate,'%Y%m%d'),'/',lpad(sub,4,0))),new_billDate);
	
    else if(select bill_id from Bill where amount is null and bill_date = new_billDate)is not null then
	set sub = substr((select max(bill_id) from Bill where bill_date = new_billDate),-1,4);
	
    else
    set sub = substr((select max(bill_id) from Bill where bill_date = new_billDate),-1,4) +1;
   insert into Bill(bill_id,bill_date) values((select concat('BIL/',date_format(new_billDate,'%Y%m%d'),'/',lpad(sub,4,0))),new_billDate);

    end if;
    end if;
   
    select * from Bill where amount is NULL and bill_date = new_billDate;
END;//
call BillDtl2('2023-01-08'); 
call BillDtl2('2023-01-23'); 
select * from Bill;

 declare @sub default 0;
    set @sub = substr((select max(bill_id) from Bill where bill_date = '2023-01-23'),-1,4) +1;

insert into Bill(bill_id,bill_date) values((select concat('BIL/',date_format('2023-01-10','%Y%m%d'),'/',lpad(@sub,4,0))),'2023-01-10');
select * from Bill;

insert into Bill(bill_id,bill_date) values((select concat('BIL/',date_format('2023-01-23','%Y%m%d'),'/',lpad(@sub,4,0))),'2023-01-23');

select concat('BIL/',date_format('2022-01-23','%Y%m%d'),'/',lpad(@sub,4,0));
  set @sub = substr('BIL/20250101/0005',-1,4) +1;
  select @sub;
  
 select date_format('2022-01-23','%Y%m%d');
 select bill_id from Bill where amount is null and bill_date = '2023-01-08';

 select bill_date ,max(substr(bill_id,-1,4)) from Bill group  by bill_date;
 select coalesce(max(substr(bill_id,-1,4)),0)+1 from Bill where bill_date='2023-01-15';
 
*/



/*3. Create SP to insert line items one by one. Return total amount during each insertion.*/

drop procedure OrderPlaced;
DELIMITER //
CREATE PROCEDURE `OrderPlaced` (in new_billId varchar(20), in new_productId varchar(5), in new_proQuantity int,in new_custId int,in new_docId varchar(5))
BEGIN
	declare total int default 0;
   declare amt int;
   set amt = (select curr_price from Product where product_id =new_productId);
   
   insert into Orders values(new_billId,new_productId,new_proQuantity,amt);
	set total =new_proQuantity * amt ;
     
     if(select amount from Bill where bill_id = new_billId) is null then
     update Bill set amount = total where bill_id =new_billId; 

    else
	update Bill set amount = (amount +total) where bill_id =new_billId; 
   end if;
	
    update Bill set cust_id = new_custId, doc_id = new_docId where bill_id = new_billID;
    select * from Bill ;
END;//

call OrderPlaced('BIL/20230110/0003','P3',1,2,'D1');
call OrderPlaced('BIL/20230110/0003','P4',1,2,'D2');
select * from Orders;

/*delete from Bill where bill_id ='BIL/20230110/0003';*/

/*4. Use trigger/SP to reduce stock inventory.*/
 
 drop trigger InventoryStock;
 DELIMITER //  
CREATE TRIGGER InventoryStock BEFORE INSERT  
ON Orders FOR EACH ROW  
BEGIN  

if (select quantity from Product where Product.product_id = new.product_id )< new.pro_quantity then
	signal sqlstate '45000' 
    set message_text ='Not valid quantity';
else
   update Product set quantity = quantity - new.pro_quantity where Product.product_id = new.product_id;

 end if;

END;// 

select * from Product;
select * from Orders;


/*5. Create SP to display top 10 items sold by date/by month. Top 10 by no. of items and monetary value.*/

/*date wise*/
drop procedure DisplayProduct;
DELIMITER //
CREATE PROCEDURE `DisplayProduct` (in new_date date)
BEGIN
select Orders.product_id ,Product.product_name,sum(pro_quantity) as Quantity_sold from Orders join Bill on Orders.bill_id = Bill.bill_id join Product on Orders.product_id = Product.product_id where Bill.bill_date = new_date group by product_id order by Quantity_sold desc limit 10;
END;//
call DisplayProduct('2023-01-10');


/*by monetary*/
drop procedure DisplayProductByMoney;
DELIMITER //
CREATE PROCEDURE `DisplayProductByMoney` ()
BEGIN
select Orders.product_id ,Product.product_name,sum(sold_price * pro_quantity) as Sold_Price from Orders join Product on Orders.product_id = Product.product_id  group by product_id order by Sold_Price desc limit 10;
END;//
call DisplayProductByMoney();

/*
select sum(pro_quantity) as cnt,Orders.product_id ,Product.product_name from Orders join Bill on Orders.bill_id = Bill.bill_id join Product on Orders.product_id = Product.product_id where Bill.bill_date = '2023-01-10' group by product_id order by cnt desc;
select sum(sold_price * pro_quantity) as amt,Orders.product_id ,Product.product_name from Orders join Product on Orders.product_id = Product.product_id group by product_id order by amt desc limit 10;
*/


/*6. Create SP to display items nearing expiry (less than 5 months, 4 months, 3....so on).*/

drop procedure DisplayProductByExpiry;
DELIMITER //
CREATE PROCEDURE `DisplayProductByExpiry` ()
BEGIN
select product_name,period_diff(date_format(expiry_date,'%y%m'),date_format(curdate(),'%y%m')) as mnthsTOExpire from Product order by mnthsTOExpire;

/*select Product.product_name, Product.product_id,period_diff(date_format(expiry_date,'%y%m'),date_format(curdate(),'%y%m')) as mnthsTOExpire , max(Bill.bill_date) as Last_Sold from Product join Orders on Product.product_id = Orders.product_id join Bill on Orders.bill_id = Bill.bill_id group by Product.product_id  order by mnthsTOExpire;
*/
END;//
call DisplayProductByExpiry();

/*
select timestampdiff(month,'2022-09-12',CURDATE()) as datedifference;
select expiry_date,datediff(expiry_date,curdate()) as df from Product;
select period_diff(date_format(expiry_date,'%y%m'),date_format(curdate(),'%y%m'))as mnthsTOExpire, product_name from Product order by mnth;
*/

/*7. Create SP/view to display items nearing out of stock. (less than 10).*/
CREATE VIEW OutOFStock AS select * from Product where quantity <=10;
select * from OutOFStock;
