*****************************************************************************************************
	-- SCRIPT PARA CRIAR AUDITORIA DE COMANDOS DDL                                                	        
*****************************************************************************************************
-- ESTE SCRIPT TEM O OBJETIVO DE PRESERVAR O ESTADO DO BANCO DE DADOS ARMAZENANDO INFORMAÇOES DE TODA ALTERAÇÃO ESTRUTURAL EM CADA OBJETO

-- CRIAR DATABASE AUDITORIA
	CREATE DATABASE "ADTDB001"
	WITH OWNER = admin
		ENCODING = 'UTF8'
		TABLESPACE = pg_default
		LC_COLLATE = 'pt_BR.UTF-8'
		LC_CTYPE = 'pt_BR.UTF-8'
		CONNECTION LIMIT = -1;
		
-- CRIAR SCHEMA AUDITORIA NO DATABASE ADTDB001(AUDITORIA)
	create schema auditoria authorization postgres;

-- CRIAR TABELA PARA ARMAZENAR OS DADOS DOS USUÁRIOS E INSTRUÇÕES
	create table auditoria.auditoria_ddl
	(
		database_connected	varchar(50)
		, schema_connected 	varchar(50)
		, user_db_connected varchar(50)
		, application_name  varchar(100)
		, ip 				varchar(30)
		, hint_host_name    varchar(100)
		, pid				varchar(10)
		, port 				varchar(10)	
		, query 			text
		, try_drop_auditoria boolean default false
		, date_execution timestamp without time zone NOT NULL DEFAULT now()
	);
	
	comment on table auditoria.auditoria_ddl is 'Tabela para armazenar os registros de auditoria de todas as transações DDL';
	comment on column auditoria.auditoria_ddl."database_connected" is 'Database em que o Usuário está conectado';
	comment on column auditoria.auditoria_ddl."schema_connected" is 'Schema em que o Usuário está conectado no momento da execução, não necessariamente é o schema em que o script foi executado';
	comment on column auditoria.auditoria_ddl."user_db_connected" is 'User do banco de dados que o usuário(desenvolvedor,tester,dba,etc) está conectado';
	comment on column auditoria.auditoria_ddl."application_name" is 'Local de onde foi executado a query, PgAdmin, DBeaver, etc';
	comment on column auditoria.auditoria_ddl."ip" is 'IP da máquina do usuário que executou o comando';
	comment on column auditoria.auditoria_ddl."hint_host_name" is 'Dica do nome do Colaborador que executou a instrução';
	comment on column auditoria.auditoria_ddl."pid" is 'PID da conexão que executou o comando';
	comment on column auditoria.auditoria_ddl."port" is 'Porta de onde foi executado o comando';
	comment on column auditoria.auditoria_ddl."query" is 'Query que foi executada';
	comment on column auditoria.auditoria_ddl."try_drop_auditoria" is 'Flag para tentativa de dropar a tabela auditoria_ddl';
	comment on column auditoria.auditoria_ddl."date_execution" is 'Data e Hora que foi executado o comando';

-- GRANT PARA OS USUARIOS QUE IRÃO INSERIR REGISTROS, TODOS OS QUE UTILIZAM O BANCO, ex: DESENVOLVEDORES, TESTERS ETC.
	grant insert on table auditoria_ddl to user name_user;
		
		
/* A FUNCTION E TRIGGER ABAIXO DEVE SER CRIADA EM CADA DATABASE QUE VOCÊ DESEJAR AUDITAR */


