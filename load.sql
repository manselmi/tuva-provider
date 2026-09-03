SET VARIABLE prefix = 'raw/';

SET VARIABLE npi = getvariable('prefix') || 'npidata_pfile_20050523-20260809.csv';
SET VARIABLE npi_othername = getvariable('prefix') || 'othername_pfile_20050523-20260809.csv';
SET VARIABLE nucc_taxonomy = getvariable('prefix') || 'nucc_taxonomy_261.csv';
SET VARIABLE medicare_specialty_crosswalk = getvariable('prefix') || 'Medicare_Provider_and_Supplier_Taxonomy_Crosswalk_August_2026.csv';

CREATE OR REPLACE SCHEMA raw_data;
USE raw_data;

CREATE TABLE npi AS
SELECT *
  REPLACE (
    npi::BIGINT AS npi,
    entity_type_code::TINYINT AS entity_type_code
  )
  RENAME (
    provider_last_name_legal_name AS provider_last_name,
    provider_organization_name_legal_business_name AS provider_organization_name
  )
FROM read_csv(
  getvariable('npi'),
  all_varchar = true,
  normalize_names = true
)
ORDER BY npi;

CREATE TABLE npi_othername AS
SELECT *
  REPLACE (
    npi::BIGINT AS npi
  )
FROM read_csv(
  getvariable('npi_othername'),
  all_varchar = true,
  normalize_names = true
)
ORDER BY npi;

CREATE TABLE nucc_taxonomy AS
SELECT *
FROM read_csv(
  getvariable('nucc_taxonomy'),
  all_varchar = true,
  normalize_names = true
)
ORDER BY code;

CREATE TABLE medicare_specialty_crosswalk AS
SELECT *
  RENAME (
    medicare_providersupplier_type_description AS medicare_provider_supplier_type_description,
    provider_taxonomy_description_type_classification_specialization AS provider_taxonomy_description
  )
FROM read_csv(
  getvariable('medicare_specialty_crosswalk'),
  all_varchar = true,
  normalize_names = true
)
ORDER BY "provider_taxonomy_code";
