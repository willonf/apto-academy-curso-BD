select p.name,
       foo.m                                                                                            as mes,
       coalesce(sum((si.quantity * p.sale_price)) filter (where to_char(s.date, 'mm/yyyy') = foo.m), 0) as total
from sale s
         cross join(select format('%s/%s', lpad(mes::varchar, 2, '0'), 2020) as m from generate_series(1, 12) mes) foo
         left join sale_item si on s.id = si.id_sale
         left join product p on si.id_product = p.id
where date_part('year', s.date) = 2020
group by 1, 2
order by 1, 2;


-- Blocos anônimos
-- Muito utilizado para consertar erros em banco de dados sem alterá-lo "fisicamente"
do
$$
    declare
        consulta record;
    begin
        for consulta in select name from department
            loop
                raise notice 'nome: %', consulta.name;
            end loop;
    end;
$$

-- TRIGGERS

-- São ações executadas de acordo com um determinado evento (Insert, Update, Delete, Truncate) usando Before ou After
-- São executadas a partir de funções que retornam um tipo específico (trigger)
-- "new" = novo valor. Usado em Insert
-- "old" = valor anterior. Usado em Update
-- O ideal é utilizar em tarefas triviais

create table cliente
(
    id   serial       not null primary key,
    nome varchar(100) not null

);

create table historico
(
    notas text not null,
    data  date not null default current_date
);

create or replace function fn_salvar_historico() returns trigger as
$$
declare
begin
    insert into historico(notas) values (format('Cadastrando o cliente %s', new.nome));
    return new;
end;
$$
    language plpgsql;

create trigger tg_fn_salvar_historico
    before insert
    on cliente
    for each row
execute function fn_salvar_historico();

select *
from historico;
insert into cliente (nome)
values ('Willon');
select *
from historico;

-- Outros exemplos de Triggers
create trigger check_update
    before update of balance
    on accounts
    for each row
execute function check_account_update();

create trigger check_update
    before update
    on accounts
    for each row
    when (old.balance is distinct from new.balance)
execute function check_account_update();



-- Extensions
-- Funcionam como plugins que são adicionados ao database quando necessários

-- Extensão usada para retirar os acentos das palavras: unaccent
create extension if not exists unaccent;
select unaccent('Olá! Você está bem?');
select unaccent('áááééééôôÔããã');

-- Extensão usada para gerar UUID (Universally Unique Identifier): uuid-ossp
-- Uuid é um identificador único universal que não se repete.
create extension if not exists "uuid-ossp";
select uuid_generate_v1();
select uuid_generate_v4();

-- Extensão usada para Pivot Tables: tablefunc
-- 1º Parâmetro: busca
-- 2º parâmetro: colunas
-- Obs.: Primeiro tente executar a consulta, depois tente arranjar as linhas e colunas
create extension if not exists tablefunc;
select *
from crosstab(
             $$
        select d.name as departamento,
        ms.name as estado_civil,
        count(*) as total
        from employee e
        inner join department d on e.id_department = d.id
        inner join marital_status ms on ms.id = e.id_marital_status
        group by 1, 2
        $$,
             $$
             -- De forma manual:
             select unnest(array['Solteiro', 'Casado', 'Divorciado', 'Viúvo'])
             -- De forma dinâmica:
--         select ms.name from marital_status ms order by ms.id
        $$
         ) as (departamento varchar, solteiro integer, casado integer, divorciado integer, viuvo integer);


-- SEGMENTAÇÃO/PARTICIONAMENTO
-- Usado em tabelas com grande número de tuplas.

create table venda
(
    id         serial       not null,
    observacao varchar(256) not null,
    data       timestamp default now()
);



do
$$
    declare
        contador integer;
        ano      integer;
    begin
        for contador in 1..10000
            loop
                for ano in 1..10
                    loop
                        insert into venda (observacao, data)
                        values (format('Venda %s no ano %s', contador, ano), now() + interval '1 year' * ano);
                    end loop;
            end loop;
    end;
$$
language plpgsql;

select *
from venda
limit 50; -- Busca na tabela toda

explain (format json )
select *
from venda v
where v.data between '2021-01-01' and '2022-12-31'; -- Ainda busca na tabela toda

drop table venda;

-- Particionando:

create table venda
(
    id         serial       not null,
    observacao varchar(256) not null,
    data       timestamp default now()
) partition by range (data);

create table venda_2021 partition of venda for values from ('2021-01-01') to ('2021-12-31');
create table venda_2022 partition of venda for values from ('2022-01-01') to ('2022-12-31');
create table venda_2023 partition of venda for values from ('2023-01-01') to ('2023-12-31');
create table venda_2024 partition of venda for values from ('2024-01-01') to ('2024-12-31');
create table venda_2025 partition of venda for values from ('2025-01-01') to ('2025-12-31');
create table venda_2026 partition of venda for values from ('2026-01-01') to ('2026-12-31');
create table venda_2027 partition of venda for values from ('2027-01-01') to ('2027-12-31');
create table venda_2028 partition of venda for values from ('2028-01-01') to ('2028-12-31');
create table venda_2029 partition of venda for values from ('2029-01-01') to ('2029-12-31');
create table venda_2030 partition of venda for values from ('2030-01-01') to ('2030-12-31');
create table venda_2031 partition of venda for values from ('2031-01-01') to ('2031-12-31');


-- No Pgadmin é possível consultar o "explain" da query em um tabela particionada de forma gráfica.
-- Na documentação oficial é possível consultar outros tipos de particionamento

-- Ideal: criar uma tabela "espelho" da tabela a ser particionada. Ex.: sale e sale_read (particionada). A partir daí podemos
-- usar triggers para atualizar a tabela sale_read de acordo com a tabela read. Assim, podemos usar a tabela sale_read
-- apenas para leitura

create table public.sale_read
(
    id          integer                  not null,
    id_customer integer                 not null,
    id_branch   integer                 not null,
    id_employee  integer                 not null,
    date        timestamp(6)            not null,
    created_at  timestamp not null,
    modified_at timestamp not null,
    active      boolean   default true  not null
) partition by range (date);

select max(date)
from sale;
select min(date)
from sale;

do
$$
    declare
        ano     integer;
        comando varchar;
    begin
        for ano in 1970..2021
            loop
                comando :=
                        format('create table sale_read_%s partition of sale_read for values from (%s) to (%s);',
                               ano, quote_literal(concat(ano::varchar, '-01-01 00:00:00.000000')),
                               quote_literal(concat(ano::varchar, '-12-31 23:59:59.999999'))
                            );
                execute comando;
            end loop;
    end;
$$;


create or replace function fn_popular_sale_read() returns trigger as
$$
begin
    insert into sale_read (id, id_customer, id_branch, id_employee, date, created_at, modified_at, active)
    values (new.id, new.id_customer, new.id_branch, new.id_employee, new.date, new.created_at, new.modified_at, new.active);
    return new;
end;
$$
    language plpgsql;

drop trigger tg_popular_sale_read_update on sale;

create trigger tg_popular_sale_read_update
    after update
    on sale
    for each row
execute function fn_popular_sale_read();

do
$$
    declare
        consulta record;
    begin
        for consulta in select * from sale
            loop
            update sale set id_customer = id_customer where id = consulta.id;
            end loop;
    end;
$$;

