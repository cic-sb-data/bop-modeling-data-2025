{% macro npc_event(
    bil_acy_des_cd='bil_acy_des_cd',
    bil_des_rea_typ='bil_des_rea_typ'
) %}
    {# 
    Definition from SAS:

    ```
    where bil_acy_des_cd = 'C' and bil_des_rea_typ = '' 
    ```
    #}
    {{ bil_acy_des_cd }} = 'C'
    and {{ bil_des_rea_typ }} = ''
{% endmacro %}