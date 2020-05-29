*****************************************************************************************************
	-- SCRIPT ORDENANDO SEQUENCES                                                     
*****************************************************************************************************
/*
	O COMANDO ABAIXO GERA UM SCRIPT PARA QUE SEJA ATUALIZADO O VALOR START DE TODAS AS SEQUENCES DO SEU TABLE_SCHEMA
	EM ALGUNS CASOS QUANDO UM BACKUP É IMPORTADO É NECESSÁRIO REORDENAR O VALOR START AS SEQUENCES
*/


-- SUBSTITUIR NA CLAUSULA WHERE nome_table_schema PELO NOME DE SEU SCHEMA, APÓS ISSO EXECUTE O SELECT COPIE O RESULTADO E EXECUTE
select  'SELECT pg_catalog.setval(pg_get_serial_sequence('''|| table_schema || '."' || table_name ||'"'','''||column_name|| '''),MAX("'||column_name||'")) FROM '
		|| table_schema || '."' || table_name || '";'
from  information_schema.columns where column_default like 'nextval%' and table_schema = 'nome_table_schema'
order by table_schema, table_name;