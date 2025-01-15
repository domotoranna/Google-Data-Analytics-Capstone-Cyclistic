# Google Data Analytics Course Capstone Project - Cyclistic
**Google Data Analytics Professional Certificate case study: How does a bike-share navigate speedy success?**

As part of the Google Data Analytics Professional Certificate, this case study focuses on analyzing data for Cyclistic, a fictional bike-share company.

In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

Cyclistic offers flexibility in its pricing plans: single-ride passes, full-day passes, and annual memberships. Users who purchase single-ride or full-day passes are referred to as customers.
Users who purchase annual memberships are subscribers.

Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, my job is to understand how casual riders and annual members use Cyclistic bikes differently.

To address the business challenge, I follow the data analysis process, structured into six stages:
1. Ask: Defining the problem and identifying key questions.
2. Prepare: Collecting and understanding the data.
3. Process: Cleaning and organizing the data for analysis.
4. Analyze: Identifying trends, patterns, and insights.
5. Share: Communicating findings through visualizations and summaries.
6. Act: Recommending actionable strategies based on the insights.

# Ask
Marketing team aims at converting casual riders into annual members. In order to do that, the team needs to better understand **how annual members and casual riders differ**, why casual riders would buy a membership, and how digital media could affect their marketing tactics. Based on my insights the marketing team can decide on the new marketing strategy. Cyclistic executives must approve my recommendations, so they need to be backed up with compelling data insights and professional data visualizations.

# Prepare 
The dataset I work with is located at https://divvy-tripdata.s3.amazonaws.com/index.html.
This dataset is public, it has been made available by Motivate International Inc. under this license: https://divvybikes.com/data-license-agreement

The dataset includes multiple years of data. Analyzing a single year ensures consistency, I wanted to choose a year that is devided into quarters rather than months, so I chose to work with data from 2019.
I downloaded the zip files containing 2019 data: Divvy_Trips_2019_Q1.zip,  Divvy_Trips_2019_Q2.zip,  Divvy_Trips_2019_Q3.zip,  Divvy_Trips_2019_Q4.zip. 
I made a backup of the files, then extracted them. 
	
Each csv file is structured the same way, containing 12 columns:
- trip_id: Unique identifier of the trip
- start_time: Time the bike was picked up in YYYY-MM-DD HH:MM:SS format
- end_time: Time the bike was brought back in YYYY-MM-DD HH:MM:SS format
- bikeid: Unique identifier of the bike
- tripduration: Duration of the trip in seconds
- from_station_name: Starting stations's name
- from station_id: Starting stations unique ID
- to_station_id: End station's name
- to_station_name: End station's unique ID
- usertype: Subscriber (purchased annual membership) or Customer (purchased single ride or full day pass)
- gender: gender of the user, can be NULL
- birthyear: birth year of the user, can be NULL

Here is a snapshot of Q1 data:
trip_id | start_time | end_time | bikeid | tripduration | from_station_name | from_station_id | to_station_id | to_station_name | usertype | gender | birthyear
--- | --- | --- | --- |--- |--- |--- |--- |--- |--- |--- |---
21742443 | 2019-01-01 00:04:37	| 2019-01-01 00:11:07 |	2167	| 390 |	199 |	Wabash Ave & Grand Ave |	84	| Milwaukee Ave & Grand Ave	| Subscriber |	Male |	1989
21742444 |	2019-01-01 00:08:13 |	2019-01-01 00:15:34 |	4386	| 441 |	44 |	State St & Randolph St	| 624 |	Dearborn St & Van Buren St (*)	| Subscriber |	Female |	1990
21742445 |	2019-01-01 00:13:23 |	2019-01-01 00:27:12	|1524 |	829 |	15 |	Racine Ave & 18th St |	644	 | Western Ave & Fillmore St (*) |	Subscriber |	Female |	1994
21742446 |	2019-01-01 00:13:45 |	2019-01-01 00:43:28 |	252	 | 1783 |	123 |	California Ave & Milwaukee Ave | 176 |	Clark St & Elm St	| Subscriber |	Male |	1993

### Limitations of the data
User ID is not stored in any form. As a result if an annual subscriber makes the same trip multiple times —such as a daily commute— the data counts each occurrence as a separate trip. This means patterns of individual behavior cannot be directly identified. Similarly, single-ride or full-day customers who repeat the same trip are also counted multiple times, making it challenging to distinguish unique riders from recurring trips. These limitations must be considered when interpreting trends.

# Process
## Chosen tools
I chose to clean and analyze the dataset in SQL Server Management Studio. This decision was based on the following considerations:
- Even the smallest file contains at least 360,000 rows, the larger files exceed the capacity of Excel sheets. Cleaning and analyzing such a large dataset in Excel would be time-consuming and impractical.
- While I initially considered using Google BigQuery, the sandbox account has some constraints such as a 100 MB limit on CSV file uploads, and inability to use DML statements.
- Microsoft SQL Server Management Studio supports large datasets and provides robust tools for executing complex queries efficiently.

All queries used for data cleaning and analysis are documented in the Cleaning and Analysis SQL files.

For the visualizations I used Tableau Public.

## Data cleaning steps

