with int_movimento as(
select 
    *
from  {{ ref("stg_movimento") }}
)
select * from int_movimento