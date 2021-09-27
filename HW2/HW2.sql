HW: 2


Exercise 1:
create table employee (id integer not null, employee_name varchar(255) not null, primary key(id));

Exercise 2:
select state from birdstrikes limit 144,1;
Answer: Tennessee

Exercise 3:
select flight_date from birdstrikes order by flight_date desc limit 1;
Answer: 2000-04-18

Exercise 4:
select distinct cost from birdstrikes order by cost limit 49,1;
Answer: 86864

Exercise 5:
select state, bird_size from birdstrikes where state is not null and state !='' and bird_size is not null and bird_size !='' limit 1,1;
Answer: Colorada

Exercise 6:
select WEEKOFYEAR (flight_date) WEEK_, flight_date from birdstrikes where state = 'Colorado' and flight_date IS NOT NULL;
select DATEDIFF(NOW(), '2000-01-01');
Answer: 7940