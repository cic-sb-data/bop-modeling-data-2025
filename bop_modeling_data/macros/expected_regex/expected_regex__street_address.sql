{% macro expected_regex__street_address() %}
    {% set address_patterns = (
        '(^P\.?O\.?\s?Box\s\d+$) |
        (^Post\sOffice\sBox\s\d+$) |
        (^\d+\s[A-Za-z]+\s(?:Street|St|Avenue|Ave|Boulevard|Blvd|Rd|Road|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir|Place|Pl|Way|Wy)\.?$) |
        (^\d+\s[A-Za-z]+\s(?:St|Ave|Blvd|Rd|Ln|Dr|Ct|Cir|Pl|Wy)\.?$) |
        (^\d+\s[A-Za-z]+\s[A-Za-z]+\s(?:Street|St|Avenue|Ave|Boulevard|Blvd|Rd|Road|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir|Place|Pl|Way|Wy)\.?$) |
        (^\d+\s[A-Za-z]+\s[A-Za-z]+\s(?:St|Ave|Blvd|Rd|Ln|Dr|Ct|Cir|Pl|Wy)\.?$) |
        (^\d+\s(?:N|S|E|W|North|South|East|West)\s[A-Za-z]+\s(?:Street|St|Avenue|Ave|Boulevard|Blvd|Rd|Road|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir|Place|Pl|Way|Wy)\.?$) |
        (^\d+\s(?:N|S|E|W|North|South|East|West)\s[A-Za-z]+\s(?:St|Ave|Blvd|Rd|Ln|Dr|Ct|Cir|Pl|Wy)\.?$) |
        (^\d+\s[A-Za-z]+\s(?:Street|St|Avenue|Ave|Boulevard|Blvd|Rd|Road|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir|Place|Pl|Way|Wy)\s(?:Apt|Apartment|Unit|Suite|Ste)\s\d+[A-Za-z]?\.$) |
        (^\d+\s[A-Za-z]+\s[A-Za-z]+\s(?:Street|St|Avenue|Ave|Boulevard|Blvd|Rd|Road|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir|Place|Pl|Way|Wy)\s(?:Apt|Apartment|Unit|Suite|Ste)\s\d+[A-Za-z]?\.$) |
        (^P\.?O\.?\s?Box\s\d+,\s(?:Apt|Apartment|Unit|Suite|Ste)\s\d+[A-Za-z]?\.$) |
        (^Post\sOffice\sBox\s\d+,\s(?:Apt|Apartment|Unit|Suite|Ste)\s\d+[A-Za-z]?\.$) |
        (\d+) |
        Missing |
        Excluded |
        ([a-zA-Z]+ [a-zA-Z])+'
    ) %}

    {{ return(address_patterns) }}
{% endmacro %}
