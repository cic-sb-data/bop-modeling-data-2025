{%- set premium_bins = [
    10000,
    15000,
    20000,
    25000,
    30000,
    40000,
    50000,
    75000,
    100000,
    125000,
    150000,
    175000,
    200000,
    300000,
    400000,
    500000,
] -%}

{%- macro convert_to_ingeger_number_of_thousands(number) -%}
    {{ number / 1000 }}
{%- endmacro -%}

case when(PROP_n_GL_Annual_EP_POL_Chars < 10000) then 'a) 000K_010K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 15000) then 'b) 010K_015K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 20000) then 'c) 015K_020K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 25000) then 'd) 020K_025K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 30000) then 'e) 025K_030K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 40000) then 'f) 030K_040K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 50000) then 'g) 040K_050K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 75000) then 'h) 050K_075K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 100000) then 'i) 075K_100K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 125000) then 'j) 100K_125K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 150000) then 'k) 125K_150K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 175000) then 'l) 150K_175K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 200000) then 'm) 175K_200K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 300000) then 'n) 200K_300K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 400000) then 'o) 300K_400K'
    when(PROP_n_GL_Annual_EP_POL_Chars < 500000) then 'p) 400K_500K'
    else 'q) 500K+'
end 

{%- macro bin_premium(prem_col) -%}
{%- set letters = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q'] -%}
{%- set prev_bin=-1 -%}
{%- for bin in premium_bins -%}
    {%- if prev_bin == -1 -%}
        {%- set prev_bin = bin -%}
        {%- set prev_bin_str = '000K_' ~ "%03d" % (bin / 1000) -%}
        case 
            when ({{ prem_col }} < {{ bin }}) then 'a) 000K_{{ "%03d" % (bin / 1000) }}'
    {%- else -%}
        {%- set bin_str = prev_bin_str ~ '_' ~ "%03d" % (bin / 1000) -%}
        when ({{ prem_col }} < {{ bin }}) then '{{ letters[loop.index0] }}) {{ bin_str }}'
        {%- set prev_bin = bin -%}
        {%- set prev_bin_str = bin_str -%}
    {%- endif -%}
{%- endfor -%}
    else '{{ letters[premium_bins|length] }}) {{ prev_bin_str }}+'
end
{%- endmacro -%}