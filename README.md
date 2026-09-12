# SQL Data Validation

[![SQL Validation](https://github.com/ashishbsdet-sketch/sql-data-validation/actions/workflows/sql-validation.yml/badge.svg)](https://github.com/ashishbsdet-sketch/sql-data-validation/actions/workflows/sql-validation.yml)

This project shows how I use SQL to test data quality, business rules and source-to-target transformations. The sample domain is a small commerce platform with customers, orders, line items, payments and a reporting warehouse.

The checks are written for PostgreSQL and run automatically in GitHub Actions. A failed rule is recorded with the number of offending rows, added to the workflow summary and then allowed to fail the pipeline.

## Validation coverage

| Area | Examples |
| --- | --- |
| Completeness | Required customer and order fields |
| Uniqueness | Case-insensitive customer email and warehouse order keys |
| Referential integrity | Orders without customers and items without orders |
| Business rules | Allowed statuses, positive quantities and valid dates |
| Financial reconciliation | Line totals, order subtotal, tax and completed payments |
| ETL validation | Missing, unexpected and mismatched warehouse records |

## Project structure

```text
.
├── db/
│   ├── schema.sql                 # Transactional, staging and warehouse tables
│   └── seed.sql                   # Small deterministic data set
├── validations/                   # Analyst-friendly exception queries
├── tests/run_assertions.sql       # Automated pass/fail checks
├── examples/introduce_bad_data.sql
├── scripts/run-validations.sh
├── docs/TEST_STRATEGY.md
└── .github/workflows/sql-validation.yml
```

## Run locally

You need PostgreSQL 16 or a compatible version.

```bash
createdb sql_qa
export DATABASE_URL="postgresql://localhost/sql_qa"
./scripts/run-validations.sh
```

The script rebuilds the `qa_demo` schema, loads deterministic test data, prints every exception query and runs 13 assertions.

To see how failures are reported:

```bash
psql "$DATABASE_URL" -f examples/introduce_bad_data.sql
psql "$DATABASE_URL" -f tests/run_assertions.sql
```

Re-run `./scripts/run-validations.sh` to restore the clean baseline.

## How the checks are designed

- Exception queries return only records that violate a rule; zero rows means the check passed.
- Financial values use `numeric`, not floating-point types.
- Reconciliation compares calculated line totals, stored order totals and successful payments separately.
- ETL checks cover missing records, unexpected records and field-level mismatches.
- Test data includes completed, processing and cancelled orders so status-specific rules are exercised.
- Assertions keep a check name, category, result and violation count for readable CI reporting.

The detailed scope and risk-based approach are documented in [the test strategy](docs/TEST_STRATEGY.md).

## Portfolio note

The data is synthetic and contains no customer information. The project demonstrates SQL testing technique and does not claim access to a real company's database.
