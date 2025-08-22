WITH tabela_frequencia AS (
	SELECT 
		GRUPO,
		COUNT(*) AS quantidade,
		SUM(COUNT(*)) OVER () AS TOTAL,
		COUNT(*) / SUM(COUNT(*)) OVER () AS frequencia
	FROM {{ ref('int_movimento') }}
	GROUP BY GRUPO
	ORDER BY quantidade DESC
),
frequencia_acumulada AS (
	SELECT
		grupo,
		quantidade,
		total,
		ROUND(frequencia,2) AS frequencia,
		SUM(frequencia) OVER(ORDER BY quantidade DESC) AS frequencia_acumulada
	FROM tabela_frequencia

)

SELECT
	grupo,
	quantidade,
	total,
	frequencia,
	ROUND(frequencia_acumulada, 2) AS frequencia_acumulada

FROM frequencia_acumulada