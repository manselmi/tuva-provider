/*
    Unpivots the 15 wide taxonomy code/switch column pairs into one row per
    (npi, taxonomy slot).

    dbt_utils.unpivot only unpivots a single value column set, so the paired
    code + switch columns are unpivoted separately (from the int_provider_taxonomy_*
    staging models) and rejoined on the numeric slot suffix. This keeps the model
    cross-database compatible (Snowflake / Postgres / Redshift / DuckDB).

    cast_to uses dbt.type_string() so the string type resolves per adapter
    (varchar / string / text) — no per-warehouse edits needed.
*/

with codes as (

    {{ dbt_utils.unpivot(
        relation=ref('int_provider_taxonomy_codes'),
        cast_to=dbt.type_string(),
        exclude=['npi'],
        field_name='taxonomy_col',
        value_name='taxonomy_code'
    ) }}

)

, switches as (

    {{ dbt_utils.unpivot(
        relation=ref('int_provider_taxonomy_switches'),
        cast_to=dbt.type_string(),
        exclude=['npi'],
        field_name='switch_col',
        value_name='taxonomy_switch'
    ) }}

)

select
      codes.npi
    , upper(codes.taxonomy_col) as taxonomy_col
    , codes.taxonomy_code
    , upper(switches.switch_col) as switch_col
    , switches.taxonomy_switch
from codes
inner join switches
    on codes.npi = switches.npi
    /* pair code_N with switch_N by the trailing slot number */
    and replace(codes.taxonomy_col, 'healthcare_provider_taxonomy_code_', '')
        = replace(switches.switch_col, 'healthcare_provider_primary_taxonomy_switch_', '')
where codes.taxonomy_code is not null
