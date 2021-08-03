-- QUESTÃO 1: Transformar a tabela de vendas particionada por ano. Lembre-se de
-- verificar todos os anos possíveis para criar as partições de forma
-- correta;

create table sale_read
(
    id          integer              not null,
    id_customer integer              not null,
    id_branch   integer              not null,
    id_employee integer              not null,
    date        timestamp(6)         not null,
    created_at  timestamp            not null,
    modified_at timestamp            not null,
    active      boolean default true not null
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
    values (new.id, new.id_customer, new.id_branch, new.id_employee, new.date, new.created_at, new.modified_at,
            new.active);
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


-- QUESTÃO 3: Crie um PIVOT TABLE para saber o total de clientes por bairro e zona.

select *
from crosstab(
             $$
            select d.name as bairro,
            z.name as zona,
            count(*)
            from district d
            inner join zone z on d.id_zone = z.id
            right join customer c on d.id = c.id_district
            group by 1,2
            ORDER BY 1
        $$,
             $$
             select z.name from zone z order by z.id
        $$
         ) as (bairro varchar, norte integer, sul integer, leste integer, oeste integer);



-- QUESTÃO 4: Crie uma coluna para saber o preço unitário do item de venda, crie
-- um script para atualizar os dados já existentes e logo em seguida uma
-- trigger para preencher o campo;

alter table sale_item
    add column unit_price numeric default 0;
do
$$
    declare
        consulta record;
    begin
        for consulta in select p.id as id_product, p.cost_price from product p
            loop
                update sale_item
                set unit_price = consulta.cost_price
                where id_product = consulta.id_product;
            end loop;
    end;
$$;


create or replace function fn_popular_sale_item() returns trigger as
$$
declare
    product_unit_price numeric;
    consulta           record;
begin
    if new.id_product IN (select p.cost_price from product p) then
        product_unit_price := (select p.cost_price from product p where new.id_product = p.id);
    end if;
    insert into sale_item(id, id_sale, id_product, quantity, unit_price)
    values (new.id, new.id_sale, new.id_product, new.quantity, product_unit_price);
    return new;
end;
$$
    language plpgsql;


create trigger tg_fn_popular_sale_item
    before insert
    on sale_item
    for each row
execute function fn_popular_sale_item();

insert into sale_item (id, id_sale, id_product, quantity)
values (default, 1, 1, 1);



-- QUESTÃO 5: Crie um campo para saber o total da venda, crie um script para
-- atualizar os dados já existentes, em seguida uma trigger para
-- preencher o campo de forma automática;


alter table sale
    add column total_sale numeric(16, 3) default 0;

do
$$
    declare
        consulta record;
        total    numeric(16, 3);
        comando  varchar default '';
    begin
        for consulta in (select s.id, s.total_sale, si.quantity, p.sale_price
                         from sale s
                                  inner join sale_item si on s.id = si.id_sale
                                  inner join product p on si.id_product = p.id
        )
            loop
                total := consulta.quantity * consulta.sale_price;
                comando :=
                        format('update sale set total_sale = %s where id = %s;', total::varchar, consulta.id::varchar);
--                 raise notice 'COMANDO: %', comando;
                execute comando;
            end loop;
    end;
$$;


create or replace function fn_popular_sale() returns trigger as
$$
declare
    total    numeric(16, 3) default 0;
    consulta record;
begin
    total := (select (si.quantity * p.sale_price)
              from sale s
                       inner join sale_item si on s.id = si.id_sale
                       inner join product p on si.id_product = p.id
              where s.id = old.id);

    insert into sale (id, id_customer, id_branch, id_employee, date, created_at, modified_at, active, total_sale)
    values (old.id, old.id_customer, old.id_branch, old.id_employee, old.date, old.created_at, old.modified_at,
            old.active, total);
    return new;
end;
$$
    language plpgsql;


create trigger tg_popular_sale_update
    before update
    on sale
    for each row
execute function fn_popular_sale();



-- QUESTÃO 6:
-- Baseado no banco de dados de crime vamos fazer algumas questões.
-- • 1 - Criar o banco de dados;
-- • 2 - Criar o DDL para estrutura das tabelas;
-- • 3 - Criar um script para criar armas de forma automática, seguindo os
-- seguintes critérios: O número de série da arma deve ser gerado por o UUID,
-- os tipos de armas são, 0 - Arma de fogo, 1 - Arma branca, 2 - Outros.

create database delegacia;

create table pessoa
(
    id              serial                  not null,
    nome            varchar(104)            not null,
    cpf             varchar(11)             not null,
    telefone        varchar(11)             not null,
    data_nascimento date                    not null,
    endereco        varchar(256)            not null,
    ativo           boolean                 not null default true,
    criado_em       timestamp default now() not null,
    modificado_em   timestamp default now() not null,
    constraint pk_pessoa primary key (id),
    constraint ak_pessoa_cpf unique (nome, cpf)
);

create table tipo_crime
(
    id                  serial                  not null,
    nome                varchar(104)            not null,
    tempo_minimo_prisao smallint,
    tempo_maximo_prisao smallint,
    tempo_prescricao    smallint,
    ativo               boolean                 not null default true,
    criado_em           timestamp default now() not null,
    modificado_em       timestamp default now() not null,
    constraint pk_tipo_crime primary key (id),
    constraint ak_tipo_crime_nome unique (nome)
);


create table arma
(
    id            serial                  not null,
    numero_serie  varchar(104),
    descricao     varchar(256)            not null,
    tipo          varchar(1)              not null,
    ativo         boolean                 not null default true,
    criado_em     timestamp default now() not null,
    modificado_em timestamp default now() not null,
    constraint pk_arma primary key (id)
);


create table crime
(
    id            serial                  not null,
    id_tipo_crime integer                 not null,
    data          timestamp               not null,
    local         varchar(256)            not null,
    observacao    text                    not null,
    ativo         boolean                 not null default true,
    criado_em     timestamp default now() not null,
    modificado_em timestamp default now() not null,
    constraint pk_crime primary key (id),
    constraint fk_tipo_crime foreign key (id_tipo_crime) references tipo_crime (id)
);

create table crime_arma
(
    id            serial                  not null,
    id_arma       integer                 not null,
    id_crime      integer                 not null,
    ativo         boolean                 not null default true,
    criado_em     timestamp default now() not null,
    modificado_em timestamp default now() not null,
    constraint pk_crime_arma primary key (id),
    constraint fk_id_arma foreign key (id_arma) references arma (id),
    constraint fk_id_crime foreign key (id_crime) references crime (id)
);

create table crime_pessoa
(
    id            serial                  not null,
    id_pessoa     integer                 not null,
    id_crime      integer                 not null,
    tipo          varchar(1)              not null,
    ativo         boolean                 not null default true,
    criado_em     timestamp default now() not null,
    modificado_em timestamp default now() not null,
    constraint pk_crime_pessoa primary key (id),
    constraint fk_id_pessoa foreign key (id_pessoa) references pessoa (id),
    constraint fk_id_crime foreign key (id_crime) references crime (id)
);

create or replace function fn_popular_armas() returns void as
$$
declare
    comando       varchar default '';
    cont          integer;
    tipo          integer;
    tx_descricao  varchar default '';
    armas_fogo    varchar array default array ['Pistola', 'Metralhadora', 'Escopeta'];
    armas_brancas varchar array default array ['Faca', 'Facão', 'Estilete'];
    armas_outros  varchar array default array ['Corda', 'Garrafa'];
begin
    for cont in 1..50
        loop
            tipo := floor(random() * 3);
            case when tipo = 1 then
                tx_descricao := armas_fogo[0];
                when tipo = 2 then
                    tx_descricao := armas_fogo[1];
                when tipo = 3 then
                    tx_descricao := armas_fogo[2];
                else
                    tx_descricao := 'Desconhecido';
                end case;
            insert into arma (numero_serie, descricao, tipo) values (uuid_generate_v4(), tx_descricao, tipo::varchar);
        end loop;
end;
$$
    language plpgsql;

select fn_popular_armas();



--  QUESTÃO 7: Faça um script para migrar todos os clientes e funcionários da base de
-- vendas como pessoas na base de dados de crimes. Os campos que
-- por ventura não existirem, coloque-os como nulo ou gere de forma
-- aleatória.

create extension if not exists dblink;
with consulta as (select *
                  from dblink(
                               'dbname=sale port=5432 host=127.0.0.1 user=postgres password=postgres',
                               '(select e.id, e.name, e.birth_date from employee e) union (select c.id, c.name, null from customer c)'
                           ) as
                           (id integer, nome varchar, nascimento date)
)
insert
into pessoa (nome, cpf, telefone, data_nascimento, endereco)
values (consulta.nome, null, null, consulta.nascimento, concat('Rua', consulta.id));

do
$$
    declare
        comando    varchar default '';
        consulta   record;
        nascimento date;
    begin
        for consulta in select *
                        from dblink(
                                     'dbname=sale port=5432 host=127.0.0.1 user=postgres password=postgres',
                                     '(select e.id, e.name, e.birth_date from employee e) union (select c.id, c.name, null from customer c)'
                                 ) as
                                 (id integer, nome varchar, nascimento date)
            loop
                if (consulta.nascimento is null) then
                    nascimento = '2021-01-01';
                else
                    nascimento = consulta.nascimento;
                end if;
                comando := format(
                        'insert into pessoa (nome, cpf, telefone, data_nascimento, endereco) values (%s, %s, %s, %s, %s);',
                        quote_literal(consulta.nome),
                        quote_literal(concat('', consulta.id::varchar)),
                        quote_literal(concat('', repeat('0', 11))),
                        quote_literal(nascimento),
                        quote_literal(consulta.nome), quote_literal(nascimento),
                        quote_literal(concat('Rua ', consulta.id::varchar)));
--                 raise notice 'QUERY: %', comando;
                execute comando;
            end loop;
    end ;
$$;

insert into pessoa (nome, cpf, telefone, data_nascimento, endereco)
values ('Brenda Vieira', '000.000.000-00', '00000-0000', '2021-01-01', 'Rua 369');