with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_des_reason',
            column_names=['bil_des_rea_typ', 'bil_des_rea_cd', 'bil_des_rea_des', 'bdr_long_des'],
            id_col_name='bil_desc_reason_id'
        )
    }}
),

desc_lkp as (
    select ' ' as bil_desc_reason_cd, 'system defined activity' as bil_desc_reason_desc
    union all select 'ACH' as bil_desc_reason_cd, 'PACS payments' as bil_desc_reason_desc
    union all select 'AMT' as bil_desc_reason_cd, 'Amount types for payable items' as bil_desc_reason_desc
    union all select 'ASO' as bil_desc_reason_cd, 'Apply Suspense Overpayment Options' as bil_desc_reason_desc
    union all select 'AST' as bil_desc_reason_cd, 'Account status' as bil_desc_reason_desc
    union all select 'BAA' as bil_desc_reason_cd, 'Amount type audits' as bil_desc_reason_desc
    union all select 'BAM' as bil_desc_reason_cd, 'Billing amount effective indicator' as bil_desc_reason_desc
    union all select 'BAS' as bil_desc_reason_cd, 'Amount type for taxes, fees, and surcharges' as bil_desc_reason_desc
    union all select 'BAT' as bil_desc_reason_cd, 'Billing item' as bil_desc_reason_desc
    union all select 'BCL' as bil_desc_reason_cd, 'Billing classes' as bil_desc_reason_desc
    union all select 'BIT' as bil_desc_reason_cd, 'Payable item for billing items' as bil_desc_reason_desc
    union all select 'BPA' as bil_desc_reason_cd, 'Payable item for audits' as bil_desc_reason_desc
    union all select 'BPS' as bil_desc_reason_cd, 'Payable item for taxes, fees, and surcharges' as bil_desc_reason_desc
    union all select 'BSC' as bil_desc_reason_cd, 'Batch Status for Cash/Credit Card' as bil_desc_reason_desc
    union all select 'BSE' as bil_desc_reason_cd, 'Batch Status for EFT Rejections' as bil_desc_reason_desc
    union all select 'BTG' as bil_desc_reason_cd, 'Agent account bill type' as bil_desc_reason_desc
    union all select 'BTP' as bil_desc_reason_cd, 'Third party bill type' as bil_desc_reason_desc
    union all select 'BTS' as bil_desc_reason_cd, 'Bill Type Display' as bil_desc_reason_desc
    union all select 'BTY' as bil_desc_reason_cd, 'Bill type other than third party or agent' as bil_desc_reason_desc
    union all select 'CAT' as bil_desc_reason_cd, 'Commission amount type' as bil_desc_reason_desc
    union all select 'CET' as bil_desc_reason_cd, 'EFT collection method' as bil_desc_reason_desc
    union all select 'CHC' as bil_desc_reason_cd, 'Hard copy collection method' as bil_desc_reason_desc
    union all select 'CIT' as bil_desc_reason_cd, 'Commission billing item' as bil_desc_reason_desc
    union all select 'CPM' as bil_desc_reason_cd, 'Check production method' as bil_desc_reason_desc
    union all select 'CPY' as bil_desc_reason_cd, 'Credit card payment' as bil_desc_reason_desc
    union all select 'CST' as bil_desc_reason_cd, 'Account cash status' as bil_desc_reason_desc
    union all select 'CTP' as bil_desc_reason_cd, 'Tape collection method' as bil_desc_reason_desc
    union all select 'CTR' as bil_desc_reason_cd, 'Transferred cash' as bil_desc_reason_desc
    union all select 'CWA' as bil_desc_reason_cd, 'Payment write-off' as bil_desc_reason_desc
    union all select 'CWM' as bil_desc_reason_cd, 'Manual payment write-off' as bil_desc_reason_desc
    union all select 'CWR' as bil_desc_reason_cd, 'Reverse payment write-off' as bil_desc_reason_desc
    union all select 'DBA' as bil_desc_reason_cd, 'Automatic disbursement' as bil_desc_reason_desc
    union all select 'DBR' as bil_desc_reason_cd, 'Manual disbursement reasons' as bil_desc_reason_desc
    union all select 'DBS' as bil_desc_reason_cd, 'Disburse status description' as bil_desc_reason_desc
    union all select 'DCR' as bil_desc_reason_cd, 'Match discrepancy types' as bil_desc_reason_desc
    union all select 'DNC' as bil_desc_reason_cd, 'NSF (non-sufficient funds) forgiven' as bil_desc_reason_desc
    union all select 'DRV' as bil_desc_reason_cd, 'Reversed disbursement due to stop pay or void' as bil_desc_reason_desc
    union all select 'DSO' as bil_desc_reason_cd, 'Match discrepancy code on unmatched items' as bil_desc_reason_desc
    union all select 'DSP' as bil_desc_reason_cd, 'Cash disposition types' as bil_desc_reason_desc
    union all select 'EAT' as bil_desc_reason_cd, 'EFT bank account type' as bil_desc_reason_desc
    union all select 'EDT' as bil_desc_reason_cd, 'Date Edits' as bil_desc_reason_desc
    union all select 'ENS' as bil_desc_reason_cd, 'Reversal of EFT payment due to NSF(non-sufficient funds' as bil_desc_reason_desc
    union all select 'EPR' as bil_desc_reason_cd, 'EFT prenote rejection' as bil_desc_reason_desc
    union all select 'ERP' as bil_desc_reason_cd, 'Reversal of EFT payment due to other than NSF(non-sufficient funds' as bil_desc_reason_desc
    union all select 'ESM' as bil_desc_reason_cd, 'EFT secondary collection method' as bil_desc_reason_desc
    union all select 'EST' as bil_desc_reason_cd, 'EFT Status' as bil_desc_reason_desc
    union all select 'FQY' as bil_desc_reason_cd, 'Frequency' as bil_desc_reason_desc
    union all select 'GRV' as bil_desc_reason_cd, 'Agent statement entry review status' as bil_desc_reason_desc
    union all select 'GST' as bil_desc_reason_cd, 'Agent account status' as bil_desc_reason_desc
    union all select 'IST' as bil_desc_reason_cd, 'Installment Invoice Status' as bil_desc_reason_desc
    union all select 'LOB' as bil_desc_reason_cd, 'Lines of business' as bil_desc_reason_desc
    union all select 'MCH' as bil_desc_reason_cd, 'Match reasons' as bil_desc_reason_desc
    union all select 'MCT' as bil_desc_reason_cd, 'Match type' as bil_desc_reason_desc
    union all select 'PID' as bil_desc_reason_cd, 'Processed Indicator' as bil_desc_reason_desc
    union all select 'PRV' as bil_desc_reason_cd, 'Payment reversal codes' as bil_desc_reason_desc

),

