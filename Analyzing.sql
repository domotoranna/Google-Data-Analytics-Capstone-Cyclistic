--Initial exploration of data, looking at the total number of rows, distinct values, maximum, minimum, and mean values.
  SELECT COUNT(*), COUNT(DISTINCT bikeid), AVG(tripduration)/60, COUNT(DISTINCT from_station_id), COUNT(DISTINCT to_station_id)
    FROM Trips_2019



  SELECT MIN(birthyear), MAX(birthyear), MIN(tripduration), MAX(tripduration)
    FROM Trips_2019
	--min birthyear: 1920
	--max birthyear: 2014


--Subscribers don't necessarily provide gender and birthyear. Customers also have the opportunity to provide gender and birthyear
  SELECT usertype, gender, birthyear
    FROM Trips_2019
    WHERE 
      (usertype='Subscriber' and (gender IS NULL OR birthyear IS NULL))
      OR
      (usertype='Customer' and (gender IS NOT NULL OR birthyear IS NOT NULL))



--Calculating the average ride_length for members and casual riders.
SELECT usertype, AVG(tripduration)/60 AS avergare_trip_duration
  FROM Trips_2019
  GROUP BY usertype
  --customer: 57 minutes
  --subscriber: 14 minutes


--Are certain months more popular among subscribers?
  SELECT MONTH(start_time) AS month, usertype, COUNT(usertype) AS count_of_users
	FROM Trips_2019
	GROUP BY MONTH(start_time), usertype
    ORDER BY MONTH(start_time)




--Calculating the average tripduration for users by day_of_week. 
SELECT day_of_week, usertype, AVG(tripduration)/60 AS avergare_trip_duration
  FROM Trips_2019
  GROUP BY day_of_week, usertype
  ORDER BY day_of_week


--Calculate the number of rides for users by day_of_week 
SELECT day_of_week, usertype, COUNT(tripduration) AS num_of_rides
  FROM Trips_2019
  GROUP BY day_of_week, usertype
  ORDER BY day_of_week, usertype




--rides throughout the day (hourly distribution)
  SELECT DATEPART(HOUR, start_time), usertype, COUNT(trip_id)
    FROM Trips_2019
    GROUP BY usertype, DATEPART(HOUR, start_time)
    ORDER BY DATEPART(HOUR, start_time), usertype



--Caltulating the number of trips that ended in the station in which they started at
  SELECT usertype, count(*) AS num_of_trips_that_ended_in_the_same_station
    FROM Trips_2019
    WHERE from_station_id = to_station_id
    GROUP BY usertype
	--Customer	    104598
    --Subscriber	47649

--Versus calculating the number of trips that ended in a different station as they started in
  SELECT usertype, count(*)
    FROM Trips_2019
    WHERE from_station_id <> to_station_id
    GROUP BY usertype
	--Customer	    776039
    --Subscriber	2889718



--which stations are the most popular among subscribers? 
  SELECT from_station_name, COUNT(*) as station_trip_count
    FROM Trips_2019
    WHERE usertype = 'Subscriber'
    GROUP BY from_station_name
    ORDER BY station_trip_count DESC



--does age influence the likelyhood to be a subscriber?
select
      case when birthyear >= 1920 and birthyear <= 1930    then '1920-1930'
           when birthyear > 1930 and birthyear <= 1940   then '1930-40'
           when birthyear > 1940 and birthyear <= 1950  then '1940-50'
           when birthyear > 1950  and birthyear <= 1960   then '1950-60'
           when birthyear > 1960 and birthyear <= 1970   then '1960-70'
           when birthyear > 1970 and birthyear <= 1980  then '1970-80'
		   when birthyear > 1980  and birthyear <= 1990   then '1980-90'
           when birthyear > 1990 and birthyear <= 2000   then '1990-2000'
           when birthyear > 2000 then '>2000'
      end AS age_group, usertype,
      count(*) as num_of_trips
   from
      Trips_2019
   group by case when birthyear >= 1920 and birthyear <= 1930    then '1920-1930'
           when birthyear > 1930 and birthyear <= 1940   then '1930-40'
           when birthyear > 1940 and birthyear <= 1950  then '1940-50'
           when birthyear > 1950  and birthyear <= 1960   then '1950-60'
           when birthyear > 1960 and birthyear <= 1970   then '1960-70'
           when birthyear > 1970 and birthyear <= 1980  then '1970-80'
		   when birthyear > 1980  and birthyear <= 1990   then '1980-90'
           when birthyear > 1990 and birthyear <= 2000   then '1990-2000'
           when birthyear > 2000 then '>2000'
      end,
	  usertype
	ORDER BY 1, 2

