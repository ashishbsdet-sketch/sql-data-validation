SET search_path TO qa_demo;

INSERT INTO customers (customer_id, email, status, created_at) VALUES
    (1, 'ava@example.test', 'active', DATE '2026-01-10'),
    (2, 'noah@example.test', 'active', DATE '2026-02-12'),
    (3, 'mia@example.test', 'inactive', DATE '2025-11-04');

INSERT INTO orders (order_id, customer_id, order_date, status, subtotal, tax_amount, total_amount, updated_at) VALUES
    (1001, 1, DATE '2026-08-01', 'completed', 50.00, 5.00, 55.00, TIMESTAMP '2026-08-01 12:30:00'),
    (1002, 1, DATE '2026-08-04', 'processing', 30.00, 3.00, 33.00, TIMESTAMP '2026-08-04 09:15:00'),
    (1003, 2, DATE '2026-08-08', 'completed', 100.00, 10.00, 110.00, TIMESTAMP '2026-08-08 16:45:00'),
    (1004, 3, DATE '2026-08-10', 'cancelled', 25.00, 2.50, 27.50, TIMESTAMP '2026-08-10 11:20:00');

INSERT INTO order_items (order_id, line_number, product_sku, quantity, unit_price, line_total) VALUES
    (1001, 1, 'KB-100', 2, 20.00, 40.00),
    (1001, 2, 'MS-200', 1, 10.00, 10.00),
    (1002, 1, 'CB-300', 3, 10.00, 30.00),
    (1003, 1, 'HD-400', 1, 100.00, 100.00),
    (1004, 1, 'ST-500', 1, 25.00, 25.00);

INSERT INTO payments (payment_id, order_id, amount, status, paid_at) VALUES
    (5001, 1001, 55.00, 'completed', TIMESTAMP '2026-08-01 12:31:00'),
    (5002, 1002, 33.00, 'pending', NULL),
    (5003, 1003, 110.00, 'completed', TIMESTAMP '2026-08-08 16:46:00');

INSERT INTO staging_order_summary (order_id, customer_email, item_total, payment_total, load_date) VALUES
    (1001, 'ava@example.test', 50.00, 55.00, DATE '2026-08-11'),
    (1003, 'noah@example.test', 100.00, 110.00, DATE '2026-08-11');

INSERT INTO warehouse_order_summary (order_id, customer_email, item_total, payment_total, load_date) VALUES
    (1001, 'ava@example.test', 50.00, 55.00, DATE '2026-08-11'),
    (1003, 'noah@example.test', 100.00, 110.00, DATE '2026-08-11');
