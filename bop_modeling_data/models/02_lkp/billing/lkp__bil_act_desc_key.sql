with

raw as (
    SELECT 'ASB' as bil_act_desc_cd, 'Agent Statement balanced' as bil_act_desc UNION ALL
    SELECT 'BCC' as bil_act_desc_cd, 'Bill class change' as bil_act_desc UNION ALL
    SELECT 'BTA' as bil_act_desc_cd, 'Account bill type change' as bil_act_desc UNION ALL
    SELECT 'BTC' as bil_act_desc_cd, 'Bill type change' as bil_act_desc UNION ALL
    SELECT 'BTT' as bil_act_desc_cd, 'Bill account transfer' as bil_act_desc UNION ALL
    SELECT 'CM' as bil_act_desc_cd, 'Manual payment write-off' as bil_act_desc UNION ALL
    SELECT 'CMC' as bil_act_desc_cd, 'Collection method change' as bil_act_desc UNION ALL
    SELECT 'CMR' as bil_act_desc_cd, 'Reverse manual payment write-off' as bil_act_desc UNION ALL
    SELECT 'CR' as bil_act_desc_cd, 'Credit into cash' as bil_act_desc UNION ALL
    SELECT 'CS' as bil_act_desc_cd, 'Cash from credit' as bil_act_desc UNION ALL
    SELECT 'CST' as bil_act_desc_cd, 'Company statement' as bil_act_desc UNION ALL
    SELECT 'DBR' as bil_act_desc_cd, 'Disburse manual' as bil_act_desc UNION ALL
    SELECT 'DMR' as bil_act_desc_cd, 'Reverse manual disburse' as bil_act_desc UNION ALL
    SELECT 'IDC' as bil_act_desc_cd, 'Statement due date change' as bil_act_desc UNION ALL
    SELECT 'OPY' as bil_act_desc_cd, 'Balance write-off overpay' as bil_act_desc UNION ALL
    SELECT 'PLN' as bil_act_desc_cd, 'Collection plan change' as bil_act_desc UNION ALL
    SELECT 'PNC' as bil_act_desc_cd, 'Payor name/address change' as bil_act_desc UNION ALL
    SELECT 'RC' as bil_act_desc_cd, 'Reverse payment - company mistake' as bil_act_desc UNION ALL
    SELECT 'RDC' as bil_act_desc_cd, 'Reference date change' as bil_act_desc UNION ALL
    SELECT 'RN' as bil_act_desc_cd, 'Reverse payment - nsf' as bil_act_desc UNION ALL
    SELECT 'RP' as bil_act_desc_cd, 'Reverse payment- protested' as bil_act_desc UNION ALL
    SELECT 'RPL' as bil_act_desc_cd, 'Reporting level change' as bil_act_desc UNION ALL
    SELECT 'SDC' as bil_act_desc_cd, 'Start date change' as bil_act_desc UNION ALL
    SELECT 'STT' as bil_act_desc_cd, 'Statement' UNION ALL
    SELECT 'UPY' as bil_act_desc_cd, 'Balance underpay' as bil_act_desc UNION ALL
    SELECT 'REI' as bil_act_desc_cd, 'Request for Auto Reinstatement' as bil_act_desc UNION ALL
    SELECT 'NRD' as bil_act_desc_cd, 'No Rescind due to Postmark Date' as bil_act_desc UNION ALL
    SELECT 'NRE' as bil_act_desc_cd, 'No Auto Reinstatement Requested' as bil_act_desc UNION ALL
    SELECT 'CIA' as bil_act_desc_cd, 'Corrected Invoice' as bil_act_desc UNION ALL
    SELECT 'RIF' as bil_act_desc_cd, 'Renewal Inforce' as bil_act_desc UNION ALL
    SELECT 'CCT' as bil_act_desc_cd, 'Credit Card Tape Processed' as bil_act_desc
),

add_desc_key as (
    select 
        row_number() over() as bil_act_desc_key,
        *
    from raw
)

select *
from add_desc_key
