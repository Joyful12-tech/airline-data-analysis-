-- Remove duplicates by creating clean version of Flights
DROP TABLE IF EXISTS Flights_clean;
CREATE TABLE Flights_clean AS SELECT DISTINCT * FROM Flights;
SELECT COUNT(*) FROM Flights_clean; -- Count after cleaning
SELECT COUNT(*) FROM Flights;       -- Count original
SELECT * FROM Flights_clean;

-- Remove duplicates by creating clean version of Passengers
DROP TABLE IF EXISTS Passengers_clean;
CREATE TABLE Passengers_clean AS SELECT DISTINCT * FROM Passengers;
SELECT * FROM Passengers_clean;
SELECT COUNT(*) FROM Passengers_clean;
SELECT COUNT(*) FROM Passengers;

-- Remove duplicates by creating clean version of Bookings
DROP TABLE IF EXISTS Bookings_clean;
CREATE TABLE Bookings_clean AS SELECT DISTINCT * FROM Bookings;
SELECT * FROM Bookings_clean;
SELECT COUNT(*) FROM Bookings_clean;
SELECT COUNT(*) FROM Bookings;

-- Standardize Flights table (trim spaces, uppercase airports, normalize status)
UPDATE Flights_clean
SET airline=TRIM(airline),
    flight_number=TRIM(flight_number),
    origin_airport=UPPER(TRIM(origin_airport)),
    destination_airport=UPPER(TRIM(destination_airport)),
    status = CASE UPPER(TRIM(status))
               WHEN 'ON TIME' THEN 'On Time'
               WHEN 'DELAYED' THEN 'Delayed'
               WHEN 'CANCELLED' THEN 'Cancelled'
               ELSE 'On Time'
             END;

-- Normalize airline names to consistent labels
UPDATE Flights_clean
SET airline = CASE UPPER(airline)
  WHEN 'DELTA' THEN 'Delta'
  WHEN 'AMERICAN AIRLINES' THEN 'American Airlines'
  WHEN 'UNITED' THEN 'United'
  WHEN 'SOUTHWEST' THEN 'Southwest'
  WHEN 'ALASKA' THEN 'Alaska'
  WHEN 'JETBLUE' THEN 'JetBlue'
  WHEN 'SPIRIT' THEN 'Spirit'
  WHEN 'FRONTIER' THEN 'Frontier'
  ELSE airline END;

-- Standardize Passengers data (trim names, normalize gender, trim nationality)
UPDATE Passengers_clean
SET name=TRIM(name),
    gender = CASE UPPER(TRIM(gender))
               WHEN 'MALE' THEN 'Male'
               WHEN 'FEMALE' THEN 'Female'
               ELSE 'Other' END,
    nationality=TRIM(nationality);

-- Standardize Bookings seat_class
UPDATE Bookings_clean
SET seat_class = CASE UPPER(TRIM(seat_class))
                   WHEN 'ECONOMY' THEN 'Economy'
                   WHEN 'BUSINESS' THEN 'Business'
                   WHEN 'FIRST' THEN 'First'
                   ELSE 'Economy' END;

-- Remove unrealistic ages (set to NULL if <5 or >100)
UPDATE Passengers_clean
SET age = NULL
WHERE age IS NULL OR age < 5 OR age > 100;
SELECT * FROM passengers_clean;

-- If flight is cancelled → arrival_time should be NULL
UPDATE Flights_clean
SET arrival_time = NULL
WHERE UPPER(status)='CANCELLED';

-- Identify flights with missing/invalid times
DROP TABLE IF EXISTS Flights_time_issues;
CREATE TABLE Flights_time_issues AS
SELECT *
FROM Flights_clean
WHERE (status <> 'Cancelled' AND arrival_time IS NULL)
   OR (arrival_time IS NOT NULL AND departure_time IS NOT NULL AND arrival_time < departure_time);

-- Identify bookings with invalid prices
DROP TABLE IF EXISTS Bookings_price_issues;
CREATE TABLE Bookings_price_issues AS
SELECT *
FROM Bookings_clean
WHERE price <= 0 OR price IS NULL;

-- Identify orphan bookings (no matching passenger/flight)
DROP TABLE IF EXISTS Bookings_orphan_refs;
CREATE TABLE Bookings_orphan_refs AS
SELECT b.*
FROM Bookings_clean b
LEFT JOIN Passengers_clean p ON b.passenger_id = p.passenger_id
LEFT JOIN Flights_clean f    ON b.flight_id = f.flight_id
WHERE p.passenger_id IS NULL OR f.flight_id IS NULL;

-- Add Primary Keys
ALTER TABLE Flights_clean
  MODIFY flight_id INT NOT NULL,
  ADD PRIMARY KEY (flight_id);

ALTER TABLE Passengers_clean
  MODIFY passenger_id INT NOT NULL,
  ADD PRIMARY KEY (passenger_id);

ALTER TABLE Bookings_clean
  MODIFY booking_id INT NOT NULL,
  ADD PRIMARY KEY (booking_id);

-- Add Indexes for faster joins
CREATE INDEX idx_bookings_passenger_id ON Bookings_clean(passenger_id);
CREATE INDEX idx_bookings_flight_id    ON Bookings_clean(flight_id);

-- Row counts for clean tables
SELECT 'Flights_clean' AS table_name, COUNT(*) row_count FROM Flights_clean
UNION ALL SELECT 'Passengers_clean', COUNT(*) FROM Passengers_clean
UNION ALL SELECT 'Bookings_clean', COUNT(*) FROM Bookings_clean;

-- Row counts for issue tables
SELECT 'Flights_time_issues' AS issue_table, COUNT(*) FROM Flights_time_issues
UNION ALL SELECT 'Bookings_price_issues', COUNT(*) FROM Bookings_price_issues
UNION ALL SELECT 'Bookings_orphan_refs', COUNT(*) FROM Bookings_orphan_refs;

