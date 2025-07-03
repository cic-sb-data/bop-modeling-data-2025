with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_policy_trm',
            column_names=['bil_pol_status_cd'],
            id_col_name='bil_pol_status_id'
        )
    }}
),

renamed as (
    select
        bil_pol_status_id,
        bil_pol_status_cd,
        case
            when bil_pol_status_cd='A' then 'Cancelled subject to audit'
            when bil_pol_status_cd='B' then 'Suspend Billing / Follow-up'
            when bil_pol_status_cd='C' then 'Cancelled'
            when bil_pol_status_cd='D' then 'Cancelled for Reissued'
            when bil_pol_status_cd='F' then 'Flat Cancellation'
            when bil_pol_status_cd='G' then 'Flat Cancelled for Reissued'
            when bil_pol_status_cd='L' then 'Suspend Follow-up'
            when bil_pol_status_cd='N' then 'Pending cancel due to NSF'
            when bil_pol_status_cd='O' then 'Open'
            when bil_pol_status_cd='P' then 'Pending Cancellation'
            when bil_pol_status_cd='Q' then 'Quote'
            when bil_pol_status_cd='R' then 'Cancelled'
            when bil_pol_status_cd='S' then 'Suspend Billing'
            when bil_pol_status_cd='T' then 'Transferred'
            when bil_pol_status_cd='W' then 'Cancelled for re-write'
            when bil_pol_status_cd='X' then 'Closed'
            when bil_pol_status_cd='Z' then 'Pending transfer (temporary values)'
            when bil_pol_status_cd='1' then 'Pending transfer with payments to be applied (temporary value)'
            when bil_pol_status_cd='2' then 'Pending transfer with payments to be held (temporary value)'
            else 'Unknown billing policy status code: ' || bil_pol_status_cd
        end as bil_pol_status_desc,
        generated_at
    from lkp
)

select *
from renamed