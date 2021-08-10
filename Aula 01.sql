-- ACESSANDO O TERMINAL DO POSTGRESQL: psql -d <database> -U <user>


--LINGUAGEM DDL

create database curso;

create table cliente (
id integer not null,
	nome varchar(100) not null
);


-- Alguns tipos de dados
/* 
	integer
	varchar
	boolean
	bigint
	smallint
	text
	numeric(10,2)
	date
	timestamp
*/


-- Sequences 
create sequence incrementador start 1 increment 1;


-- Schemas
create schema cadastros;

create table cadastros.zona (
	id smallint not null,
	nome varchar(20) not null
);


-- Users
create user will with encrypted password '123456';


alter table cliente add column salario numeric(10,2) not null;

select nextval ('incrementador');
alter sequence incrementador restart 1;

alter user will superuser;

alter table cliente
add column data_aniversario date not null;

drop table cadastros.zona;
drop schema cadastros;

-- Obs: O tipo serial cria uma sequence e um tipo inteiro
create table funcionario (
	id serial not null primary key,
	nome varchar(104) not null
);

drop table funcionario;

create table funcionario (
	id serial not null,
	nome varchar(104) not null,
	constraint pk_funcionario_nome_customizado primary KEY (id)
);

alter table cliente
add constraint pk_cliente primary key(id);

-- Chave primário composta
create table bairro (
	nome varchar(40),
	zona varchar(20) not null,
	constraint pk_bairro primary key (nome, zona)
);

insert into bairro (nome, zona) values ('São José', 'Leste');


alter table bairro
drop constraint pk_bairro;

alter table bairro add column id serial not null,
add constraint pk_bairro PRIMARY key (id);


drop table funcionario;


-- Adicionando uma primary key
create table departamento(
	id serial not null,
	nome varchar(104) not null,
	constraint pk_departamento primary key (id)
);

-- Adicionando uma foreign key
create table funcionario(
	id serial not null,
	nome varchar(104) not null,
	id_departamento integer not null,
	constraint pk_funcionario primary key (id),
	constraint fk_funcionario_departamento foreign key(id_departamento) references departamento (id)
);


insert into departamento (nome) values ('TI');
insert into departamento (nome) values ('Financeiro');


insert into funcionario (nome, id_departamento) values ('Osenias', 1);
insert into funcionario (nome, id_departamento) values ('Izzie', 1);
insert into funcionario (nome, id_departamento) values ('Taty', 2);
select * from funcionario;
-- Bancos relacionais, de forma automática, faz a verificação de integridade referencial
-- No exemplo abaixo, não será possível realizar a query, pois irão vioalr a integridade do banco
insert into funcionario (nome, id_departamento) values ('Eloah', 4);


create table produto (
	id integer not null,
	nome varchar(104) not null,
	preco_venda numeric(10,2) DEFAULT 10.00,
	ativo boolean not null default true,
	constraint pk_produto primary key (id)
);


insert into produto (id, nome) values (1, 'Coca-Cola');
insert into produto (id, nome) values (2, 'Pepsi');
insert into produto (id, nome) values (3, 'Fanta Laranja');


-- ATIVIDADE:
-- 1 Criar um sequence
create sequence produto_id_seq start 1 increment 1;
-- ou: create sequence produto_id_seq start 1 increment 1 owned by produto.id;

-- 2 Restartar o sequence para 4
alter sequence produto_id_seq restart 4;
-- 3 Associar o valor do sequence ao id da tabela produto
alter table produto alter column id set default nextval('produto_id_seq');

insert into produto (nome) values ('Fanta Uva');
insert into produto (nome) values ('Coca-Cola Café');
select * from produto;

-- ATIVIDADE:
-- Q1
create schema vendas;
-- Q2
create table vendas.fornecedor (
	nome varchar(104) not null,
	cnpj varchar(14)
);
--Q3
alter table vendas.fornecedor add column ativo boolean default true;
--Q4
alter table vendas.fornecedor add column data_cadastro timestamp default now();
--Q5
create sequence vendas.fornecedor_id_seq start 1 increment 1;
--Q6
alter table vendas.fornecedor
add column id integer not null,
add constraint pk_fornecedor primary key (id),
alter column id set default nextval('fornecedor_id_seq');

alter table vendas.fornecedor alter column id set default nextval('vendas.fornecedor_id_seq');

insert into vendas.fornecedor (nome, cnpj) values ('FPF Tech', '00000000000000');
insert into vendas.fornecedor (nome, cnpj) values ('Google Inc.', '11111111111111');
insert into vendas.fornecedor (nome, cnpj) values ('Microsoft Inc..', '22222222222222');
select * from vendas.fornecedor;
-- Alterando o schema padrão das queries
set search_path to vendas;


-- Checks

alter table funcionario
add column sexo varchar(1);

alter table funcionario
add constraint check_funcionario_sexo check (sexo in ('M', 'F'));

insert into funcionario(nome, id_departamento, sexo) values ('Azzy', 2, 'A');
insert into funcionario(nome, id_departamento, sexo) values ('Azzy', 2, 'F');

select * from funcionario;


-- ATIVIDADE:
ALTER TABLE produto ADD column preco_custo numeric(10,2);

alter table produto
add constraint check_produto_preco_custo check (preco_custo > 0);

alter table produto
add constraint check_produto_preco_venda check (preco_venda > 0);

alter table produto
add constraint check_produto_preco_venda_maior_custo check (preco_venda > preco_custo);

insert into produto (nome, preco_custo, preco_venda) values ('Real Comum', 10, 20);
insert into produto (nome, preco_custo, preco_venda) values ('Real Gold', 10, 25);
insert into produto (nome, preco_custo, preco_venda) values ('Coca Cola', 0, 25);
insert into produto (nome, preco_custo, preco_venda) values ('Coca Cola', 10, 0);
insert into produto (nome, preco_custo, preco_venda) values ('Coca Cola', -3, -2);
insert into produto (nome, preco_custo, preco_venda) values ('Coca Cola', 10, 5);




