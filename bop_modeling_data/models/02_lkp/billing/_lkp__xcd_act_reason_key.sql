with 

raw as (
    SELECT 'Spaces' AS bil_act_reason_type_cd, 'system defined activity' as bil_act_reason_type UNION ALL
    SELECT 'ACH' AS bil_act_reason_type_cd, 'PACS payments' as bil_act_reason_type UNION ALL
    SELECT 'AMT' AS bil_act_reason_type_cd, 'Amount types for payable items' as bil_act_reason_type UNION ALL
    SELECT 'ASO' AS bil_act_reason_type_cd, 'Apply Suspense Overpayment Options' as bil_act_reason_type UNION ALL
    SELECT 'AST' AS bil_act_reason_type_cd, 'Account status' as bil_act_reason_type UNION ALL
    SELECT 'BAA' AS bil_act_reason_type_cd, 'Amount type audits' as bil_act_reason_type UNION ALL
    SELECT 'BAM' AS bil_act_reason_type_cd, 'Billing amount effective indicator' as bil_act_reason_type UNION ALL
    SELECT 'BAS' AS bil_act_reason_type_cd, 'Amount type for taxes, fees, and surcharges' as bil_act_reason_type UNION ALL
    SELECT 'BAT' AS bil_act_reason_type_cd, 'Billing item' as bil_act_reason_type UNION ALL
    SELECT 'BCL' AS bil_act_reason_type_cd, 'Billing classes' as bil_act_reason_type UNION ALL
    SELECT 'BIT' AS bil_act_reason_type_cd, 'Payable item for billing items' as bil_act_reason_type UNION ALL
    SELECT 'BPA' AS bil_act_reason_type_cd, 'Payable item for audits' as bil_act_reason_type UNION ALL
    SELECT 'BPS' AS bil_act_reason_type_cd, 'Payable item for taxes, fees, and surcharges' as bil_act_reason_type UNION ALL
    SELECT 'BSC' AS bil_act_reason_type_cd, 'Batch Status for Cash/Credit Card' as bil_act_reason_type UNION ALL
    SELECT 'BSE' AS bil_act_reason_type_cd, 'Batch Status for EFT Rejections' as bil_act_reason_type UNION ALL
    SELECT 'BTG' AS bil_act_reason_type_cd, 'Agent account bill type' as bil_act_reason_type UNION ALL
    SELECT 'BTP' AS bil_act_reason_type_cd, 'Third party bill type' as bil_act_reason_type UNION ALL
    SELECT 'BTS' AS bil_act_reason_type_cd, 'Bill Type Display' as bil_act_reason_type UNION ALL
    SELECT 'BTY' AS bil_act_reason_type_cd, 'Bill type other than third party or agent' as bil_act_reason_type UNION ALL
    SELECT 'CAT' AS bil_act_reason_type_cd, 'Commission amount type' as bil_act_reason_type UNION ALL
    SELECT 'CET' AS bil_act_reason_type_cd, 'EFT collection method' as bil_act_reason_type UNION ALL
    SELECT 'CHC' AS bil_act_reason_type_cd, 'Hard copy collection method' as bil_act_reason_type UNION ALL
    SELECT 'CIT' AS bil_act_reason_type_cd, 'Commission billing item' as bil_act_reason_type UNION ALL
    SELECT 'CPM' AS bil_act_reason_type_cd, 'Check production method' as bil_act_reason_type UNION ALL
    SELECT 'CPY' AS bil_act_reason_type_cd, 'Credit card payment' as bil_act_reason_type UNION ALL
    SELECT 'CST' AS bil_act_reason_type_cd, 'Account cash status' as bil_act_reason_type UNION ALL
    SELECT 'CTP' AS bil_act_reason_type_cd, 'Tape collection method' as bil_act_reason_type UNION ALL
    SELECT 'CTR' AS bil_act_reason_type_cd, 'Transferred cash' as bil_act_reason_type UNION ALL
    SELECT 'CWA' AS bil_act_reason_type_cd, 'Payment write-off' as bil_act_reason_type UNION ALL
    SELECT 'CWM' AS bil_act_reason_type_cd, 'Manual payment write-off' as bil_act_reason_type UNION ALL
    SELECT 'CWR' AS bil_act_reason_type_cd, 'Reverse payment write-off' as bil_act_reason_type UNION ALL
    SELECT 'DBA' AS bil_act_reason_type_cd, 'Automatic disbursement' as bil_act_reason_type UNION ALL
    SELECT 'DBR' AS bil_act_reason_type_cd, 'Manual disbursement reasons' as bil_act_reason_type UNION ALL
    SELECT 'DBS' AS bil_act_reason_type_cd, 'Disburse status reason_activity_desc_type' UNION ALL
    SELECT 'DCR' AS bil_act_reason_type_cd, 'Match discrepancy types' as bil_act_reason_type UNION ALL
    SELECT 'DNC' AS bil_act_reason_type_cd, 'NSF (non-sufficient funds) forgiven' as bil_act_reason_type UNION ALL
    SELECT 'DRV' AS bil_act_reason_type_cd, 'Reversed disbursement due to stop pay or void' as bil_act_reason_type UNION ALL
    SELECT 'DSO' AS bil_act_reason_type_cd, 'Match discrepancy code on unmatched items' as bil_act_reason_type UNION ALL

    SELECT 'DSP' as bil_act_reason_type_cd, 'Cash disposition types' as bil_act_reason_type UNION ALL
    SELECT 'EAT' as bil_act_reason_type_cd, 'EFT bank account type' as bil_act_reason_type UNION ALL
    SELECT 'EDT' as bil_act_reason_type_cd, 'Date Edits' as bil_act_reason_type UNION ALL
    SELECT 'ENS' as bil_act_reason_type_cd, 'Reversal of EFT payment due to NSF(non-sufficient funds)' as bil_act_reason_type UNION ALL
    SELECT 'EPR' as bil_act_reason_type_cd, 'EFT prenote rejection' as bil_act_reason_type UNION ALL
    SELECT 'ERP' as bil_act_reason_type_cd, 'Reversal of EFT payment due to other than NSF(non-sufficient funds)' as bil_act_reason_type UNION ALL
    SELECT 'ESM' as bil_act_reason_type_cd, 'EFT secondary collection method' as bil_act_reason_type UNION ALL
    SELECT 'EST' as bil_act_reason_type_cd, 'EFT Status' as bil_act_reason_type UNION ALL
    SELECT 'FQY' as bil_act_reason_type_cd, 'Frequency' as bil_act_reason_type UNION ALL
    SELECT 'GRV' as bil_act_reason_type_cd, 'Agent statement entry review status' as bil_act_reason_type UNION ALL
    SELECT 'GST' as bil_act_reason_type_cd, 'Agent account status' as bil_act_reason_type UNION ALL
    SELECT 'IST' as bil_act_reason_type_cd, 'Installment Invoice Status' as bil_act_reason_type UNION ALL
    SELECT 'LOB' as bil_act_reason_type_cd, 'Lines of business' as bil_act_reason_type UNION ALL
    SELECT 'MCH' as bil_act_reason_type_cd, 'Match reasons' as bil_act_reason_type UNION ALL
    SELECT 'MCT' as bil_act_reason_type_cd, 'Match type' as bil_act_reason_type UNION ALL
    SELECT 'PID' as bil_act_reason_type_cd, 'Processed Indicator' as bil_act_reason_type UNION ALL
    SELECT 'PRV' as bil_act_reason_type_cd, 'Payment reversal codes' as bil_act_reason_type UNION ALL
    SELECT 'PST' as bil_act_reason_type_cd, 'Policy status' as bil_act_reason_type UNION ALL
    SELECT 'PTS' as bil_act_reason_type_cd, 'System Plans Identifier Type' as bil_act_reason_type UNION ALL
    SELECT 'PYS' as bil_act_reason_type_cd, 'Payment sources' as bil_act_reason_type UNION ALL
    SELECT 'PYT' as bil_act_reason_type_cd, 'Cash payment types' as bil_act_reason_type UNION ALL
    SELECT 'QSP' as bil_act_reason_type_cd, 'Quote Scheduling Policy/Account' as bil_act_reason_type UNION ALL
    SELECT 'RAD' as bil_act_reason_type_cd, 'Receipt Activity Display' as bil_act_reason_type UNION ALL
    SELECT 'RAH' as bil_act_reason_type_cd, 'Receipt Activity History' as bil_act_reason_type UNION ALL
    SELECT 'RBA' as bil_act_reason_type_cd, 'Resume billing and follow-up automatic' as bil_act_reason_type UNION ALL
    SELECT 'RBM' as bil_act_reason_type_cd, 'Resume billing and follow-up manual' as bil_act_reason_type UNION ALL
    SELECT 'RCT' as bil_act_reason_type_cd, 'Receipt reason_activity_desc_type' UNION ALL
    SELECT 'REV' as bil_act_reason_type_cd, 'Receipts processing verify codes' as bil_act_reason_type UNION ALL
    SELECT 'REX' as bil_act_reason_type_cd, 'Overpayment' as bil_act_reason_type UNION ALL
    SELECT 'RFA' as bil_act_reason_type_cd, 'Resume follow-up automatic' as bil_act_reason_type UNION ALL
    SELECT 'RFM' as bil_act_reason_type_cd, 'Resume follow-up manual' as bil_act_reason_type UNION ALL
    SELECT 'RSA' as bil_act_reason_type_cd, 'Resume billing automatic' as bil_act_reason_type UNION ALL
    SELECT 'RSC' as bil_act_reason_type_cd, 'Account cash status, Resume' as bil_act_reason_type UNION ALL
    SELECT 'RSM' as bil_act_reason_type_cd, 'Resume billing manual' as bil_act_reason_type UNION ALL
    SELECT 'RVD' as bil_act_reason_type_cd, 'Reversed disbursement due to resuspend or reversal' as bil_act_reason_type UNION ALL
    SELECT 'RW1' as bil_act_reason_type_cd, 'Rev prm w/o due to BPC or CR' as bil_act_reason_type UNION ALL
    SELECT 'SBC' as bil_act_reason_type_cd, 'Account cash status, Suspend' as bil_act_reason_type UNION ALL
    SELECT 'SBF' as bil_act_reason_type_cd, 'Suspense billing and follow-up' as bil_act_reason_type UNION ALL
    SELECT 'SBI' as bil_act_reason_type_cd, 'Suspense billing' as bil_act_reason_type UNION ALL
    SELECT 'SBO' as bil_act_reason_type_cd, 'Suspense follow-up' as bil_act_reason_type UNION ALL
    SELECT 'SCA' as bil_act_reason_type_cd, 'Service Charge Action' as bil_act_reason_type UNION ALL
    SELECT 'SCT' as bil_act_reason_type_cd, 'Service Charge Type' as bil_act_reason_type UNION ALL
    SELECT 'SUS' as bil_act_reason_type_cd, 'Suspense reasons' as bil_act_reason_type UNION ALL
    SELECT 'TRF' as bil_act_reason_type_cd, 'Policy premium transfer reasons' as bil_act_reason_type UNION ALL
    SELECT 'TST' as bil_act_reason_type_cd, 'Third party status' as bil_act_reason_type UNION ALL
    SELECT 'UIT' as bil_act_reason_type_cd, 'Unidentified Cash Identifier Type' as bil_act_reason_type UNION ALL
    SELECT 'U%%' as bil_act_reason_type_cd, 'Customer defined activity codes' as bil_act_reason_type UNION ALL
    SELECT 'WPA' as bil_act_reason_type_cd, 'Write off of scheduled amounts automatic' as bil_act_reason_type UNION ALL
    SELECT 'WPG' as bil_act_reason_type_cd, 'Agent statement balance write off' as bil_act_reason_type UNION ALL
    SELECT 'WPI' as bil_act_reason_type_cd, 'Third party write off' as bil_act_reason_type UNION ALL
    SELECT 'WPR' as bil_act_reason_type_cd, 'Write off of scheduled amounts manual' as bil_act_reason_type UNION ALL
    SELECT 'WRR' as bil_act_reason_type_cd, 'Write-off reversals manual and automatic' as bil_act_reason_type UNION ALL
    SELECT 'W01' as bil_act_reason_type_cd, 'Full pay service charge write off' as bil_act_reason_type
), 

add_bil_act_reason_type_key as (
    select 
        row_number() over() as activity_reason_key,
        *

    from raw
)

select *
from add_bil_act_reason_type_key
