SET search_path TO qa_demo;
TRUNCATE TABLE qa_test_results;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Required customer fields are populated', 'Completeness', count(*) = 0, count(*)
FROM customers
WHERE nullif(btrim(email), '') IS NULL OR status IS NULL OR created_at IS NULL;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Customer emails are unique ignoring case', 'Uniqueness', count(*) = 0, count(*)
FROM (
    SELECT lower(btrim(email))
    FROM customers
    GROUP BY lower(btrim(email))
    HAVING count(*) > 1
) violations;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Every order has a customer', 'Referential integrity', count(*) = 0, count(*)
FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Every line item has an order', 'Referential integrity', count(*) = 0, count(*)
FROM order_items i LEFT JOIN orders o ON o.order_id = i.order_id
WHERE o.order_id IS NULL;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Line totals equal quantity times price', 'Financial reconciliation', count(*) = 0, count(*)
FROM order_items
WHERE line_total <> round(quantity * unit_price, 2);

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Order subtotals equal summed line totals', 'Financial reconciliation', count(*) = 0, count(*)
FROM (
    SELECT o.order_id
    FROM orders o JOIN order_items i ON i.order_id = o.order_id
    GROUP BY o.order_id, o.subtotal
    HAVING o.subtotal <> sum(i.line_total)
) violations;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Order total equals subtotal plus tax', 'Business rules', count(*) = 0, count(*)
FROM orders
WHERE total_amount <> subtotal + tax_amount;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Completed orders are fully paid', 'Financial reconciliation', count(*) = 0, count(*)
FROM (
    SELECT o.order_id
    FROM orders o LEFT JOIN payments p ON p.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id, o.total_amount
    HAVING o.total_amount <> coalesce(sum(p.amount) FILTER (WHERE p.status = 'completed'), 0)
) violations;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Order lifecycle dates are valid', 'Business rules', count(*) = 0, count(*)
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date < c.created_at
   OR o.order_date > current_date
   OR o.updated_at::date < o.order_date;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Staging order keys are unique', 'ETL', count(*) = 0, count(*)
FROM (
    SELECT order_id FROM staging_order_summary
    GROUP BY order_id HAVING count(*) > 1
) violations;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Every staging record reached the warehouse', 'ETL', count(*) = 0, count(*)
FROM staging_order_summary s
LEFT JOIN warehouse_order_summary w ON w.order_id = s.order_id
WHERE w.order_id IS NULL;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Warehouse has no unexpected records', 'ETL', count(*) = 0, count(*)
FROM warehouse_order_summary w
LEFT JOIN staging_order_summary s ON s.order_id = w.order_id
WHERE s.order_id IS NULL;

INSERT INTO qa_test_results (check_name, category, passed, violation_count)
SELECT 'Source and target values match', 'ETL', count(*) = 0, count(*)
FROM staging_order_summary s
JOIN warehouse_order_summary w ON w.order_id = s.order_id
WHERE (s.customer_email, s.item_total, s.payment_total, s.load_date)
      IS DISTINCT FROM
      (w.customer_email, w.item_total, w.payment_total, w.load_date);

TABLE qa_test_results;

DO $$
DECLARE
    failed_checks integer;
BEGIN
    SELECT count(*) INTO failed_checks
    FROM qa_test_results
    WHERE NOT passed;

    IF failed_checks > 0 THEN
        RAISE EXCEPTION '% SQL validation check(s) failed', failed_checks;
    END IF;
END
$$;
