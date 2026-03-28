CREATE DATABASE straigthofhormuz;
USE straigthofhormuz;

CREATE TABLE Ship_Traffic (
    Date DATE,
    Vessel_ID VARCHAR(20),
    Ship_Type VARCHAR(50),
    Latitude FLOAT,
    Longitude FLOAT,
    Speed_knots FLOAT
);

CREATE TABLE Oil_Prices (
    Date DATE,
    Brent_Price FLOAT,
    WTI_Price FLOAT
);

CREATE TABLE Events (
    Date DATE,
    Event_Type VARCHAR(50),
    Severity VARCHAR(20)
);


select * from events;
select * from oil_prices;
select * from ship_traffic;

-- BASIC LEVEL

-- Q1: Count total rows in each table
select COUNT(*) FROM events;
select count(*) from oil_prices;
select count(*) from ship_traffic;
-- Q2: View first 10 rows from each table
select * from events limit 10;
select * from oil_prices limit 10;
select * from ship_traffic limit 10;
-- Q3: Find distinct ship types
select distinct ship_type from ship_traffic;
-- Q4: Find date range in each table
select max(date),min(date) from ship_traffic;
select max(date),min(date) from events;
select max(date),min(date) from oil_prices;
-- Q5: Count number of ships per day
select date,count(*) from ship_traffic group by date ;

-- SHIP TABLE

-- Q6: Find total ships by ship type
select ship_type,count(*) from ship_traffic group by ship_type;
-- Q7: Find average ship speed
select avg(speed_knots) from ship_traffic;
-- Q8: Find max and min ship speed
select max(speed_knots),min(speed_knots) from ship_traffic;
-- Q9: Find ships with speed > 15 knots
select * from ship_traffic where speed_knots > 15;
-- Q10: Count ships per ship type per day
SELECT date, ship_type, COUNT(*) from ship_traffic 
GROUP BY date, ship_type;

-- OIL PRICES

-- Q11: Find average Brent and WTI price
select avg(brent_price) as average_brint_price,avg(wti_price) as average_wti_price from oil_prices;
-- Q12: Find highest and lowest oil price
select max(brent_price) as brent_price_max , min(brent_price) as brent_price_min ,max(wti_price) as wti_price_max, min(wti_price) as wti_price_min from oil_prices;
-- Q13: Show daily oil price trend
select date,sum(brent_price),sum(wti_price) from oil_prices group by date;

-- EVENTS

-- Q14: Count events by type
select event_type,count(*) from events group by Event_Type;
-- Q15: Count events by severity
select severity,count(*) from events group by severity;
-- Q16: Find how many days had “No Incident”
select Event_Type,count(*) from events group by event_type having Event_Type = 'No incident';

-- INTERMEDIATE LEVEL

-- Q17: Join Ship_Traffic with Oil_Prices
select * from ship_traffic as s1 inner join oil_prices s2 on s1.date = s2.date; 
-- Q18: Join Ship_Traffic with Events
select * from ship_traffic as s1 inner join events s2 on s1.date = s2.date; 
-- Q19: Join all 3 tables
SELECT *
FROM Ship_Traffic s
JOIN Oil_Prices o ON s.date = o.date
JOIN Events e ON e.date = o.date;

-- ANALYSIS

-- Q20: Count ships on each event type
SELECT event_type,count(*) as ship_count
FROM Ship_Traffic s
JOIN Events e ON s.date = e.date
group by event_type;
-- Q21: Find average ship speed per event type
select event_type,avg(speed_knots) FROM Ship_Traffic s
JOIN Events e ON s.date = e.date
group by event_type;  
-- Q22: Find ship count by severity
select severity,count(*) FROM Ship_Traffic s
JOIN Events e ON s.date = e.date
group by severity;  
-- Q23: Find average oil price per event type
select event_type,avg(brent_price),avg(wti_price) FROM Oil_Prices o
JOIN Events e ON e.date = o.date
group by event_type; 
-- Q24: Compare oil price on event vs no-event days

SELECT 
    CASE 
        WHEN event_type = 'No Incident' THEN 'No Event'
        ELSE 'Event'
    END as Event,
    avg(brent_price),avg(wti_price)
FROM Oil_Prices o
JOIN Events e ON e.date = o.date
GROUP BY event;

 
-- TREND ANALYSIS

