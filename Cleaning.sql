--1. Loading the four csv files into tables
-- Tasks > Import flat file
--Created Trips_2019_Q1, Trips_2019_Q2, Trips_2019_Q3, Trips_2019_Q4 tables


--2. Doing the same cleaning steps four times can lead to errors, so the second thing I did was merging the four tables to a single table for easier cleaning and analysis
  SELECT t.* INTO Trips_2019 
    FROM
    (
      SELECT * FROM Trips_2019_Q1
      UNION ALL
      SELECT * FROM Trips_2019_Q2
      UNION ALL
      SELECT * FROM Trips_2019_Q3
      UNION ALL
      SELECT * FROM Trips_2019_Q4
    ) t

--I validated the data by adding the row numbers of Q1, Q2, Q3, Q4 tables. The unioned table Trips_2019 had the same number of entries.

		
--3. Tripduration values look like "2,137.0", the separator comma and the decimal point can't be interpreted together so the column type is wrong
  UPDATE Trips_2019
    SET tripduration = REPLACE(tripduration, ',', '')
--now the column's data type can be changed		
  ALTER TABLE [Cyclistic].[dbo].[Trips_2019]
    ALTER COLUMN tripduration float
		
		
--4. I used the following query to find out if there are any duplicate rows
  SELECT trip_id, start_time, end_time, bikeid, tripduration, from_station_id, from_station_name, to_station_id, to_station_name, usertype, gender, birthyear, COUNT(*)
    FROM Trips_2019
    GROUP BY trip_id, start_time, end_time, bikeid, tripduration, from_station_id, from_station_name, to_station_id, to_station_name, usertype, gender, birthyear
    HAVING COUNT(*) > 1;
			

--5. I checked for missing values of non-nullable fields (trip_id, start_time, end_time, bikeid, from_station_id, to_station_id, usertype)
  SELECT trip_id, start_time, end_time, bikeid, from_station_id, to_station_id, usertype
    FROM Trips_2019
    WHERE (usertype IS NULL) OR LEN(usertype) = 0
	  OR (start_time IS NULL) OR LEN(start_time) = 0
	  OR (end_time IS NULL) OR LEN(end_time) = 0
      OR (bikeid IS NULL) OR LEN(bikeid) = 0
      OR (from_station_id IS NULL) OR LEN(from_station_id) = 0
      OR (to_station_id IS NULL) OR LEN(to_station_id) = 0
      OR (trip_id IS NULL) OR LEN(trip_id) = 0
		

--6. I checked the maximum and minimum values (where it made sense) to check for outliers.
  SELECT MIN(birthyear), MAX(birthyear), MIN(start_time), MAX(start_time), MIN(end_time), MAX(end_time), MIN(tripduration), MAX(tripduration)
    FROM Trips_2019

	
--I found that the lowest birtyear is 1759. The dataset contains 783 entries where the birtyear is less than 1920. 
--These birthyears were probably given mistakenly at registration. I didn't delete these rows, because the trip data is probably still valid, 
--but I removed the birtyear from these entries, as it might skew the results of the analysis that I can make based on the birtyear. 
  UPDATE Trips_2019
    SET birthyear = NULL
    WHERE birthyear < 1920

--The highest tripduration is 10628400 seconds (about 123 days). I found than in 1848 cases the tripduration is higher than 24 hours.
--Since this is only 0,0005% of the total cases, I decided not to delete these entries, but if this was a real life project, the data should be checked
--with Cyclistic team, if it's a bug or possible data. I would ask them if they have a policy to return the bikes after a certain time, and delete the
--entries where the tripduration is higher.
  SELECT COUNT(*) 
    FROM Trips_2019 
    WHERE tripduration > 86400
		

--7. I validated that only 2 types of usertype values are present in the dataset. (customer and subscriber)
  SELECT DISTINCT usertype
    FROM Trips_2019
	

--8. I validated that every trip_id is 8 characters long.
  SELECT LEN(trip_id) AS len_trip_id
    FROM Trips_2019
    WHERE LEN(trip_id) <> 8
	

--9. I added a column "day_of_week", it will be useful to see which days are the busies for bike rental
  ALTER TABLE Trips_2019
    ADD day_of_week nvarchar(10);
		
  UPDATE Trips_2019
    SET day_of_week = DATENAME(WEEKDAY, start_time)