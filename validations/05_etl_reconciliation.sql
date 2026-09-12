SET search_path TO qa_demo;

-- Source records missing from the warehouse.
SELECT s.order_id
FROM staging_order_summary s
LEFT JOIN warehouse_order_summary w ON w.order_id = s.order_id
WHERE w.order_id IS NULL;

-- Unexpected warehouse records with no source.
SELECT w.order_id
FROM warehouse_order_summary w
LEFT JOIN staging_order_summary s ON s.order_id = w.order_id
WHERE s.order_id IS NULL;

-- Field-level source-to-target differences.
SELECT s.order_id,
       s.customer_email AS source_email,
       w.customer_email AS target_email,
       s.item_total AS source_item_total,
       w.item_total AS target_item_total,
       s.payment_total AS source_payment_total,
       w.payment_total AS target_payment_total,
       s.load_date AS source_load_date,
       w.load_date AS target_load_date
FROM staging_order_summary s
JOIN warehouse_order_summary w ON w.order_id = s.order_id
WHERE (s.customer_email, s.item_total, s.payment_total, s.load_date)
      IS DISTINCT FROM
      (w.customer_email, w.item_total, w.payment_total, w.load_date);
