--SUBQUERIES

-- OPERADORES: EXISTS, NOT EXISTS, IN, NOT IN, ANY/SOME, ALL
select *
from employee e
where e.salary in (1000, 2000, 300);

----------------------------------

select c.name
from city c
where c.id in (
    select d.id_city
    from sale s
             inner join branch b on s.id_branch = b.id
             inner join district d on b.id_district = d.id
    where date_part('year', s.date) = 2021
);
----------------------------------

select z.name
from zone z
where z.id in (
    select d.id_zone
    from sale s
             inner join branch b on s.id_branch = b.id
             inner join district d on b.id_district = d.id
    where date_part('year', s.date) = 2021
);

select z.name
from zone z
where z.id = any (
    select d.id_zone
    from sale s
             inner join branch b on s.id_branch = b.id
             inner join district d on b.id_district = d.id
    where date_part('year', s.date) = 2021
);

select z.name
from zone z
where exists(
              select d.id_zone
              from sale s
                       inner join branch b on s.id_branch = b.id
                       inner join district d on b.id_district = d.id
              where date_part('year', s.date) = 2021
                and d.id_zone = z.id
          );

----------------------------------

select s.name
from state s
where s.id not in (
    select c.id_state
    from sale s
             inner join branch b on s.id_branch = b.id
             inner join district d on b.id_district = d.id
             inner join city c on d.id_city = c.id
    where date_part('year', s.date) = 2020
);

select st.name
from state st
where not exists(
        select c.id_state
        from sale s
                 inner join branch b on s.id_branch = b.id
                 inner join district d on b.id_district = d.id
                 inner join city c on d.id_city = c.id
        where date_part('year', s.date) = 2020
          and c.id_state = st.id
    );

----------------------------------

select *
from customer c
where c.id = all (select s.id_customer from sale s);

----------------------------------

explain
select *
from customer c
where row (c.id, c.active) in (select s.id_customer, s.active from sale s);

explain
select *
from customer c
where exists(select s.id_customer, s.active from sale s where s.id_customer = c.id and c.active = s.active);

----------------------------------

select d.id,
       d.name,
       (select max(e.salary) from employee e where e.id_department = d.id),
       (select e.salary from employee e where e.id_department = d.id order by coalesce(e.salary, 0) desc limit 1),
       (select array_agg(e.name) from employee e where e.id_department = d.id)
from department d;

----------------------------------


select c.name
from customer c
where exists(
              select *
              from sale s
              where s.id_customer = c.id
                and date_part('year', s.date) = 2012
          );

----------------------------------

select *
from zone z
where exists(select *
             from sale s
                      inner join customer c on s.id_customer = c.id
                      inner join district d on c.id_district = d.id
             where date_part('year', s.date) = 2021
               and z.id = d.id_zone
          );

----------------------------------

select b.name
from branch b
where exists(
              select *
              from sale s
                       inner join sale_item si on s.id = si.id_sale
                       inner join product p on p.id = si.id_product
                       inner join product_group pg on pg.id = p.id_product_group
              where date_part('year', s.date) = 2013
                and unaccent(pg.name) = 'Alimenticio'
                and b.id = s.id_branch
          );

create extension unaccent;
drop extension unaccent;

----------------------------------
--Relatório crosstab é o ideal
select case
           when consulta.sexo = 'F' then 'Feminino'
           else 'Masculino' end                 as sexo,
       (select sum(p.sale_price * si.quantity)
        from sale s
                 inner join customer c on s.id_customer = c.id
                 inner join sale_item si on s.id = si.id_sale
                 inner join product p on p.id = si.id_product
        where date_part('year', s.date) = 2010) as ano_2010,
       (select sum(p.sale_price * si.quantity)
        from sale s
                 inner join customer c on s.id_customer = c.id
                 inner join sale_item si on s.id = si.id_sale
                 inner join product p on p.id = si.id_product
        where date_part('year', s.date) = 2011) as ano_2011
from (
         select unnest(array ['M', 'F']) as sexo
     ) as consulta;



----------------------------------
select *
from product p
where not exists(
        select *
        from sale s
                 inner join sale_item si on si.id_sale = s.id
        where date_part('year', s.date) = 2020
          and p.id = si.id_product
    );

----------------------------------
explain
select p.name
from product p
where exists(
              select *
              from sale_item si
                       inner join sale s on s.id = si.id_sale and date_part('year', s.date) = 2015
                       inner join customer c on c.id = s.id_customer and c.id_marital_status != 2
              where p.id = si.id_product
          );
----------------------------------

--- REFAZER
select pg.name,
       (select sum((p.sale_price - p.cost_price) * si.quantity)
        from sale s
                 inner join sale_item si on s.id = si.id_sale
                 inner join product p on p.id = si.id_product
        where date_part('month', s.date) = 01
          and pg.id = p.id_product_group
       ) as janeiro
from product_group pg;


----------------------------------

select sp.name
from supplier sp
where not exists(select *
                 from sale s
                          inner join sale_item si on s.id = si.id_sale and date_part('year', s.date) = 2021
                          inner join product p
                                     on si.id_product = p.id
                 where sp.id = p.id_supplier)
;

----------------------------------

select p.name,
       (select concat(
                       sum(si.quantity) filter (where c.id_marital_status = 1), ' - ',
                       sum(si.quantity) filter (where c.id_marital_status = 2), ' - ',
                       sum(si.quantity) filter (where c.id_marital_status = 3), ' - ',
                       sum(si.quantity) filter (where c.id_marital_status = 4)
                   )
        from sale s
                 inner join sale_item si on s.id = si.id_sale
                 inner join customer c on s.id_customer = c.id
        where si.id_product = p.id
          and date_part('year', s.date) = 2019) as total
from product p
where exists(select *
             from sale s2
                      inner join sale_item i on s2.id = i.id_sale
             where date_part('year', s2.date) = 2019);

----------------------------------
-- VIEWS
-- São estruturas que armazenam um SQL para ser executada mais facilmente.
-- É utilizada em cenários onde a mesma consulta é realizada repetidas vezes


create or replace view vw_exemplo as
select *
from state;

select v.name
from vw_exemplo v;






