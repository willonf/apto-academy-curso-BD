-- DB Link é uma extensão do postgres que permite nos comunicar com outra base de dados (no mesmo ou em outro servidor)

create extension if not exists dblink;

select * from dblink(
    'dbname=delegacia port=5432 host=127.0.0.1 user=postgres password=postgres',
    'select id, numero_serie from arma' -- Query select realizado no database especificado acima
                  ) as
    (id integer, numero_serie varchar); -- Colunas que virão da base

-- Vacuum
-- A grosso modo, ele "limpa" a tabela, retirando os "rastros" das operações. Isso libera espaço em disco;
vacuum full freeze verbose analyze public.sale;

-- REINDEX
-- Reindexação dos índices
REINDEX;