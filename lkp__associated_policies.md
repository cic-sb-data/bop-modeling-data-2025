# Optimization Plan: `lkp__associated_policies` Model

## A. General Overview

The `lkp__associated_policies` model is a critical lookup component in the business owners policy (BOP) modeling system. Its primary purpose is to establish relationships between policies within policy chains, enabling the identification of all historically associated policies for any given policy in the decision file (decfile) process.

This model:
1. Creates associations between policies using their common policy chain IDs
2. Maintains the five-field compound key (company number, policy symbol, policy number, policy module, policy effective date)
3. Links each policy to its corresponding `sb_policy_key` 
4. Serves as a foundational lookup table for downstream analytical processes

Current performance issues are preventing the model from running in a reasonable timeframe, necessitating optimization work to improve efficiency while maintaining the integrity of policy relationships.

## B. Current State of the DBT Project

### Project Structure
- **Layered Architecture**: The project follows a well-organized layered architecture with clear separation of concerns:
  - `00_raw`: Raw data ingestion (primarily CSV sources)
  - `01_stg`: Staging models with basic transformations and type casting
  - `02_lkp`: Lookup models for reference data (our focus area)
  - `03_fct`: Fact models for transactional data
  - `05_mrt`: Mart models for analytical outputs
  - `06_chk`: Check models for data quality validation
  - `07_tmp`: Temporary/intermediate models for complex logic

### Key Data Sources
1. `raw__decfile__sb_policy_lookup`: Contains policy data from the decision file process with `sb_policy_key`
2. `raw__modcom__policy_chain_v3`: Contains policy chain information from a SAS file 
3. Billing data from various sources in `screngn` schema

### Dependencies
- The `lkp__associated_policies` model is central to the project, referenced by numerous downstream models:
  - `lkp__billing_policies`
  - `fct__associated_policy_eff_date`
  - `dm__npc_counts`

## C. Current State of the `lkp__associated_policies` Model

### Processing Logic
The current implementation uses a series of intermediate tables in the `07_tmp` folder:

1. **`_lkp__associated_policies_counts__sb_policies`** (TABLE):  
   - Provides the base set of policies from `stg__decfile__sb_policy_lookup`
   - Contains policy keys and policy chain IDs
   - Adds row count tracking via `sb_policies__nrows`

2. **`_lkp__associated_policies_counts__policy_chain`** (EPHEMERAL):  
   - Sources policy chain data from `stg__modcom__policy_chain_v3`
   - Contains policy chain IDs and five-key components
   - Adds row count tracking via `policy_chain__nrows`

3. **`_lkp__associated_policies_counts__filtered_policy_chains`** (EPHEMERAL):  
   - Joins policy chains to sb_policies on policy_chain_id
   - Links each policy to all other policies in its chain
   - Adds row count tracking via `filtered_policy_chains__nrows`

4. **`_lkp__associated_policies_counts__associated_policies`** (EPHEMERAL):  
   - Generates associated_policy_key using the `policy_key()` macro
   - Adds associated_sb_policy_key from filtered_policy_chains
   - Adds row count tracking via `associated_policies__nrows`

5. **`_lkp__associated_policies_counts__add_final_associated_policy_key`** (EPHEMERAL):  
   - Prepares the final structure for the lookup table
   - Adds row count tracking via `add_final_associated_policy_key__nrows`

6. **`_lkp__associated_policies_counts`**:  
   - Consolidates the results from the previous step

7. **`lkp__associated_policies`** (TABLE):  
   - Final lookup table that adds duplicate checking and finalizes data types
   - Uses window functions to identify duplicate policies

### Performance Issues
1. **Inefficient Joins**: The model involves multiple joins across large datasets
2. **Excessive Window Functions**: Each step uses `count(*) over()` for row counting
3. **Redundant Processing**: The ephemeral models reprocess data in memory multiple times
4. **Materialization Strategy**: Excessive use of ephemeral models may be causing recomputation
5. **Hash Key Generation**: `md5_number()` used in the `policy_key()` macro for each row
6. **Duplicate Detection**: Window function applied to the entire dataset for duplicate detection

### Data Volume Considerations
- The check model `chk__lkp__associated_policies__row_counts` tracks row counts at each step
- Each policy can be linked to multiple lines of business (LOBs), creating a many-to-many relationship
- The number of policies grows with each step of the process as additional chain relationships are identified

## D. Potential Next Steps for Optimization

### Option 1: Optimize Current Structure
**Pros:**
- Preserves existing logic and structure
- Lower risk of breaking changes
- Easier to implement and review

**Cons:**
- May not address fundamental performance issues
- Limited performance improvement potential

**Approach:**
1. Convert ephemeral models to table/incremental materialization
2. Add indexes or clustering keys
3. Optimize window functions or replace with group by aggregates
4. Implement partition pruning where possible

### Option 2: Refactor to Simplified Model Structure
**Pros:**
- Can achieve significant performance improvements
- Cleaner, more maintainable code
- Better scalability for future growth

**Cons:**
- Higher risk due to logic changes
- Requires comprehensive testing
- More development time

