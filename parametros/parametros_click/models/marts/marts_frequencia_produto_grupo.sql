WITH tabela_frequencia_produtos AS (
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

tabela_frequencia AS (
	SELECT
		codigo,
		grupo,
		cast(contagem_total_grupo as int) AS frequencia_geral_grupo,
		cast(contagem_item_grupo as int) AS frequencia_item,
		cast(contagem_item_grupo as decimal)/contagem_total_grupo AS frequencia_produto
	FROM resultado_final
	ORDER BY 1
),
tabela_produtos AS (
    SELECT 
		codigo,
		MIN(descricao) AS descricao
	FROM {{ ref('int_movimento') }}
	GROUP BY codigo
),

resultado AS (
    SELECT 
		a.grupo,
		a.codigo,
		b.descricao,	
		a.frequencia_geral_grupo,
		a.frequencia_item,
		ROUND(a.frequencia_produto,6) AS frequencia_produto
	FROM tabela_frequencia a
	LEFT JOIN tabela_produtos b
	ON a.codigo = b.codigo
)

SELECT 
	grupo,
    codigo,	
    descricao,
	frequencia_geral_grupo,
	frequencia_item,
	frequencia_produto
FROM resultado
ORDER BY 4 DESC, 5 DESC