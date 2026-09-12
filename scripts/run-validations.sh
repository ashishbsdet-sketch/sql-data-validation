#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?Set DATABASE_URL to a PostgreSQL connection string}"

psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f db/schema.sql
psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f db/seed.sql

for validation in validations/*.sql; do
  echo "Running ${validation}"
  psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f "${validation}"
done

psql "${DATABASE_URL}" -v ON_ERROR_STOP=1 -f tests/run_assertions.sql
