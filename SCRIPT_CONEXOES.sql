*****************************************************************************************************
	-- POSTGRESQL -- CONEXÕES E TRANSAÇÕES
*****************************************************************************************************


-- LISTAR CONEXÕES ATIVAS ORDENADOS POR QUERY
SELECT * FROM PG_STAT_ACTIVITY ORDER BY QUERY;


-- CONTAR CONEXÕES
SELECT COUNT(*) FROM PG_STAT_ACTIVITY;


-- CONTAR CONEXÕES DE UM DATABASE ESPECIFICO
SELECT * FROM PG_STAT_ACTIVITY WHERE DATNAME = ‘NOME_DO_BANCO’;


-- FINALIZAR CONEXÕES
	-- O PID É OBTIDO ATRAVÉS DO SELECT NA TABELA PG_STAT_ACTIVITY.
	SELECT PG_TERMINATE_BACKEND(PID);


-- FINALIZAR TODAS AS CONEXÕES MENOS A SUA(CONECTADA)
SELECT PG_TERMINATE_BACKEND(PID) FROM PG_STAT_ACTIVITY WHERE PID <> PG_BACKEND_PID();


-- FINALIZAR TODAS AS CONEXÕES COM STATE IDLE E QUERY SHOW TRANSACTION ISOLATION LEVEL
SELECT PG_TERMINATE_BACKEND(PID) FROM PG_STAT_ACTIVITY  WHERE state = 'idle' AND query = 'SHOW TRANSACTION ISOLATION LEVEL';


-- LISTAR CONEXÕES INATIVAS AGRUPADAS
SELECT
	client_addr
	, usename
	, datname
	, state
	, count(*)
FROM pg_stat_activity
GROUP BY client_addr, usename, datname, state ORDER BY count(*) DESC;


-- VERIFICAR DURAÇÃO DAS TRANSAÇÕES SENDO EXECUTADAS OU IDLE(INATIVAS)
SELECT
	client_addr
	, usename
	, datname
	, clock_timestamp() - xact_start AS xact_age
	, clock_timestamp() - query_start AS query_age
	, state
	, query
FROM pg_stat_activity
ORDER BY coalesce(xact_start, query_start);


-- TRANSAÇÕES INATIVAS COM DURAÇÃO DE MAIOR DO QUE 10 SEGUNDOS
SELECT
client_addr, usename, datname,
now() - xact_start AS xact_age,
now() - query_start AS query_age,
state, query
FROM pg_stat_activity
WHERE xact_start IS NULL AND (
(now() - xact_start) > '00:00:10'::interval OR
(now() - query_start) > '00:00:10'::interval AND
 state = 'idle'
 )
ORDER BY coalesce(xact_start, query_start);


-- TRANSAÇÕES AGUARANDO OUTRA TRANSAÇÕES, TALVEZ SEJA UM DEAD LOCK
SELECT
	client_addr
	, usename
	, datname
	, now() - xact_start AS xact_age
	, now() - query_start AS query_age
	, state
	, waiting
	, query
FROM pg_stat_activity
WHERE waiting
ORDER BY coalesce(xact_start, query_start);