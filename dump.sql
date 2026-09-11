.cd data

USE claims_data_model;

COPY (
  SELECT *
  FROM provider
  ORDER BY npi
)
TO 'provider.parquet'
WITH (
  FORMAT parquet,
  COMPRESSION zstd
);
