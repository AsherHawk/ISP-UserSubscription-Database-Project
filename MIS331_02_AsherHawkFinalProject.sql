-- NETID: asherhawk
-- Asher Hawk's MIS 331 02 Final Project
-- Topic Assigned to Me: ISP 
-- Database Idea: User Subscription Service
USE asherhawk_project;

-- put drop table if they exist once done with all them

DROP TABLE IF EXISTS `ServiceNotifications`;
DROP TABLE IF EXISTS `PaymentHistory`;
DROP TABLE IF EXISTS `Billing`;
DROP TABLE IF EXISTS `SubscriptionServices`;
DROP TABLE IF EXISTS `NetworkDevices`;
DROP TABLE IF EXISTS `UserSupportTickets`;
DROP TABLE IF EXISTS `PaymentMethods`;
DROP TABLE IF EXISTS `ServiceUsage`;
DROP TABLE IF EXISTS `UserStatusChangeLog`;
DROP TABLE IF EXISTS `UserSubscriptions`;
DROP TABLE IF EXISTS `Users`;
DROP TABLE IF EXISTS `ServiceAnnouncements`;
DROP TABLE IF EXISTS `SubscriptionPlans`;
DROP TABLE IF EXISTS `ServiceTypes`;
DROP TABLE IF EXISTS `RatePlans`;

-- these tables are in the correct order that they should be ran now. proceed like this going forward within your project

CREATE TABLE `Users` (
  `UserID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserName` VARCHAR(50),
  `UserPassword` VARCHAR(64),
  `Email` VARCHAR(320),
  `FullName` VARCHAR(100),
  `Address` VARCHAR(255),
  `PhoneNumber` VARCHAR(20),
  `RegistrationDate` DATE,
  `UserStatus` ENUM('Active', 'Suspended', 'Deleted')
);

DROP INDEX idx_user_status ON Users;
CREATE INDEX idx_user_status ON Users(UserStatus); -- All the indexes i have created are based on the amount of types i used a table in my stored procedures and functions. so all my indexes going forward will have the same comment next to them which is 'Index created due to use of within a procedure/function'

CREATE TABLE `UserStatusChangeLog` (
  `LogID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT,
  `OldStatus` ENUM('Active', 'Suspended', 'Deleted'),
  `NewStatus` ENUM('Active', 'Suspended', 'Deleted'),
  `ChangeDate` DATE,
  FOREIGN KEY (`UserID`) REFERENCES `Users`(`UserID`)
);

DROP INDEX idx_change_date ON UserStatusChangeLog;
CREATE INDEX idx_change_date ON UserStatusChangeLog(ChangeDate); -- 'Index created due to use within a procedure/function'

CREATE TABLE `SubscriptionPlans` (
  `PlanID` INT AUTO_INCREMENT PRIMARY KEY,
  `PlanName` VARCHAR(100),
  `InternetSpeedLimit` VARCHAR(50),
  `DataCap` INT,
  `PricePerMonth` DECIMAL(10,2)
);

CREATE TABLE `ServiceTypes` (
  `ServiceTypeID` INT AUTO_INCREMENT PRIMARY KEY,
  `ServiceTypeName` VARCHAR(100),
  `Description` TEXT
);

CREATE TABLE `RatePlans` (
  `RatePlanID` INT AUTO_INCREMENT PRIMARY KEY,
  `RatePlanName` VARCHAR(100),
  `Description` TEXT,
  `DiscountRate` DECIMAL(5,2),
  `StartDate` DATE,
  `EndDate` DATE,
  `Conditions` TEXT
);

CREATE TABLE `ServiceAnnouncements` (
  `AnnouncementID` INT AUTO_INCREMENT PRIMARY KEY,
  `Title` VARCHAR(150),
  `DatePosted` DATE,
  `Content` TEXT,
  `ExpirationDate` DATE,
  `Category` VARCHAR(50)
);

CREATE TABLE `ServiceNotifications` (
  `NotificationID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT NOT NULL,
  `NotificationDate` DATE NOT NULL,
  `Message` TEXT NOT NULL,
  `AnnouncementID` INT,
  FOREIGN KEY (`UserID`) REFERENCES `Users`(`UserID`),
  FOREIGN KEY (`AnnouncementID`) REFERENCES `ServiceAnnouncements`(`AnnouncementID`)
);
-- for foreign keys to work had to make sure this table is created after Users and ServiceAnnouncement
DROP INDEX idx_notification_user ON ServiceNotifications;
CREATE INDEX idx_notification_user ON ServiceNotifications(UserID); -- 'Index created due to use within a procedure/function'

CREATE TABLE `UserSubscriptions` (
  `SubscriptionID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT,
  `PlanID` INT,
  `StartDate` DATE,
  `EndDate` DATE,
  `SubscriptionStatus` ENUM('Active', 'Pending', 'Paused', 'Expired', 'Cancelled'),
  FOREIGN KEY (`UserID`) REFERENCES `Users`(`UserID`),
  FOREIGN KEY (`PlanID`) REFERENCES `SubscriptionPlans`(`PlanID`)
);

DROP INDEX idx_subscription_status ON UserSubscriptions;
CREATE INDEX idx_subscription_status ON UserSubscriptions(SubscriptionStatus); -- 'Index created due to use within a procedure/function'

CREATE TABLE `NetworkDevices` (
  `DeviceID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT,
  `DeviceType` VARCHAR(50),
  `ModelNumber` VARCHAR(50),
  `SerialNumber` VARCHAR(50),
  `MACAddress` VARCHAR(20),  -- Corrected spelling
  `InstallationDate` DATE,
  `DeviceStatus` ENUM('Active', 'Inactive', 'Under Maintenance'),
  FOREIGN KEY (`UserID`) REFERENCES `Users`(`UserID`)
);

DROP INDEX idx_device_status ON NetworkDevices;
CREATE INDEX idx_device_status ON NetworkDevices(DeviceStatus); -- 'Index created due to use within a procedure/function'

