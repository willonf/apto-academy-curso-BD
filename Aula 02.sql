-- Unique Index
select * from departamento;

create unique index ak_departamento_nome on departamento (nome);

insert into departamento (nome) values ('TI');

drop index ak_departamento_nome;

alter table departamento add constraint ak_departamento_nome unique (nome);

alter table departamento drop constraint ak_departamento_nome;


create unique index ak_departamento_nome on departamento (upper(nome));

insert into departamento (nome) values ('ti');


-- Index (de performance)
-- Tipos: B-Tree e Hash (coluna com sinal de igualdade)

create index idx_nome_funcionario on funcionario using btree (nome);
create index idx_sexo_funcionario on funcionario using hash (sexo);


-- ATIVIDADE:

-- Criando a chave composta:
-- alter table bairro add constraint pk_bairro primary key (nome, zona);

alter table bairro drop constraint pk_bairro;

drop sequence bairro_id_seq cascade;

alter table bairro add constraint pk_bairro primary key (id);

create unique index ak_nome_zona_bairro on bairro(nome, zona);

create index idx_zona on bairro using hash (zona);

create sequence bairro_id_seq start 3 increment 1;
alter table bairro alter column id set default nextval('bairro_id_seq');

-- DCL (DATA CONTROL LANGUAGE)
-- grant, revoke (permissões dos usuários)

create user will with encrypted password '123456';
select * from bairro;
create user teste superuser encrypted password '123456';


grant select on funcionario to will;
grant select on bairro to will;
grant insert on bairro to will;
grant update on bairro_id_seq to will;
grant all on bairro_id_seq to will;

revoke all on bairro_id_seq from will;

revoke select on bairro from will;

grant select (nome) on bairro to will;

revoke all on bairro from will;

grant select (nome, id), update(nome) on bairro to will;

-- Grupos de usuários

create role colaboradores;

alter group colaboradores add user will;

create user taty encrypted password '123456';

alter group colaboradores add user taty;

grant select on bairro to colaboradores;

-- ATIVIDADE:

select concat('Brasil', ' ', ' Penta Campeão');
select concat('Brasil' || ' ' || ' Penta Campeão');

select
	concat ('grant select on ', schemaname,'.', tablename, ' to will;')
from pg_tables
where schemaname in ('public', 'vendas');


-- BLOCO ANÔNIMO
do
$$
declare
-- Declaração de variáveis
begin
-- Corpo do bloco anônimo
	raise notice 'Hello';
	raise notice 'HI';
end;
$$

do
$$
declare
-- Declaração de variáveis
	consulta record; -- O tipo record armazena resultados de consultas
	comando varchar default '';
begin
-- Corpo do bloco anônimo
	for consulta in select * from pg_tables where schemaname in ('public', 'vendas') loop
		comando := concat ('grant select on ', consulta.schemaname,'.', consulta.tablename, ' to will;'); -- ':=' é um operador de atribuição
		execute comando; -- executa a string gerada
	end loop;
end;
$$

select * from vendas.fornecedor;

grant usage on schema vendas to will;


-- DML (DATA MANIPULATION LANGUAGE)
-- Linguagem de manipulação de dados
-- insert, update, delete

insert into departamento (nome) values ('RH');
insert into departamento values (default, 'Facilities');
insert into departamento values (default, 'Diretoria');
insert into departamento values (default, 'Diretoria 01');
insert into departamento values (default, 'Diretoria 02');
insert into departamento values (default, 'Diretoria 03');
insert into departamento values (default, 'Diretoria 04');
insert into departamento values (default, 'Diretoria 05');
	

select * from departamento;

update departamento set nome = 'Direção' where id = 6;
update produto set nome = id::varchar || '-' || nome; -- Recebe o id do respectivo dado. "::" é um operador de cast


delete from departamento where id = 6;
delete from funcionario where id in (1,2);
delete from departamento;

-- autocommit = true por padrão no PostgreSQL. Ou seja, as ações de DML (somente DML) não podem ser desfeitas
-- 

begin;
	insert into departamento values (default, 'Diretoria 06');

commit; -- Encerra a execução temporária do código acima (Linha 151 e 152) completando a transaction
rollback; -- Encerra a execução temporária do código acima (Linha 151 e 152) sem completar a transaction


select * from departamento;

do
$$
declare
	idade integer default 10;
begin
	if idade >= 18 then
		raise notice 'Maior de idade';
	else
		raise notice 'Menor de idade';
	end if;
end;
$$

select mod(10, 2)
select * from funcionario;
-- ATIVIDADE
alter table funcionario add column salario numeric default 0.0 not null;
alter table funcionario alter column salario numeric (10,2);

insert into funcionario values(default, 'Lily', 1, 'M', default);

update funcionario set salario = id*1000;

insert into funcionario values(default, 'Marshall', 1, 'M', default);

do
$$
declare
	contador integer default 1;
begin
	while contador <= 1000 loop
		raise notice 'contador: %', contador;
		contador := contador + 1;
	end loop;
end;
$$

select round(cast(random() * 1000 as numeric), 2);

do
$$
declare
	contador integer;
	sexo varchar(1);
begin
	for contador in 1..1000 loop
		--raise notice 'contador: %', contador;
		
		if mod(contador, 2) = 1 then
			sexo := 'M';
		else
			sexo := 'F';
		end if;
		
		insert into funcionario (nome, salario, sexo, id_departamento)
		values (
			'FUNCIONÁRIO_' || contador::varchar,
			round(cast(random() * 1000 as numeric), 2),
			sexo,
			1
		);
	end loop;
end;
$$


select * from funcionario;








