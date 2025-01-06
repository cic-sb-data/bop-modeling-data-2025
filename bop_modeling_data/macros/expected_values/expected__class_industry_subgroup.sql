{% macro expected__class_industry_subgroup(type) %}
{%- set var = 'class_industry_subgroup' -%}
{%- if type == 'raw' -%}
    [   
        'Animal Services',
        'Apparel & Footwear',
        'Building Materials & Garden Supplies',
        'Business Equipment & Supplies',
        'Cleaning Services',
        'Condominium, Cooperative & Homeowner Associations',
        'Consulting',
        'Creative & Entertainment Arts',
        'Design & Drafting',
        'Electronics & Appliances',
        'Equipment & Clothing Rental Services',
        'Finance & Insurance',
        'Fitness & Exercise',
        'Food & Beverage',
        'Food Services',
        'General Business Services',
        'Home Goods',
        'Installation & Repair Services',
        'Landscaping & Garden',
        'Legal',
        'Limited Service Restaurants',
        'Marketing & Advertising',
        'Medical Offices',
        'Missing',
        'Other Health Care Facilities & Practitioners',
        'Other Services',
        'Personal Services',
        'Photography',
        'Printing, Publishing & Mailing',
        'Property Rental & Leasing',
        'Real Estate Services',
        'Specialty Goods',
        'Sports, Hobbies, Music & Books'
    ]
{%- elif type == 'clean' -%}
    [
        'Animal Services',
        'Apparel & Footwear',
        'Building Materials & Garden Supplies',
        'Business Equipment & Supplies',
        'Cleaning Services',
        'Condominium, Cooperative & Homeowner Associations',
        'Consulting',
        'Creative & Entertainment Arts',
        'Design & Drafting',
        'Electronics & Appliances',
        'Equipment & Clothing Rental Services',
        'Finance & Insurance',
        'Fitness & Exercise',
        'Food & Beverage',
        'Food Services',
        'General Business Services',
        'Home Goods',
        'Installation & Repair Services',
        'Landscaping & Garden',
        'Legal',
        'Limited Service Restaurants',
        'Marketing & Advertising',
        'Medical Offices',
        'Missing',
        'Other Health Care Facilities & Practitioners',
        'Other Services',
        'Personal Services',
        'Photography',
        'Printing, Publishing & Mailing',
        'Property Rental & Leasing',
        'Real Estate Services',
        'Specialty Goods',
        'Sports, Hobbies, Music & Books'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}