CREATE TABLE `PaymentMethods` (
  `PaymentMethodID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT,
  `PaymentMethodName` VARCHAR(50),
  `IsDefault` BOOLEAN,
  `LastUsedDate` DATE,
  FOREIGN KEY (`UserID`) REFERENCES `Users`(`UserID`)
);

DROP INDEX idx_payment_default ON PaymentMethods;
CREATE INDEX idx_payment_default ON PaymentMethods(IsDefault); -- 'Index created due to use within a procedure/function'

CREATE TABLE `SubscriptionServices` (
  `SubscriptionServiceID` INT AUTO_INCREMENT PRIMARY KEY,
  `SubscriptionID` INT,
  `ServiceTypeID` INT,
  FOREIGN KEY (`SubscriptionID`) REFERENCES `UserSubscriptions`(`SubscriptionID`),
  FOREIGN KEY (`ServiceTypeID`) REFERENCES `ServiceTypes`(`ServiceTypeID`)
);

CREATE TABLE `Billing` (
  `BillID` INT AUTO_INCREMENT PRIMARY KEY,
  `SubscriptionID` INT,
  `BillingDate` DATE,
  `BillingDueDate` DATE,
  `BillingAmount` DECIMAL(10,2),
  `BillingStatus` ENUM('Issued', 'Paid', 'Overdue', 'Disputed'),
  FOREIGN KEY (`SubscriptionID`) REFERENCES `UserSubscriptions`(`SubscriptionID`)
);

DROP INDEX idx_billing_status ON Billing;
CREATE INDEX idx_billing_status ON Billing(BillingStatus); -- 'Index created due to use within a procedure/function'

CREATE TABLE `PaymentHistory` (
  `PaymentID` INT AUTO_INCREMENT PRIMARY KEY,
  `BillID` INT,
  `PaymentDate` DATE,
  `PaymentMethod` VARCHAR(50),
  `AmountPaid` DECIMAL(10,2),
  FOREIGN KEY (`BillID`) REFERENCES `Billing`(`BillID`)
);

DROP INDEX idx_payment_date ON PaymentHistory;
CREATE INDEX idx_payment_date ON PaymentHistory(PaymentDate); -- 'Index created due to use within a procedure/function'

CREATE TABLE `UserSupportTickets` (
  `TicketID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT,
  `IssueDate` DATE,
  `IssueDescription` TEXT,
  `ResolutionStatus` ENUM('New', 'Open', 'Pending', 'Resolved', 'Closed', 'Cancelled'),
  FOREIGN KEY (`UserID`) REFERENCES `Users`(`UserID`)
);

DROP INDEX idx_ticket_status ON UserSupportTickets;
CREATE INDEX idx_ticket_status ON UserSupportTickets(ResolutionStatus); -- 'Index created due to use within a procedure/function'

CREATE TABLE `ServiceUsage` (
  `UsageID` INT AUTO_INCREMENT PRIMARY KEY,
  `SubscriptionID` int,
  `CurrentDate` date,
  `DataUsed` int,
  FOREIGN KEY (`SubscriptionID`) REFERENCES `UserSubscriptions`(`SubscriptionID`)
);

DROP INDEX idx_usage_date ON ServiceUsage;
CREATE INDEX idx_usage_date ON ServiceUsage(CurrentDate); -- 'Index created due to use within a procedure/function'

-- Now here is my inserting sample data
-- these were adjusted many times as my procedures and functions were being made so that when they were run they would show results that proved the function worked and not just 0 or NUll because the functions could work when that shows up but you can't really know for sure
-- took a while to get the order of the insert values correct as well to make the foreign keys all be integrate and work and run smoothly, but as i worked on it I understod the concept more and more it got easier in future adjustments
-- to keep it neat i'm not going to put the code in here randomly, but i will say that 'set foreign key checks to 0, truncating the table, and setting it back to 1' was my savior at times. thought i would at least explain a little how i made these adjustments rather just say im doing them
INSERT INTO `Users` (`UserName`, `UserPassword`, `Email`, `FullName`, `Address`, `PhoneNumber`, `RegistrationDate`, `UserStatus`)
VALUES 
('jdoe', 'pass123', 'jdoe@example.com', 'John Doe', '123 Broadway St', '999-555-1234', '2015-02-24', 'Active'),
('Jamgih', 'pass456', 'jamigh@example.com', 'Jared Amigh', '456 Phillip St', '888-555-5678', '2014-05-14', 'Active'),
('Cteal', 'pass445', 'cteal@example.com', 'Craig Teal', '23 Happy Blvd', '444-555-6878', '2021-07-07', 'Active'),
('Mpoppins', 'pass332', 'mpoppins@example.com', 'Marry Poppins', '16 Fairytale Rd', '122-585-5678', '2022-01-04', 'Suspended');

-- now that 4 samples are created. if our addnewuser procedure was ran it would create a new user after these and create our 5th user
SELECT *
FROM Users;
-- SELECT Statment to check Users Values

INSERT INTO `UserStatusChangeLog` (`UserID`, `OldStatus`, `NewStatus`, `ChangeDate`)
VALUES
(1, 'Active', 'Active', '2023-09-01'),
(2, 'Active', 'Active', '2023-09-02'), 
(3, 'Active', 'Suspended', '2023-07-08'), 
(4, 'Active', 'Suspended', '2022-01-05');
-- sample data for the changelog
SELECT *
FROM UserStatusChangeLog;
-- SELECT Statment to check UserStatusChangeLog Values


INSERT INTO `ServiceTypes` (`ServiceTypeName`, `Description`)
VALUES 
('Internet', 'High-speed internet service'),
('TV', 'High-speed internet service'),
('Premium Internet', 'Cable television service'),
('Basic Cable TV', 'Standard Cable Service');
-- some examples our servicetypes that ISP's provide
SELECT *
FROM ServiceTypes;
-- SELECT Statement to check ServiceTypes Values




INSERT INTO `SubscriptionPlans` (`PlanName`, `InternetSpeedLimit`, `DataCap`, `PricePerMonth`)
VALUES 
('Basic Internet', '200Mbps', 1000, 39.99),
('Better Internet', '400Mbps', 2000, 59.99),
('Best Internet', '940Mbps', 0, 79.99),
('Basic TV + Internet', '200Mbps', 1000, 79.99),
('Premium TV + Internet', '940Mbps', 0, 129.99);
-- these samples are a mix of using real life ISP's like Verizon to understand pricepoints and datacaps and speedlimits while also using dummy names like 'basic' 'better' and those titles for the subscription plans
-- looked at verizons subscirptions plans and comcasts for frame of reference if you need to go back
SELECT *
FROM SubscriptionPlans;
-- SELECT Statement to check SubscriptionPlans Values

INSERT INTO `RatePlans` (`RatePlanName`, `Description`, `DiscountRate`, `StartDate`, `EndDate`, `Conditions`)
VALUES 
('Summer Special', 'A Summer Discount for new members during summer', 15.00, '2023-06-01', '2023-08-31', 'New memebrs only'),
('New Year Special', 'Start the new year with new internet', 10.00, '2024-01-01', '2024-01-31', 'New memebrs only');
-- just two sample rateplans that are examples of what some popular events that might lead to new rates being created
SELECT *
FROM RatePlans;
-- SELECT Statement to check RatePlans Values

