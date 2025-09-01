WITH movimento_mes AS (
    SELECT 
        codigo,
        descricao,
        SUM(quantidade) AS quantidade,
        EXTRACT(MONTH FROM data_baixa) AS mes,
        EXTRACT(YEAR FROM data_baixa) AS ano,
        grupo
    FROM {{ ref('int_movimento') }}
    GROUP BY codigo, descricao, grupo, EXTRACT(MONTH FROM data_baixa), EXTRACT(YEAR FROM data_baixa)
),

produtos AS (
    SELECT 
        codigo,
        descricao,
        estoque_minimo,
        tempo_reposicao,
        grupo
    FROM {{ ref('int_produtos') }}
),

media_global AS (
    SELECT
        codigo,
        CAST(media_mensal AS INT) AS media_mensal,
        desvio_padrao_mensal
    FROM {{ ref('int_estatisticas') }}
),

media_movel_3_meses AS (
    SELECT 
        codigo,
        descricao,
        quantidade,
        grupo,
        mes,
        ano,
        AVG(quantidade) OVER (
            PARTITION BY codigo
            ORDER BY ano, mes
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS media_movel_3_meses
    FROM movimento_mes
),

media_movel_6_meses AS (
    SELECT 
        codigo,
        descricao,
        quantidade,
        mes,
        ano,
        AVG(quantidade) OVER (
            PARTITION BY codigo
            ORDER BY ano, mes
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) AS media_movel_6_meses
    FROM movimento_mes
),

-- Último ano/mês por produto
ultima_data_por_produto AS (
    SELECT 
        codigo,
        MAX(ano * 100 + mes) AS ano_mes_max
    FROM movimento_mes
    GROUP BY codigo
),

resultado_media_3_meses AS (
    SELECT
        m.codigo,
        m.descricao,
        m.grupo,
        CAST(m.media_movel_3_meses AS INT) AS media_movel_3_meses,
        m.mes,
        m.ano
    FROM media_movel_3_meses m
    JOIN ultima_data_por_produto u
      ON m.codigo = u.codigo
     AND (m.ano * 100 + m.mes) = u.ano_mes_max
),

resultado_media_6_meses AS (
    SELECT
        m.codigo,
        m.descricao,
        CAST(m.media_movel_6_meses AS INT) AS media_movel_6_meses,
        m.mes,
        m.ano
    FROM media_movel_6_meses m
    JOIN ultima_data_por_produto u
      ON m.codigo = u.codigo
     AND (m.ano * 100 + m.mes) = u.ano_mes_max
),

resultado AS (
    SELECT 
        a.codigo,
        a.descricao,
        b.grupo,
        d.estoque_minimo,
        d.tempo_reposicao,
        c.media_mensal,
        a.media_movel_6_meses,
        b.media_movel_3_meses,
        c.desvio_padrao_mensal
    FROM resultado_media_6_meses a
    JOIN resultado_media_3_meses b ON a.codigo = b.codigo
    JOIN media_global c ON a.codigo = c.codigo
    JOIN produtos d ON a.codigo = d.codigo
),

querycompleta AS (
    SELECT 
        codigo,
        descricao,
        grupo,
        estoque_minimo,
        tempo_reposicao,
        ROUND(media_mensal / 22 * tempo_reposicao + (1.5 * desvio_padrao_mensal), 0) AS calculo_estoque,
        media_mensal,
        media_movel_3_meses,
        media_movel_6_meses,
        CASE 
            WHEN media_mensal / 22 * tempo_reposicao + (1.5 * desvio_padrao_mensal) > estoque_minimo 
            THEN 'estoque minimo abaixo do recomendado' 
            ELSE 'estoque minimo acima do recomendado'
        END AS observacao
    FROM resultado
    WHERE grupo IN ('SUSEPE')
    ORDER BY descricao
)

-- Resultado final
SELECT * FROM querycompleta