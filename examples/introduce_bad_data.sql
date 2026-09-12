SET search_path TO qa_demo;

-- Controlled failures for demonstrating the validation output.
-- Run only after the clean baseline has been loaded.
ALTER TABLE order_items DISABLE TRIGGER ALL;

UPDATE order_items
SET line_total = line_total + 5
WHERE order_id = 1001 AND line_number = 1;

UPDATE warehouse_order_summary
SET payment_total = payment_total - 10
WHERE order_id = 1003;

ALTER TABLE order_items ENABLE TRIGGER ALL;

-- tests/run_assertions.sql should now report two failed checks:
-- line-total reconciliation and source-to-target matching.
