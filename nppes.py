#!/usr/bin/env -S mise exec -- uv run --no-dev --script
#
# ruff:noqa:S608


from pathlib import Path
from textwrap import dedent
from typing import TYPE_CHECKING

from duckdb import connect as _connect
from typer import Typer

if TYPE_CHECKING:
    from duckdb import DuckDBPyConnection


# https://github.com/duckdb/duckdb-python/blob/main/_duckdb-stubs/__init__.pyi
type Config = dict[str, str | bool | int | float | list[str]]


RAW_DIR = Path(__file__).with_name("raw")
DATA_DIR = Path(__file__).with_name("data")
DATABASE = DATA_DIR.joinpath("nppes.duckdb")
RAW_SCHEMA = "raw_data"
CLAIMS_SCHEMA = "claims_data_model"


NPI = RAW_DIR.joinpath("npidata_pfile_20050523-20260913.csv")
NPI_OTHERNAME = RAW_DIR.joinpath("othername_pfile_20050523-20260913.csv")
NUCC_TAXONOMY = RAW_DIR.joinpath("nucc_taxonomy_261.csv")
MEDICARE_SPECIALTY_CROSSWALK = RAW_DIR.joinpath(
    "Medicare_Provider_and_Supplier_Taxonomy_Crosswalk_August_2026.csv"
)


GLOBAL_CONFIG: Config = {
    "storage_compatibility_version": "latest",
}
LOCAL_CONFIG: Config = {
    "progress_bar_time": 0,
}


app = Typer(no_args_is_help=True, pretty_exceptions_show_locals=True)


@app.command()
def load() -> None:
    DATABASE.unlink(missing_ok=True)
    with connect(DATABASE, global_config=GLOBAL_CONFIG, local_config=LOCAL_CONFIG) as con:
        load_raw_schema(con)


def load_raw_schema(con: DuckDBPyConnection, /) -> None:
    quoted_schema = quote_identifier(RAW_SCHEMA)

    con.execute(f"DROP SCHEMA IF EXISTS {quoted_schema} CASCADE")
    con.execute(f"CREATE SCHEMA {quoted_schema}")
    con.execute(f"USE {quoted_schema}")

    con.execute(
        dedent(f"""\
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
            {quote_string(NPI.as_posix())},
            all_varchar = true,
            normalize_names = true
        )
        ORDER BY npi""")
    )

    con.execute(
        dedent(f"""\
        CREATE TABLE npi_othername AS
        SELECT *
            REPLACE (
                npi::BIGINT AS npi
            )
        FROM read_csv(
            {quote_string(NPI_OTHERNAME.as_posix())},
            all_varchar = true,
            normalize_names = true
        )
        ORDER BY npi""")
    )

    con.execute(
        dedent(f"""\
        CREATE TABLE nucc_taxonomy AS
        SELECT *
        FROM read_csv(
            {quote_string(NUCC_TAXONOMY.as_posix())},
            all_varchar = true,
            normalize_names = true
        )
        ORDER BY code""")
    )

    con.execute(
        dedent(f"""\
        CREATE TABLE medicare_specialty_crosswalk AS
        SELECT *
            RENAME (
                medicare_providersupplier_type_description AS
                    medicare_provider_supplier_type_description,
                provider_taxonomy_description_type_classification_specialization AS
                    provider_taxonomy_description
            )
        FROM read_csv(
            {quote_string(MEDICARE_SPECIALTY_CROSSWALK.as_posix())},
            all_varchar = true,
            normalize_names = true
        )
        ORDER BY provider_taxonomy_code""")
    )


@app.command()
def dump() -> None:
    with connect(
        DATABASE,
        read_only=True,
        global_config=GLOBAL_CONFIG,
        local_config=LOCAL_CONFIG,
    ) as con:
        dump_provider(con)


def dump_provider(con: DuckDBPyConnection, /) -> None:
    con.execute(f"USE {quote_identifier(CLAIMS_SCHEMA)}")

    rel = con.sql("SELECT * FROM provider")
    rel = rel.project(
        ", ".join(
            f"{quote_identifier(col)} AS {quote_identifier(col.upper())}" for col in rel.columns
        )
    ).sort("NPI")

    con.execute(
        dedent(f"""\
        COPY rel
        TO {quote_string(DATA_DIR.joinpath("provider.parquet").as_posix())}
        WITH (
          FORMAT parquet,
          COMPRESSION zstd
        )""")
    )


def connect(
    database: Path | str = ":memory:",
    /,
    *,
    read_only: bool = False,
    global_config: Config | None = None,
    local_config: Config | None = None,
) -> DuckDBPyConnection:
    con = None
    try:
        con = _connect(database, read_only=read_only, config=global_config)
        for key, value in (local_config or {}).items():
            con.execute(f"SET {quote_identifier(key)} = ?", [value])
    except:
        if con:
            con.close()
        raise
    else:
        return con


def quote_identifier(identifier: str, /) -> str:
    return f'"{identifier.replace('"', '""')}"'


def quote_string(string_: str, /) -> str:
    return f"'{string_.replace("'", "''")}'"


if __name__ == "__main__":
    app()