**Approach:**
1. Consolidate multiple steps into a single optimized query
2. Use CTEs for logical steps without creating intermediate tables
3. Replace window functions with simpler alternatives
4. Implement proper indexing on join keys

### Option 3: Add LOB-Specific Processing
**Pros:**
- Directly addresses the policy-to-LOB relationship
- Creates more specific keys (sb_prop_key, sb_liab_key)
- Better supports downstream use cases

**Cons:**
- Increases complexity of the model
- May require changes to downstream dependencies
- Additional testing requirements

**Approach:**
1. Add LOB filtering to create separate property and liability keys
2. Create dedicated columns for common LOB combinations
3. Optimize the join logic for specific LOB use cases

## E. Selected Path Forward

Based on the analysis, **Option 2: Refactor to Simplified Model Structure** offers the best balance of performance improvement and maintainability. This approach will:

1. Consolidate the multi-step process into a more optimized structure
2. Maintain the core functionality and interfaces
3. Reduce computational overhead through smarter materialization
4. Lay groundwork for potential LOB-specific enhancements in the future

We'll implement this refactoring with careful attention to:
- Maintaining identical output schema
- Preserving key business logic
- Ensuring all downstream dependencies continue to function
- Adding comprehensive testing to validate results

## F. Implementation Checklist

### Phase 1: Analysis and Planning
- [x] Review current model structure and dependencies
- [ ] Document the existing data flow and transformations
- [ ] Identify specific performance bottlenecks
- [ ] Set up performance baseline measurements
- [ ] Define success criteria for optimization

### Phase 2: Develop Optimized Solution
- [ ] Create a new branch for development
- [ ] Develop consolidated model replacing the multi-step process
- [ ] Implement proper materialization strategy
- [ ] Add appropriate indexes and optimization hints
- [ ] Consider partitioning strategies if applicable
- [ ] Document all changes and optimization rationale

### Phase 3: Testing and Validation
- [ ] Create unit tests for the new model
- [ ] Test compatibility with downstream dependencies
- [ ] Validate output matches original model exactly
- [ ] Measure performance improvements
- [ ] Review SQL execution plan for further optimization opportunities
- [ ] Run full project to ensure all dependencies work correctly

### Phase 4: LOB-Specific Enhancements
- [ ] Analyze policy-to-LOB relationships
- [ ] Design schema extensions for LOB-specific keys
- [ ] Implement LOB filtering logic
- [ ] Create separate sb_prop_key and sb_liab_key fields
- [ ] Update documentation to explain LOB-specific functionality
- [ ] Test LOB-specific functionality

### Phase 5: Implementation and Monitoring
- [ ] Create pull request with detailed description of changes
- [ ] Address review comments and make necessary adjustments
- [ ] Deploy to production with performance monitoring
- [ ] Document performance improvements
- [ ] Update model documentation with optimization details
- [ ] Schedule follow-up review to ensure performance remains optimal

### Phase 6: Knowledge Sharing and Documentation
- [ ] Update project documentation with optimization patterns
- [ ] Document lessons learned for future optimization work
- [ ] Create knowledge sharing session for the team
- [ ] Document any remaining optimization opportunities

## Technical Implementation Details

### Proposed Optimized Model Structure:
```sql
{{
  config(
    materialized='table',
    unique_key='associated_policy_key',
    indexes=[
      {'columns': ['associated_sb_policy_key']},
      {'columns': ['policy_chain_id']},
      {'columns': ['company_numb', 'policy_sym', 'policy_numb', 'policy_module', 'policy_eff_date']}
    ]
  )
}}

with 

sb_policies as (
    select 
        sb_policy_key,
        policy_chain_id,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date
    from {{ ref('stg__decfile__sb_policy_lookup') }}
),

policy_chains as (
    select distinct
        policy_chain_id,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date
    from {{ ref('stg__modcom__policy_chain_v3') }}
),

associated_policies as (
    select 
        {{ policy_key() }} as associated_policy_key,
        sb_policies.sb_policy_key as associated_sb_policy_key,
        policy_chains.policy_chain_id,
        policy_chains.company_numb,
        policy_chains.policy_sym,
        policy_chains.policy_numb,
        policy_chains.policy_module,
        policy_chains.policy_eff_date,
        case 
            when count(*) over(
                partition by sb_policies.sb_policy_key, 
                policy_chains.company_numb,
                policy_chains.policy_sym,
                policy_chains.policy_numb,
                policy_chains.policy_module,
                policy_chains.policy_eff_date
            ) > 1 then 1
            else 0
        end as is_gt1_five_key_in_table
    from policy_chains
    inner join sb_policies
        on policy_chains.policy_chain_id = sb_policies.policy_chain_id
)

select
    associated_policy_key,
    try_cast(associated_sb_policy_key as uint32) as associated_sb_policy_key,
    policy_chain_id,
    company_numb,
    policy_sym,
    policy_numb,
    policy_module,
    try_cast(policy_eff_date as date) as policy_eff_date,
    try_cast(is_gt1_five_key_in_table as uint8) as __is_gt1_five_key_in_table
from associated_policies
```