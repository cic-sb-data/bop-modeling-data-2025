with 

-- ======= DECLARATIONS =============================================

-- load all lob policyxml tables
bop_policyxml as (
    select * 
    from {{ ref('stg__bop_policy_xml') }}
),

auto_filtered as (
    select *
    from {{ ref('stg__auto_policy_xml') }}
    where view_id = 0
),

wc_filtered as (
    select *
    from {{ ref('stg__wc_policy_xml') }}
    where view_id = 0
),

umb_filtered as (
    select *
    from {{ ref('stg__umb_policy_xml') }}
    where view_id = 0
),

-- load the tbl quotes 
tblquotes as (
    select
        submission__quote_numb,
        client_id

    from
        {{ ref('stg__tbl_quotes_hit_ratio') }}

    where
        view_id = 0
),

-- filter the lob tables for view_id = 0
bop_filtered as (
    select distinct bop_policyxml.* 
    from bop_policyxml
    left join tblquotes
    on bop_policyxml.quote_numb = tblquotes.submission__quote_numb
    where bop_policyxml.view_id = 0
),

-- not clear to me whether or not this is used
bop_on_main as (
    select distinct
        bop_policyxml.*,
        tblquotes.client_id

    from
        bop_policyxml
    left join
        tblquotes
    on
        bop_policyxml.quote_numb = tblquotes.submission__quote_numb

    where
        bop_policyxml.rated = 'True'
        and bop_policyxml.rated_successfully = 1
),

-- ======== NAME SCRIPT ==============================================
-- get all the insureds & quotes from bop
name__all_bop as (
    select distinct
        epp_id,
        quote_numb,
        lower(insured__name) as insured_name,
        trim(replace(insured_address, 'Mailing Address: ', '')) as insured_address, 
        lower(acct__first_named_insured) as first_named_insured,
        'bop' as lob

    from
        bop_filtered

    where
        epp_id > 0
),

-- get all the insureds & quotes from auto

name__all_auto as (
     select distinct
        epp_id,
        quote_numb,
        lower(insured__name) as insured_name,
        trim(replace(insured_address, 'Mailing Address: ', '')) as insured_address, 
        lower(acct__first_named_insured) as first_named_insured,
        'auto' as lob

    from
        auto_filtered

    where
        epp_id > 0
),

-- get all the insureds & quotes from wc
name__all_wc as (
    select distinct
        epp_id,
        quote_numb,
        lower(insured__name) as insured_name,
        trim(replace(insured_address, 'Mailing Address: ', '')) as insured_address, 
        lower(acct__first_named_insured) as first_named_insured,
        'wc' as lob

    from
        wc_filtered

    where
        epp_id > 0
),

-- get all the insureds & quotes from umb
name__all_umb as (
    select distinct
        epp_id,
        quote_numb,
        lower(insured__name) as insured_name,
        trim(replace(insured_address, 'Mailing Address: ', '')) as insured_address, 
        lower(acct__first_named_insured) as first_named_insured,
        'umb' as lob

    from
        umb_filtered

    where
        epp_id > 0
),

name__eppid_list as (
    with
    
    -- combine the insureds & quotes into a single table
    unsorted as (
        select * from name__all_bop
        union
        select * from name__all_auto
        union 
        select * from name__all_wc
        union
        select * from name__all_umb
    ),

    -- sort the values and dedup
    sorted as (
        select distinct *
        from unsorted
        order by epp_id
    ),

    -- add counts of insured name
    add_name_counts as (
        select 
            epp_id,
            any_value(quote_numb),
            any_value(insured_name),
            any_value(insured_address),
            any_value(first_named_insured),
            any_value(lob),
            count(distinct insured_name) as name_count
        from sorted
        where epp_id > 0
        group by epp_id
    )

    select * from add_name_counts
),

name__table as (
    select distinct
        eppid.epp_id,
        coalesce(
            bop.quote_numb,
            auto.quote_numb,
            wc.quote_numb,
            umb.quote_numb
        ) as quote_numb,
        upper(bop.insured_name) as name__bop,
        upper(auto.insured_name) as name__auto,
        upper(wc.insured_name) as name__wc,
        upper(umb.insured_name) as name__umb,
        upper(bop.first_named_insured) as name__account

    from
        name__eppid_list as eppid
    left join 
        name__all_bop as bop
    on
        eppid.epp_id = bop.epp_id
    
    left join 
        name__all_auto as auto
    on
        eppid.epp_id = auto.epp_id

    left join
        name__all_wc as wc
    on
        eppid.epp_id = wc.epp_id

    left join
        name__all_umb as umb
    on
        eppid.epp_id = umb.epp_id
),

-- ==== ADDRESS =================================================
address__table as (
    with
    
    -- list of epp_ids to filter on
    eppids as (
        select distinct epp_id from name__eppid_list 
    ),

    -- epp_id, address, lob for each of lobs:
    bop as (
        select distinct epp_id, insured_address, lob
        from name__bop
        where epp_id in (from eppids)
    ),

    auto as (
        select distinct epp_id, insured_address, lob
        from name__auto
        where epp_id in (from eppids)
    ),

    wc as (
        select distinct epp_id, insured_address, lob
        from name__wc
        where epp_id in (from eppids)
    ),

    umb as (
        select distinct epp_id, insured_address, lob
        from name__umb
        where epp_id in (from eppids)
    ),

    -- combine lob tables into one mega-table of addresses by epp_id
    appended as (
        select * from bop
        union
        select * from auto
        union
        select * from wc
        union
        select * from umb
    ),

    -- get epp ids with > 1 address
    get_address_counts as (
        select distinct
            epp_id,
            count(distinct insured_address) as address_count
        from address__tall
        group by epp_id
    ),

    -- eppids and insured names for epp_ids with >1 address
    more_than_one_address as (
        select 
            t.epp_id,
            -- adding insured name here to keep the next
            -- step from having 8 joins
            coalesce(
                name__bop.insured_name,
                name__auto.insured_name,
                name__wc.insured_name,
                name__umb.insured_name
            ) as insured_name
        from get_address_counts t
        left join name__bop
            on t.epp_id = name__bop.epp_id
        left join name__auto
            on t.epp_id = name__auto.epp_id
        left join name__wc
            on t.epp_id = name__wc.epp_id
        left join name__umb
            on t.epp_id = name__umb.epp_id
        where t.address_count > 1
    )
    
    -- add column names for the lob addresses
    get_addresses_by_lob as (
        select distinct
            more_than_one_address.epp_id,
            more_than_one_address.insured_name,
            bop.insured_address as address_bop,
            auto.insured_address as address_auto,
            wc.insured_address as address_wc,
            umb.insured_address as address_umb

        from
            more_than_one_address
        left join bop
            on more_than_one_address.epp_id = bop.epp_id
        left join auto
            on more_than_one_address.epp_id = auto.epp_id
        left join wc
            on more_than_one_address.epp_id = wc.epp_id
        left join umb
            on more_than_one_address.epp_id = umb.epp_id
    )

    select * from get_addresses_by_lob

)


select * from address__table

