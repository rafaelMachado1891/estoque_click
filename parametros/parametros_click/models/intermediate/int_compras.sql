with tabela_compras as (
    select 
        
        data_entrega,
        fornecedor,
        numero_oc,
        codigo_produto,
        descricao,
        saldo as quantidade,
        valor_total      

    from {{ ref("stg_compras") }}
)
select 
    
    *

from tabela_compras
order by 2, 1