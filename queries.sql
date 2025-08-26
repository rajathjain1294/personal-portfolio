--  CREATE A DATABASE
CREATE DATABASE ZOMATO ;

-- SELECT THE DATABASE
USE ZOMATO ;

-- IMPORT THE CSV FILE FROM THE IMPORT WIZARD OPTION
-- MAKE SURE TO USE THE CORRECT DATATYPE AS PER DATAMODEL

-- Explore the imported data
-- Restaurant data
select * from restaurant_data ;
-- Country data
select * from country_data ;

/* Q1. Get overall statistics for the Indian restaurant market. */
select count(*) total_restaurants,
       count(distinct city) as total_cities,
       avg(Rating) as average_rating,
       avg(Average_Cost_for_two) avg_cost
from restaurant_data rd
inner join country_data cd
on rd.CountryCode = cd.Country_Code 
where Country = 'India';

/* Q2. Top 10 Indian cities with number of restaurant, average rating, average cost */
select top 10 city, 
        count(*) restaurant_count,
        avg(Rating) avg_rating,
        avg(Average_Cost_for_two) avg_cost
from restaurant_data rd 
inner join country_data cd 
on cd.Country_Code = rd.CountryCode
where Country = 'India' 
group by city 
order by 2 desc;

/* Q3. Understand pricing segments and their relationship with ratings in India. */
select Price_range, 
    count(*) as restaurant_count,
    avg(Rating) avg_rating,
    count(*) * 100 / (select count(*) from restaurant_data where CountryCode = 1) percentage,
    min(Average_Cost_for_two) min_cost_for_two,
    max(Average_Cost_for_two) max_cost_for_two
from restaurant_data rd 
inner join country_data cd 
on cd.Country_Code = rd.CountryCode
where Country = 'India'
group by Price_range
order by 2 desc;

/* Q4. Compare restaurant types based on service offerings in India.
Online Delivery vs Dine-in Analysis */

select Has_Online_delivery, Has_Table_booking,
        count(*) restaurant_count,
        avg(Rating) avg_rating,
        avg(Average_Cost_for_two) avg_cost,
        avg(Votes) avg_votes
from country_data cd 
inner join restaurant_data rd 
on cd.Country_Code = rd.CountryCode 
where Country = 'India' 
group by Has_Online_delivery, Has_Table_booking;

/* Q5. Identify top 15 most popular cuisine types and their performance metrics in India. */
select TOP 15 Cuisines, 
        count(*) restaurant_count,
        avg(Rating) avg_rating,
        avg(Average_Cost_for_two) avg_cost,
        avg(Votes) avg_votes
from restaurant_data rd 
join country_data cd 
on rd.CountryCode = cd.Country_Code
where country = 'India'
group by Cuisines 
order by 2 desc;

/* Q6. Compare budget vs premium restaurant segments in India */
select  
    case 
        when Price_range in (1, 2) then 'Budget'
        when Price_range in (3, 4) then 'Premium'
    end as segment,
    count(*) restaurant_count,
    avg(Rating) avg_rating,
    avg(Votes) avg_votes,
    avg(Average_Cost_for_two) avg_cost,
    sum(case when Has_Online_delivery = 'Yes' then 1 else 0 end) online_delivery_count,
    sum(case when Has_Table_booking = 'Yes' then 1 else 0 end) table_booking_count
from country_data cd 
join restaurant_data rd 
on cd.Country_Code = rd.CountryCode 
where Country = 'India' 
group by 
    case 
        when Price_range in (1, 2) then 'Budget'
        when Price_range in (3, 4) then 'Premium'
    end;

/* Q7. City-wise Rating Distribution in Top 5 Indian Cities */

with top_cities as (
    select top 5 City
    from country_data cd 
    join restaurant_data rd 
    on cd.Country_Code = rd.CountryCode 
    where Country = 'India' 
    group by City
    order by count(*) desc
)
select tc.City, count(*) restaurant_count ,
    sum(case when Rating >= 4 then 1 else 0 end) as excellent_rating,
    sum(case when Rating >= 3  and rating < 4then 1 else 0 end) as good_rating,
    sum(case when Rating < 3  and rating > 0 then 1 else 0 end) as poor_rating,
    sum(case when Rating = 0  and rating is null then 1 else 0 end) as no_rating
from top_cities tc
join restaurant_data rd
on tc.City = rd.City 
group by tc.City
order by 2 desc;

/* Q8. Compare average dining costs across different countries */
select Country,
    avg(Average_Cost_for_two) avg_cost,
    Currency
from restaurant_data rd 
inner join country_data cd
on rd.CountryCode = cd.Country_Code
group by Country, Currency
order by 2 desc;

/* Q9. Analyze digital service adoption across Indian cities */
select City, count(*) restaurant_count,
    sum(case 
            when Has_Online_delivery = 'Yes' or Has_Table_booking = 'Yes' then 1 
            else 0 
        end) digital_adoption_count,
    sum(case 
            when Has_Online_delivery = 'Yes' or Has_Table_booking = 'Yes' then 1 
            else 0 
        end) * 100 / count(*) as digital_adoption_percentage
from country_data cd 
join restaurant_data rd 
on cd.Country_Code = rd.CountryCode 
where Country = 'India' 
group by city 
order by 2 desc;

/* Q10. Top Rated Restaurants in India with High Vote Count */
select top 20 RestaurantID,
    RestaurantName,
    City,
    Cuisines, 
    Rating,
    Votes,
    Average_Cost_for_two,
    Has_Online_delivery,
    Has_Table_booking
from country_data cd 
join restaurant_data rd 
on cd.Country_Code = rd.CountryCode 
where Country = 'India' 
    and Rating >= 4
    and Votes >= 100 
order by 5 desc, 6 desc;

/* Q11. India vs Other Countries - Service Features Comparison */
select case 
        when Country = 'India' then 'India'
        else 'Other Countries'
       end as region,
       count(*) restaurant_count,
       avg(Rating) avg_rating,
       avg(Votes) avg_votes,
       sum(case 
            when Has_Online_delivery = 'Yes' or Has_Table_booking = 'Yes' then 1 
            else 0 
        end) * 100 / count(*) as digital_adoption_percentage
from restaurant_data rd 
join country_data cd 
on cd.Country_Code = rd.CountryCode 
group by 
    case 
        when Country = 'India' then 'India'
        else 'Other Countries'
    end ;

/* HOMEWORK

1. Market Penetration Analysis - India vs International 
    - Compare Zomato's market presence and performance across key countries.
    - 'India', 'United States', 'UAE', 'Singapore', 'Australia'
2. Cuisine Diversity Analysis by Indian Cities
    - Measure culinary diversity across Indian cities. 
    
*/