with mart_produtos as (
    select
        *
    from public.int_produtos
),
estatisticas as (
    select
        *
    from public.int_estatisticas
),
resultado as (
    SELECT 
        a.codigo as codigo_item,
        a.descricao,
        a.grupo,
        b.*
    FROM mart_produtos a
    JOIN estatisticas b ON a.codigo = b.codigo
),
tabela_frequencia_grupo AS (
	SELECT 
		GRUPO,
		COUNT(*) AS quantidade,
		SUM(COUNT(*)) OVER () AS TOTAL,
		COUNT(*) / SUM(COUNT(*)) OVER () AS frequencia
	FROM {{ ref('int_movimento') }}
	GROUP BY GRUPO
	ORDER BY quantidade DESC
),
frequencia_acumulada_grupo AS (
	SELECT
		grupo,
		quantidade,
		total,
		ROUND(frequencia,2) AS frequencia,
		SUM(frequencia) OVER(ORDER BY quantidade DESC) AS frequencia_acumulada
	FROM tabela_frequencia_grupo

),
resultado_tabela_frequencia_grupo as (
    SELECT
        grupo,
        quantidade,
        total,
        frequencia,
        ROUND(frequencia_acumulada, 2) AS frequencia_acumulada

    FROM frequencia_acumulada_grupo
),
estatisticas_quantitativas as(
select 
    codigo_item,
    descricao,
    grupo,
    soma,
    maximo,
    minimo,
    media_dia,
    desvio_padrao,
    mediana,
    contagem,
    primeiro_quartil,
    terceiro_quartil,
    maximo_mensal,
    minimo_mensal,
    media_mensal,
    desvio_padrao_mensal,
    mediana_mensal,
    contagem_mensal,
    primeiro_quartil_mensal,
    terceiro_quartil_mensal
from resultado
),

tabela_frequencia_produtos AS (
	SELECT 
		DISTINCT 
		COUNT(codigo) OVER(PARTITION BY codigo, grupo) AS contagem_item_grupo,
		codigo,
		grupo
	FROM {{ ref('int_movimento') }}
),

tabela_agrupada AS (
	SELECT 
        grupo, 
        COUNT(*) AS contagem_total_grupo
    FROM {{ ref('int_movimento') }}
    GROUP BY grupo
),

tabela_frequencia_grupos AS (
	SELECT 
	    m.codigo,
	    m.grupo,
	    t.contagem_total_grupo
	FROM (
	    SELECT DISTINCT codigo, grupo
	    FROM {{ ref('int_movimento') }}
	) m
	JOIN tabela_agrupada t ON m.grupo = t.grupo
),

resultado_final AS (
	SELECT 
	    g.codigo,
	    g.grupo,
	    g.contagem_total_grupo,
	    p.contagem_item_grupo
	FROM tabela_frequencia_grupos g
	JOIN tabela_frequencia_produtos p
	  ON g.codigo = p.codigo AND g.grupo = p.grupo
),

tabela_frequencia_por_produto_grupo AS (
	SELECT
		codigo,
		grupo,
		cast(contagem_total_grupo as int) AS frequencia_geral_do_grupo,
		cast(contagem_item_grupo as int) AS frequencia_item,
		cast(contagem_item_grupo as decimal)/contagem_total_grupo AS frequencia_produto
	FROM resultado_final
	ORDER BY 1
),

resultado_frequencia_produto_grupo AS (
    SELECT 
		a.grupo,
		a.codigo,	
		a.frequencia_geral_do_grupo,
		a.frequencia_item,
		ROUND(a.frequencia_produto,6) AS frequencia_produto
	FROM tabela_frequencia_por_produto_grupo a
),
resultado_tabela_frequencia_por_produto_grupo as (
    SELECT 
        grupo,
        codigo,	
        frequencia_geral_do_grupo,
        frequencia_item,
        frequencia_produto
    FROM resultado_frequencia_produto_grupo
    ORDER BY 4 DESC, 5 DESC
)

select
    a.*,
    b.frequencia_geral_do_grupo,
    b.frequencia_item,
    b.frequencia_produto
from  estatisticas_quantitativas a
join resultado_tabela_frequencia_por_produto_grupo b 
on a.codigo_item = b.codigo
order by frequencia_geral_do_grupo desc, frequencia_produto desc