-- CREATE FUNCTION auditoria_ddl PARA INSERIR OS DADOS NA TABELA AUDITORIA NO DATABASE AUDITORIA
drop EVENT trigger if exists auditoria_ddl;
drop function if exists public.auditoria_ddl();
 
	CREATE OR REPLACE FUNCTION public.auditoria_ddl()
	RETURNS event_trigger
	LANGUAGE 'plpgsql' SECURITY DEFINER 
	AS $$
	
	declare
		v_datname varchar(100);
		v_application_name varchar(100);
		v_ip varchar(30);
		v_hint_host_name varchar(100);
		v_pid varchar(10);
		v_query text;
		v_try_drop_auditoria boolean;
		v_pos_inicial integer;
		v_pos_final integer;
		v_tam_string integer;
		v_schema text;
	
	begin
		
		-- CARREGAR INFORMAÇÕES DA INSTRUÇÃO
		select datname, application_name, pid, query into v_datname, v_application_name, v_pid, v_query 
		from PG_STAT_ACTIVITY where client_port = inet_client_port();
		
		-- BUSCAR SCHEMA EM QUE ESTÁ SENDO EXECUTADO A INSTRUÇÃO
		v_schema := v_query;		
		v_pos_inicial:= position('TABLE' in upper(v_query)) + 5;
		v_pos_final := position('.' in v_query);
		v_tam_string :=  case when(v_pos_final - v_pos_inicial) < 0 then 0 else (v_pos_final - v_pos_inicial) end as v_qtd;	
		v_schema := SUBSTRING(v_query, v_pos_inicial, v_tam_string); 
		v_schema := TRIM(REPLACE(v_schema,'if exists',''));
		v_query  := TRIM(REPLACE(v_query,'''',''));
		
		
		v_ip := inet_client_addr();
		v_ip := trim(v_ip);
		v_hint_host_name := case 
								when v_ip = '0.0.0.01' then 'Nome Desenv01'
								when v_ip = '0.0.0.02' then 'Nome Desenv02'
								when v_ip = '0.0.0.03' then 'Nome Desenv03'
								when v_ip = '0.0.0.04' then 'Nome Desenv04'
								when v_ip = '0.0.0.05' then 'Nome Desenv05'
								when v_ip = '0.0.0.06' then 'Nome Tester02'
								when v_ip = '0.0.0.07' then 'Nome Tester03'
								when v_ip = '0.0.0.08' then 'Nome Tester04'
								when v_ip = '0.0.0.09' then 'Nome Tester05'
							else 'ip desconhecido'
						 	end;
	
		
		-- VERIFICAR SE ESTÃO TENTANDO APAGAR A TABELA DA AUDITORIA
		if (position('AUDITORIA' in UPPER(v_query)) > 0) and (position('AUDITORIA' in UPPER(v_schema)) > 0) then
			v_try_drop_auditoria := true;
		else
			v_try_drop_auditoria := false;
		end if;
	
	
		-- CONECTANDO NO DATABASE DE AUDITORIA
		perform (SELECT public.dblink_connect('hostaddr=10.123.45.67 dbname=ADTDB001 user=admin'));
			
		
		-- INSERINDO REGISTRO NA TABELA AUDITORIA
 		perform (SELECT public.dblink_exec('insert into auditoria.auditoria_ddl(database_connected, schema_connected, user_db_connected, application_name, ip, hint_host_name, pid, port, query, try_drop_auditoria)
		values ('
					||''''|| current_database()  ||''''|| 
				',' ||''''|| current_schema()    ||''''|| 
				',' ||''''|| session_user        ||''''|| 
				',' ||''''|| v_application_name  ||''''|| 
				',' ||''''|| v_ip				 ||''''|| 
				',' ||''''|| v_hint_host_name	 ||''''|| 
				',' ||''''|| v_pid               ||''''||
				',' ||''''|| inet_client_port()  ||''''|| 
				',' ||''''|| trim(v_query)       ||''''||
				',' ||''''||v_try_drop_auditoria ||''''||
			');'));
		
		perform (SELECT public.dblink_exec('commit;'));
		
		-- VERIFICAR SE NA QUERY CONTÉM TEM A PALAVRA AUDITORIA E ALGUMA DAS SIGLAS QUE ADMINISTRAMOS
		if (position('AUDITORIA' in UPPER(v_query)) > 0) and (position('AUDITORIA' in UPPER(v_schema)) > 0) then
			RAISE EXCEPTION 'Não é possível alterar/excluir os objetos do schema auditoria. Contate o administrador do banco de dados.';
		end if;
	END;
	$$;


-- CRIAR TRIGGER DE EVENTO DE COMANDO DDL
CREATE EVENT TRIGGER auditoria_ddl ON ddl_command_end
   EXECUTE PROCEDURE public.auditoria_ddl();    
   
-- REPITA O PASSO A PASSO PARA CADA DATABASE QUE VOCÊ DESEJA AUDITAR.

-- DICAS
	PARA TODO IMPORT DE BASES QUE CONTÉM OBJETOS COM O NOME AUDITORIA VOCÊ TERÁ DE DESATIVAR TEMPORARIAMENTE A TRIGGER.
	MANTENHA SEMPRE ATUALIZADO COM O NOME DOS COLABORADORES
	ABAIXO ALGUMAS CONSULTAS QUE VOCÊ PODE UTILIZAR
	
	select * from auditoria.auditoria_ddl
	where upper(query) like '%NOME_TABELA%'
	order by date_execution desc;
	