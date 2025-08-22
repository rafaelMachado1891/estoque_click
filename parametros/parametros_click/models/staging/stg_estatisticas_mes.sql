

{{ config(materialized='view') }}

with source_data as (

    select * from {{ source('parametros_click_db', 'ESTATISTICAS_MENSAL') }}
),

tabela_transformada as(
select 
    cast(codigo as text) as codigo,
    cast(soma as numeric) as soma_mensal,
    cast(minimo_mes as numeric) as minimo_mensal,
    cast(maximo_mes as numeric) as maximo_mensal,
    cast(media__mes as decimal) as media_mensal,
    round(cast(desvio_padrao_mes as decimal),4) as desvio_padrao_mensal,
    round(cast(mediana_mes as decimal),2) as mediana_mensal,
    cast(contagem_mes as numeric) as contagem_mensal,
    cast(q1_mes as decimal) as primeiro_quartil_mensal,
    cast(q3_mes as decimal) as terceiro_quartil_mensal
from source_data

)

select *
from tabela_transformada
