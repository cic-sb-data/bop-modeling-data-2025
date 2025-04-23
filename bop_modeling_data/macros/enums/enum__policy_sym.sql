{%- macro enum__policy_sym() -%}
    drop type if exists policySymType;
    create type policySymType as enum ('EBD', 'ECO', 'ECP', 'ECT', 'ENA', 'ENP', 'EPP', 'ETD', 'ETN');
{%- endmacro -%}