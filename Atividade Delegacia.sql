create schema delegacia;
create database delegacia;

create table pessoa(
	id serial not null,
	nome varchar(104) not null,
	endereco varchar(256) not null,
	telefone varchar(11) not null,
	cpf varchar(11) not null,
	data_nascimento date not null,
	ativo boolean not null default true,
	criado_em timestamp default now(),
	modificado_em timestamp default now(),
	constraint pk_pessoa primary key (id),
	constraint ak_pessoa_cpf unique (nome, cpf)
);

create table tipo_crime(
	id serial not null,
	nome varchar(104) not null,
	tempo_minimo_prisao smallint,
	tempo_maximo_prisao smallint,
	tempo_prescricao smallint,
	constraint pk_tipo_crime primary key (id),
	constraint ak_tipo_crime_nome unique (nome)
);


create table arma (
	id serial not null,
	numero_serie varchar(104),
	descricao varchar(256) not null,
	tipo varchar(1) not null,
	constraint pk_arma primary key (id)
);


create table crime(
	id serial not null,
	data timestamp not null,
	local varchar(256) not null,
	observacao text not null,
	constraint pk_crime primary key (id),
	constraint fk_tipo_crime foreign key 
);



insert into pessoa values (default, 'Will', 'Rua Itape', '9998887711', '12345678910', '1995-04-12', default, default, default)
select * from pessoa;