{%- macro generate_aiv_key(lob, cfxmlid, coverage_component_agreement_id) -%}

hash({{ lob }} || {{ cfxmlid }} || {{ coverage_component_agreement_id }}) as aiv_key

{%- endmacro -%}