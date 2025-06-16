# BOP Modeling Data 2025 — Current State

## 1. Project Overview

This dbt project prepares and transforms insurance billing and policy data for predictive modeling, specifically to sort prospective policyholders into risk tiers based on expected loss ratios. The project ingests raw data from various sources (SAS exports, CSVs, and Python-processed files), applies cleaning and transformation logic, and builds analytical tables and marts for downstream modeling and analytics.

**Main components:**
- **Raw ingestion**: Loads and standardizes raw data from SAS and other sources.
- **Staging**: Cleans, renames, and type-casts raw data for consistency.
- **Lookup (LKP)**: Builds key relationships and lookup tables (e.g., policy chains, associated policies).
- **Fact/Mart**: Aggregates and prepares data for modeling and reporting.
- **Macros**: Provides reusable SQL logic for keys, recoding, and transformations.
- **Tests & Documentation**: Ensures data quality and documents models.

---

## 2. Data Sources

Defined in `bop_modeling_data/models/sources.yml`:

- **raw**: Base schema for raw data.
- **screngn**: SAS "Scoring Engine" tables for billing and policy-level scoring.
  - Tables: `xcd_bil_account`, `xcd_bil_act_summary`, `xcd_bil_cash_dsp`, `xcd_bil_cash_receipt`, `xcd_bil_des_reason`, `xcd_bil_ist_schedule`, `xcd_bil_pol_proc_req`, `xcd_bil_policy_trm`, `xcd_bil_policy`
- **decfile**: "Decision File" tables identifying small business policies for modeling.
  - Tables: `sb_aiv_lookup`, `sb_policy_lookup`, `screngn_policy_lookup`
- **modcom**: "Model Common" SAS datasets, especially `policy_chain_v3` (loaded via Python).
  - Table: `policy_chain_v3`

**Note:** All sources are well-defined, but some (e.g., `sb_aiv_lookup`, `screngn_policy_lookup`) may not be fully used in current models.

---

## 3. Models

Organized by layer and folder. Key models and their purposes:

### Raw Layer (`00_raw`)
- **raw__screngn__xcd_bil_account**: Raw billing account data from SAS.
- **raw__screngn__xcd_bil_act_summary**: Raw billing activity summary.
- **raw__screngn__xcd_bil_cash_dsp**: Raw billing cash disposition.
- **raw__screngn__xcd_bil_cash_receipt**: Raw billing cash receipt.
- **raw__screngn__xcd_bil_des_reason**: Raw billing description reasons.
- **raw__screngn__xcd_bil_ist_schedule**: Raw installment schedule.
- **raw__screngn__xcd_bil_pol_proc_req**: Raw policy processing requests.
- **raw__screngn__xcd_bil_policy_trm**: Raw policy term data.
- **raw__screngn__xcd_bil_policy**: Raw policy data.
- **raw__decfile__sb_aiv_lookup**: Raw AIV lookup from decfile.
- **raw__decfile__sb_policy_lookup**: Raw SB policy lookup from decfile.
- **raw__decfile__screngn_policy_lookup**: Raw screngn policy lookup from decfile.
- **raw__modcom__policy_chain_v3**: Raw policy chain data from SAS (Python model).

### Staging Layer (`01_stg`)
- **screngn__xcd_bil_account**: Renames/casts billing account fields.
- **screngn__xcd_bil_act_summary**: Cleans billing activity summary.
- **screngn__xcd_bil_cash_dsp**: Cleans billing cash disposition.
- **screngn__xcd_bil_cash_receipt**: Cleans billing cash receipt.
- **screngn__xcd_bil_des_reason**: Cleans billing description reasons.
- **screngn__xcd_bil_ist_schedule**: Cleans installment schedule.
- **screngn__xcd_bil_pol_proc_req**: Cleans policy processing requests.
- **screngn__xcd_bil_policy_trm**: Cleans policy term data.
- **screngn__xcd_bil_policy**: Cleans policy data.
- **decfile__sb_policy_lookup**: Staging for SB policy lookup.
- **modcom__policy_chain_v3**: Adds keys to policy chain data.

### Lookup Layer (`02_lkp`)
- **associated_policies**: Links policies within chains; key for downstream analytics.
- **billing_policies**: Associates billing data with policies.
- **dates**: Date dimension with prior year calculations.
- **policy_chain_ids**: Distinct policy chain IDs and counts.
- **sb_policy_key**: Lookup for SB policy keys.
- **billing key models**: Various models for generating and joining billing keys (e.g., `xcd_bil_policy_key`, `xcd_bil_act_summary_key`, etc.).

### Fact/Mart Layer (`03_fct`, `04_mrt`)
- **associated_policy_eff_date**: Fact table for associated policy effective dates.
- **npc_counts**: Mart for NonPayCancel counts (in progress).

### Temporary/Check Models (`06_chk`, `07_tmp`)
- **chk__lkp__associated_policies__row_counts**: Row count checks for associated policies pipeline.
- **_lkp__associated_policies_counts**: Temporary/intermediate models for associated policies logic.

---

## 4. Tests

Defined in `tests/generic/` and `tests/singular/`:

- **assert_foreign_keys_are_present.sql**: Ensures all foreign keys in a child table exist in the parent table (no orphans).
- **assert_lkp_associated_policies_coverage.sql**: Ensures every `sb_policy_key` with a `policy_chain_id` is represented in `lkp__associated_policies`, and all `policy_chain_id`s in `lkp__associated_policies` exist in the source policy chain model.

**Model-level tests** (in YAML schemas):
- Uniqueness, not-null, value ranges, compound key uniqueness, and referential integrity for key columns in most models.
- Many models use `dbt_expectations` and `dbt_utils` for expressive tests.

---

## 5. Documentation

**Defined:**
- Most models have YAML schema files with descriptions and column-level documentation.
- Source tables are described in `sources.yml`.
- Some macros have docstrings or comments.

**Needs completion:**
- Some placeholder columns in raw models and temporary models (e.g., `_schema.yml` files) need detailed descriptions.
- Not all columns in all models have full descriptions.
- Some macros and utility SQL may benefit from more detailed doc blocks.
- Centralized documentation (like this file) is being established.

---

**Last updated:** _[Insert date here as needed]_
