-- /KPI/
create database kpi;
use kpi;
create table zom (RestaurantID varchar(30),RestaurantName text, Countrycode varchar(255), Country varchar(255),city varchar(100)
, Currency varchar(100), Has_table_booking varchar(5), 
 Has_online_delivery varchar(5), price_range int, votes int, average_cost_for_two int,
 rating DECIMAL(3,2), datekey_opening date,USD_RATE DECIMAL(12,9) );
 select * from zom;

# Build a Calendar Table using the Column Datekey
SELECT 
    datekey_opening,
    YEAR(datekey_opening) AS year,
    MONTH(datekey_opening) AS month_no,
    DATE_FORMAT(datekey_opening, '%M') AS month_fullname,
    DATE_FORMAT(datekey_opening, '%Y-%m') AS year1_month,
    DAYOFWEEK(datekey_opening) AS weekday_no,
    DATE_FORMAT(datekey_opening, '%W') AS weekday_name
FROM 
    zom;
    
 #  Numbers of Restaurants opening based on Year,  Month
select
Year(datekey_opening) as year,
Month(datekey_opening) as Month,
count(*) as num_opening from zom 
group by Year(datekey_opening),Month(datekey_opening) order by Year, Month;

 # Find the Numbers of Resturants based on City and Country.
select city,Country,count(RestaurantID) as number_of_restaurants from zom group by city,Country order by city,Country;

# Count of Resturants based on Average Ratings
SELECT 
    CASE
        WHEN rating <= 2 THEN 'Poor'
        WHEN rating > 2 AND rating <= 2.9 THEN 'Fair'
        WHEN rating > 2.9 AND rating <= 3.9 THEN 'Good'
        WHEN rating > 3.9 THEN 'Excellent'
    END AS rating_category,
    COUNT(*) AS restaurant_count
FROM 
    zom
GROUP BY 
    rating_category;
# Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets
SELECT 
    CASE
        WHEN price_range = 1 THEN 'Lower End'
        WHEN price_range = 2 THEN 'Lower Mid'
        WHEN price_range = 3 THEN 'Higher Mid'
        WHEN price_range = 4 THEN 'Higher End'
    END AS buckets,
    COUNT(restaurantid) AS restaurant_count
FROM 
    zom
GROUP BY 
    buckets;

# Percentage of Resturants based on "Has_Table_booking" 
select Has_table_booking, count(RestaurantID) as 'No of Restaurants',
concat(round(count(RestaurantID)/(select count(RestaurantID) from zom) *100,2),'%') as 'Restaurant %' 
from zom group by Has_table_booking;

# Percentage of Resturants based on "Has_Online_delivery"
select Has_online_delivery, count(RestaurantID) as 'No. of Restaurants', 
concat(round(count(RestaurantID)/(select count(RestaurantID) from zom) *100,2),'%') as 'Restaurant %' 
from zom group by Has_online_delivery;

# Average Rating by City
select city, Round (avg(rating), 2) as 'Average Rating' from zom group by city;

# Average Rating Change Over Previous Period
SELECT datekey_opening, AVG(rating) AS avg_rating, LAG(AVG(rating)) OVER (ORDER BY datekey_opening) AS previous_avg_rating FROM zom 
GROUP BY datekey_opening ORDER BY datekey_opening;

# Average Votes per Restaurant
SELECT RestaurantID,RestaurantName , AVG(votes) AS avg_votes FROM zom GROUP BY RestaurantID,RestaurantName;

# Percentage of Restaurants with Table Booking and High Ratings
SELECT COUNT(CASE WHEN Has_table_booking = 'Yes' AND rating >= 4.0 THEN 1 END) * 100.0 / COUNT(*) AS pct_table_booking_high_rating FROM zom;

# Ratio of Online Delivery to Table Booking Adoption
SELECT COUNT(CASE WHEN Has_online_delivery = 'Yes' THEN 1 END) * 1.0 / COUNT(CASE WHEN Has_table_booking = 'Yes' THEN 1 END) AS online_delivery_to_booking_ratio 
FROM zom;

# Number of Restaurants Offering Both Table Booking and Online Delivery
SELECT COUNT(*) AS num_restaurants FROM zom WHERE Has_table_booking = 'Yes' AND Has_online_delivery = 'Yes';

# Number of Restaurants by City
SELECT city, COUNT(DISTINCT RestaurantID) AS num_restaurants FROM zom GROUP BY city;