-- Start fresh
DROP DATABASE IF EXISTS coffeeshop;
CREATE DATABASE coffeeshop;
USE coffeeshop;

-- Step 1: Drop all tables (reversed dependency order)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orderdetails;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS orderitemstemp;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS roledetail;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS tbl_user;

-- Step 2: Create `role`
CREATE TABLE `role` (
  `RoleID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` enum('Employee','Customer') NOT NULL,
  `CreatedOn` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`RoleID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 3: Create `roledetail`
CREATE TABLE `roledetail` (
  `RoleDetailID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleID` int(11) NOT NULL,
  `EmployeeID` int(11) DEFAULT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `PhoneNumber` varchar(15) NOT NULL UNIQUE,
  `Email` varchar(100) NOT NULL UNIQUE,
  `Photo` BLOB DEFAULT NULL,
  PRIMARY KEY (`RoleDetailID`),
  KEY `RoleID` (`RoleID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Step 4: Create `customers`
CREATE TABLE `customers` (
  `CustomerID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleDetailID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`CustomerID`),
  KEY `RoleDetailID` (`RoleDetailID`),
  CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`RoleDetailID`) REFERENCES `roledetail` (`RoleDetailID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 5: Create `employee`
CREATE TABLE `employee` (
  `EmployeeID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleDetailID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`EmployeeID`),
  KEY `RoleDetailID` (`RoleDetailID`),
  CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`RoleDetailID`) REFERENCES `roledetail` (`RoleDetailID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 6: Create `products`
CREATE TABLE `products` (
  `ProductID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Category` varchar(50) NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  `img` char(255) DEFAULT NULL,
  PRIMARY KEY (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 7: Create `orders`
CREATE TABLE `orders` (
  `OrderID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) DEFAULT NULL,
  `OrderDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `TotalAmount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `CustomerID` (`CustomerID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 8: Create `orderdetails`
CREATE TABLE `orderdetails` (
  `OrderDetailID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) DEFAULT NULL,
  `ProductID` int(11) DEFAULT NULL,
  `Quantity` int(11) NOT NULL,
  `Subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`OrderDetailID`),
  KEY `OrderID` (`OrderID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `orderdetails_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE,
  CONSTRAINT `orderdetails_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 9: Create `payments`
CREATE TABLE `payments` (
  `PaymentID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) DEFAULT NULL,
  `PaymentMethod` enum('Cash') DEFAULT 'Cash',
  `PaymentDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `Amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`PaymentID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Step 10: Create `OrderItemsTemp`
CREATE TABLE `orderitemstemp` (
  `TempID` int(11) NOT NULL AUTO_INCREMENT,
  `ProductID` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`TempID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Step 11: Create optional user table
CREATE TABLE `tbl_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `surname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `sex` varchar(10) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `address` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Step 12: Insert Roles
INSERT INTO `role` VALUES
(1,'Employee','2024-12-18 10:42:09'),
(2,'Customer','2024-12-18 10:42:09');

-- Step 13: Insert RoleDetails
INSERT INTO `roledetail` VALUES
(1,1,1,NULL,'111-222-3333','johndoe@example.com',NULL),
(2,1,2,NULL,'121-222-3333','kratie@example.com',NULL),
(11,2,NULL,5,'222-333-4444','janesmith@example.com',NULL),
(12,2,NULL,6,'123-456-7890','alice@example.com',NULL),
(13,2,NULL,7,'987-654-3210','bob@example.com',NULL),
(14,2,NULL,8,'555-123-4567','charlie@example.com',NULL);

-- Step 14: Insert Customers
INSERT INTO `customers` VALUES
(5,11,'Jane Smith'),
(6,12,'Alice Johnson'),
(7,13,'Bob Smith'),
(8,14,'Charlie Brown');

-- Step 15: Insert Employees
INSERT INTO `employee` VALUES
(1,1,'John Doe','password123',1),
(2,2,'Kratie','password345',1);

-- Step 16: Insert sample Payments
INSERT INTO `payments` (`OrderID`, `PaymentMethod`, `PaymentDate`, `Amount`)
VALUES
((SELECT `OrderID` FROM `orders` ORDER BY `OrderID` LIMIT 1), 'Cash', '2024-12-18 10:42:09', 6.00),
((SELECT `OrderID` FROM `orders` ORDER BY `OrderID` LIMIT 1 OFFSET 1), 'Cash', '2024-12-18 10:42:09', 8.50);

-- Step 17: Stored Procedure
DELIMITER ;;
CREATE DEFINER=`coffeedb`@`%` PROCEDURE `CreateMultiItemOrder`(
    IN p_customer_id INT
)
BEGIN
    DECLARE v_new_order_id INT;
    DECLARE v_rows_updated INT;

    START TRANSACTION;

    INSERT INTO orders (CustomerID, TotalAmount) 
    VALUES (p_customer_id, 0);
    
    SET v_new_order_id = LAST_INSERT_ID();

    INSERT INTO orderdetails (OrderID, ProductID, Quantity, Subtotal)
    SELECT 
        v_new_order_id,
        t.ProductID,
        t.Quantity,
        p.Price * t.Quantity AS Subtotal
    FROM OrderItemsTemp t
    JOIN products p ON t.ProductID = p.ProductID;

    UPDATE orders 
    SET TotalAmount = (
        SELECT COALESCE(SUM(Subtotal), 0)
        FROM orderdetails 
        WHERE OrderID = v_new_order_id
    )
    WHERE OrderID = v_new_order_id;

    SELECT ROW_COUNT() INTO v_rows_updated;
    
    IF v_rows_updated = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Failed to update order total';
    END IF;

    COMMIT;

    TRUNCATE TABLE OrderItemsTemp;

    WITH OrderSummary AS (
        SELECT 
            o.OrderID,
            o.CustomerID,
            o.TotalAmount,
            od.ProductID,
            p.Name AS ProductName,
            od.Quantity,
            od.Subtotal
        FROM orders o
        JOIN orderdetails od ON o.OrderID = od.OrderID
        JOIN products p ON od.ProductID = p.ProductID
        WHERE o.OrderID = v_new_order_id
    )
    SELECT * FROM OrderSummary
    UNION ALL
    SELECT 
        OrderID,
        CustomerID,
        TotalAmount,
        NULL as ProductID,
        'TOTAL' as ProductName,
        SUM(Quantity),
        SUM(Subtotal)
    FROM OrderSummary
    GROUP BY OrderID, CustomerID, TotalAmount;
END ;;
DELIMITER ;

-- Step 18: Create and grant user
CREATE USER IF NOT EXISTS 'coffeedb'@'%' IDENTIFIED BY 'passwd123';
GRANT ALL PRIVILEGES ON coffeeshop.* TO 'coffeedb'@'%';
FLUSH PRIVILEGES;
