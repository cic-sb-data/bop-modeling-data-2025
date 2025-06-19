{# This macro checks if a commercial intelliscore column is 
   within the range of 1 to 100 and returns 1 if it is, otherwise 
   returns 0. #}

{%- macro commercial_intelliscore_hit(col) -%}
case when (1 <= {{ col }}) and ({{ col }} <= 100) then 1 else 0 end 
{%- endmacro -%}
