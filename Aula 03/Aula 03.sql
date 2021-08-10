-- ATIVIDADE

select * from pg_tables where schemaname = 'public';

do
$$
declare
	consulta record;
	comando varchar default '';
begin
	for consulta in select * from pg_tables where schemaname = 'public' loop
		comando := concat('alter table ', consulta.tablename,
						  ' add column created_at timestamp default now(), 
						  add column modified_at timestamp default now(), 
						  add column active boolean default true;'
						 );
-- 		raise notice '%', comando;
 		execute comando;
	end loop;
end;
$$



--SQL - ATIVIDADES--

select e.name from employee e where e.name ilike '%silva%';

------------------------------------------------------------

select e.name, e.salary from employee e where e.salary > 5000 order by e.salary asc;

------------------------------------------------------------

select c.name, c.income from customer c where c.income < 2000;

------------------------------------------------------------

select
	e.name as "Employee",
	date_part('year', e.admission_date) as "Admission Date"
from 
	employee e
where
	date_part('year', e.admission_date) between  2010 and 2021
order by
	2;

------------------------------------------------------------
explain
select
	e.name, m.name as "Marital Status"
from
	employee e
inner join
	marital_status m on m.id = e.id_marital_status
group by
	1, 2

------------------------------------------------------------

select
	e.name, m.name
from
	employee e
inner join
	marital_status m on m.id=e.id_marital_status
where
	m.id in (1,2)

------------------------------------------------------------

select
	e.name, e.salary
from
	employee e
where
	e.salary between 1000 and 5000
order by 2 desc

------------------------------------------------------------

select
	pd.name, pd.cost_price, pd.sale_price, (pd.sale_price - pd.cost_price) as "diference"
from
	product pd
	
------------------------------------------------------------

select
	e.name, e.salary
from
	employee e
where
	e.salary not between 4000 and 8000
order by 2 

------------------------------------------------------------

select distinct s.id_customer from sale s;

explain
select
	c.name
from
	customer c
where
	c.id in (select distinct s.id_customer from sale s);
	
	
explain
select
	c.name
from
	customer c
where
	exists (select distinct s.id_customer from sale s where s.id_customer = c.id);


select
	c.name
from
	customer c
where
	not exists (select distinct s.id_customer from sale s where s.id_customer = c.id);

------------------------------------------------------------

-- Continuar no exercício 2, página 77

------------------------------------------------------------


select * from sale s
where date_part('year', s.date) between 2010 and 2021;


-- Estrutura CASE:

select
	case when condicao then 'Valor retornado'
		 when outra_condicao then 'Valor retornado'
		 else 'Valor default retornado'
	end
from tabela


select e.name,
	case 
		when e.gender = 'M' then 'Masculino'
		else 'Feminino'
	end as sexo
from employee e;

------------------------------------------------------------

select e.name,
	case when date_part('year', age(e.birth_date)) between 18 and 25 then 'Jr.'
	when date_part('year', age(e.birth_date)) between 26 and 34 then 'Pl.'
	when date_part('year', age(e.birth_date)) >= 35 then 'Jr.'
	else 'Menor aprendiz'
	end as status
from employee e;


select e.name,
	case when date_part('year', age(e.birth_date)) between 18 and 25 then 'Jr.'
	when date_part('year', age(e.birth_date)) between 26 and 34 then 'Pl.'
	when date_part('year', age(e.birth_date)) >= 35 then 'Jr.'
	end as status
from employee e
where date_part('year', age(e.birth_date)) >= 18;


select * from
(
	select e.name,
	case when date_part('year', age(e.birth_date)) between 18 and 25 then 'Jr.'
	when date_part('year', age(e.birth_date)) between 26 and 34 then 'Pl.'
	when date_part('year', age(e.birth_date)) >= 35 then 'Jr.'
	end as status
	from employee e
) as consulta
where consulta.status is not null;


with consulta as
(
	select e.name,
	case when date_part('year', age(e.birth_date)) between 18 and 25 then 'Jr.'
	when date_part('year', age(e.birth_date)) between 26 and 34 then 'Pl.'
	when date_part('year', age(e.birth_date)) >= 35 then 'Jr.'
	end as status
	from employee e
) 
select * from consulta
where consulta.status is not null;

------------------------------------------------------------

select 
	e.name,
	date_part('year', age(e.admission_date)) as time_company,
	case when date_part('year', age(e.admission_date)) <= 2 then 'Novato'
	     when date_part('year', age(e.admission_date)) between 3 and  5 then 'Intermediário'
		else 'Veterano'
	end as status
from employee e
order by 2;

------------------------------------------------------------

--JOINS

-- INNER JOIN
select e.id_department, d.id  from employee e
inner join department d on e.id_department = d.id

-- LEFT JOIN
select
	e.name,
	d.name as departamento
from employee e
left join department d on e.id_department = d.id;

-- RIGHT JOIN
select
	e.name,
	d.name as departamento
from department d
RIGHT join employee e on e.id_department = d.id;

-- CROSS JOIN
select * from department d
cross join marital_status;

-- O SGBD faz o join e depois faz o filtro o where.
-- Se colocarmos as condições do where dentro do join, a consulta tem mais performance
explain
select * from employee e
inner join department d on e.id_department = d.id and e. salary >= 3000
order by e.id desc;


-- ATIVIDADES

select e.name, e.id_district, d.name, d.id from employee e
inner join district d on d.id = e.id_district;

select c.name as customer, ci.name as city, z.name as zone from customer c
inner join district d on d.id = c.id_district
inner join zone z on z.id = d.id_zone
inner join city ci on ci.id = d.id_city

select
	b.id as branch_id,
	b.id_district as branch_id_district,
	b.name as filial,
	s.name as estado,
	ci.name as cidade
from branch b
inner join district d on d.id = b.id_district
inner join city ci on ci.id = d.id_city
inner join state s on s.id = ci.id_state;

select
	e.name as funcionario,
	ms.name as estado_civil,
	d.name as departamento
from employee e
inner join marital_status ms on ms.id = e.id_marital_status
inner join department d on d.id = e.id_department;










