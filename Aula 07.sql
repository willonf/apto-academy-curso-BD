-- PROCEDURES

create
    or replace procedure inserir_dados(nome varchar[])
    language sql as
$$
insert into cliente(nome)
values (nome[1]);
insert into cliente(nome)
values (nome[2]);
$$;

call inserir_dados(array ['Willon', 'Naty']);


-- FUNÇÕES
-- Estrutura de uma função
-- create or replace function nome_funcao(parametro_a integer) returns varchar as
-- $$
-- declare
-- Variáveis
-- begin
-- Corpo da função
-- end
-- $$
-- language plpgsql;

-- Chamada da função:
-- select nome_funcao(parametro);


create
    or replace function hello_world() returns varchar as
$$
declare
begin
    return 'Hello, World!';
end
$$
    language plpgsql;

select hello_world();



create
    or replace function soma(number1 integer, number2 integer) returns integer as
$$
declare
    sum integer;
begin
    sum = number1 + number2;
    return sum;
end
$$
    language plpgsql;

select soma(1, 2);


create
    or replace function fn_decisao(valor integer) returns boolean as
$$
declare
begin
    if
        valor > 10 then
        return true;
    else
        return false;
    end if;
end;
$$
    language plpgsql;

select fn_decisao(9);
select fn_decisao(11);


create
    or replace function fn_maior_idade(valor integer) returns varchar as
$$
declare
begin
    raise
        notice 'valor: %', valor;
    if
        valor between 1 and 10 then
        return 'criança';
    elseif
        valor between 11 and 17 then
        return 'adolescete';
    else
        return 'adulto';
    end if;
end;
$$
    language plpgsql;

select fn_maior_idade(5);
select fn_maior_idade(15);
select fn_maior_idade(18);


create
    or replace function fn_maior_idade2(valor integer) returns varchar as
$$
declare
    msg varchar default '';
begin
    raise
        notice 'valor: %', valor;
    case
        when valor between 1 and 10 then
            msg := 'criança';
        when valor between 11 and 17 then
            msg := 'adolescete';
        else
            msg := 'adulto';
        end case;
    return msg;
end;
$$
    language plpgsql;

select fn_maior_idade(5);
select fn_maior_idade(15);
select fn_maior_idade(18);



create
    or replace function fn_par_ou_impar(num integer) returns varchar as
$$
declare
    msg varchar default '';
begin
    raise
        notice 'Number: %', num;
    if
        num % 2 = 0 then
        msg := 'Par';
    else
        msg := 'Impar';
    end if;
    return msg;
end;
$$
    language plpgsql;

select fn_par_ou_impar(2);
select fn_par_ou_impar(3);


create
    or replace function fn_perfil_salario(salario numeric) returns varchar as
$$
declare
    msg varchar default '';
begin
    case
        when salario between 1 and 2000 then
            msg := 'Jr.';
        when salario between 2001 and 5000 then
            msg := 'Pl.';
        when salario > 5000 then
            msg := 'Sr.';
        else
            msg := 'Unknown';
        end case;
    return msg;
end;
$$
    language plpgsql;

select fn_perfil_salario(1500);
select fn_perfil_salario(2500);
select fn_perfil_salario(5001);

select e.name,
       e.salary,
       (select fn_perfil_salario(e.salary)) as "perfil"
from employee e
order by 2;


create
    or replace function fn_repeticao1() returns void as
$$
declare
    counter integer default 1;
begin
    loop
        if counter > 100 then
            exit;
        end if;
        counter
            := counter + 1;
        raise
            notice 'Counter: %', counter;
    end loop;
end;
$$
    language plpgsql;

select fn_repeticao1();

create
    or replace function fn_repeticao2() returns void as
$$
declare
    counter integer default 1;
begin
    loop
        exit when counter > 100;
        raise
            notice 'counter: %', counter;
        counter
            := counter + 1;
    end loop;
end;
$$
    language plpgsql;

create
    or replace function fn_repeticao3() returns void as
$$
declare
    counter integer default 1;
