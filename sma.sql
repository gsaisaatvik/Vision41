-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 05, 2025 at 12:30 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- 
-- Database: `sma`
-- 

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY, -- Primary key to uniquely identify users
    Name VARCHAR(100) NOT NULL, -- Name of the user
    Age INT NOT NULL, -- Age of the user
    Gender VARCHAR(10) NOT NULL, -- Gender of the user (e.g., Male, Female)
    SmokerStatus BOOLEAN NOT NULL, -- Indicates if the user is a smoker (TRUE/FALSE)
    PreExistingCondition BOOLEAN NOT NULL, -- Indicates if the user has a pre-existing condition (TRUE/FALSE)
    BMI FLOAT NOT NULL -- Body Mass Index (BMI) of the user
);

-- 
-- Dumping data for table `Users`
--

INSERT INTO Users (Name, Age, Gender, SmokerStatus, PreExistingCondition, BMI)
VALUES
    ('Raj Kumar', 35, 'Male', TRUE, TRUE, 28.0),
    ('Ananya', 29, 'Female', FALSE, FALSE, 22.0);

-- --------------------------------------------------------

--
-- Table structure for table `Companies`
--

CREATE TABLE Companies (
    CompanyID INT AUTO_INCREMENT PRIMARY KEY, -- Primary key to uniquely identify companies
    CompanyName VARCHAR(100) NOT NULL, -- Name of the insurance company
    ContactInfo VARCHAR(150) NOT NULL -- Contact information for the insurance company
);

-- 
-- Dumping data for table `Companies`
--

INSERT INTO Companies (CompanyName, ContactInfo)
VALUES
    ('ABC Health Shield', 'contact@abc.com'),
    ('DEF Medic', 'support@def.com');

-- --------------------------------------------------------

--
-- Table structure for table `HealthInsurancePolicies`
--

CREATE TABLE HealthInsurancePolicies (
    PolicyID INT AUTO_INCREMENT PRIMARY KEY, -- Primary key to uniquely identify insurance policies
    CompanyID INT NOT NULL, -- Foreign key referencing the Companies table
    PolicyName VARCHAR(100) NOT NULL, -- Name of the insurance policy
    MinAge INT NOT NULL, -- Minimum age eligible for the policy
    MaxAge INT NOT NULL, -- Maximum age eligible for the policy
    SumAssured INT NOT NULL, -- Coverage amount provided by the policy
    BasePremiumRate FLOAT NOT NULL, -- Base premium rate for the policy
    SmokerSurchargeRate FLOAT NOT NULL, -- Additional premium rate for smokers
    PreExistingRate FLOAT NOT NULL, -- Additional premium rate for pre-existing conditions
    BMIImpactRate FLOAT NOT NULL, -- Additional premium impact rate based on BMI
    AdminFee FLOAT NOT NULL, -- Administrative fee for the policy
    TaxRate FLOAT NOT NULL, -- Tax rate applicable on the total premium
    FOREIGN KEY (CompanyID) REFERENCES Companies(CompanyID) -- Maintains referential integrity with Companies
);

-- 
-- Dumping data for table `HealthInsurancePolicies`
--

INSERT INTO HealthInsurancePolicies (CompanyID, PolicyName, MinAge, MaxAge, SumAssured, BasePremiumRate, SmokerSurchargeRate, PreExistingRate, BMIImpactRate, AdminFee, TaxRate)
VALUES
    (1, 'Comprehensive Plan', 18, 60, 500000, 6.0, 0.2, 0.15, 0.1, 500.0, 18.0),
    (2, 'Family Secure Plan', 21, 55, 1000000, 7.0, 0.25, 0.2, 0.12, 700.0, 18.0);

-- --------------------------------------------------------

--
-- Table structure for table `PremiumCalculations`
--

CREATE TABLE PremiumCalculations (
    CalculationID INT AUTO_INCREMENT PRIMARY KEY, -- Primary key to uniquely identify calculations
    UserID INT NOT NULL, -- Foreign key referencing the Users table
    PolicyID INT NOT NULL, -- Foreign key referencing the HealthInsurancePolicies table
    TotalPremium FLOAT NOT NULL, -- Total premium amount calculated
    CalculationDate DATE NOT NULL, -- Date of the premium calculation
    FOREIGN KEY (UserID) REFERENCES Users(UserID), -- Maintains referential integrity with Users
    FOREIGN KEY (PolicyID) REFERENCES HealthInsurancePolicies(PolicyID) -- Maintains referential integrity with HealthInsurancePolicies
);

-- 
-- Dumping data for table `PremiumCalculations`
--

INSERT INTO PremiumCalculations (UserID, PolicyID, TotalPremium, CalculationDate)
VALUES
    (1, 1, 5723.0, '2025-01-04'),
    (2, 2, 8260.0, '2025-01-04');

-- --------------------------------------------------------

--
-- Procedure to dynamically calculate premiums
--

DELIMITER //
CREATE PROCEDURE CalculatePremiums()
BEGIN
    DECLARE basePremium FLOAT;
    DECLARE smokerSurcharge FLOAT;
    DECLARE preExistingSurcharge FLOAT;
    DECLARE bmiImpact FLOAT;
    DECLARE total FLOAT;

    -- Iterate through all users and policies to calculate premiums
    INSERT INTO PremiumCalculations (UserID, PolicyID, TotalPremium, CalculationDate)
    SELECT 
        u.UserID, 
        p.PolicyID, 
        ROUND((p.BasePremiumRate + 
              (u.SmokerStatus * p.SmokerSurchargeRate * p.BasePremiumRate) + 
              (u.PreExistingCondition * p.PreExistingRate * p.BasePremiumRate) + 
              ((u.BMI - 25) * p.BMIImpactRate * p.BasePremiumRate) + 
              p.AdminFee) * (1 + p.TaxRate / 100), 2) AS TotalPremium,
        CURDATE() AS CalculationDate
    FROM Users u
    CROSS JOIN HealthInsurancePolicies p
    WHERE u.Age BETWEEN p.MinAge AND p.MaxAge;
END //
DELIMITER ;

-- 
-- Call the Procedure to Calculate Premiums
--

CALL CalculatePremiums();

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
