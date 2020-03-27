*****************************************************************************************************
	--	POSTGRESQL - INFORMAÇÕES SOBRE O TAMANHO DE SCHEMAS E DATABASES
*****************************************************************************************************


-- BUSCAR TAMANHO DE TODAS TABELAS
SELECT esquema, tabela,
	   pg_size_pretty(pg_relation_size(esq_tab)) AS tamanho,
	   pg_size_pretty(pg_table_size(esq_tab)) AS tamanho_tabela, -- TABELA
	   pg_size_pretty(pg_indexes_size(esq_tab)) AS tamanho_indices, -- TABELA
       pg_size_pretty(pg_total_relation_size(esq_tab)) AS tamanho_tabela_e_indices -- TABELA + INDICES 
       -- pg_total_relation_size é a soma da pg_table_size e pg_indexes_size
  FROM (SELECT tablename AS tabela,
               schemaname AS esquema,
               schemaname||'.'||tablename AS esq_tab
          FROM pg_catalog.pg_tables
         WHERE schemaname NOT
            IN ('pg_catalog', 'information_schema', 'pg_toast') ) AS x
 ORDER BY pg_total_relation_size(esq_tab) DESC;
 
 
 -- BUSCAR TAMANHO DE UMA TABELA
 SELECT pg_size_pretty(pg_relation_size('schema.name_tabela')) AS tamanho,
       pg_size_pretty(pg_total_relation_size('schema.name_tabela')) AS tamanho_total;
	  	   
	   
-- LISTAR TODOS SCHEMAS
select schema_name from information_schema.schemata;


-- QUANTIDADE DE REGISTROS EM TODOS SCHEMAS
select  
  sum(reltuples)::bigint
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r' 
  AND nspname = 'imasm001'; 
  
  
-- QUANTIDADE DE REGISTROS EM UM SCHEMA 
select  
  sum(reltuples)::bigint
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
	nspname = 'name_schema'
  AND  relkind='r' ; 
  
  
-- BUSCAR TAMANHO DE TODOS SCHEMAS
SELECT schema_name, 
       pg_size_pretty(sum(table_size)::bigint),
       (sum(table_size) / pg_database_size(current_database())) * 100
FROM (
  SELECT pg_catalog.pg_namespace.nspname as schema_name,
         pg_relation_size(pg_catalog.pg_class.oid) as table_size
  FROM   pg_catalog.pg_class
     JOIN pg_catalog.pg_namespace ON relnamespace = pg_catalog.pg_namespace.oid
) t
GROUP BY schema_name
ORDER BY schema_name;


-- BUSCAR TAMANHO DE TODOS OS DATABASES
(SELECT
	datname                                   AS banco,
	pg_database_size(datname)                 AS tamanho,
	pg_size_pretty(pg_database_size(datname)) AS tamanho_pretty
FROM pg_database
WHERE datname NOT IN ('template0', 'template1', 'postgres')
ORDER BY tamanho DESC, banco ASC)

UNION ALL

(SELECT
	'TOTAL'                                        AS banco,
	sum(pg_database_size(datname))                 AS tamanho,
	pg_size_pretty(sum(pg_database_size(datname))) AS tamanho_pretty
FROM pg_database
WHERE datname NOT IN ('template0', 'template1', 'postgres'));