begin
    while
        true
        loop
            exit when counter > 100;
            raise
                notice 'counter: %', counter;
            counter
                := counter + 1;
        end loop;
end;
$$
    language plpgsql;

create
    or replace function fn_repeticao4() returns void as
$$
declare
    i integer;
begin
    for i in 1..10
        loop
            raise notice 'i: %', i;
        end loop;
end;
$$
    language plpgsql;

create
    or replace function fn_repeticao5() returns void as
$$
declare
    i integer;
begin
    for i in 1..10 by 2
        loop
            raise notice 'i: %', i;
        end loop;
end;
$$
    language plpgsql;

create
    or replace function fn_repeticao6() returns void as
$$
declare
    i integer;
begin
    for i in reverse 10..1 by 2
        loop
            raise notice 'i: %', i;
        end loop;
end;
$$
    language plpgsql;

create
    or replace function fn_repeticao7(numeros int[]) returns void as
$$
declare
    indice integer;
begin
    foreach indice in array numeros
        loop
            raise notice 'Índice: %', indice;
        end loop;
end;
$$
    language plpgsql;

--- ATIVIDADES


select string_to_array('palavra', '');


create
    or replace function fn_qtde_vogais_consoantes(palavra varchar) returns jsonb as
$$
declare
    qtde_vogais integer default 0;
    qtde_consoantes
                integer default 0;
    tamanho
                integer;
    index
                integer;
begin
    tamanho
        := length(palavra);
    for index in 1..tamanho
        loop
            if unaccent(lower(substring(palavra, index, 1))) in ('a', 'e', 'i', 'o', 'u') then
                qtde_vogais := qtde_vogais + 1;
            else
                qtde_consoantes := qtde_consoantes + 1;
            end if;
        end loop;
    return jsonb_build_object('vogais', qtde_vogais, 'consoantes', qtde_consoantes);
end;
$$
    language plpgsql;


select fn_qtde_vogais_consoantes('willon');
select fn_qtde_vogais_consoantes('aeIouB');
select fn_qtde_vogais_consoantes('ÁeIouB');


create
    or replace function fn_reverter_palavra(palavra varchar) returns varchar as
$$
declare
    index integer;
    tamanho
          integer default length(palavra);
    palavra_invertida
          varchar default '';
begin
    for index in reverse tamanho..1
        loop
            palavra_invertida := concat(palavra_invertida, substring(palavra, index, 1));
        end loop;
    return palavra_invertida;
end;
$$
    language plpgsql;

select fn_reverter_palavra('willon');


create
    or replace function fn_soma_pares_impares(numeros integer[]) returns jsonb as
$$
declare
    soma_posicoes_pares integer default 0;
    soma_posicoes_impares
                        integer default 0;
    posicao
                        integer;
begin
    for posicao in 1..array_length(numeros, 1)
        loop
            if mod(posicao, 2) = 0 then
                soma_posicoes_pares := soma_posicoes_pares + numeros[posicao];
            else
                soma_posicoes_impares := soma_posicoes_impares + numeros[posicao];
            end if;
        end loop;
    return jsonb_build_object('pares', soma_posicoes_pares, 'impares', soma_posicoes_impares);
end;
$$
    language plpgsql;

select fn_soma_pares_impares(array [1, 2, 3, 4, 5]);


select generate_series(20, 30);

create
    or replace function fn_questao4(inicial integer, final integer) returns setof integer as
$$
declare
    numero integer;
begin
    for numero in inicial..final
        loop
            return next numero;
        end loop;

    return;
end;
$$
    language plpgsql;

select fn_questao4(10, 20);

drop function fn_queryset();


create
    or replace function fn_queryset(consulta varchar, filtros jsonb) returns varchar as
$$
declare
    filtros_montados varchar default '';
    keys
                     varchar[];
    key              varchar;
begin
    select array_agg(k)
    from jsonb_object_keys(filtros) as k
    into keys;
    foreach key in array keys
        loop
            filtros_montados := concat(filtros_montados, format('%s = %s AND ', key,
                                                                quote_literal(jsonb_extract_path_text(filtros, key))));
        end loop;
    return rtrim(concat(consulta, ' WHERE ', filtros_montados), 'AND ');
