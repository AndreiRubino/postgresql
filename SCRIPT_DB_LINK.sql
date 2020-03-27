*****************************************************************************************************
	-- SCRIPT CONEXÃO DB LINK                                                      
*****************************************************************************************************


O DBLINK NOS PERMITE CONECTAR ENTRE SERVIDORES DE BANCO DE DADOS

-- CRIANDO EXTENSION DBLINK
	CREATE EXTENSION dblink;
	
	
-- TESTE DA CONEXÃO
	SELECT dblink_connect('hostaddr=12.345.67.89 dbname=NAME_DATABASE user=name_user password=senha');
		
		
-- EFETUANDO UMA CONSULTA EM OUTRO SERVIDOR DE BANCO DE DADOS, TEMOS QUE DEFINIR OS TIPOS DAS COLUNAS NA SAIDA DO SELECT
	SELECT * FROM dblink('hostaddr=12.345.67.89 dbname=NAME_DATABASE user=name_user password=senha', 
	'select 
		coluna1
		, coluna2
		, coluna3
		, coluna4
		, coluna5
		from schema.name_table') 
	AS minha_tabela(coluna1 varchar, coluna2 integer, coluna3 text, coluna4 varchar(7), coluna5 boolean);  