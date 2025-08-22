

{{ config(materialized='view') }}

with source_data as (

    select * from {{ source('parametros_click_db', 'ESTATISTICAS_DIA') }}
),

tabela_transformada as(
select 
    cast(codigo as text) as codigo,
    cast(soma as numeric),
    cast(minimo as numeric),
    cast(maximo as numeric),
    cast(media_dia  as decimal),
    round(cast(desvio_padrao as decimal),4) as desvio_padrao,
    round(cast(mediana as decimal),2) as mediana,
    cast(contagem as numeric),
    cast(q1 as decimal) as primeiro_quartil,
    cast(q3 as decimal) as terceiro_quartil
from source_data

)

select *
from tabela_transformada
