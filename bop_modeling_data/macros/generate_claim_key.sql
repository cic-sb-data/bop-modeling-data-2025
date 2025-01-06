{%- macro generate_claim_key(claim_numb, subclaim_numb, date_of_loss) -%}

hash({{ claim_numb }} || {{ subclaim_numb }} || {{ date_of_loss }} ) as claim_key

{%- endmacro -%}