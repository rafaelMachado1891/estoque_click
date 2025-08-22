

{{ config(materialized='view') }}

with source_data as (

    select * from {{ source('parametros_click_db', 'MOVIMENTO') }}
),

tabela_transformada as(
select 
    cast(codigo as text) as codigo,
    cast(descricao as text) as descricao,
    cast(data_baixa as date) as data_baixa,
    cast(total_movimento as float) as quantidade,
    cast(grupo  as text)  as grupo,
    cast(estoque_minimo as int) as estoque_minimo,
    tempo_reposicao
from source_data

)

select *
from tabela_transformada

