with estaticas_dia as (
    select
        codigo,
        soma,
        maximo,
        minimo,
        media_dia,
        desvio_padrao,
        mediana,
        contagem,
        primeiro_quartil,
        terceiro_quartil
    from {{ ref('stg_estatisticas_dia') }}

),
estaticas_mensal as (
    select
        codigo,
        soma_mensal,
        maximo_mensal,
        minimo_mensal,
        media_mensal,
        desvio_padrao_mensal,
        mediana_mensal,
        contagem_mensal,
        primeiro_quartil_mensal,
        terceiro_quartil_mensal
    from {{ ref('stg_estatisticas_mes') }}
),
agrupamento as (
    select
        a.codigo,
        a.soma,
        a.maximo,
        a.minimo,
        a.media_dia,
        a.desvio_padrao,
        a.mediana,
        a.contagem,
        a.primeiro_quartil,
        a.terceiro_quartil,
        b.soma_mensal,
        b.maximo_mensal,
        b.minimo_mensal,
        b.media_mensal,
        b.desvio_padrao_mensal,
        b.mediana_mensal,
        b.contagem_mensal,
        b.primeiro_quartil_mensal,
        b.terceiro_quartil_mensal
    from estaticas_dia a 
    join estaticas_mensal b
    on a.codigo = b.codigo
)
select * from agrupamento


