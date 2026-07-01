/*
    Staging model feeding dbt_utils.unpivot in taxonomy_unpivot.
    Isolates npi + the 15 taxonomy CODE columns so the macro can be
    pointed at a relation whose only unpivot targets are the codes.
    Materialized as a view (dbt_utils.unpivot introspects the relation's
    columns, so it cannot run against an ephemeral model).
*/
{{ config(materialized='view') }}

select
      npi
    , healthcare_provider_taxonomy_code_1
    , healthcare_provider_taxonomy_code_2
    , healthcare_provider_taxonomy_code_3
    , healthcare_provider_taxonomy_code_4
    , healthcare_provider_taxonomy_code_5
    , healthcare_provider_taxonomy_code_6
    , healthcare_provider_taxonomy_code_7
    , healthcare_provider_taxonomy_code_8
    , healthcare_provider_taxonomy_code_9
    , healthcare_provider_taxonomy_code_10
    , healthcare_provider_taxonomy_code_11
    , healthcare_provider_taxonomy_code_12
    , healthcare_provider_taxonomy_code_13
    , healthcare_provider_taxonomy_code_14
    , healthcare_provider_taxonomy_code_15
from {{ source('nppes', 'npi') }}
