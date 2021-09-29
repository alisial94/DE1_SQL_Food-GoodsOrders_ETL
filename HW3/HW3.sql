HW3

Exercise 1:
select speed, aircraft, airline,
IF (SPEED<100 OR SPEED IS NULL, 'LOW SPEED', 'HIGH SPEED') AS speed_category 
FROM birdstrikes.birdstrikes
ORDER BY speed_category;

Excersie 2:
select count(distinct aircraft) from birdstrikes;

Exercise 3:
select min(speed) from birdstrikes where aircraft like 'H%';
Answer: 9;

Exercise 4:
select phase_of_flight, count(*) as count from birdstrikes group by phase_of_flight order by count limit 1;

Exercise 5:
select phase_of_flight, round(avg(cost)) as avg_cost from birdstrikes group by phase_of_flight
order by avg_cost desc limit 1;
Answer: Climb & 54673;

Exercise 6:
SELECT AVG(speed) AS avg_speed,state FROM birdstrikes GROUP BY state HAVING length(state)<5 and state!='' order by avg_speed desc limit 1;
Answer: 2862.5000 & Iowa