INSERT INTO `UserSubscriptions` (`UserID`, `PlanID`, `StartDate`, `EndDate`, `SubscriptionStatus`)
VALUES 
(1, 1, '2023-01-01', '2024-01-01', 'Active'),
(2, 2, '2023-01-15', '2024-01-15', 'Active'),
(3, 3, '2024-01-01', '2025-01-01', 'Active'),
(3, 3, '2022-04-22', '2024-03-22', 'Active'),
(4, 4, '2023-01-11', '2024-01-11', 'Active');

SELECT *
FROM UserSubscriptions;
-- SELECT Statement to check UserSubscriptions Values

INSERT INTO `NetworkDevices` (`UserID`, `DeviceType`, `ModelNumber`, `SerialNumber`, `MACAddress`, `InstallationDate`, `DeviceStatus`)
VALUES 
(1, 'Router', 'EXROUT1000', 'EXMODEL123', '01-2345-6789-ABCD', '2023-01-01', 'Active'),
(2, 'Router', 'EXROUT2000', 'EXMODEL345', '98-765-4321-ZYXW', '2023-01-15', 'Active'),
(3, 'Router', 'EXROUT3000', 'EXMODEL678', '03-4444-2121-LMNO', '2024-01-01', 'Active');
-- typed in random seriel numbers and devicetypes etc...
SELECT *
FROM NetworkDevices;
-- SELECT Statement to check NetworkDevices Values

INSERT INTO `PaymentMethods` (`UserID`, `PaymentMethodName`, `IsDefault`, `LastUsedDate`)
VALUES 
(1, 'Credit Card', TRUE, '2023-01-01'),
(2, 'Debit Card', TRUE, '2023-01-15'),
(3, 'Credit Card', TRUE, '2024-01-01');
--
SELECT *
FROM PaymentMethods;
-- SELECT Statement to check PaymentMethods Values

INSERT INTO `SubscriptionServices` (`SubscriptionID`, `ServiceTypeID`)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4);

SELECT *
FROM SubscriptionServices;
-- SELECT Statement to check SubscriptionServices Values


INSERT INTO `Billing` (`SubscriptionID`, `BillingDate`, `BillingDueDate`, `BillingAmount`, `BillingStatus`)
VALUES 
(1, '2023-01-01', '2023-02-01', 29.99, 'Overdue'),
(2, '2023-01-15', '2023-02-15', 29.99, 'Issued'),
(3, '2024-01-01', '2024-02-01', 29.99, 'Issued'),
(4, '2024-01-11', '2024-02-11', 29.99, 'Overdue');
--
SELECT *
FROM Billing;
-- SELECT Statement to check Billing Values

INSERT INTO `PaymentHistory` (`BillID`, `PaymentDate`, `PaymentMethod`, `AmountPaid`)
VALUES 
(1, '2023-01-01', 'Credit Card', 29.99),
(2, '2023-01-17', 'Debit Card', 29.99),
(3, '2024-01-25', 'Credit Card', 29.99),
(4, '2024-01-20', 'Credit Card', 29.99);
-- billID matches up with Billing's billId so foreign keys work
-- also important to note that for this to work smoothly it also must be ran after billing is ran so the foreign keys actually work. hence why this code falls after the billing code
SELECT *
FROM PaymentHistory;
-- SELECT Statement to check PaymentHistory Values

INSERT INTO `UserSupportTickets` (`UserID`, `IssueDate`, `IssueDescription`, `ResolutionStatus`)
VALUES 
(1, '2023-01-10', 'Issue with setting up router.', 'Closed'),
(2, '2023-05-10', 'Issue with internet speed.', 'Closed'),
(3, '2023-04-16', 'Issue with adding new user to home internet.', 'Open'),
(4, '2023-03-10', 'Cable Tv is done.', 'Closed');
-- foreign keys match up (UserID here matches up with UserId on Users table)
SELECT *
FROM UserSupportTickets;
-- SELECT Statement to check UserSupportTickets Values

INSERT INTO `ServiceUsage` (`SubscriptionID`, `CurrentDate`, `DataUsed`)
VALUES 
(1, '2023-12-10', 250),
(1, '2024-01-10', 300),
(1, '2024-02-10', 200),
(2, '2023-12-15', 150),
(3, '2024-01-15', 275),
(3, '2024-02-15', 325),
(3, '2024-03-15', 350),
(4, '2024-01-20', 3000);
-- SubscriptionID foreign keys match up and work
SELECT *
FROM ServiceUsage;
-- SELECT Statement to check ServiceUsage Values

INSERT INTO `ServiceAnnouncements` (`Title`, `DatePosted`, `Content`, `ExpirationDate`, `Category`)
VALUES 
('Troublehsooting', '2024-04-27', 'debugging and troubleshooting required; expected downtime during midnight.', '2024-04-28', 'Maintenance');
-- example of a maintenance update that could occur in the ISP's operations
SELECT *
FROM ServiceAnnouncements;
-- SELECT Statement to check ServiceAnnouncements Values

INSERT INTO `ServiceNotifications` (`UserID`, `NotificationDate`, `Message`, `AnnouncementID`)
VALUES
(1, '2023-04-22', 'Reminder: Scheduled maintenance on April 28th for Troubleshooting. Expect service to be down.', 1),
(2, '2023-04-22', 'Reminder: Scheduled maintenance on April 28th for Troubleshooting. Expect service to be down.', 1),
(3, '2023-04-22', 'Reminder: Scheduled maintenance on April 28th for Troubleshooting. Expect service to be down.', 1),
(4, '2023-04-22', 'Reminder: Scheduled maintenance on April 28th for Troubleshooting. Expect service to be down.', 1);
-- example of a maintenance update notification that could occur in the ISP's operations
SELECT *
FROM ServiceNotifications;
-- SELECT Statement to check ServiceNotifications Values

