{% macro expected__naics_2_desc(type) %}
{%- set var = 'naics_2_desc' -%}
{%- if type == 'raw' -%}
    [
        'Accommodation and Food Services',
        'Administrative and Support, Waste Management and Remediation Services',
        'Agriculture, Forestry, Fishing and Hunting',
        'Arts, Entertainment, and Recreation',
        'Construction',
        'Educational Services',
        'Finance and Insurance',
        'Health Care and Social Assistance',
        'Information',
        'Management of Companies and Enterprises',
        'Manufacturing',
        'Mining, Quarrying, and Oil and Gas Extraction',
        'Missing',
        'Other Public Services (Except Public Administration)',
        'Professional, Scientific, and Technical Services',
        'Public Administration',
        'Real Estate and Rental and Leasing',
        'Retail Trade',
        'Transportation and Warehousing',
        'Utilities',
        'Wholesale Trade'
    ]
{%- elif type == 'clean' -%}
    [
        'Accommodation and Food Services',
        'Administrative and Support, Waste Management and Remediation Services',
        'Agriculture, Forestry, Fishing and Hunting',
        'Arts, Entertainment, and Recreation',
        'Construction',
        'Educational Services',
        'Finance and Insurance',
        'Health Care and Social Assistance',
        'Information',
        'Management of Companies and Enterprises',
        'Manufacturing',
        'Mining, Quarrying, and Oil and Gas Extraction',
        'Missing',
        'Other Public Services (Except Public Administration)',
        'Professional, Scientific, and Technical Services',
        'Public Administration',
        'Real Estate and Rental and Leasing',
        'Retail Trade',
        'Transportation and Warehousing',
        'Utilities',
        'Wholesale Trade'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
