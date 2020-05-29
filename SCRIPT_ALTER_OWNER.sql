*****************************************************************************************************
	-- SCRIPT ALTER OWNER                                                    
*****************************************************************************************************
/* 
	O OBJETIVO DOS COMANDOS ABAIXO É AUTOMATIZAR SCRIPTS QUE SÃO EXECUTADOS FREQUENTEMENTE
	O SCRIPT GERA UM SCRIPT PARA ALTERAR O OWNER DE TABELAS, SEQUENCES E VIEWS.
*/


-- SUBSTITUIR O NOME_USUARIO PELO NOME DO USUÁRIO QUE VOCÊ DESEJA DAR GRANT, EXECUTE O SELECT COPIE O RESULTADO E EXECUTE O ALTER TABLE
(SELECT 'ALTER TABLE '|| schemaname || '."' || tablename ||'" OWNER TO NOME_USUARIO;' as SCRIPT
FROM pg_tables WHERE schemaname = ''
ORDER BY schemaname, tablename)


-- SUBSTITUIR O NOME_USUARIO PELO NOME DO USUÁRIO QUE VOCÊ DESEJA DAR GRANT, EXECUTE O SELECT COPIE O RESULTADO E EXECUTE O ALTER TABLE
(SELECT 'ALTER SEQUENCE '|| sequence_schema || '."' || sequence_name ||'" OWNER TO NOME_USUARIO;' as SCRIPT
FROM information_schema.sequences WHERE  sequence_schema = ''
ORDER BY sequence_schema, sequence_name)

UNION 

(SELECT 'ALTER VIEW '|| table_schema || '."' || table_name ||'" OWNER TO NOME_USUARIO;' as SCRIPT
FROM information_schema.views WHERE  table_schema = ''
ORDER BY table_schema, table_name)
ORDER BY SCRIPT