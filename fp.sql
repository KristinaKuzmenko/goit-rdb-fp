-- 1

create schema pandemic;

use pandemic;

select * from infectious_cases;

-- 2 Normalization 

create table if not exists countries
(id int auto_increment primary key,
country_code varchar(10) not null,
country_name varchar(50) not null);

create table if not exists inf_cases_norm
(id int auto_increment primary key,
country_id int not null,
year int not null,
number_yaws text,
polio_cases int,
cases_guinea_worm int,
number_rabies text,
number_malaria text,
number_hiv text,
number_tuberculosis text,
number_smallpox text,
number_cholera_cases text,
foreign key (country_id) references countries (id));

insert into countries (country_code, country_name)
select distinct code, entity from infectious_cases
where code is not null and code != '';

insert into inf_cases_norm (
    country_id, 
    year, 
    number_yaws, 
    polio_cases, 
    cases_guinea_worm, 
    number_rabies, 
    number_malaria, 
    number_hiv, 
    number_tuberculosis, 
    number_smallpox, 
    number_cholera_cases
)
select 
    c.id, 
    ic.year, 
    ic.number_yaws, 
    ic.polio_cases, 
    ic.cases_guinea_worm, 
    ic.number_rabies, 
    ic.number_malaria, 
    ic.number_hiv, 
    ic.number_tuberculosis, 
    ic.number_smallpox, 
    ic.number_cholera_cases
from infectious_cases ic 
inner join countries c on (ic.code = c.country_code and ic.entity = c.country_name);


-- 3

select ic.country_id, c.country_name, avg(cast(number_rabies as float)) as average, 
min(cast(number_rabies as float)) as min, 
max(cast(number_rabies as float)) as max,
sum(cast(number_rabies as float)) as sum
from inf_cases_norm ic
join countries c on (ic.country_id = c.id)
where number_rabies != ''
group by ic.country_id, c.country_name
order by average desc
limit 10;


-- 4

select makedate(year,1) as date, curdate() as cur_date, 
timestampdiff(year, makedate(year,1), curdate()) as full_year_diff,
datediff(curdate(), makedate(year,1))/365.25 as date_diff
from inf_cases_norm;

-- 5

-- function for calculating year difference
drop function if exists year_difference;

delimiter //
create function year_difference(input int)
returns float
no sql
begin
    declare result float;
    if input not between 1000 and 9999 then set result = null;
    else set result = datediff(curdate(), makedate(input,1))/365.25;
    end if;
    return result;
end//
delimiter ; 

select year_difference(2010);

-- function for calculating incidence rate for period of half a year, quaurter or month
drop function if exists incidence_rate;

delimiter //
create function incidence_rate(input_1 float, input_2 int)
returns float
deterministic
no sql
begin
    declare result float;
    if input_2 not in (2, 4, 12) then return null;
    else set result = input_1/input_2;
    end if;
    return result;
end//
delimiter ; 

select country_id, country_name, year, number_rabies, incidence_rate(cast(number_rabies as float), 2) as half_year_rete 
from inf_cases_norm ic
join countries c on (ic.country_id = c.id)
where number_rabies != ''
limit 40;

