Memória Cache e Index o que tem haver?

•	O que é memória cache?
O princípio básico das memória cache é o de manter uma cópia dos dados e instruções mais utilizados recentemente (Princípio da Localidade) para que os mesmos não precisem ser buscados na memória principal

•	Como funciona? 
Para cada dado a ser acessado há uma probabilidade dele estar na memória Cache. 
Se isso ocorrer dizemos que houve um Cache Hit e o sistema ganha muito tempo com isso. 
Caso contrário, ocorre uma Cache Miss e o desempenho é bastante prejudicado. 

A grande questão é, como fazemos para aumentar a probabilidade de um determinado dado estar na memória Cache ao invés da memória Principal? 

Abaixo alguns scripts para que você entenda o que está ocorrendo com seu banco de dados!

•	CONSULTAR A TAXA DE ACERTO DO CACHE 
SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio -- taxa de acerto quanto mais perto de 99 melhor 
FROM 
  pg_statio_user_tables;

SELECT 
  sum(idx_blks_read) as idx_read,
  sum(idx_blks_hit)  as idx_hit,
  (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) as ratio -- taxa de acerto quanto mais perto de 99 melhor
FROM 
  pg_statio_user_indexes;


•	COMO SABER SE DEVO CRIAR INDICE PARA AS TABELAS? 
Obs: SE NÃO ESTIVER EM TORNO DE 99% EM QUALQUER TABELA COM MAIS DE 10.000 LINHAS CONSIDERE CRIAR UM INDICE (FAÇA TESTES)
SELECT 
  schemaname,
  relname, 
  100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, 
  n_live_tup rows_in_table
FROM 
  pg_stat_user_tables
WHERE 
    seq_scan + idx_scan > 0 
ORDER BY 
  n_live_tup DESC;

•	VERIFICAR INDICES QUE NÃO ESTÃO SENDO UTILIZADOS
Índices precisam ser sempre revisados, em muitos casos encontramos índices que são adicionados anos atrás ou até mesmo sem real necessidade. O índice que não ajuda atrapalha! Cada índice que o sistema precisa manter diminuirá a taxa de transferência de gravação no banco de dados.  
O PostgreSQL simplifica a consulta de índices não utilizados, para que você possa recuperar um desempenho facilmente removendo-os.

SELECT
  schemaname || '.' || relname AS table,
  indexrelname AS index,
  pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
  idx_scan as index_scans
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
ORDER BY pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
pg_relation_size(i.indexrelid) DESC;


•	TEMPO TOTAL DE QUERYS EXECUTADAS NO BANCO DE DADOS
SELECT 
  (total_time / 1000 / 60) as total,  -- total em minutos
  (total_time/calls) as avg, -- tempo médio em milisegundos
  query 
FROM pg_stat_statements 
ORDER BY 1 DESC 
LIMIT 100;