-- Check NULL counts in Flights
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN flight_id IS NULL OR flight_id='' THEN 1 ELSE 0 END) AS flight_id_nulls,
    SUM(CASE WHEN airline IS NULL OR airline='' THEN 1 ELSE 0 END) AS airline_nulls,
    SUM(CASE WHEN flight_number IS NULL OR flight_number='' THEN 1 ELSE 0 END) AS flight_number_nulls,
    SUM(CASE WHEN origin_airport IS NULL OR origin_airport='' THEN 1 ELSE 0 END) AS origin_airport_nulls,
    SUM(CASE WHEN destination_airport IS NULL OR destination_airport='' THEN 1 ELSE 0 END) AS destination_airport_nulls,
    SUM(CASE WHEN departure_time IS NULL OR departure_time='' THEN 1 ELSE 0 END) AS departure_time_nulls,
    SUM(CASE WHEN arrival_time IS NULL OR arrival_time='' THEN 1 ELSE 0 END) AS arrival_time_nulls,
    SUM(CASE WHEN status IS NULL OR status='' THEN 1 ELSE 0 END) AS status_nulls
FROM Flights_clean;

-- Check NULL counts in Passengers
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN passenger_id IS NULL OR passenger_id='' THEN 1 ELSE 0 END) AS passenger_id_nulls,
    SUM(CASE WHEN name IS NULL OR name='' THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN gender IS NULL OR gender='' THEN 1 ELSE 0 END) AS gender_nulls,
    SUM(CASE WHEN age IS NULL OR age='' THEN 1 ELSE 0 END) AS age_nulls,
    SUM(CASE WHEN nationality IS NULL OR nationality='' THEN 1 ELSE 0 END) AS nationality_nulls
FROM Passengers_clean;

-- Check NULL counts in Bookings
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN booking_id IS NULL OR booking_id='' THEN 1 ELSE 0 END) AS booking_id_nulls,
    SUM(CASE WHEN passenger_id IS NULL OR passenger_id='' THEN 1 ELSE 0 END) AS passenger_id_nulls,
    SUM(CASE WHEN flight_id IS NULL OR flight_id='' THEN 1 ELSE 0 END) AS flight_id_nulls,
    SUM(CASE WHEN booking_date IS NULL OR booking_date='' THEN 1 ELSE 0 END) AS booking_date_nulls,
    SUM(CASE WHEN seat_class IS NULL OR seat_class='' THEN 1 ELSE 0 END) AS seat_class_nulls,
    SUM(CASE WHEN price IS NULL OR price='' THEN 1 ELSE 0 END) AS price_nulls
FROM Bookings_clean;

-- Replace NULL ages with average
SELECT ROUND(AVG(age)) AS avg_age
FROM Passengers_clean
WHERE age IS NOT NULL;

-- Example: set null/empty ages to 50
UPDATE Passengers_clean
SET age = 50
WHERE age IS NULL OR age = '';

-- Fill missing arrival_time with departure_time + 2 hours
UPDATE Flights_clean
SET arrival_time = DATE_ADD(departure_time, INTERVAL 120 MINUTE)
WHERE arrival_time IS NULL OR arrival_time = '';

-- Look at distinct values for QA checks
SELECT DISTINCT gender FROM Passengers_clean ORDER BY gender;
SELECT DISTINCT status FROM Flights_clean ORDER BY status;
SELECT DISTINCT airline FROM Flights_clean;
SELECT DISTINCT nationality FROM Passengers_clean;

-- Check extreme values
SELECT * FROM Bookings_clean WHERE price <= 0 OR price > 5000;
SELECT * FROM Passengers_clean WHERE age < 0 OR age > 120;

-- Show final table structure
DESCRIBE flights_clean;
DESCRIBE passengers_clean;
DESCRIBE bookings_clean;

-- Convert booking_date from TEXT → DATETIME
ALTER TABLE bookings_clean 
ADD COLUMN booking_date_new DATETIME;
UPDATE bookings_clean
SET booking_date_new = STR_TO_DATE(booking_date, '%Y-%m-%d %H:%i:%s');

-- Fix spelling errors in airline names
UPDATE Flights_clean
SET airline = 'EMIRATES'
WHERE airline IN ('EMIRATESS', 'EMIRAT', 'EMIRTES');

-- Join 3 tables to create a combined master dataset
SELECT 
    b.booking_id,
    p.passenger_id,
    p.name AS passenger_name,
    p.gender,
    p.age,
    p.nationality,
    f.flight_id,
    f.airline,
    f.flight_number,
    f.origin_airport,
    f.destination_airport,
    f.departure_time,
    f.arrival_time,
    f.status AS flight_status,
    b.seat_class,
    b.booking_date,
    b.price
FROM bookings_clean b
JOIN passengers_clean p ON b.passenger_id = p.passenger_id
JOIN flights_clean f ON b.flight_id = f.flight_id;

-- Create airline_master table for analysis
CREATE TABLE airline_master AS
SELECT 
    b.booking_id,
    p.passenger_id,
    p.name AS passenger_name,
    p.gender,
    p.age,
    p.nationality,
    f.flight_id,
    f.airline,
    f.flight_number,
    f.origin_airport,
    f.destination_airport,
    f.departure_time,
    f.arrival_time,
    f.status AS flight_status,
    b.seat_class,
    b.booking_date,
    b.price
FROM bookings_clean b
JOIN passengers_clean p ON b.passenger_id = p.passenger_id
JOIN flights_clean f ON b.flight_id = f.flight_id;

-- calling out my new unqiue table 
SELECT * FROM airline_master;
