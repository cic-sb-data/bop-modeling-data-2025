with

raw as (
    select 
        'gl' as lob,
        cfxmlid as cfxml_id,
        coveragecomponentagreementid as cover_component_agreement_id,

        cfxmlprevid as cfxml_prev_id,
        transactionsequencenumber as trans_sequence_numb,
        try_cast(policynumber as uinteger) as policy_numb,
        {{ recode__company_code('companycode') }} as company_numb,
        policysymbol as policy_sym,
        try_cast(policyeffectivedate as date) as policy_eff_date,
        try_cast(policyexpirationdate as date) as policy_exp_date,
        try_cast(statisticalpolicymodulenumber as uinteger) as policy_module,
        try_cast(quotenumber as ubigint) as quote_numb,
        try_cast(quoteversionnumber as uinteger) as quote_version_numb,
        try_cast(firstpolicyeffectivedate as date) as first_policy_eff_date,
        crossreferencenumber as cross_ref_numb,
        firstinsuredlegalentitytype as first_insured_legal_entity_type,
        firstinsuredfullname as first_insured_full_name,
        insured_address_city as insured_city,
        insured_address_county as insured_county,
        insured_address_zip_5 as insured_zip_5,
        insured_address_zip_extension as insured_zip_extension,
        insured_address_state as insured_state,
        insured_address_latitude as insured_latitude,
        insured_address_longitude as insured_longitude,
        try_cast(insured_address_verified_ind as utinyint) as is_insured_address_verified,
        policyproducttypedescription as policy_product_type_desc,
        packagetypedescription as package_type_desc,
        risktypecode as risk_type_cd,
        risktypedescription as risk_type_desc,
        try_cast(customer_care_center_ind as utinyint) as is_cccc,
        try_cast(agencynumber as uinteger) as agy_numb,
        agencyfullname as agy_name,
        agencystatecode as agy_state,
        try_cast(firstinsurednaicscode as ubigint) as first_insured_naics_cd,
        try_cast(naicsoverriddenindicator as utinyint) as is_naics_overridden,
        try_cast(naicsvalidatedindicator as utinyint) as is_naics_validated,
        primaryriskstatecode as primary_risk_state,
        billingmethoddescription as billing_method_desc,
        paymentmethoddescription as pmt_method_desc,
        premiumpaymentplandescription as premium_pmt_plan_desc,
        packagecommissionpercent as package_commission_pct,
        transactiontypedescription as trans_type_desc,
        transactiontypesourcedescription as trans_type_source_desc,
        try_cast(transactioneffectivedate as date) as trans_eff_date,
        try_cast(transactionexpirationdate as date) as trans_exp_date,
        transactionstatusdescription as trans_status_desc,
        transactionprocesseddatetime as trans_processed_at,
        try_cast(trans_out_of_seq_ind as utinyint) as is_trans_out_of_sequence,
        policystatusdescription as policy_status_desc,
        try_cast(imagenumber as ubigint) as image_numb,
        try_cast(imageeffectivedate as date) as image_eff_date,
        try_cast(imageexpirationdate as date) as image_exp_date,
        try_cast(numberofexposuredays as uinteger) as n_exposure_days,

        try_cast(premises_hazard_grade as uinteger) as premops_hazard_grade,
        try_cast(products_hazard_grade as uinteger) as products_hazard_grade,

        generalaggregatelimitamount as agg_limit,
        occurrencelimitamount as occ_limit,
        productaggregatelimitamount as products_agg_limit,
        medicalpaymentslimitamount as med_pay_limit,

        try_cast(policy_location_count as uinteger) as n_locations_on_policy,
        try_cast(policy_class_count as uinteger) as n_classes_on_policy,
        try_cast(policy_class_count_not_if_any as uinteger) as n_classes_not_if_any_on_policy,

        coveragestate as coverage_state,
        statenumber as state_numb,
        locationnumber as location_numb,
        territory as terr,
        territory_name as terr_name,
        zip_code as zip,
        location_zipcode as location_zip,
        expense_mod as expense_mod,
        experience_mod as experience_mod,
        lpdp as lpdp,
        other_mod as other_mod,
        package_mod as package_mod,
        schedule_mod as schedule_mod,
        medical_malpractice_total_rmf as med_mal_tmf,
        state_total_rmf as state_tmf,
        class_total_rmf as class_tmf,
        risk_tier_description as risk_tier_desc,


        try_cast(location_class_count as uinteger) as n_classes_at_loc,
        try_cast(location_class_count_not_if_any as uinteger) as n_classes_not_if_any_at_loc,
        
        coverageratingversionidentifier as cover_rating_version_id,

        try_cast(premisesratebook1 as uinteger) as premops_ratebook,
        try_cast(productcompratebook1 as uinteger) as products_ratebook,

        classificationcode as class_code,
        classificationdescription as class_desc,
        try_cast(class_description_overridden_ind as utinyint) as is_class_desc_overridden,
        cincipak_class_code as cincipak_class_code,
        type_of_rating as rating_type,
        exposurebasisdescription as exposure_basis_desc,
        try_cast(premisesarateindicator as utinyint) as is_premops_arated,
        try_cast(ifanyexposureindicator as utinyint) as has_if_any_exposure,
        try_cast(premisesinclusionindicator as utinyint) as is_premises_included,
        try_cast(productsarateindicator as utinyint) as is_products_arated,
        try_cast(productsinclusionindicator as utinyint) as is_products_included,

        premisespddeductibleamount as premops_deductible,
        productspddeductibleamount as products_deductible,
        premisescombineddeductibleamount as prempos_combined_deductible,
        productscombineddeductibleamount as products_combined_deductible,
        premisesbideductibleamount as premops_bi_deductible,
        productsbideductibleamount as products_bi_deductible,
        deductibleleveldescription as deductible_level_desc,

        exclusionforproductsdescription as exclusion_for_products_desc,

        premisesexposurequantity as premops_exposure,
        productsexposurequantity as products_exposure,

        annualpremiumamount as annual_prem,
        transactionpremiumamount as trans_prem,
        gl_annual_premium as gl_annual_prem,
        gl_transaction_premium as gl_trans_prem,
        hnoliabtotalpremium as hno_liab_prem,
        try_cast(classifcationtotalpremium as double) as class_prem,
        premisesgeneratedpremium1 as premops_generated_prem,
        productsgeneratedpremium1 as products_generated_prem,
        premisestotalpremium1 as premops_prem,
        productstotalpremium1 as products_prem,

        policyearnedpremium as policy_ep,
        glpolicyearnedpremium as gl_policy_ep,
        class_earned_premium as class_ep,
        premises_earned_premium1 as premises_ep,
        products_earned_premium1 as products_ep,

        premisesarate1 as premops_arate,
        productsarate1 as products_arate,
        rn as rn,
        actionindicator as is_action,
        ghost as ghost
    
    from raw.gl_exposureview
), 

add_keys as (
    select
        {{ generate_aiv_key('lob', 'cfxml_id', 'cover_component_agreement_id') }},
        {{ generate_quote_key('quote_numb', 'quote_version_numb') }},
        {{ generate_policy_key('company_numb', 'policy_sym', 'policy_numb', 'policy_module', 'policy_eff_date')}},
        *

    from raw
)

select * from add_keys