renamed as (
    select
        bil_desc_reason_id,
        bil_des_rea_typ as bil_desc_reason_type,
        bil_des_rea_cd as bil_desc_reason_cd,
        bil_des_rea_des as bil_desc_reason_desc,
        bdr_long_des as bil_desc_reason_long_desc,
        generated_at
    from lkp
),

join_desc as (
    select
        r.bil_desc_reason_id,
        r.bil_desc_reason_type,
        r.bil_desc_reason_cd,
        d.bil_desc_reason_desc,
        r.bil_desc_reason_long_desc,
        r.generated_at

    from renamed r
    left join desc_lkp d 
        on r.bil_desc_reason_cd = d.bil_desc_reason_cd

),

-- 6/18/2025: I noticed that either the long description or the "regular" discription is populated, but never both.
-- I will coalesce the two columns to ensure that we have a description available, and are not maintaining a bunch 
-- of null/blank/-9 values.
coalesce_descriptions as (
    select 
        bil_desc_reason_id,
        bil_desc_reason_type,
        bil_desc_reason_cd,
        coalesce(
            case
                when bil_desc_reason_long_desc = '-9' then bil_desc_reason_desc
                else bil_desc_reason_long_desc
            end,
            'Missing'
        ) as bil_desc_reason_desc,
        generated_at

    from join_desc
),

-- 6/18/25: Recoding the descriptions related to prem issued tx
recode_prem_issued_tx as (
    with

    pit_s as (
        select *
        from coalesce_descriptions
        where trim(lower(bil_desc_reason_desc)) like '%prem issued%'
    ),

    others as (
        select *
        from coalesce_descriptions
        where bil_desc_reason_id not in (
            select bil_desc_reason_id
            from pit_s
        )
    ),

    recoded as (
        select
            bil_desc_reason_id,
            bil_desc_reason_type,
            bil_desc_reason_cd,
            case
                when trim(lower(bil_desc_reason_desc)) like '%in%from%' then 'Prem Issued Tax/Tarrif - In From Account'
                when trim(lower(bil_desc_reason_desc)) like '%out%to%' then 'Prem Issued Tax/Tarrif - Out To Account'
                else bil_desc_reason_desc
            end as bil_desc_reason_desc,
            generated_at
        from pit_s
        union all
        select *
        from others
    )

    select * from recoded
)

select *
from recode_prem_issued_tx
order by bil_desc_reason_id