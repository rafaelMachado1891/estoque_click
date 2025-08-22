with produtos as (
    select 
        codigo,
        min(descricao) as descricao,
        estoque_minimo,
        tempo_reposicao,
        grupo
    from {{ ref('stg_movimento') }}
    group by codigo,grupo,estoque_minimo, tempo_reposicao
)

select 
    codigo,
    descricao,
    estoque_minimo,
    case when tempo_reposicao = 0 then 1 else tempo_reposicao end,
    grupo
from produtos order by codigo