1. First I loaded the four csv files into four tables. (Tasks > Import flat file)
2. Doing the same cleaning steps 4 times can lead to errors, so I merged the four tables into a single table for easier cleaning and analysis.
3. Tripduration column is in "2,137.0" format, the separator comma and the decimal point can't be interpreted, so the comma should be removed with an UPDATE command. Now the column's data type can be changed.

 ![table](https://github.com/user-attachments/assets/49b0503b-ea9d-430d-b12c-e98f89c435f2)

4. Validated that there are no duplicate entries.
5. Checked for missing values in case of non-nullable fields (trip_id, start_time, end_time, bikeid, from_station_id, to_station_id, usertype).
6. I checked the maximum and minimum values (where it made sense) to check for outliers.
		
I found that the lowest birth year is 1759. The dataset contains 783 entries where the birth year is less than 1920. These values were probably entered mistakenly. I didn't delete these rows, because the trip data is probably still valid, but I removed the birtyear from these entries, as it might skew the results of the analysis that I will make based on the birtyear.
		
The highest tripduration is 10628400 seconds (about 123 days). I found that in 1848 cases the tripduration is higher than 24 hours. Since this is only 0,0005% of the total cases, I decided not to delete these entries. If this was a real life project, I would check with Cyclistic team if it's an error or possible data. I would ask them if they have a policy to return the bikes after a certain time, and delete the entries where the tripduration is higher than that.

7. Validated usertype can only have two possible values (customer or subscriber).
8. Validated that every trip_id is 8 characters long.
9. Added the column "day_of_week" to the dataset, it will be useful to see which days are the busies for bike rental.



# Analyze & Share
In this chapter I include my findings through analysis and supporting visualizations.


## Initial observations
Total number of trips | Number of bikes used |  Average trip duration in minutes | Distinct start stations |  Distinct end stations 
--- | --- | --- | --- | ---
3818004 | 6017 | 24,17 | 616	| 617 



### Seasonal trends
I compared customers' and subscribers' number of trips throughout the year.
![Number of trips each month by user type](https://github.com/user-attachments/assets/1150a8c1-12ce-4abb-90ca-4a50e9543383)

This reveals that the summer months are the most popular among both user types. However, the proportion of customers (casual riders) is notably higher during this period. In summer, approximately 30% of users are customers. In contrast, during winter months, the percentage of customers drops significantly.

A clear example is February, where customers make up only about 2.5% of total users, with the remaining majority being subscribers. Customers rarely rent bikes in the colder months. January, February, March, November and December seem to be more popular among subscribers.


### What is the average ride duration per day?
I compared the average ride durations of the two user types across the days of the week.
![TripDurationByDay](https://github.com/user-attachments/assets/0d224e73-fbb9-49d8-ac85-f2248a377038)

There is no significant difference between the days, but it is clear that customers consistently rent the bikes for longer durations than subscribers.


### What is the average ride length for members and casual riders?
Customers: 57 minutes\
Subscribers: 14 minutes


### What is the average number of rides per day?
![TripCountByDay](https://github.com/user-attachments/assets/42b4ff42-8193-480a-96cb-9af7787553a8)

We can see that on weekdays a bigger portion of the users are subscribers, while the gap between subscribers and customers narrows on weekends. One time customers are more likely to use the bikes on weekends. Knowing from the previous calculation that customers also tend to use the bikes for longer, we can assume that they are more likely to use the bikes for leisure activities or trips rather than for commuting to work or school. Subscribers, on the other hand, appear to use the service more consistently for routine activities such as commuting.


### How do rides distribute throughout the day?
![TripCountByHour](https://github.com/user-attachments/assets/e43e7ce1-579d-404a-9278-929bf8f8dfa8)
Customers' rides are evenly distributed throughout the day, subscribers are most likely to rent a bike at rush hour. This reinforces the earlier assumption that subscribers are more likely to use the bikes for routine commuting, while customers tend to use the service more flexibly.


### Number of trips that ended in the station in which they started at
![RoundTrips](https://github.com/user-attachments/assets/61f2dc4c-f3e4-4565-bf61-10f2620a0db4)

Let's compare it to the number of trips that ended in a different station than they started in.

![OneWayTrips](https://github.com/user-attachments/assets/6d6362a8-283b-4093-b784-d5d8811c753d)

From these calculations I see that subscribers are more likely to travel from one station to another, while customers are more likely to arrive back at the station they departed from.


### Which stations are the most popular among subscribers? 
The below table summarizes the 5 most popular stations used by subscribers, with their trip counts:
Station name | Number of trips
--- | ---
Canal St & Adams St |	50575
Clinton St & Madison St |	45990
Clinton St & Washington Blvd |	45378
Columbus Dr & Randolph St	| 31370
Franklin St & Monroe St	| 30832


### Does age influence the likelyhood to be a subscriber?
![AgeGroups](https://github.com/user-attachments/assets/3b7830e8-0da3-465a-bc73-9448ee798567)

From this calculation I can see that the percentage of one time customers is the highest among people born after 2000. The data is from 2019, so these people are most likely students.

# Act
Based on my analysis, I propose the following top three recommendations to the marketing team:

1. Introduce student passes: Given the popularity of bike rentals among commuters, student passes could attract a large amount of riders. These passes would offer a more affordable option for students who rely on bikes for commuting, expanding the subscriber base.
   
2. Local advertising at popular stations: Since most subscribers appear to use bikes for commuting, placing local advertisements at high-traffic stations could effectively attract more subscribers. These ads could also include limited-time special discounts to encourage sign-ups.

3. Weekend passes: As weekend trips are a common use case among casual riders, Cyclistic could offer weekend passes at a lower price compared to the annual membership. This would appeal to customers who use the service for leisure or occasional trips, potentially increasing weekend usage and converting more casual riders into regular users.

