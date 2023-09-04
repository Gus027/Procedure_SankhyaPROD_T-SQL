
CREATE PROCEDURE "EXCLUSAONFERECLASSIFIC" (
       @P_TIPOEVENTO INTEGER,    -- Identifica o tipo de evento
       @P_IDSESSAO VARCHAR(MAX), -- Identificador da execução. Serve para buscar informações dos campos da execução.
       @P_CODUSU INTEGER         -- Código do usuário logado
) AS
DECLARE
       @BEFORE_INSERT INTEGER,
       @AFTER_INSERT  INTEGER,
       @BEFORE_DELETE INTEGER,
       @AFTER_DELETE  INTEGER,
       @BEFORE_UPDATE INTEGER,
       @AFTER_UPDATE  INTEGER,
       @BEFORE_COMMIT INTEGER,
       
	   @CODTOP INT,
       @CODPROJ INT,
	   @TOP INT
BEGIN
       SET @BEFORE_INSERT = 0
       SET @AFTER_INSERT  = 1
       SET @BEFORE_DELETE = 2
       SET @AFTER_DELETE  = 3
       SET @BEFORE_UPDATE = 4
       SET @AFTER_UPDATE  = 5
       SET @BEFORE_COMMIT = 10
       SET @TOP = 1401
       

/*==================================================*/
/*		PROCEDURE PRODUCED FOR: GUSTAVO GOMES F.	*/
/*				DATE: 22-08-2023					*/
/*==================================================*/       
   
/*******************************************************************************
	  E possivel obter o valor dos campos atraves das Functions:
   
	  EXECUTE EVP_GET_CAMPO_DTA P_IDSESSAO, 'NOMECAMPO'   -- PARA CAMPOS DE DATA
	  EXECUTE EVP_GET_CAMPO_INT P_IDSESSAO, 'NOMECAMPO'   -- PARA CAMPOS NUMERICOS INTEIROS
	  EXECUTE EVP_GET_CAMPO_DEC P_IDSESSAO, 'NOMECAMPO'   -- PARA CAMPOS NUMERICOS DECIMAIS
	  EXECUTE EVP_GET_CAMPO_TEXTO P_IDSESSAO, 'NOMECAMPO' -- PARA CAMPOS TEXTO
  
	  O primeiro argumento e uma chave para esta execucao. O segundo es o nome do campo.
  
	  Para os eventos BEFORE UPDATE, BEFORE INSERT e AFTER DELETE todos os campos estarao disponiveis.
	  Para os demais, somente os campos que pertencem a PK
  
	  * Os campos CLOB/TEXT serao enviados convertidos para VARCHAR(4000)
  
	  Tambem e possivel alterar o valor de um campo atraves das Stored procedures:
  
	  EXECUTE EVP_SET_CAMPO_DTA @P_IDSESSAO,  'NOMECAMPO', TO_DATE(VALOR, 'DD-MM-YYYY') -- VALOR DEVE SER UMA DATA
	  EXECUTE EVP_SET_CAMPO_INT @P_IDSESSAO,  'NOMECAMPO', VALOR -- VALOR DEVE SER UM NUMERO INTEIRO
	  EXECUTE EVP_SET_CAMPO_DEC @P_IDSESSAO,  'NOMECAMPO', VALOR -- VALOR DEVE SER UM NUMERO DECIMAL
	  EXECUTE EVP_SET_CAMPO_TEXTO @P_IDSESSAO,  'NOMECAMPO', 'VALOR' -- VALOR DEVE SER UM TEXTO
********************************************************************************/
    IF @P_TIPOEVENTO = @AFTER_DELETE
    BEGIN
	   SELECT @CODTOP = SANKHYA.EVP_GET_CAMPO_INT(@P_IDSESSAO, 'CODTIPOPER') --- Percorre a nota. Se a variavel conter a top 1401, ele executa a exclusão
	   IF (@CODTOP = @TOP)
	   BEGIN
		  SELECT @CODPROJ = SANKHYA.EVP_GET_CAMPO_INT(@P_IDSESSAO, 'CODPROJ')

		/*====================INSERT NA TABELA MONITOR========================*/    
		  INSERT INTO AD_MONITOR_EXCLUSSAORECLASSIFIC
			SELECT
				NUNOTA,
				CODEMP,
				NUMNOTA,
				DTNEG,
				DTFATUR,
				DTENTSAI,
				DTMOV,
				CODEMPNEGOC L,
				CODPARC,
				CODTIPOPER,
				DHTIPOPER,
				TIPMOV
			FROM TGFCAB
			WHERE CODPROJ = @CODPROJ
			AND CODTIPOPER = 1161
			AND CODEMP = 1
		/*===========================DELETE===================================*/  	
		  DELETE FROM TGFCAB
	      WHERE CODPROJ = @CODPROJ
	      AND CODTIPOPER = 1161
	      AND CODEMP = 1
        END
    END
END;