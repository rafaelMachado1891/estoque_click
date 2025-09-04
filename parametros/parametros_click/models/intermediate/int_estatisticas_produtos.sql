WITH movimento_geral AS (
	SELECT 
		* 
	FROM {{ ref('stg_movimento') }}
),
estatisticas_gerais AS (
    SELECT 
        *
    FROM {{ ref('stg_estatisticas_mes') }}
),
agregate_mensal AS (
	SELECT
		codigo,
		sum(quantidade) AS quantidade,
        tempo_reposicao,
		EXTRACT(MONTH FROM data_baixa) AS mes,
		EXTRACT(YEAR FROM data_baixa) AS ano
	FROM movimento_geral
	GROUP BY 
	codigo, 
	EXTRACT(MONTH FROM data_baixa),
	EXTRACT(YEAR FROM data_baixa),
    tempo_reposicao
	ORDER BY codigo, ano, mes 
),
media_movel_produtos AS(
	SELECT
		codigo,
		quantidade,
        tempo_reposicao,
		ano,
		mes,
		AVG(quantidade) OVER(PARTITION BY codigo ORDER BY ano, mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS media_movel_3meses,
		AVG(quantidade) OVER(PARTITION BY codigo ORDER BY ano, mes ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS media_movel_6meses,
		AVG(quantidade) OVER(PARTITION BY codigo ORDER BY ano, mes) AS media,
		sum(quantidade) OVER(PARTITION BY codigo order by ano, mes) AS soma
	FROM agregate_mensal
	ORDER BY codigo,ano DESC, mes DESC	 
),
media_movel_atual as(
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY codigo ORDER BY ano DESC, mes DESC) AS rn
	FROM media_movel_produtos
),
tabela_de_medias AS (
	SELECT
		* 
	FROM media_movel_atual 
	WHERE RN = 1
),
resultado AS (
	SELECT 
		a.codigo,
		a.ano,
		a.mes,
        ROUND((a.media /22 * a.tempo_reposicao) + (1*b.desvio_padrao_mensal)) AS calculo_estoque,
		ROUND(a.media) AS media,
		ROUND(a.media_movel_3meses) AS media_movel_3meses,
		ROUND(a.media_movel_6meses) AS media_movel_6meses,
        ROUND(b.desvio_padrao_mensal) AS desvio_padrao,
        ROUND(b.mediana_mensal) mediana_mensal,
        b.primeiro_quartil_mensal AS primeiro_quartil,
        b.terceiro_quartil_mensal AS terceiro_quartil
	FROM tabela_de_medias a
    JOIN estatisticas_gerais b
    ON a.codigo = b.codigo
)
SELECT * FROM resultado