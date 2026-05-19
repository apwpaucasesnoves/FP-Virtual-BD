DROP DATABASE IF EXISTS `GYM`;
CREATE DATABASE `GYM`;
USE `GYM`;

-- EXERCISE 1

-- Create the CLIENT table
CREATE TABLE CLIENT (
 client_id INT PRIMARY KEY, -- 1 Unique client identifier
 first_name VARCHAR(100) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 registration_date DATE NOT NULL,
 email VARCHAR(100) UNIQUE NOT NULL, -- 4 Title cannot be repeated
 phone_number VARCHAR(15) NOT NULL
);

-- Create the EQUIPMENT table
CREATE TABLE EQUIPMENT (
 equipment_id INT PRIMARY KEY, -- 1 Unique equipment identifier
 name VARCHAR(255) NOT NULL, 
 brand VARCHAR(100) NOT NULL,
 category ENUM('Free Weight', 'Cardio', 'Strength') NOT NULL, 
 -- 6. The category attribute can only take these values: Free Weight, Cardio, and Strength. 
 availability BOOLEAN DEFAULT TRUE NOT NULL, -- 7 Default value is true
 quantity INT CHECK (quantity > 0) NOT NULL -- 5 Quantity cannot be zero or negative
);

-- Create the LOAN table
CREATE TABLE RENT (
 rent_id INT PRIMARY KEY, -- 1 Unique rent identifier
 client_id INT NOT NULL, -- 2 Foreign key reference to CLIENT
 equipment_id INT NOT NULL, -- 3- Foreign key reference to EQUIPMENT
 start_date DATETIME NOT NULL,
 end_date DATETIME , -- 8. End date can be NULL
 FOREIGN KEY (client_id) REFERENCES CLIENT(client_id), -- 2. The client identifier of the RENT must be a reference to the CLIENT table. 
 FOREIGN KEY (equipment_id) REFERENCES EQUIPMENT(equipment_id) -- 3. The equipment identifier of the RENT must be a reference to the EQUIPEMNT table. 
);



-- EXERCISE 2

-- 1. Create a tier field in the EQUIPMENT table. Its domain is Free, Normal and Premium.
ALTER TABLE EQUIPMENT
ADD COLUMN status ENUM('Free', 'Normal', 'Premium');
-- 2. The quantity field must be equal to or greater than 3.
ALTER TABLE EQUIPMENT
MODIFY COLUMN quantity INT CHECK (quantity >= 3);
-- 3. The registration date of a member must be later than March 13st, 2026.
ALTER TABLE CLIENT
ADD CONSTRAINT check_registration_date CHECK (registration_date > '2026-03-13');
-- 4. A rent cannot be inserted unless the start date is today between 6:00 AM and 9:00 PM.
ALTER TABLE RENT
ADD CONSTRAINT check_rent_time CHECK (DATE(start_date) = CURRENT_DATE() AND HOUR(start_date) >= 6 AND
HOUR(start_date) <= 21);
-- 5. Remove the previous constraint about the quantity field.
ALTER TABLE EQUIPMENT
MODIFY COLUMN quantity INT;
-- 6. Delete the phone column of the CLIENT table.
ALTER TABLE CLIENT
DROP COLUMN phone_number;
-- 7. Two equipments cannot have the same name
ALTER TABLE EQUIPMENT
ADD CONSTRAINT unique_equipment_name UNIQUE (name);
-- 8. Change the RENT table primary key to the combination of dentifier fields.
ALTER TABLE RENT
DROP PRIMARY KEY,
ADD PRIMARY KEY (rent_id, client_id, equipment_id);
-- 9. One client can only have one equipment on use at a time. Create a unique index to
-- validate that.
CREATE UNIQUE INDEX unique_client_rent
ON RENT (client_id, start_date);
-- 10.Rename CLIENT table to MEMBER.
RENAME TABLE CLIENT TO MEMBER;
-- 11.Remove the RENT table.
DROP TABLE RENT;
-- 12.Create a user with your name and a password. Give SELECT and INSERT
-- privileges on the EQUIPMENT table to that user.
CREATE USER 'your_username'@'localhost' IDENTIFIED BY 'your_password';
GRANT SELECT, INSERT ON EQUIPMENT TO 'your_username'@'localhost';
