select  from customer
select  from actor
select  from film_actor
select  from rental
select  from inventory
--1.1
with StaffTotalRevenue as (
  select
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    sum(p.amount) as total_revenue
  from
    staff s
    join payment p on s.staff_id = p.staff_id
    join rental r on p.rental_id = r.rental_id
 where
   extract(year from p.payment_date) = 2017
  group by
    s.staff_id, s.first_name, s.last_name, s.store_id
)
select
  str.staff_id,
  str.first_name,
  str.last_name,
  str.store_id,
  str.total_revenue
from
  StaffTotalRevenue str
where
  not exicts (
    select 1
    from StaffTotalRevenue str2
    where str2.store_id = str.store_id
     and str2.total_revenue > str.total_revenue
  );
--1.2
select distinct on (s.store_id)
  s.store_id,
  p.staff_id,
  s.first_name,
  s.last_name,
  sum(p.amount) as total_revenue
from
  staff s
  join payment p on s.staff_id = p.staff_id
  join rental r on p.rental_id = r.rental_id
where
  EXTRACT(YEAR FROM p.payment_date) = 2017
group by
  s.store_id, p.staff_id, s.first_name, s.last_name
order by
  s.store_id, total_revenue DESC;
  
--2.1
select
  f.film_id,
  f.title,
  f.rating,
  count(r.rental_id) as rental_count
from
  film f
  join inventory i on f.film_id = i.film_id
  join  rental r on i.inventory_id = r.inventory_id
group by
  f.film_id, f.title, f.rating
order by
  rental_count DESC
limit 5;
--2.2
with FilmRentalCounts as (
  select
    f.film_id,
    f.title,
    f.rating,
    count(r.rental_id) as rental_count,
    dense_rank() over (order by count(r.rental_id) DESC) AS rank
  from
    film f
    join inventory i on f.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
  group by
    f.film_id, f.title, f.rating
)
select
  film_id,
  title,
  rating,
  rental_count
from
  FilmRentalCounts
where
  rank <= 5
limit 5;

--3.1
select a.first_name, a.last_name, max(f.release_year) as latest_year 
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
group by a.first_name, a.last_name
order by latest_year asc;

--3.2

select a.first_name, a.last_name, (select max(f.release_year)
from film_actor fa
join film f on fa.film_id = f.film_id
where fa.actor_id = a.actor_id) 
as latest_year

from actor a order by latest_year asc;