-- Q25: Find daily ship traffic trend
SELECT date, COUNT(*)
FROM ship_traffic
GROUP BY date
ORDER BY date;
-- Q26: Find daily average speed
SELECT date, ROUND(avg(speed_knots),1) AS AVERAGE_SPEED
FROM ship_traffic
GROUP BY date
ORDER BY date;
-- Q27: Find daily oil price trend with events
SELECT o.date,e.event_type,brent_price,wti_price
FROM oil_prices o
JOIN Events e ON o.date = e.date;
-- Q28: Find busiest day (max ships)
select date , count(*) as ships_no from ship_traffic 
group by date
order by 2 desc 
limit 1;
-- Q29: Find slowest traffic day
select date , avg(Speed_knots) as slowest_traffic from ship_traffic 
group by date
order by 2 
limit 1;

-- ADVANCED LEVEL

-- Q30: Does ship traffic decrease on high severity days?
select severity,count(*) from ship_traffic s join 
events e on s.date = e.date 
group by severity; 
-- Answer: Yes,ship traffic decreases;

-- Q31: Which event type causes maximum traffic drop?
with daily_traffic as
(
SELECT e.date,event_type, COUNT(*) AS ships
from ship_traffic s join
events e
on s.date = e.date
group by e.date,event_type
)
select event_type,avg(ships) average_traffic from daily_traffic
group by event_type
order by average_traffic
limit 1;

-- Answer: Event type - sanction

-- Q32: Compare avg traffic across severity levels
with daily_traffic as
(
SELECT e.date,severity, COUNT(*) AS ships
from ship_traffic s join
events e
on s.date = e.date
group by e.date,event_type
)
select event_type,avg(ships) average_traffic from daily_traffic
group by event_type
order by average_traffic
limit 1;

-- PRICE VS EVENTS

-- Q33: Which event type causes highest oil price?
select Event_Type,sum(brent_price),sum(wti_price) 
from events e join oil_prices o on e.date = o.date
group by event_type
order by 1 desc
limit 1; 
-- Q34: Do high severity events increase oil prices?
select severity,avg(brent_price)
from events e join oil_prices o on e.date = o.date
group by Severity
order by 2 desc; 

-- Q35: Find days where price spikes occur
WITH temp AS (
    SELECT 
        date,
        brent_price,
        LAG(brent_price) OVER (ORDER BY date) AS prev_price
    FROM oil_prices
)
SELECT *
FROM temp
WHERE brent_price > prev_price
AND (brent_price - prev_price)/prev_price > 0.05;
-- TRAFFIC VS PRICE

-- Q36: Do lower ship counts correlate with higher oil prices?
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS brent_price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
)

SELECT 
    traffic_type,
    AVG(brent_price)
FROM (
    SELECT 
        date,
        ship_count,
        brent_price,
        CASE 
            WHEN ship_count <  (SELECT AVG(ship_count) FROM daily_data) THEN 'Low Traffic'
            ELSE 'High Traffic'
        END AS traffic_type
    FROM daily_data
) t
GROUP BY traffic_type;
-- Q37: Find days with low traffic and high price
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS brent_price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
),

classified_data AS (
    SELECT 
        date,
        ship_count,
        brent_price,
        CASE 
            WHEN ship_count < (SELECT AVG(ship_count) FROM daily_data) 
            THEN 'Low Traffic'
            ELSE 'High Traffic'
        END AS traffic_type
    FROM daily_data
)

SELECT 
    traffic_type,
    AVG(brent_price) AS avg_price
FROM classified_data
GROUP BY traffic_type;

-- This could mean:

-- Traffic is responding to demand, not causing price
-- Or dataset doesn’t capture real disruption patterns

-- EXPERT LEVEL

-- Q38: Calculate day-over-day change in oil prices
WITH temp AS (
    SELECT 
        date,
        brent_price,
        LAG(brent_price) OVER (ORDER BY date) AS prev_price
    FROM oil_prices
)
select date,brent_price,prev_price,ROUND((brent_price - prev_price)/prev_price * 100,2) as dod_change from temp where prev_price is not null;
-- Q39: Find rolling average of oil prices (7 days)