end;
$$
    language plpgsql;

select *
from fn_queryset('select * from employee', '{
  "salary": "2097.00",
  "gender": "F"
}'::jsonb);

select *
from employee
WHERE gender = 'F'
  AND salary = '2097.00';

-- AULA 08

create
    or replace function usando_record() returns void as
$$
declare
    consulta record;
begin
    for consulta in
        select name
        from employee
        loop
            raise notice 'Nome: %', consulta.name;
        end loop;
end;
$$
    language plpgsql;

select usando_record();


create type exemplo as
(
    data   date,
    numero integer
);

create
    or replace function usando_tipos() returns setof exemplo as
$$
declare
    linha exemplo%rowtype;
    contador
          integer;
begin
    for contador in 1..100
        loop
            linha.data := current_date + interval '1 day' * contador;
            linha.numero
                := contador;
            return
                next linha;
        end loop;
end;
$$
    language plpgsql;

select *
from usando_tipos();


create
    or replace function fn_table()
    returns table
            (
                id_customer   integer,
                customer_name varchar
            )
as
$$
declare
    consulta record;
begin
    for consulta in
        select id, name
        from customer
        loop
            id_customer := consulta.id;
            customer_name
                := consulta.name;
            return
                next;
        end loop;
end;
$$
    language plpgsql;

create
    or replace function fn_table2()
    returns table
            (
                id_customer   integer,
                customer_name varchar
            )
as
$$
declare
begin
    return query select id, name from customer;
end;
$$
    language plpgsql;

select fn_table();
select fn_table2();


create type vendas_por_estado_civil as
(
    produto    varchar,
    solteiro   numeric,
    casado     numeric,
    divorciado numeric
);

create
    or replace function fn_vendas_por_estado_civil() returns setof vendas_por_estado_civil as
$$
declare
    consulta record;
    linha
             vendas_por_estado_civil%rowtype;
begin
    for consulta in (
        select p.name, c.id_marital_status, p.sale_price, si.quantity
        from product p
                 inner join sale_item si on p.id = si.id_product
                 inner join sale s on si.id_sale = s.id
                 inner join customer c on s.id_customer = c.id
                 inner join marital_status ms on c.id_marital_status = ms.id
    )
        loop
            linha.produto := consulta.name;
            linha.solteiro
                := sum(consulta.quantity * consulta.sale_price) where consulta.id_marital_status = 1;
            linha.casado
                := sum(consulta.quantity * consulta.sale_price) where consulta.id_marital_status = 2;
--             linha.divorciado := sum(consulta.quantity * consulta.sale_price) where consulta.id_marital_status = 3;
            return
                next linha;
        end loop;
end;
$$
    language plpgsql;

select *
from fn_vendas_por_estado_civil();


-- EXCEÇÕES

create
    or replace function fn_divisao(num1 numeric, num2 numeric) returns numeric as
$$
declare
begin
    begin
        return num1 / num2;
    exception
        when division_by_zero then
            raise exception 'Error division by zero! Try again :(';
    end;
end;
$$
    language plpgsql;


select fn_divisao(1, 2);
select fn_divisao(1, 0);

drop function fn_projecao(ano integer);


create type projecao_mensal as
(
    produto   varchar,
    janeiro   numeric,
    fevereiro numeric,
    marco     numeric,
    abril     numeric,
    maio      numeric,
    junho     numeric,
    julho     numeric,
    agosto    numeric,
    setembro  numeric,
    outubro   numeric,
    novembro  numeric,
    dezembro  numeric
);

select p.name,
       foo.mes,
       coalesce(
                       sum(coalesce(si.quantity, 0) * p.sale_price)
                       filter (where to_char(s.date, 'mm/yyyy') = foo.mes), 0) as total
from sale s
         cross join (select format('%s/%s', lpad(generate_series(1, 12)::varchar, 2, '0'), 2020) as mes) as foo
         left join sale_item si on s.id = si.id_sale
         left join product p on si.id_product = p.id
where date_part('year', s.date) = 2020
group by 1, 2;
