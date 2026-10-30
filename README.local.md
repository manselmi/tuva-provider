## Prerequisites

1. [Install mise](https://mise.jdx.dev/installing-mise.html).

1. Download and move the data files referenced in the [README](./README.md) into the `raw`
   directory.

    * If the monthly NPPES data dissemination is not available from `download.cms.gov` (e.g. site is
      down), then check the [mirror](https://data.nber.org/npi/zip/) maintained by the National
      Bureau of Economic Research.

1. Update the filenames near the top of `nppes.py` to match the filenames of the data files from the
   previous step.

## Load the raw data

``` shell
mise run load
```

This creates a DuckDB database at `data/nppes.duckdb`.

## Build the dbt project

``` shell
mise run
```

## Dump to Parquet

``` shell
mise run dump
```

This dumps the `provider` table to a Parquet file at `data/provider.parquet`.
