-- SQL

select e.name,
       e.salary
from employee e
order by e.salary desc
limit 10;

----------------------------------------

select c.name,
       c.income
from customer c
order by 2
limit 20;

----------------------------------------

select e.name,
       e.salary
from employee e
order by 2 desc
limit 10 offset 10;

select pd.name,
       pd.sale_price
from product pd
where p.id in (
    select si.id_product
    from sale s
             inner join sale_item si on s.id = si.id_sale
    where date_part('year', s.date) = 2021
)
order by 2 desc;


select pd.name,
       pd.sale_price
from product pd
where exists(
              select *
              from sale s
                       inner join sale_item si on s.id = si.id_sale
              where date_part('year', s.date) = 2021
                and si.id_product = pd.id
          )
order by pd.sale_price desc;

----------------------------------------

-- UNION ALL: Não remove valores duplicados
-- UNION: Não remove valores duplicados
-- As colunas precisam ser iguais (em quantidade e tipo);

(select e.name,
        e.salary
 from employee e
 order by 2 desc
 limit 5)
union
(
    select c.name,
           c.income
    from customer c
    order by 2 desc
    limit 5);

----------------------------------------	
(select e.name,
        e.salary
 from employee e
 order by 2 asc
 limit 5)
union
(
    select c.name,
           c.income
    from customer c
    order by 2 asc
    limit 5);
----------------------------------------

(select c.name,
        c.income as valor
 from customer c
 where c.gender = 'F'
 order by valor desc)
union
(select e.name,
        e.salary as valor
 from employee e
 where e.gender = 'F'
 order by e.salary desc)
order by valor desc
limit 50

----------------------------------------

-- FUNÇÕES DE STRINGS

select e.salary::varchar
from employee e;
select cast(e.salary as varchar)
from employee e;

select e.name, length(e.name), char_length(e.name), character_length(e.name)
from employee e;

select e.name, lower(e.name)
from employee e;
select e.name, upper(e.name)
from employee e;

-- No Postgres, o índice inicial é 1
select overlay('Txxxxas' placing 'hom' from 2 for 4)

select position('om' in 'Thomas');

select substring('Willon', 1, 3);
select substr('Willon', 1, 3);
select substring('Willon', from 1 for 3);
select substring('8888*0000' from '^[0-9]{4}');

select trim('    Willon    ');
select ltrim('    Willon    ');
select rtrim('    Willon    ');

select trim('    a     WillonAA', 'A');
select ltrim('    a     WillonAA', 'A');
select rtrim('    a     WillonAA', 'A');

select concat('Willon', ' Ferreira');
select concat('Willon' || ' Ferreira');

select concat_ws(' SEPARADOR ', 'Willon', ' Ferreira');

select format('Olá, %s!', 'Willon')

select initcap('willon');

select left('willon', 2);
select right('willon', 2);

select repeat('Will ', 4);
select replace('Willoon Ferreira', 'Willoon', 'Willon');
select reverse('nolliw');

select lpad('A', '4', '0');
select lpad('AA', '4', '0');
select rpad('A', '4', '0');
select rpad('AA', '4', '0');

select 'Brasil';
select quote_literal('Brasil');
select 'brasil ' || quote_nullable(null);

select e.name
from employee e
where starts_with(e.name, 'A')
limit 10;

select split_part('Willon$Ferreira$Da$Silva', '$', 1);
select split_part('Willon$Ferreira$Da$Silva', '$', 2);
select split_part('Willon$Ferreira$Da$Silva', '$', 3);
select split_part('Willon$Ferreira$Da$Silva', '$', 4);

----------------------------------------
select substring(foo.name_replace, 1, position(' ' in foo.name_replace))
from (
         select replace(replace(replace(replace(replace(e.name, 'Sr. ', ''), 'Dra. ', ''), 'Srta. ', ''), 'Dr. ', ''),
                        'Sra.', '') as name_replace
         from employee e
     ) as foo;


select case
           when string_to_array(e.name, ' ')[1] in ('Sr.', 'Sra.', 'Srta.', 'Dr.', 'Dra.') then
           else string_to_array(e.name, ' ')[2]
           end
from employee e;


select substring(foo.name_exp from 1 for position(' ' in foo.name_exp))
from (
         select regexp_replace(e.name, 'Sr. |Dr. |sra. | Srta. |Dra. ', '') as name_exp
         from employee e
     ) as foo;

----------------------------------------

select e.name,
       trim(reverse(substring(reverse(e.name) from 1 for position(' ' in reverse(e.name)))))
from employee e;
----------------------------------------
select e.name,
       initcap(replace(lower(e.name), 'silva', 'oliveira'))
