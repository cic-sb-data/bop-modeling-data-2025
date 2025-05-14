with

raw as (
    SELECT 'ASB' as bil_act_desc_code, 'Agent Statement balanced' as bil_act_desc UNION ALL
    SELECT 'BCC' as bil_act_desc_code, 'Bill class change' as bil_act_desc UNION ALL
    SELECT 'BTA' as bil_act_desc_code, 'Account bill type change' as bil_act_desc UNION ALL
    SELECT 'BTC' as bil_act_desc_code, 'Bill type change' as bil_act_desc UNION ALL
    SELECT 'BTT' as bil_act_desc_code, 'Bill account transfer' as bil_act_desc UNION ALL
    SELECT 'CM' as bil_act_desc_code, 'Manual payment write-off' as bil_act_desc UNION ALL
    SELECT 'CMC' as bil_act_desc_code, 'Collection method change' as bil_act_desc UNION ALL
    SELECT 'CMR' as bil_act_desc_code, 'Reverse manual payment write-off' as bil_act_desc UNION ALL
    SELECT 'CR' as bil_act_desc_code, 'Credit into cash' as bil_act_desc UNION ALL
    SELECT 'CS' as bil_act_desc_code, 'Cash from credit' as bil_act_desc UNION ALL
    SELECT 'CST' as bil_act_desc_code, 'Company statement' as bil_act_desc UNION ALL
    SELECT 'DBR' as bil_act_desc_code, 'Disburse manual' as bil_act_desc UNION ALL
    SELECT 'DMR' as bil_act_desc_code, 'Reverse manual disburse' as bil_act_desc UNION ALL
    SELECT 'IDC' as bil_act_desc_code, 'Statement due date change' as bil_act_desc UNION ALL
    SELECT 'OPY' as bil_act_desc_code, 'Balance write-off overpay' as bil_act_desc UNION ALL
    SELECT 'PLN' as bil_act_desc_code, 'Collection plan change' as bil_act_desc UNION ALL
    SELECT 'PNC' as bil_act_desc_code, 'Payor name/address change' as bil_act_desc UNION ALL
    SELECT 'RC' as bil_act_desc_code, 'Reverse payment - company mistake' as bil_act_desc UNION ALL
    SELECT 'RDC' as bil_act_desc_code, 'Reference date change' as bil_act_desc UNION ALL
    SELECT 'RN' as bil_act_desc_code, 'Reverse payment - nsf' as bil_act_desc UNION ALL
    SELECT 'RP' as bil_act_desc_code, 'Reverse payment- protested' as bil_act_desc UNION ALL
    SELECT 'RPL' as bil_act_desc_code, 'Reporting level change' as bil_act_desc UNION ALL
    SELECT 'SDC' as bil_act_desc_code, 'Start date change' as bil_act_desc UNION ALL
    SELECT 'STT' as bil_act_desc_code, 'Statement' UNION ALL
    SELECT 'UPY' as bil_act_desc_code, 'Balance underpay' as bil_act_desc UNION ALL
    SELECT 'REI' as bil_act_desc_code, 'Request for Auto Reinstatement' as bil_act_desc UNION ALL
    SELECT 'NRD' as bil_act_desc_code, 'No Rescind due to Postmark Date' as bil_act_desc UNION ALL
    SELECT 'NRE' as bil_act_desc_code, 'No Auto Reinstatement Requested' as bil_act_desc UNION ALL
    SELECT 'CIA' as bil_act_desc_code, 'Corrected Invoice' as bil_act_desc UNION ALL
    SELECT 'RIF' as bil_act_desc_code, 'Renewal Inforce' as bil_act_desc UNION ALL
    SELECT 'CCT' as bil_act_desc_code, 'Credit Card Tape Processed' as bil_act_desc
),

add_desc_key as (
    select 
        row_number() over() as bil_act_desc_key,
        *
    from raw
)

select *
from add_desc_key
