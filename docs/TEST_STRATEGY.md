# SQL Data Test Strategy

## Purpose

This suite checks whether transactional and reporting data remains complete, internally consistent and aligned with defined business rules. It is designed as a compact example of SQL-based QA that can run locally and in CI.

## Test levels

| Level | Goal |
| --- | --- |
| Column | Required values, domains and formats are valid |
| Row | Calculated values and lifecycle dates are internally consistent |
| Relationship | Parent and child records resolve correctly |
| Aggregate | Line items, orders and payments reconcile |
| ETL | Source and warehouse populations and values match |

## Risk-based priorities

Financial reconciliation and missing warehouse records are the highest-risk checks because they can affect reporting, customer balances and operational decisions. Completeness and key uniqueness follow because failures can spread into several downstream systems.

## Test data

The baseline is deterministic and intentionally small enough to review manually. It includes multiple customers and order states, multiple line items, completed and pending payments, and two reporting records. The separate bad-data script introduces known failures without weakening the baseline.

## Pass criteria

A pipeline passes when:

1. PostgreSQL creates the schema without error.
2. All seed records satisfy database constraints.
3. Every exception query executes.
4. All 13 automated checks record zero violations.
5. The workflow summary contains a non-zero test total.

## Failure investigation

Start with the failed check name and violation count in `qa_test_results`. Run the related file in `validations/` to see the offending keys and calculated values. Compare source and target records before changing data or transformation logic.

## Regression scope

A change to order calculation should rerun line, subtotal, tax and payment checks. A mapping or pipeline change should rerun the complete ETL group. Schema changes should trigger the entire suite because they may affect every rule.

## Limitations

Synthetic data cannot represent production volume or every edge case. Production checks would also include freshness thresholds, volume trends, execution performance and environment-specific privacy controls.