from employee e
where e.name ilike '%silva%';
----------------------------------------
select concat('update employee set name = ', quote_literal(e.name || ' - ' || e.salary), ' where id = ', e.id, ';'),
       format('update employee set name = %s where id = %s;', quote_literal(e.name || ' - ' || e.salary), e.id)
from employee e;
----------------------------------------

-- FUNÇÕES DE AGREGAÇÃO
-- Principais: AVG, MIN, MAX, COUNT, SUM

select max(e.salary)
from employee e
where e.gender = 'F';

select max(e.salary)
from employee e
where e.gender = 'M';

select min(e.salary)
from employee e;

select avg(e.salary)
from employee e;

select sum(e.salary)
from employee e;

select count(e.id)
from employee e
where e.gender = 'F';

select count(e.id)
from employee e
where e.gender = 'M';

-- Às vezes precisamos informar quais campos desejamos agrupar. Usamos o GROUP BY

select e.gender,
       count(*)
from employee e
group by 1;
-- As funções de agrupamento possuem um tipo de "where": HAVING
SELECT e.gender,
       count(*),
       avg(e.salary)
from employee e
group by 1
having count(*) > 150


----------------------------------------

select count(e.id),
       ms.name
from employee e
         inner join marital_status ms on ms.id = e.id_marital_status
group by 2;


----------------------------------------

select sum(p.sale_price * si.quantity) as total_vendas,
       b.name
from sale_item si
         inner join sale s on si.id_sale = s.id
         inner join branch b on s.id_branch = b.id
         inner join product p on si.id_product = p.id
group by 2;
----------------------------------------


select case
           when e.gender = 'M' then 'Masculino'
           else 'Feminino'
           end              as sexo,
       round(avg(e.salary)) as avg_salary
from employee e
group by 1;


----------------------------------------
-- Obs.: campos com valor 'null' não são considerados nas funções de agrupamento
-- O 'coalesce' troca o valor null por outro escolhido
select d.name,
       avg(coalesce(e.salary, 0))
from employee e
         inner join department d on e.id_department = d.id
group by 1;

----------------------------------------
select extract('year' from s.date)     as ano,
       sum(si.quantity * p.sale_price) as subtotal
from sale s
         inner join sale_item si on s.id = si.id_sale
         inner join product p on p.id = si.id_product
group by 1
order by 1;
----------------------------------------
select date_part('year', age(e.birth_date)) as idade,
       sum(si.quantity * p.sale_price)      as subtotal
from sale s
         inner join sale_item si on s.id = si.id_sale
         inner join product p on p.id = si.id_product
         inner join employee e on e.id = s.id_employee
group by 1
order by 1;

----------------------------------------

select c.name,
       sum(si.quantity) as total
from sale s
         inner join branch b on b.id = s.id_branch
         inner join district d on d.id = b.id_district
         inner join city c on c.id = d.id_city
         inner join sale_item si on s.id = si.id_sale
group by 1;

----------------------------------------

select pg.name,
       round(sum((si.quantity * p.sale_price) / pg.gain_percentage), 2) as lucro
from sale_item si
         inner join product p on si.id_product = p.id
         inner join product_group pg on p.id_product_group = pg.id
group by 1
having round(sum((si.quantity * p.sale_price) / pg.gain_percentage), 2) > 200
order by 2 desc;
----------------------------------------
select pg.name,
       round(sum((si.quantity * p.sale_price) / pg.gain_percentage), 2) as lucro
from sale_item si
         inner join product p on si.id_product = p.id
         inner join product_group pg on p.id_product_group = pg.id
group by 1
having round(sum((si.quantity * p.sale_price) / pg.gain_percentage), 2) > 200
order by 2 desc;
----------------------------------------

select
       b.name,
    sum(p.sale_price * si.quantity)
from sale s
         inner join branch b on b.id = s.id_branch
inner join sale_item si on s.id = si.id_sale
inner join product p on si.id_product = p.id
group by 1;

----------------------------------------
select
       z.name,
    sum(p.sale_price * si.quantity)
from sale s
         inner join branch b on b.id = s.id_branch
inner join sale_item si on s.id = si.id_sale
inner join product p on si.id_product = p.id
inner join district d on b.id_district = d.id
inner join zone z on d.id_zone = z.id
group by 1;
----------------------------------------
select
       s2.name,
    sum(p.sale_price * si.quantity)
from sale s
         inner join branch b on b.id = s.id_branch
inner join sale_item si on s.id = si.id_sale
inner join product p on si.id_product = p.id
inner join district d on b.id_district = d.id
inner join city c on d.id_city = c.id
inner join state s2 on c.id_state = s2.id
group by 1;





