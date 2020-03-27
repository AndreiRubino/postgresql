*****************************************************************************************************
--	POSTGRESQL -- BACKUP E RESTORE
*****************************************************************************************************


-- DICAS GERAIS
	DEFINIR SEMPRE UMA ESTRATEGIA DE BACKUPS
	TIPOS, PARAMETROS E OPÇÕES DE BACKUP
	FREQUENCIA
	LOCAIS DE ARMAZENAMENTO E RESTAURAÇÃO 
	EFETUAR SEMPRE TESTES(RESTORE) DOS BACKUPS REALIZADOS 
	CRIAR DOCUMENTAÇÃO PARA RESTAURAÇÃO
	FICAR ATENTO SE HÁ ESPAÇO EM DISCO	
	ONDE FICARÁ ARMAZENADO O BACKUP? É VIAVEL TRANSFERIR PELA REDE?
	
	
-- FERRAMENTAS DO POSTGRESQL PARA BACKUP RESTORE
	PG_DUMP
	PSQL
	PG_RESTORE
	BARMAN
	
	
-- EXEMPLOS EXPORT EM AMBIENTES LINUX

	-- PG_DUMP PARAMETROS DE BACKUP 
		--no-owner  	-- BACKUPS SEM OWNER PARA QUE O OWNER SEJA O USUÁRIO QUE REALIZARA A IMPORTAÇÃO
		-U				-- USUÁRIO
		-d				-- DATABASE 
		-n				-- SCHEMA
		-t				-- TABELA
		--format plain 	-- EXPORTAR EM FORMATO .sql
		--section pre-data	-- DUMP SOMENTE DA ESTRUTURA SEM OS REGISTROS
		--exclude-table=nome_tabela   -- EXCLUIR UMA TABELA DE UM BACKUP
		 
		 
	-- CONECTAR COM USUÁRIO POSTGRES
	# su - postgres
	
	-- BACKUP DO DATABASE COMPLETO
	$ pg_dump --no-owner -U postgres -d NAME_DATABASE > /diretorio/nome_arquivo.sql 
	
	-- BACKUP DE UM SCHEMA ESPECIFICO
	$ pg_dump --no-owner -U postgres -d NAME_DATABASE -n name_schema > /diretorio/nome_arquivo.sql 
	
	-- COMPACTANDO BACKUPS
	$ pg_dump --no-owner -U postgres -d NAME_DATABASE -n name_schema -F tar  -f {nome_arquivo.tar.gz}
	
	-- BACKUP APENAS DE UMA TABELA
	$ pg_dump  --no-owner -U postgres -t name_schema.name_table -d NAME_DATABASE -n name_schema  > /diretorio/nome_arquivo.sql 
	
	-- BACKUP SEM UMA TABELA
	$ pg_dump  --no-owner -U postgres -d NAME_DATABASE -n name_schema  > /diretorio/nome_arquivo.sql --exclude-table=nome_tabela;
	
	-- DUMP SOMENTE DA ESTRUTURA SEM REGISTROS 
	pg_dump  --no-owner --format plain --section pre-data -U postgres -d NAME_DATABASE -n name_schema  > /diretorio/nome_arquivo.sql 
	
	-- EXTRAIR REGISTROS DE UMA TABELA PARA UM ARQUIVO CSV
	COPY (SELECT * from name_schema.name_table) To '/diretorio/nome_arquivo.csv' with csv;
	COPY (SELECT * from name_schema.name_table where coluna1 >= 1 and coluna1 < 100) To '/diretorio/nome_arquivo.csv' with csv;
	
	

-- EXEMPLOS IMPORT  EM AMBIENTES LINUX	
	# su - postgres
	
	
-- RESTORE DO DATABASE COMPLETO
	$ psql NAME_DATABASE  -U postgres < /diretorio/arquivo.sql

-- RESTORE SOMENTE DE UM SCHEMA, NESTA OPÇÃO VOCÊ PODE CRIAR O SCHEMA E PASSAR ELE COMO PARAMETRO OU UTILIZAR O PRÓPIO CREATE SCHEMA DO DUMP GERADO.
	$ psql NAME_DATABASE  -U postgres -n name_schema < /diretorio/arquivo.sql
 
 
-- RESTORE SOMENTE DE UM SCHEMA COM PG_RESTORE 
   $ pg_restore -U postgres -d NAME_DATABASE /diretorio/arquivo.sql

	

DEIXO MAIS 2 MODELOS AFIM DE ESTUDO

EXISTEM OUTROS TIPOS DE BACKUP COMO BACKUPS FEITO PELO SISTEMA OPERACIONAL
NO ENTANTO ESTE É MODELO OFFLINE TEMOS DE PARAR O BANCO DE DADOS E COPIAR OS ARQUIVOS MANUALMENTE.
E TAMBÉM O ARQUIVAMENTO CONTÍNUO/POINT-IN-TIME RECOVERY (PITR) ONDE DEVE SER FEITO ALGUMAS CONFIGURAÇÕES NO ARQUIVO POSTGRES.CONF.