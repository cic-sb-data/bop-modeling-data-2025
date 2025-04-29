select *
from {{ ref('lkp__associated_policies') }}
where __is_gt1_five_key_in_table = 1