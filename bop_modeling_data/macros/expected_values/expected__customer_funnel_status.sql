{% macro expected__customer_funnel_status(type) %}
{%- set var = 'customer_funnel_status' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Declined', 'Expired-Quoted but not written', 'Expired-Ready for Referral', 'Expired-Ready to Issue-Not-STP', 'Expired-Ready to Issue-STP', 'Expired-Review UW Changes', 'In Progress', 'Issued-Not-STP', 'Issued-STP', 'Quoted but not written-Not-STP', 'Quoted but not written-STP', 'Ready for Referral', 'Ready to Issue-Not-STP', 'Ready to Issue-STP', 'Submitted but not quoted']
{%- elif type == 'clean' -%}
    ['Missing', 'Declined', 'Expired-Quoted but not written', 'Expired-Ready for Referral', 'Expired-Ready to Issue-Not-STP', 'Expired-Ready to Issue-STP', 'Expired-Review UW Changes', 'In Progress', 'Issued-Not-STP', 'Issued-STP', 'Quoted but not written-Not-STP', 'Quoted but not written-STP', 'Ready for Referral', 'Ready to Issue-Not-STP', 'Ready to Issue-STP', 'Submitted but not quoted']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
