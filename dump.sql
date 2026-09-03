COPY
  (
    SELECT *
    FROM claims_data_model.provider
    ORDER BY npi
  )
  TO 'data/provider.parquet'
  (
    FORMAT parquet,
    COMPRESSION zstd
  );
