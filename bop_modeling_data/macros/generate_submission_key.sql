{%- macro generate_submission_key(submission_identifier) -%}

hash({{ submission_identifier }}) as submission_key

{%- endmacro -%}