-- NOW THAT ALL THE TABLES ARE CREATED AND FOREIGN KEYS ARE MATCHED AND WORKING AND SAMPLE DATA IS PUT INTO THE TABELS IM GOING TO MOVE TO THE STORED PROCEDURES.
-- My first 15 procedures (orginally 13 but two tables were created during the creation of procedure #17 & #18) were based on your suggestion in the orignial semster instruction, "I suggest writing one procedure for each table (inserting all of the information about a new customer)"
-- I wanted to do it anyways to test myself and because,for me personally at least, its sometimes easier expanding and doing the more details for the project to see it all come together rather than trying to find ways to concise it as much as possible while still making it work
-- I am aware that i could basically take those insert procedures could and modify them slightly and have Update procedures or Delete procedures but didn't know if that was really gonna be that necessary. but im gonna ask in class again

-- ORDERED SAME AS TABLE CREATION ORDER

-- Procedure #1 Table: Users
-- This was part of my project deliverable so i went a little one step further with it to show what i have learned this semester
-- by that i mean using both IN and OUT paremeters and incorprated an IF ELSE statement 
DROP PROCEDURE IF EXISTS `AddNewUser`
-- the p is short for parameter to just keep it simple for parameter names, using that for all procedure and functinos so i'm consistent whenever i log back on and off of workbench to work on this project
DELIMITER $$
CREATE PROCEDURE AddNewUser(
    IN pUsername VARCHAR(50),
    IN pUserPassword VARCHAR(64),
    IN pEmail VARCHAR(320),
    IN pFullName VARCHAR(100),
    IN pAddress VARCHAR(255),
    IN pPhoneNumber VARCHAR(20),
    OUT NewUserID INT,
    OUT OperationStatus VARCHAR(100)
)
BEGIN
    INSERT INTO `Users` (`Username`, `UserPassword`, `Email`, `FullName`, `Address`, `PhoneNumber`, `RegistrationDate`, `UserStatus`)
    VALUES (pUsername, pUserPassword, pEmail, pFullName, pAddress, pPhoneNumber, CURDATE(), 'Active');
	-- Shown in class to set NewUserID to the last inserted ID
    SET NewUserID = LAST_INSERT_ID();
    
    IF NewUserID > 0 THEN
        SET OperationStatus = 'Success: User added.';
    ELSE
        SET OperationStatus = 'Failure: User was not added.';
    END IF;
END$$

DELIMITER ;
-- Found the If Else statment example in the documentation and adjusted it to my scenario
-- to check if it worked
CALL AddNewUser('exampleUser', 'examplePass', 'user@example.com', 'Example Name', '123 Main St', '123-456-789', @NewUserID, @OperationStatus); 
-- in and out paramenters entered. we enter all the users infromation and out comes as new userid and approval that it was sucessful. 
SELECT @NewUserID, @OperationStatus;

SELECT *
FROM Users;
-- Select statements


-- Procedure #2 Table: UserStatusChangeLog
DROP PROCEDURE IF EXISTS `InsertUserStatusChangeLog`;

-- Creating the procedure
DELIMITER $$

CREATE PROCEDURE `InsertUserStatusChangeLog`(
    IN pUserID INT,
    IN pOldStatus VARCHAR(50),
    IN pNewStatus VARCHAR(50),
    IN pChangeDate DATE
)
BEGIN
    INSERT INTO `UserStatusChangeLog` (`UserID`, `OldStatus`, `NewStatus`, `ChangeDate`)
    VALUES (pUserID, pOldStatus, pNewStatus, pChangeDate);
END$$

DELIMITER ;

CALL InsertUserStatusChangeLog(5, 'Active', 'Active', '2023-09-01');
-- sample data 
-- essentially using same template of stored procedure for each table for these insert procedures going forward
SELECT *
FROM UserStatusChangeLog;
-- Select statement for checking use


-- Procedure #3 Table: SubscriptionPlans
DROP PROCEDURE IF EXISTS `InsertSubscriptionPlan`;

DELIMITER $$
CREATE PROCEDURE `InsertSubscriptionPlan`(
    IN pPlanName VARCHAR(100),
    IN pInternetSpeedLimit VARCHAR(50),
    IN pDataCap INT,
    IN pPricePerMonth DECIMAL(10,2)
)
BEGIN
    INSERT INTO `SubscriptionPlans` (`PlanName`, `InternetSpeedLimit`, `DataCap`, `PricePerMonth`)
    VALUES (pPlanName, pInternetSpeedLimit, pDataCap, pPricePerMonth);
END$$

DELIMITER ;

-- Call action to run the procedure 
CALL InsertSubscriptionPlan('Temporary Account Freezing', '0 Mbps', 0, 7.99);
-- this is an example if maybe a customer wanted to take a break from their subcription service but not deleted their account entirely
SELECT *
FROM SubscriptionPlans;
-- Select statement for checking use

-- Procedure #4 Table: ServiceTypes -- quick and easy following same formats
DROP PROCEDURE IF EXISTS `InsertServiceType`;

DELIMITER $$

CREATE PROCEDURE `InsertServiceType`(
    IN pServiceTypeName VARCHAR(100),
    IN pDescription TEXT
)
BEGIN
    INSERT INTO `ServiceTypes` (`ServiceTypeName`, `Description`)
    VALUES (pServiceTypeName, pDescription);
END$$

DELIMITER ;

CALL InsertServiceType('Streaming Services', 'Provides access to streaming content including movies and TV shows etc...');
-- call to check procedure
SELECT *
FROM ServiceTypes;
-- Select statement for checking use

-- Procedure #5 Table: RatePlans
DROP PROCEDURE IF EXISTS `InsertRatePlan`;

DELIMITER $$
CREATE PROCEDURE `InsertRatePlan`(
    IN pRatePlanName VARCHAR(100),
    IN pDescription TEXT,
    IN pDiscountRate DECIMAL(5,2),
    IN pStartDate DATE,
    IN pEndDate DATE,
    IN pConditions TEXT
)
BEGIN
    INSERT INTO `RatePlans` (`RatePlanName`, `Description`, `DiscountRate`, `StartDate`, `EndDate`, `Conditions`)
    VALUES (pRatePlanName, pDescription, pDiscountRate, pStartDate, pEndDate, pConditions);
END$$

DELIMITER ;
-- call function to check it
CALL InsertRatePlan('Black Friday', 'Black Friday discount rate for new subscriptions.', 15.00, '2023-11-26', '2023-11-28', 'Available to new customers only.');

SELECT *
FROM RatePlans;
-- Select statement for checking use


-- Procedure #6 Table: ServiceAnnouncements
DROP PROCEDURE IF EXISTS `InsertServiceAnnouncement`;
DELIMITER $$

CREATE PROCEDURE `InsertServiceAnnouncement`(
    IN pTitle VARCHAR(150),
    IN pDatePosted DATE,
    IN pContent TEXT,
    IN pExpirationDate DATE,
    IN pCategory VARCHAR(50)
)
BEGIN
    INSERT INTO `ServiceAnnouncements` (`Title`, `DatePosted`, `Content`, `ExpirationDate`, `Category`)
    VALUES (pTitle, pDatePosted, pContent, pExpirationDate, pCategory);
END$$

DELIMITER ;

CALL InsertServiceAnnouncement('System Update', '2023-04-27', ' Service update scheduled.', '2023-04-30', 'Update');
-- call function to check it
SELECT *
FROM ServiceAnnouncements;
-- Select statement for checking use

-- Procedure #7 Table: ServiceNotifications
DROP PROCEDURE IF EXISTS `InsertServiceNotification`;

DELIMITER $$
CREATE PROCEDURE `InsertServiceNotification`(
    IN pUserID INT,
    IN pNotificationDate DATE,
    IN pMessage TEXT,
    IN pAnnouncementID INT
)
BEGIN
    INSERT INTO `ServiceNotifications` (`UserID`, `NotificationDate`, `Message`, `AnnouncementID`)
    VALUES (pUserID, pNotificationDate, pMessage, pAnnouncementID);
END$$

DELIMITER ;
-- call function to check
CALL InsertServiceNotification(1, '2024-05-05', 'Reminder: Scheduled maintenance on May 5th.', 2);

SELECT *
FROM ServiceNotifications;
-- Select statement for checking use



-- Procedure #8 Table: UserSubscriptions
DROP PROCEDURE IF EXISTS `InsertUserSubscription`;

DELIMITER $$
CREATE PROCEDURE `InsertUserSubscription`(
    IN pUserID INT,
    IN pPlanID INT,
    IN pStartDate DATE,
    IN pEndDate DATE,
    IN pSubscriptionStatus ENUM('Active', 'Pending', 'Paused', 'Expired', 'Cancelled')
)
BEGIN
    INSERT INTO `UserSubscriptions` (`UserID`, `PlanID`, `StartDate`, `EndDate`, `SubscriptionStatus`)
    VALUES (pUserID, pPlanID, pStartDate, pEndDate, pSubscriptionStatus);
END$$

DELIMITER ;
-- Call function to check it
CALL InsertUserSubscription(1, 2, '2023-01-01', '2024-02-01', 'Active');

SELECT *
FROM UserSubscriptions;
-- Select statement for checking use


-- Procedure #9 Table: NetworkDevices
DROP PROCEDURE IF EXISTS `InsertNetworkDevice`;
DELIMITER $$

CREATE PROCEDURE `InsertNetworkDevice`(
    IN pUserID INT,
    IN pDeviceType VARCHAR(50),
    IN pModelNumber VARCHAR(50),
    IN pSerialNumber VARCHAR(50),
    IN pMACAddress VARCHAR(20),
    IN pInstallationDate DATE,
    IN pDeviceStatus ENUM('Active', 'Inactive', 'Under Maintenance')
)
BEGIN
    INSERT INTO `NetworkDevices` (`UserID`, `DeviceType`, `ModelNumber`, `SerialNumber`, `MACAddress`, `InstallationDate`, `DeviceStatus`)
    VALUES (pUserID, pDeviceType, pModelNumber, pSerialNumber, pMACAddress, pInstallationDate, pDeviceStatus);
END$$

DELIMITER ;
-- Call function to check it
CALL InsertNetworkDevice(4, 'Router', 'EXROUT4000', 'EXMODEL932', '03-7645-6719-ATCI', '2023-09-01', 'Active');

SELECT *
FROM NetworkDevices;
-- Select statement for checking use


-- Procedure #10 Table: PaymentMethods
DROP PROCEDURE IF EXISTS `InsertPaymentMethod`;
DELIMITER $$

CREATE PROCEDURE `InsertPaymentMethod`(
    IN pUserID INT,
    IN pPaymentMethodName VARCHAR(50),
    IN pIsDefault BOOLEAN,
    IN pLastUsedDate DATE
)
BEGIN
    INSERT INTO `PaymentMethods` (`UserID`, `PaymentMethodName`, `IsDefault`, `LastUsedDate`)
    VALUES (pUserID, pPaymentMethodName, pIsDefault, pLastUsedDate);
END$$

DELIMITER ;
-- Call action to check it
CALL InsertPaymentMethod(4, 'Credit Card', TRUE, '2024-03-01');

SELECT *
FROM PaymentMethods;
-- Select statement for checking use

-- Procedure #11 Table: SubscriptionServices
DROP PROCEDURE IF EXISTS `InsertSubscriptionService`;

DELIMITER $$
CREATE PROCEDURE `InsertSubscriptionService`(
    IN pSubscriptionID INT,
    IN pServiceTypeID INT
)
BEGIN
    INSERT INTO `SubscriptionServices` (`SubscriptionID`, `ServiceTypeID`)
    VALUES (pSubscriptionID, pServiceTypeID);
END$$

DELIMITER ;
-- Call action to check it
CALL InsertSubscriptionService(3, 2);

SELECT *
FROM SubscriptionServices;
-- Select statement for checking use

-- Procedure #12 Table: Billing
DROP PROCEDURE IF EXISTS `InsertBill`;

DELIMITER $$

CREATE PROCEDURE `InsertBill`(
    IN pSubscriptionID INT,
    IN pBillingDate DATE,
    IN pBillingDueDate DATE,
    IN pBillingAmount DECIMAL(10,2),
    IN pBillingStatus ENUM('Issued', 'Paid', 'Overdue', 'Disputed')
)
BEGIN
    INSERT INTO `Billing` (`SubscriptionID`, `BillingDate`,`BillingDueDate`,`BillingAmount`,`BillingStatus`)
    VALUES (pSubscriptionID, pBillingDate, pBillingDueDate, pBillingAmount, pBillingStatus);
END$$

DELIMITER ;
-- Call action to check it
CALL InsertBill(5, '2024-04-01', '2024-05-01', 49.99, 'Paid');

SELECT *
FROM Biling;
-- Select statement for checking use

-- Procedure #13 Table: PaymentHistory
DROP PROCEDURE IF EXISTS `InsertPayment`;

DELIMITER $$

CREATE PROCEDURE `InsertPayment`(
    IN pBillID INT,
    IN pPaymentDate DATE,
    IN pPaymentMethod VARCHAR(50),
    IN pAmountPaid DECIMAL(10,2)
)
BEGIN
    INSERT INTO `PaymentHistory` (`BillID`, `PaymentDate`, `PaymentMethod`, `AmountPaid`)
    VALUES (pBillID, pPaymentDate, pPaymentMethod, pAmountPaid);
END$$

DELIMITER ;
-- Call action to check it
CALL InsertPayment(5, '2024-04-11', 'Debit Card', 49.99);

SELECT *
FROM PaymentHistory;
-- Select statement for checking use

-- Procedure #14 Table: UserSupportTickets
DROP PROCEDURE IF EXISTS `InsertUserSupportTicket`;

DELIMITER $$

CREATE PROCEDURE `InsertUserSupportTicket`(
    IN pUserID INT,
    IN pIssueDate DATE,
    IN pIssueDescription TEXT,
    IN pResolutionStatus ENUM('New', 'Open', 'Pending', 'Resolved', 'Closed', 'Cancelled')
)
BEGIN
    INSERT INTO `UserSupportTickets` (`UserID`, `IssueDate`, `IssueDescription`, `ResolutionStatus`)
    VALUES (pUserID, pIssueDate, pIssueDescription, pResolutionStatus);
END$$

DELIMITER ;
-- Call action to check it
CALL InsertUserSupportTicket(4, '2023-08-23', 'Internet issues', 'New');

SELECT *
FROM UserSupportTickets;
-- Select statement for checking use

-- Procedure #15 Table: Service Usage
DROP PROCEDURE IF EXISTS `InsertServiceUsage`;

DELIMITER $$

CREATE PROCEDURE `InsertServiceUsage`(
    IN pSubscriptionID INT,
    IN pCurrentDate DATE,
    IN pDataUsed INT
)
BEGIN
    INSERT INTO `ServiceUsage` (`SubscriptionID`, `CurrentDate`, `DataUsed`)
    VALUES (pSubscriptionID, pCurrentDate, pDataUsed);
END$$

DELIMITER ;
-- Call action to check it
CALL InsertServiceUsage(3, CURDATE(), 200);

SELECT *
FROM ServiceUsage;
-- Select statement for checking use

-- Procedure #16 
-- Now that I did an Insert Procedure for each of my tables I wanted to now switch for my last couple procedures to be more creative while also completing the necessary takes when setting up and ISP User Subcription Service database
-- So for this Procedure I wanted to solve the Issue of Overdue Charges. 
-- My thoughts before starting this:  looking at my ERD, this is where I can use a Join between Billing and subcriptionID tables and have it change the users account to paused or cancelled depending on how many days past the due date 
-- GO BACK AND LOOK AT THE CASE STATMENT DOCUMENTATION AND USE AS REFERENCE TO INCORPORTE CASE IN PROCEDURE

DROP PROCEDURE IF EXISTS `UpdateSubscriptionStatusBasedOnBilling`;

DELIMITER $$

CREATE PROCEDURE `UpdateSubscriptionStatusBasedOnBilling`()
BEGIN
    -- Updating a User's subscription status so we are doing an update statement, 
    UPDATE UserSubscriptions AS us
	JOIN Billing AS b 
	ON us.SubscriptionID = b.SubscriptionID
    SET us.SubscriptionStatus = CASE
		WHEN DATEDIFF(CURDATE(), b.BillingDueDate) BETWEEN 1 AND 30 THEN 'Paused' -- updates to paused for the subcirption status if between 1 to 30 days overdue
        WHEN DATEDIFF(CURDATE(), b.BillingDueDate) > 30 THEN 'Cancelled' -- updates to cancelled for the subscription status if over 30 days overdue
        ELSE us.SubscriptionStatus -- neither of these are the case then the status will just remain the same 
    END
    WHERE b.BillingStatus = 'Overdue'; -- looks for overdue billing status's
END$$

DELIMITER ;

CALL UpdateSubscriptionStatusBasedOnBilling();
-- Call action to run it
SELECT `SubscriptionID`, `SubscriptionStatus`
FROM `UserSubscriptions`
WHERE `SubscriptionID` IN (1, 4);
-- SELECT Statement to prove it worked


--  Procedure #17
-- kind of building off that last procedure, this next one will do bulk updates of users billing status
--  To do this after looking more into procedures in the documentation, I might benefit from adding a additional table that can log these User status changes
-- go back and put this table in the table creation order. put it rigth after the Users table to make sure the foreign keys work
-- this table will be used to insert logs of suspensions and reactivations 
DROP PROCEDURE IF EXISTS `BulkUpdateUserStatus`;

DELIMITER $$
CREATE PROCEDURE `BulkUpdateUserStatus`() -- this procedure won't be using parameters
BEGIN
    -- Temporarily suspend users with overdue bills and high data usage
    UPDATE Users AS u
    JOIN Billing AS b ON u.UserID = b.SubscriptionID -- Inner Joins used to use data acorss tese three tablesl Users, Billing, Service Usage
    JOIN ServiceUsage AS su ON u.UserID = su.SubscriptionID
    SET u.UserStatus = 'Suspended' -- this will set the status to Suspended if the where/and clause's conditions are both meet 
    WHERE b.BillingStatus = 'Overdue' AND su.DataUsed > (SELECT AVG(DataUsed) * 1.5 FROM ServiceUsage) -- what this does is, the computer will look for any active status' that have overdue paymetns and then looks at the User's data usage compared to the average. I did 1.5 times more than the average just because that is a clear indication of a user partaking in high data usage 
    AND u.UserStatus = 'Active'; -- identifies the overdue active accounts 

    INSERT INTO UserStatusChangeLog (UserID, OldStatus, NewStatus, ChangeDate) -- now this insert statment will help insert suspension logs into the changelog table
    SELECT UserID, 'Active', 'Suspended', CURDATE()
    FROM Users
    WHERE UserStatus = 'Suspended';

    UPDATE Users AS u -- This update system is to reactivate users who have paid their overdue bills
    JOIN Billing AS b ON u.UserID = b.SubscriptionID
    SET u.UserStatus = 'Active'
    WHERE b.BillingStatus = 'Paid'
    AND u.UserStatus = 'Suspended';

    INSERT INTO UserStatusChangeLog (UserID, OldStatus, NewStatus, ChangeDate) -- This insert statement is to log the reactivations that are updated in the update statmement
    SELECT UserID, 'Suspended', 'Active', CURDATE()
    FROM Users
    WHERE UserStatus = 'Active';
END$$

DELIMITER ;

-- call action to run it
CALL `BulkUpdateUserStatus`();
-- create select statement for professor to run and see procedure work
SELECT u.UserID, u.UserName, u.UserStatus, b.BillingStatus, b.BillingDueDate,su.DataUsed
FROM Users AS u
JOIN Billing AS b 
ON u.UserID = b.SubscriptionID
JOIN ServiceUsage AS su 
ON u.UserID = su.SubscriptionID
WHERE u.UserStatus = 'Suspended' OR b.BillingStatus = 'Overdue';

--  Procedure #18
-- for this next procedure. im gonna try and be a little more creative and have this procedure be for sendign out notification to any active users when a scheduled maintence announcement and when it is going to occur
-- as i look at my erd even though i have a serviceannouncements table i think im going to need to make another table for the servicenotifications themself. gonna make that table and go add it in the table creation before starting anything
-- personal note: april 17th update before you leave class, i have now went back and added the new table and new insert values and new insert procedure for it. should be good to start playing around with what to do with this procedure
DROP PROCEDURE IF EXISTS `NotifyServiceMaintenance`;

DELIMITER $$
CREATE PROCEDURE `NotifyServiceMaintenance`(
    IN pServiceTypeID INT,
    IN pStartDate DATE,
    IN pEndDate DATE,
    IN pNotificationMessage TEXT
)
BEGIN
    INSERT INTO ServiceAnnouncements (Title, DatePosted, Content, ExpirationDate, Category) -- This insert statement whille insert a new service announcement
    VALUES ('Scheduled Maintenance', CURDATE(), pNotificationMessage, pEndDate, 'Maintenance');

    SET @announcementID = LAST_INSERT_ID();  -- Use Last_Insert_Id to grab the ID of the announcement previously inserted

    INSERT INTO ServiceNotifications (UserID, NotificationDate, Message, AnnouncementID) -- This was the new table created. Now i want to use this to Insert the new notifications for any active users based on the announcement
    SELECT
        us.UserID, 
        CURDATE(), 
        CONCAT(pNotificationMessage, ' Please check our service announcements for more details.'), -- Tried other things and i couldn't get it work. realized needed concat becasue the pnotificationmessage is also a text type so concat will let the two texts be shown next to each other
        @announcementID
    FROM 
        UserSubscriptions AS us
    JOIN 
        SubscriptionServices AS ss ON us.SubscriptionID = ss.SubscriptionID
    WHERE 
        ss.ServiceTypeID = pServiceTypeID
    AND 
        us.SubscriptionStatus = 'Active';
END$$
DELIMITER ;
-- Call action to run it
CALL NotifyServiceMaintenance(1, '2024-05-15', '2023-05-16', 'We will be performing maintenance on your internet service from May 15 to May 16.');
-- Select statement for professor to run and see that it worked
SELECT NotificationID, UserID, NotificationDate, Message, AnnouncementID
FROM ServiceNotifications
ORDER BY NotificationID DESC; -- did DESC order to present the most recent announcement at the top

-- Procedure #19 
-- for this procedure. after talking to a family friend who works in Tech he said a good idea could be creating a procedure that can look at a customers data usage and if they could benefit from a ISP Plan upgrade
-- 
DROP PROCEDURE IF EXISTS `SuggestServiceUpgrade`;

DELIMITER $$
CREATE PROCEDURE `SuggestServiceUpgrade`()
BEGIN
    
    SELECT -- When this select is done it should select users who consistently (so plan to use the AVG function) exceed their data cap
        us.UserID, 
        us.PlanID, 
        sp.DataCap, 
        AVG(su.DataUsed) AS AverageUsage,
        'Consider upgrading to a higher plan.' AS Suggestion
    FROM 
        UserSubscriptions AS us
    JOIN 
        SubscriptionPlans AS sp ON us.PlanID = sp.PlanID
    JOIN 
        ServiceUsage AS su ON us.SubscriptionID = su.SubscriptionID
    WHERE 
        us.SubscriptionStatus = 'Active'
    GROUP BY 
        us.UserID, us.PlanID
    HAVING 
        AVG(su.DataUsed) > sp.DataCap;
END$$

DELIMITER ;
-- After debugging and expierementing. I decided to make the procedure not update the subcription plan just yet becuase a customer might not want it. and instead this select statement will create a list of customers who could benefit from it and lists them out so The ISP can reach out to each users and from here maybe send out notifcations to all them that they are elligble for an upgrade
-- Call function to run it
CALL SuggestServiceUpgrade();
-- Because this procedure is a select statement procedure. I don't need to make a select statement after the call to show the professor it works. one you run the call it should show the results and showed that it worked. 




-- Now moving on to my functions; we have the first one already done from the project 1 deliverable, looking for where in ISP's user subscription database scenario would single output calucations be neccessary or more efficent to a whole procedure. 
-- IMPORTANT NOTE: For all functions if I ever get stuck '15.1.17 CREATE PROCEDURE and CREATE FUNCTION Statements' this is the section in the documentation that i found the most useful when making it. leaving this here so it's easy to find any time i need to pull it back up 


-- Function #1
-- function for this i want to be able to take the name of a service type as an input parameter and then return the total count of active subscriptions associated with that service type.
DROP FUNCTION IF EXISTS GetActiveSubscriptionsCountByServiceType;

DELIMITER $$

CREATE FUNCTION GetActiveSubscriptionsCountByServiceType(
    pServiceTypeName VARCHAR(100)
) RETURNS INT
BEGIN
    DECLARE ActiveSubscriptionsCount INT;
    
    SELECT COUNT(DISTINCT us.SubscriptionID) INTO ActiveSubscriptionsCount
    FROM UserSubscriptions AS us
    JOIN SubscriptionServices AS ss ON us.SubscriptionID = ss.SubscriptionID
    JOIN ServiceTypes AS st ON ss.ServiceTypeID = st.ServiceTypeID
    WHERE st.ServiceTypeName = pServiceTypeName AND us.SubscriptionStatus = 'Active';

    RETURN activeSubscriptionsCount;
END$$
DELIMITER ;
-- Select statement for professor to run and check its validity
SELECT GetActiveSubscriptionsCountByServiceType('Premium Internet') AS ActivePremiumInternetSubscriptions; 

-- Function #2
-- For this function i want to calculate the total billed amount for a specific user by adding up together their bills
-- On the top of my head I know that my IN paremeter is gonna be UserID so whenever I call this function i just insert to UserId to figure out their bills due. 
DROP FUNCTION IF EXISTS CalculateTotalBilledAmount;

DELIMITER $$
CREATE FUNCTION CalculateTotalBilledAmount(
    pUserID INT
) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE TotalBilledAmount DECIMAL(10,2);

    SELECT SUM(b.BillingAmount) INTO TotalBilledAmount
    FROM Billing AS b
    JOIN UserSubscriptions AS us ON b.SubscriptionID = us.SubscriptionID
    WHERE us.UserID = pUserID;

    RETURN IFNULL(TotalBilledAmount, 0.00); 
    -- forgot this first time trying to make this function but then found something like this in a functions youtube video and incorporated it into my code. 
    -- basically if they have nothing due (a.k.a if the data is null) then i want it to say 0.00 not null to the customer so this return statement should do it.
    -- Just for your laughs while reading this. it took me an hour to figure out the IFNULL has no space between it. was doing IF NULL for the longest time.
END$$
DELIMITER ;
-- make a select statement for professor to run to test its validity
SELECT CalculateTotalBilledAmount(1) AS TotalBilledAmountForUser1; 

-- Function #3 
-- this function is honestly pretty straightword but I just think a neccesary simple function to have
-- that function being counting the number of devices a user has
-- once again my input would be userID so i can just put an id number in and return the number of devices that customer has
DROP FUNCTION IF EXISTS GetUserDeviceCount;

DELIMITER $$
CREATE FUNCTION GetUserDeviceCount(
    pUserID INT
) RETURNS INT
BEGIN
    DECLARE DeviceCount INT; -- double check documentation to make sure you are using declare right

	SELECT COUNT(*) INTO DeviceCount -- This select statment is counting the number of devices and pulling it from networkdevices using the where clause to focus on userid
    FROM NetworkDevices
    WHERE UserID = pUserID;

    RETURN DeviceCount;
END$$

DELIMITER ;
-- Select statement for professor to run and check it's validity
SELECT GetUserDeviceCount(1) AS TotalUserDeviceCount;
 
 -- Function #4
 -- trying to get a little more creative on this one but also doing something that is a real world scenario  
 -- trying to look at what ive done so far. ive used infromation like datausage to suggest upgrades to customers. 
 -- so i was thinking maybe doing finding a customers average service usage over a ceratin period of time.
 -- might not be a neccessity exaclty, not a full expert in ISP's but i can't imagine this not being helpful to someone at some point
DROP FUNCTION IF EXISTS CalculateAverageUsage;
 
DELIMITER $$

CREATE FUNCTION CalculateAverageUsage(
    pUserID INT,
    pStartDate DATE,
    pEndDate DATE
) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE AvgUsage DECIMAL(10,2);

    SELECT AVG(DataUsed) INTO AvgUsage
    FROM ServiceUsage AS su
    JOIN UserSubscriptions AS us ON su.SubscriptionID = us.SubscriptionID
    WHERE us.UserID = pUserID
    AND su.CurrentDate BETWEEN pStartDate AND pEndDate
    AND us.SubscriptionStatus = 'Active';

    RETURN IFNULL(AvgUsage, 0); -- same case as before where i don't want it to say null i want it to say 0 so just copy and pasted same code and adjusted accordingly, luckily didn't take me an hour this time haha
END$$

DELIMITER ;
-- select statement for professor ot check validity
-- Example to calculate average data usage for user ID 1 within a specific period
SELECT CalculateAverageUsage(3, '2023-12-01', '2024-04-01') AS AverageUsageForUserID3; 
-- to help you see it works. i went back and changed my service usage sample data (you won't noticed because i went and changed them properly) but now you will see users3 usage over that period of time
-- Im going to provide another select statement that highlights userid3 serviceusage logs so you can see the 3 numbers that should be in the caluclations and you can add them up and divide by three oyusefl reeal quick to see the numbers match up
-- if done correctly it both the computer and you should get 316.67

-- for some reason it took me a while to figure this select statement out even though it's pretty simple
--  but im glad i did becuase it can help you test the validity of this function a lot quicker and was good for a 'double check my work' for myself
SELECT su.DataUsed, su.CurrentDate 
FROM ServiceUsage AS su
JOIN UserSubscriptions AS us ON su.SubscriptionID = us.SubscriptionID
WHERE us.UserID = 3
AND su.CurrentDate BETWEEN '2023-12-01' AND '2024-04-01'
AND us.SubscriptionStatus = 'Active'; -- make sure the users subscription is still active so all the right years and months are accounted for in between those two dates given

 -- Function #5
 -- for this function it was made all based on a accident. For this function I wanted to use the UserSupportTickets table because I haven't rly used it in any of my procedures or functions
 -- so i decided to do a count of all the tickets by the status that they are in. However as you can see in my code i have an if else statement where you can do BOTH look at the total of tickets by status or do it indvidually for a customer usign their UserID as well
--  When i say this was based on an accident it's because when making this function i orginally was only planning on doing the total numebr of tickets and count by status' but I've was in such of habit of incorporating the UserId in the functions as you can tell from the majority of my functions
-- that i wrote the code for a user specifcally instead. the code worked so i thought to keep it and do the total as well by using an IF ElSE statement 

DROP FUNCTION IF EXISTS CountTicketsByStatus;
 
DELIMITER $$
CREATE FUNCTION CountTicketsByStatus(
    pStatus VARCHAR(50),
    pUserID INT -- took me a little to figure out how to combine it, especially had trouble because i tried to make the pUserID in the parameter a DEFAULT NULL, and eventually realized you cant set nulls in parameters
) RETURNS INT
BEGIN
    DECLARE TicketCount INT;

    IF pUserID IS NOT NULL THEN -- which i then moved the null to be within the if else statement so either you can ask for the total. or the total of a certain user by just puting 
        SELECT COUNT(*) INTO TicketCount
        FROM UserSupportTickets
        WHERE ResolutionStatus = pStatus AND UserID = pUserID; -- connects parameter infromation to table infromation if a specifc user is requested for
    ELSE
        SELECT COUNT(*) INTO TicketCount -- if not then this would occur and they would get the total of the status requested for
        FROM UserSupportTickets
        WHERE ResolutionStatus = pStatus;
    END IF;

    RETURN TicketCount;
END$$
DELIMITER ;
-- SELECT statements for professor to test its validity 
-- The first select is if you wanted the total number of closed status ticket numbers
SELECT CountTicketsByStatus('Closed', NULL) AS TotalClosedTickets;
-- The second select statement is if you wanted to see a certain status of a ticket number but for a specifc user as well using the UserID
SELECT CountTicketsByStatus('Closed', 1) AS TotalCosedTicketsUserID1;
-- just placing this here for your convience so you can quickly match up the select statement results to the actual data within the UserSupportTicket table
SELECT *
FROM UserSupportTickets;






