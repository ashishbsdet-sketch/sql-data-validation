SET search_path TO qa_demo;

-- Order totals that do not reconcile to subtotal plus tax.
SELECT order_id, subtotal, tax_amount, total_amount
FROM orders
WHERE total_amount <> subtotal + tax_amount;

-- Dates that violate the expected order lifecycle.
SELECT o.order_id, o.order_date, c.created_at, o.updated_at
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date < c.created_at
   OR o.order_date > current_date
   OR o.updated_at::date < o.order_date;
