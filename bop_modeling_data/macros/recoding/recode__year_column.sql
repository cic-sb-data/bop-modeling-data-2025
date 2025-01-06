{%- macro get_year_business_started() -%}
try_cast(
    case
        {# normal case: when experian_year_business_started exists and is > 1000 #}
        when try_cast(experian_year_business_started as integer) is not null
            and coalesce(try_cast(experian_year_business_started as integer), 0) > 1000
            then coalesce(try_cast(experian_year_business_started as integer), 0)
        
        {# when experian_year_business_started exists but is < 1000, if < 200, subtract #}
        {# the value from the original submission create year, assuming it is really a business #}
        {# age, not a year #}
        when coalesce(try_cast(experian_year_business_started as integer), 0) < 1000
            then year(submission_created_date) - coalesce(try_cast(experian_year_business_started as integer), 0)

        {# when experian_year_business_started is null, try to reconstruct it from #}
        {# acct_years in business and/or evolve_tier_years in business #}
        when try_cast(experian_year_business_started as integer) is null
            then case

                {# first try acct_years in business -- if it is > 1000, it is probably #}
                {# year and not an age, so use it as is #}
                when try_cast(acct_years_in_business as integer) is not null
                    and coalesce(try_cast(acct_years_in_business as integer), 0) > 1000
                    then coalesce(try_cast(acct_years_in_business as integer), 0)

                {# now do the same  thing for evolve_tier_years_in_business #}
                when try_cast(evolve_tier_years_in_business as integer) is not null
                    and coalesce(try_cast(evolve_tier_years_in_business as integer), 0) > 1000
                    then coalesce(try_cast(evolve_tier_years_in_business as integer), 0)

                {# if acct_years_in_business is < 1000, assume it is actually #}
                {# a business age, so add 2000 to  #}
                when try_cast(acct_years_in_business as integer) is not null
                    and coalesce(try_cast(acct_years_in_business as integer), 0) < 1000
                    then year(submission_created_date) - coalesce(try_cast(acct_years_in_business as integer), 0)

                {# do the same thing for evolve_tier_years_in_business #}
                when try_cast(evolve_tier_years_in_business as integer) is not null
                    and coalesce(try_cast(evolve_tier_years_in_business as integer), 0) < 1000
                    then year(submission_created_date) - coalesce(try_cast(evolve_tier_years_in_business as integer), 0)

                {# if all else fails, return null #}
                else null
            end
        else coalesce(try_cast(experian_year_business_started as integer), 0)
    end as integer
)

{%- endmacro -%}


{%- macro get_years_in_business() -%}

try_cast(
    case
        {# normal case: when experian_years_in_business_code exists and is > 1000 #}
        when try_cast(experian_years_in_business_code as integer) is not null
            and coalesce(try_cast(experian_years_in_business_code as integer), 0) > 1000
            then coalesce(try_cast(experian_years_in_business_code as integer), 0)
        
        {# when experian_years_in_business_code exists but is < 1000, if < 200, subtract #}
        {# the value from the original submission create year, assuming it is really a business #}
        {# age, not a year #}
        when coalesce(try_cast(experian_years_in_business_code as integer), 0) < 1000
            then year(submission_created_date) - coalesce(try_cast(experian_years_in_business_code as integer), 0)

        {# when experian_years_in_business_code is null, try to reconstruct it from #}
        {# acct_years in business and/or evolve_tier_years in business #}
        when try_cast(experian_years_in_business_code as integer) is null
            then case

                {# first try acct_years in business -- if it is > 1000, it is probably #}
                {# year and not an age, so use it as is #}
                when try_cast(acct_years_in_business as integer) is not null
                    and coalesce(try_cast(acct_years_in_business as integer), 0) > 1000
                    then coalesce(try_cast(acct_years_in_business as integer), 0)

                {# now do the same  thing for evolve_tier_years_in_business #}
                when try_cast(evolve_tier_years_in_business as integer) is not null
                    and coalesce(try_cast(evolve_tier_years_in_business as integer), 0) > 1000
                    then coalesce(try_cast(evolve_tier_years_in_business as integer), 0)

                {# if acct_years_in_business is < 1000, assume it is actually #}
                {# a business age, so add 2000 to  #}
                when try_cast(acct_years_in_business as integer) is not null
                    and coalesce(try_cast(acct_years_in_business as integer), 0
    as integer
)


{%- endmacro -%}