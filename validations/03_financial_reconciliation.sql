SET search_path TO qa_demo;

-- Stored line totals that do not equal quantity multiplied by unit price.
SELECT order_id, line_number, quantity, unit_price, line_total,
       round(quantity * unit_price, 2) AS calculated_line_total
FROM order_items
WHERE line_total <> round(quantity * unit_price, 2);

-- Orders whose subtotal differs from the sum of their lines.
SELECT o.order_id, o.subtotal, sum(i.line_total) AS calculated_subtotal
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
GROUP BY o.order_id, o.subtotal
HAVING o.subtotal <> sum(i.line_total);

-- Completed orders whose successful payment does not match the order total.
SELECT o.order_id, o.total_amount,
       coalesce(sum(p.amount) FILTER (WHERE p.status = 'completed'), 0) AS paid_amount
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> coalesce(sum(p.amount) FILTER (WHERE p.status = 'completed'), 0);
