-- UM POUCO DO HÍBRIDO

-- ARRAY
create table cliente
(
    id        serial       not null primary key,
    nome      varchar(100) not null,
    telefones varchar(10)[]
);

drop table cliente;
delete
from cliente
where id > 0;
create table cliente
(
    id        serial       not null primary key,
    nome      varchar(100) not null,
    telefones varchar[3]
);

insert into cliente (nome, telefones)
values ('Willon', array ['00000-0000', '11111-1111']);
insert into cliente (nome, telefones)
values ('Lily', '{22222-2222, 33333-3333}');

select c.nome, c.telefones
from cliente c;
select c.telefones[1]
from cliente c;

update cliente
set telefones = array_append(telefones, '33333-3333');
update cliente
set telefones = array_append(telefones, '44444-4444')
where id = 2;

select *
from cliente c
where c.telefones[1] ilike '%00000%';

select *
from cliente c
where '33333-3333' = any (telefones);

select array_append(array [1,2], 3);

select array_cat(array [1,2,3], array [4,5]);

select array_length(array [1,2,3], 1);

select array_position(array [1,2,3], 2);
select array_position(array [1,2,3], 4);

select array_positions(array ['A', 'B','A', 'B','A', 'B','C'], 'A');

select array_prepend(0, array [1,2,3]);

select array_remove(array [1,2,3,2,2], 2);

select array_replace(array [1,2,3,4], 5, 4);

select array_to_string(array [1,2,3, null,5], ',', '*');

select string_to_array('xx-yy-zz', '-');
select string_to_array('xx-yy-zz', '-', 'yy');

select unnest(array [1,2,3,4]);


-- JSON

drop table cliente;

select '{
  "key": "value"
}'::jsonb;

create table cliente
(
    id        serial       not null primary key,
    nome      varchar(100) not null,
    telefones varchar(10)[],
    infos     jsonb
);


insert into cliente
    (nome, telefones, infos)
values ('Will',
        array ['11111-1111', '22222-2222'],
        '{
          "idade": 26,
          "email": "willon@gmail.com"
        }');

select *
from cliente;

-- Obs.: "->>" retorna um texto. '->' retorna um "campo" do json
select nome,
       c.infos ->> 'idade'    as idade,
       c.infos ->> 'telefone' as tel,
       c.infos -> 'email'     as email
from cliente c;

select nome,
       jsonb_extract_path(c.infos, 'idade')          as idade,
       jsonb_extract_path(c.infos, 'telefone')       as fone,
       jsonb_extract_path(c.infos, 'email')::varchar as email
from cliente c;


update cliente
set infos = infos || '{"cpf":"000.000.000-00"}';

select nome,
       jsonb_extract_path(c.infos, 'cpf') as cpf,
       c.infos ->> 'cpf'                  as cpf,
       c.infos -> 'cpf'                   as cpf
from cliente c;

select nome,
       jsonb_extract_path_text(c.infos, 'cpf') as cpf
from cliente c;

select nome,
       c.infos ->> 'idade'    as idade,
       c.infos ->> 'telefone' as tel,
       c.infos ->> 'email'    as email,
       c.infos ->> 'cpf'      as cpf
from cliente c;

select *
from cliente c
where c.infos @@ '$.cpf == "000.000.000-00"';
select *
from cliente c
where c.infos ->> 'cpf' = '000.000.000-00';



select json_build_object('foo', 1, 2, row (3, 'bar'));

select json_object('{a,1, b, "def", c, 3.5}');

select *
from jsonb_each_text('{
  "a": "foo",
  "b": "bar"
}');

select *
from jsonb_object_keys(
        '{
          "f1": "abc",
          "f2": {
            "f3": "a",
            "f4": "b"
          }
        }'
    );

update cliente
set infos = infos || jsonb_build_object('telefones', cliente.telefones);

alter table cliente
    drop column telefones;

select *
from cliente;

select c.infos -> 'telefones'
from cliente c;

select jsonb_extract_path(infos, 'telefones') -> 0
from cliente;
select jsonb_extract_path(infos, 'telefones') ->> 0
from cliente;
select c.infos -> 'telefones' ->> 0
from cliente c;
select c.infos -> 'telefones' ->> 1
from cliente c;

-- TYPE

drop table cliente;

create type infos as
(
    email varchar(100),
    cpf   varchar(11)
);


create table cliente
(
    id    serial       not null,
    nome  varchar(100) not null,
    dados infos
);

insert into cliente (nome, dados)
values ('Willon', row('willon@gmail.com', '000000000'));

select nome, (dados).email, (dados).cpf from cliente c;

-- Dúvida: Como realizar a seguinte query? É possível?
-- select c.nome, c.(dados).email, c.(dados).cpf from cliente c;

update cliente set dados.email = 'willon@hotmail.com' where id = 1;

create type sexos as enum('M', 'F');
