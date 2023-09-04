CREATE PROCEDURE "LIT_INSERT_ETQAMOSTRA_PROJETO" (
       @P_CODUSU INT,                -- Código do usuário logado
       @P_IDSESSAO VARCHAR(4000),    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       @P_QTDLINHAS INT,             -- Informa a quantidade de registros selecionados no momento da execução.
       @P_MENSAGEM VARCHAR(4000) OUT -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
DECLARE
       @FIELD_CODOEA INT,
       @PARAM_CODPROJ INT,
       @I INT
BEGIN
       -- Os valores informados pelo formulário de parâmetros, podem ser obtidos com as funções:
       --     ACT_INT_PARAM
       --     ACT_DEC_PARAM
       --     ACT_TXT_PARAM
       --     ACT_DTA_PARAM
       -- Estas funções recebem 2 argumentos:
       --     ID DA SESSÃO - Identificador da execução (Obtido através de P_IDSESSAO))
       --     NOME DO PARAMETRO - Determina qual parametro deve se deseja obter.
	
		---	SET @PARAM_CODPROJ = sankhya.ACT_INT_PARAM(@P_IDSESSAO, 'CODPROJ')
		SET @PARAM_CODPROJ = sankhya.ACT_INT_PARAM(@P_IDSESSAO, 'CODPROJ')
	

       SET @I = 1 -- A variável "I" representa o registro corrente.
       WHILE @I <= @P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       BEGIN
           		SET @FIELD_CODOEA = sankhya.ACT_INT_FIELD(@P_IDSESSAO, @I, 'CODOEA')
        
           		INSERT INTO AD_ETQCOR(CODOEA,CODSEQ,CODCOR,CODPROJ,DESCRPROD,CODPROD,PATONE) --- Sub-tabela da AD_ETQEA
					SELECT
						(SELECT CODOEA FROM AD_ETQOEA WHERE CODOEA = @FIELD_CODOEA) AS CODOEA,
						ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS CODSEQ
						, S.CODCOR2
						, S.CODPROJ
						, S.DESCRPROD
						, S.CODPROD
						, ISNULL(S.CODPANTONE,'PROD PAI') AS CODPANTONE
					FROM (
					SELECT COR.NOMECOR,cab.CODPROJ,CASE WHEN (SELECT CODPRODGR1 FROM AD_FAMGR1 GRT WHERE GRT.CODPRODGR1 = ITE.CODPROD) = ITE.CODPROD THEN 1 
					ELSE 0 END TIPO,pro.CODPROD,pro.AD_CODANT,pro.DESCRPROD,pro.NCM,ITE.QTDNEG,PRO.AD_GRAMATURALINEAR GRAMATURA,pro.CODVOL,
					ISNULL(voa.CODVOL,pro.CODVOL) VOLALT,pro.PESOBRUTO,pro.PESOLIQ,isnull(cor.CODCOR2,'PROD PAI') CODCOR2,
					ISNULL(cor.CODPANTONE,'PROD PAI') CODPANTONE, ite.VLRUNIT, ite.AD_QTDROLO, 
					STUFF(';' + (SELECT TGFITE.AD_REFSORT + ' ; ' FROM TGFITE WHERE TGFITE.CODPROD = ITE.CODPROD AND TGFITE.NUNOTA = CAB.NUNOTA FOR XML PATH('')), 1, 1, '') AS AD_REFSORT, ite.AD_TAMPECASORT,
					STUFF(',' + (SELECT NROCONTAINER + ', ' FROM TCECON CON,TCECAB CAB WHERE CAB.NUIMP = CON.NUIMP AND CAB.CODPROJ = @PARAM_CODPROJ  FOR XML PATH('')), 1, 1, '') AS CNTR,
					PRODIMP.DESCREXP DESCRICAO_EXPORTADOR
					from TGFCAB cab
					inner join TGFITE ite on ite.NUNOTA = cab.NUNOTA
					inner join TGFPRO pro on pro.CODPROD = ite.CODPROD
					left JOIN TGFVOA voa ON voa.CODPROD = ite.CODprod
					LEFT JOIN AD_PANTONE cor ON cor.CODCOR = pro.AD_CODCOR
					LEFT JOIN AD_SORTPROD SORTPROD ON SORTPROD.CODPRODSON = PRO.CODPROD AND SORTPROD.CODPROJ = CAB.CODPROJ
					LEFT JOIN AD_PRODIMP PRODIMP ON PRODIMP.CODPROJ = SORTPROD.CODPROJ AND PRODIMP.CODPROD = SORTPROD.CODPROD
					where cab.CODPROJ = @PARAM_CODPROJ
					and TIPMOV = 'O'
					UNION ALL
					SELECT cor.NOMECOR,cab.CODPROJ,1 tipo,gr3.CODPRODGR2 CODPROD,pro.AD_CODANT,pro.DESCRPROD,pro.NCM,SUM(ite.QTDNEG) QTDNEG,PRO.AD_GRAMATURALINEAR GRAMATURA,pro.CODVOL,ISNULL(voa.CODVOL,pro.CODVOL) VOLALT,pro.PESOBRUTO,pro.PESOLIQ,isnull(cor.CODCOR2,'PROD PAI') CODCOR2,ISNULL(cor.CODPANTONE,'PROD PAI') CODPANTONE, ite.VLRUNIT, SUM(ite.AD_QTDROLO) AS AD_QTDROLO, 
					STUFF(';' + (SELECT TGFITE.AD_REFSORT + ' ; ' FROM TGFITE, AD_FAMGR3  WHERE TGFITE.CODPROD = AD_FAMGR3.CODPRODGR3 AND TGFITE.NUNOTA = CAB.NUNOTA AND AD_FAMGR3.CODPRODGR2 = gr3.CODPRODGR2 FOR XML PATH('')), 1, 1, '') AS AD_REFSORT, SUM(ite.AD_TAMPECASORT) AS AD_TAMPECASORT,
					 STUFF(',' + (SELECT NROCONTAINER + ', ' FROM TCECON CON,TCECAB CAB WHERE CAB.NUIMP = CON.NUIMP AND CAB.CODPROJ = @PARAM_CODPROJ FOR XML PATH('')), 1, 1, '') AS CNTR,
					PRODIMP.DESCREXP DESCRICAO_EXPORTADOR
					from TGFCAB cab
					inner join TGFITE ite on ite.NUNOTA = cab.NUNOTA
					INNER JOIN AD_FAMGR3 gr3 on gr3.CODPRODGR3 = ite.CODPROD
					inner join TGFPRO pro on pro.CODPROD = GR3.CODPRODGR2
					left JOIN TGFVOA voa ON voa.CODPROD = pro.CODPROD
					LEFT JOIN AD_PANTONE cor ON cor.CODCOR = pro.AD_CODCOR
					LEFT JOIN AD_SORTPROD SORTPROD ON SORTPROD.CODPRODSON = PRO.CODPROD AND SORTPROD.CODPROJ = CAB.CODPROJ
					LEFT JOIN AD_PRODIMP PRODIMP ON PRODIMP.CODPROJ = SORTPROD.CODPROJ AND PRODIMP.CODPROD = SORTPROD.CODPROD
					where cab.CODPROJ = @PARAM_CODPROJ
					and TIPMOV = 'O'
					GROUP BY CAB.CODPROJ,CODPRODGR2,pro.AD_CODANT,DESCRPROD,NCM,AD_GRAMATURALINEAR,pro.CODVOL,voa.CODVOL,pro.PESOBRUTO,pro.PESOLIQ,cor.CODCOR2,cor.CODPANTONE, ite.VLRUNIT, CAB.NUNOTA, PRODIMP.DESCREXP, COR.NOMECOR
					)S INNER JOIN TGFPRO ON S.CODPROD = TGFPRO.CODPROD
			
			/*UPDATE COLUMN 'REPET':
			 * 	Essa update atualiza a inserção da tabela AD_ETQCOR, para que o usuario não precise preencher a coluna 'REPET' de impressão
			 * evitando erro na hora de imprimir caso o mesmo seja igual a null*/	
					
				UPDATE AD_ETQCOR 
				SET REPET = 1
				WHERE CODOEA = @FIELD_CODOEA
           SET @I = @I + 1
       END
END
