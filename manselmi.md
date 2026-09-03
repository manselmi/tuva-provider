## Prepare raw data

Download and move data files referenced in the [README](./README.md) into the `raw` directory.

## Load raw data

``` shell
DB=data/nppes.duckdb
rm -f -- "${DB}"
duckdb -bail -f load.sql "${DB}"
```

## dbt

``` shell
python3.13 -m venv -- .venv
source -- .venv/bin/activate
python -m pip install --upgrade -- pip setuptools wheel
python -m pip install -- dbt-duckdb
python -m pip check
hash -r
dbt deps
dbt build
deactivate
```

## Dump `provider` to Parquet

``` shell
duckdb -bail -f dump.sql "${DB}"
```