SELECT 
    date,
    brent_price,
    ROUND(
        AVG(brent_price) OVER (
            ORDER BY date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_avg_3d
FROM oil_prices;

-- Q41: Rank ship types by speed
WITH temp AS (
    SELECT 
	
        ship_type,
        AVG(speed_knots) AS avg_speed
    FROM ship_traffic
    GROUP BY ship_type
)

SELECT 
    ship_type,
    avg_speed,
    RANK() OVER (
        ORDER BY avg_speed desc
    ) AS speed_rank
FROM temp;

-- RISK ANALYSIS

-- Q42: Identify high-risk days (high severity + low traffic + high price)
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS average_brent_price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
),

classified_data AS (
    SELECT 
        date,
        ship_count,
        average_brent_price,
        CASE 
            WHEN ship_count < (SELECT AVG(ship_count) FROM daily_data) 
            THEN 'Low Traffic'
            ELSE 'High Traffic'
        END AS traffic_type
    FROM daily_data
)

SELECT *
FROM classified_data c
JOIN Events e ON c.date = e.date
WHERE 
    traffic_type = 'Low Traffic'
    AND severity = 'High'
    AND average_brent_price > (
        SELECT AVG(brent_price) FROM oil_prices
    );
-- Q43: Identify low-risk days (no events + high traffic + stable prices)
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS average_brent_price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
),

classified_data AS (
    SELECT 
        date,
        ship_count,
        average_brent_price,
        CASE 
            WHEN ship_count < (SELECT AVG(ship_count) FROM daily_data) 
            THEN 'Low Traffic'
            ELSE 'High Traffic'
        END AS traffic_type
    FROM daily_data
),

avg_price_cte AS (
    SELECT AVG(brent_price) AS avg_price FROM oil_prices
)

SELECT *
FROM classified_data c
JOIN Events e ON c.date = e.date
CROSS JOIN avg_price_cte a
WHERE 
    traffic_type = 'High Traffic'
    AND event_type = 'No Incident'
    AND average_brent_price BETWEEN a.avg_price * 0.95 AND a.avg_price * 1.05;

-- BUSINESS INSIGHTS

-- Q44: Which factor impacts oil prices most?

WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS average_brent_price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
),

classified_data AS (
    SELECT 
        date,
        ship_count,
        average_brent_price,
        CASE 
            WHEN ship_count < (SELECT AVG(ship_count) FROM daily_data) 
            THEN 'Low Traffic'
            ELSE 'High Traffic'
        END AS traffic_type
    FROM daily_data
),

avg_price_cte AS (
    SELECT AVG(brent_price) AS avg_price FROM oil_prices
)

SELECT traffic_type
FROM classified_data c
JOIN Events e ON c.date = e.date
JOIN S
CROSS JOIN avg_price_cte a;


-- Q45: What patterns indicate disruption risk?
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
)

SELECT *
FROM daily_data d
JOIN events e ON d.date = e.date
WHERE 
    severity = 'High'
    AND ship_count < (SELECT AVG(ship_count) FROM daily_data)
    AND price > (SELECT AVG(brent_price) FROM oil_prices);
-- Q46: Which days should shipping companies avoid?
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
)

SELECT d.date
FROM daily_data d
JOIN events e ON d.date = e.date
WHERE 
    severity = 'High'
    AND ship_count < (SELECT AVG(ship_count) FROM daily_data)
    AND price > (SELECT AVG(brent_price) FROM oil_prices);
-- Q47: Build a risk score using severity, traffic, and price
WITH daily_data AS (
    SELECT 
        s.date,
        COUNT(*) AS ship_count,
        AVG(brent_price) AS price
    FROM ship_traffic s
    JOIN oil_prices o ON s.date = o.date
    GROUP BY s.date
),

scored_data AS (
    SELECT 
        d.date,
        
        -- Severity score
        CASE 
            WHEN e.severity = 'High' THEN 3
            WHEN e.severity = 'Medium' THEN 2
            ELSE 1
        END AS severity_score,

        -- Traffic score
        CASE 
            WHEN d.ship_count < (SELECT AVG(ship_count) FROM daily_data) THEN 3
            ELSE 1
        END AS traffic_score,

        -- Price score
        CASE 
            WHEN d.price > (SELECT AVG(brent_price) FROM oil_prices) THEN 3
            ELSE 1
        END AS price_score

    FROM daily_data d
    JOIN events e ON d.date = e.date
)

SELECT 
    date,
    (severity_score + traffic_score + price_score) AS risk_score
FROM scored_data
ORDER BY risk_score DESC;