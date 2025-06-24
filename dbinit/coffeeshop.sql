CREATE DATABASE coffeeshop;
use coffeeshop;

DROP TABLE IF EXISTS `OrderItemsTemp`;
CREATE TABLE `OrderItemsTemp` (
  `TempID` int(11) NOT NULL AUTO_INCREMENT,
  `ProductID` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`TempID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `OrderItemsTemp` WRITE;
UNLOCK TABLES;

DROP TABLE IF EXISTS `customers`;

CREATE TABLE `customers` (
  `CustomerID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleDetailID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`CustomerID`),
  KEY `RoleDetailID` (`RoleDetailID`),
  CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`RoleDetailID`) REFERENCES `roledetail` (`RoleDetailID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

LOCK TABLES `customers` WRITE;
INSERT INTO `customers` VALUES
(5,11,'Jane Smith'),
(6,12,'Alice Johnson'),
(7,13,'Bob Smith'),
(8,14,'Charlie Brown');
UNLOCK TABLES;

DROP TABLE IF EXISTS `employee`;

CREATE TABLE `employee` (
  `EmployeeID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleDetailID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`EmployeeID`),
  KEY `RoleDetailID` (`RoleDetailID`),
  CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`RoleDetailID`) REFERENCES `roledetail` (`RoleDetailID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES
(1,1,'John Doe','password123',1),
(2,2,'Kratie','password345',1);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;


DROP TABLE IF EXISTS `orderdetails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=7202 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


DROP TABLE IF EXISTS `orderitemstemp`;

CREATE TABLE `orderitemstemp` (
  `TempID` int(11) NOT NULL AUTO_INCREMENT,
  `ProductID` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`TempID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

LOCK TABLES `orderitemstemp` WRITE;
/*!40000 ALTER TABLE `orderitemstemp` DISABLE KEYS */;
/*!40000 ALTER TABLE `orderitemstemp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `OrderID` int(11) NOT NULL AUTO_INCREMENT,
  `CustomerID` int(11) DEFAULT NULL,
  `OrderDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `TotalAmount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `CustomerID` (`CustomerID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1073 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;

UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payments` (
  `PaymentID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) DEFAULT NULL,
  `PaymentMethod` enum('Cash') DEFAULT 'Cash',
  `PaymentDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `Amount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`PaymentID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES
(1,1,'Cash','2024-12-18 10:42:09',6.00),
(2,2,'Cash','2024-12-18 10:42:09',8.50);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `ProductID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Category` varchar(50) NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  `img` char(255) DEFAULT NULL,
  PRIMARY KEY (`ProductID`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
UNLOCK TABLES;

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `RoleID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` enum('Employee','Customer') NOT NULL,
  `CreatedOn` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`RoleID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES
(1,'Employee','2024-12-18 10:42:09'),
(2,'Customer','2024-12-18 10:42:09');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roledetail`
--

DROP TABLE IF EXISTS `roledetail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roledetail` (
  `RoleDetailID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleID` int(11) NOT NULL,
  `EmployeeID` int(11) DEFAULT NULL,
  `CustomerID` int(11) DEFAULT NULL,
  `PhoneNumber` varchar(15) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Photo` blob DEFAULT NULL,
  PRIMARY KEY (`RoleDetailID`),
  UNIQUE KEY `PhoneNumber` (`PhoneNumber`),
  UNIQUE KEY `Email` (`Email`),
  KEY `RoleID` (`RoleID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roledetail`
--

LOCK TABLES `roledetail` WRITE;
/*!40000 ALTER TABLE `roledetail` DISABLE KEYS */;
INSERT INTO `roledetail` VALUES
(1,1,1,NULL,'111-222-3333','johndoe@example.com',NULL),
(2,1,2,NULL,'121-222-3333','kratie@example.com',NULL),
(11,2,NULL,5,'222-333-4444','janesmith@example.com',NULL),
(12,2,NULL,6,'123-456-7890','alice@example.com',NULL),
(13,2,NULL,7,'987-654-3210','bob@example.com',NULL),
(14,2,NULL,8,'555-123-4567','charlie@example.com',NULL);
/*!40000 ALTER TABLE `roledetail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tbl_user`
--

DROP TABLE IF EXISTS `tbl_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tbl_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `surname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `sex` varchar(10) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `address` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100301 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tbl_user`
--

LOCK TABLES `tbl_user` WRITE;
/*!40000 ALTER TABLE `tbl_user` DISABLE KEYS */;

UNLOCK TABLES;

DELIMITER ;;
CREATE DEFINER=`coffeedb`@`%` PROCEDURE `CreateMultiItemOrder`(
    IN p_customer_id INT
)
BEGIN
    DECLARE v_new_order_id INT;
    DECLARE v_rows_updated INT;
    DECLARE v_total_amount DECIMAL(10,2);

    -- Start transaction
    START TRANSACTION;

    -- Create new order with initial total of 0
    INSERT INTO orders (CustomerID, TotalAmount) 
    VALUES (p_customer_id, 0);
    
    SET v_new_order_id = LAST_INSERT_ID();

    -- Insert order details for all items
    INSERT INTO orderdetails (OrderID, ProductID, Quantity, Subtotal)
    SELECT 
        v_new_order_id,
        t.ProductID,
        t.Quantity,
        p.Price * t.Quantity AS Subtotal
    FROM OrderItemsTemp t
    JOIN products p ON t.ProductID = p.ProductID;

    -- Update order total
    UPDATE orders 
    SET TotalAmount = (
        SELECT COALESCE(SUM(Subtotal), 0)
        FROM orderdetails 
        WHERE OrderID = v_new_order_id
    )
    WHERE OrderID = v_new_order_id;

    -- Verify the update was successful
    SELECT ROW_COUNT() INTO v_rows_updated;
    
    IF v_rows_updated = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Failed to update order total';
    END IF;

    COMMIT;

    -- Clear the temporary items
    TRUNCATE TABLE OrderItemsTemp;

    -- Return order details with product information
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
        SUM(Quantity) as TotalQuantity,
        SUM(Subtotal) as TotalAmount
    FROM OrderSummary
    GROUP BY OrderID, CustomerID, TotalAmount;

END ;;
DELIMITER ;
CREATE USER 'coffeedb' IDENTIFIED BY 'passwd123';
GRANT ALL PRIVILEGES ON coffeeshop.* TO 'coffeedb';
FLUSH PRIVILEGES;