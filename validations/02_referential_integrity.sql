SET search_path TO qa_demo;

-- Orders whose customer key does not resolve.
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Line items whose order key does not resolve.
SELECT i.order_id, i.line_number
FROM order_items i
LEFT JOIN orders o ON o.order_id = i.order_id
WHERE o.order_id IS NULL;
