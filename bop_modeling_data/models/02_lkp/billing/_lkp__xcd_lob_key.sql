with

lkp as (
    select 'ACV' as lob_cd, 'Commercial Auto Voluntary Non Fleet' as lob_desc union all
    select 'AFV' as lob_cd, 'Commercial Auto Voluntary Fleet' as lob_desc union all
    select 'APV' as lob_cd, 'Personal Auto' as lob_desc union all
    select 'CP4' as lob_cd, 'Monoline Commercial Fire(Property)' as lob_desc union all
    select 'CPP' as lob_cd, 'Commercial Package Policy,(Non-discounted)' as lob_desc union all
    select 'CP3' as lob_cd, 'Commercial Package Policy(Discount)' as lob_desc union all
    select 'CR5' as lob_cd, 'Monoline Crime' as lob_desc union all
    select 'DF' as lob_cd, 'Dwelling Fire' as lob_desc union all
    select 'GL5' as lob_cd, 'Monoline General Liability' as lob_desc union all
    select 'HP' as lob_cd, 'Homeowners' as lob_desc union all
    select 'IM9' as lob_cd, 'Monoline Inland Marine' as lob_desc union all
    select 'MH' as lob_cd, 'Mobile Homeowners' as lob_desc union all
    select 'PPP' as lob_cd, 'Personal Package Policy' as lob_desc union all
    select 'UMB' as lob_cd, 'Umbrella' as lob_desc union all
    select 'WC8' as lob_cd, 'Workers Compensation' as lob_desc union all
    select 'WTC' as lob_cd, 'Watercraft' as lob_desc
),

add_lob_id as (
    select
        row_number() over() as lob_id,
        lob_cd,
        lob_desc

    from lkp
)

select *
from add_lob_id
order by lob_id