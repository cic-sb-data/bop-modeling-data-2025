#!/bin/bash

mkdir -p models/staging/base
echo "" > models/staging/base/stg_$1__$2.sql
dbt --quiet run-operation generate_base_model --args '{"source_name": "'$1'", "table_name": "'$2'"}' | tail -n +3 >> models/staging/base/stg_$1__$2.sql