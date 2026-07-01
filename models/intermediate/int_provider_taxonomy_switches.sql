/*
    Staging model feeding dbt_utils.unpivot in taxonomy_unpivot.
    Isolates npi + the 15 primary-taxonomy SWITCH columns so the macro can be
    pointed at a relation whose only unpivot targets are the switches.
    Materialized as a view (dbt_utils.unpivot introspects the relation's
    columns, so it cannot run against an ephemeral model).
*/
{{ config(materialized='view') }}

select
      npi
    , healthcare_provider_primary_taxonomy_switch_1
    , healthcare_provider_primary_taxonomy_switch_2
    , healthcare_provider_primary_taxonomy_switch_3
    , healthcare_provider_primary_taxonomy_switch_4
    , healthcare_provider_primary_taxonomy_switch_5
    , healthcare_provider_primary_taxonomy_switch_6
    , healthcare_provider_primary_taxonomy_switch_7
    , healthcare_provider_primary_taxonomy_switch_8
    , healthcare_provider_primary_taxonomy_switch_9
    , healthcare_provider_primary_taxonomy_switch_10
    , healthcare_provider_primary_taxonomy_switch_11
    , healthcare_provider_primary_taxonomy_switch_12
    , healthcare_provider_primary_taxonomy_switch_13
    , healthcare_provider_primary_taxonomy_switch_14
    , healthcare_provider_primary_taxonomy_switch_15
from {{ source('nppes', 'npi') }}
