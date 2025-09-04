with source_data as (

    select * from {{ source('parametros_click_db', 'COMPRAS') }}
),

tabela_transformada as(
select 
    cast(numero as int) as numero_oc,
    cast(codigo as text) as codigo_produto,
    cast(descricao as text) as descricao,
    cast(un as text) as un,
    cast(saldo as int) as saldo,
    cast(preco as float) as preco,
    cast(valor_total as decimal),
    cast(data_entrega as date) as data_entrega,
    cast(razao as text) as fornecedor,
    cast(cod_terceiro as int) as cod_terceiro
from source_data

)

select
    numero_oc,
    codigo_produto,
    descricao,
    un,
    saldo,
    preco,
    round(valor_total,2) as valor_total,
    data_entrega,
    fornecedor,
    cod_terceiro
from tabela_transformada