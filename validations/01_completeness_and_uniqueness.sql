SET search_path TO qa_demo;

-- Required customer values that are null or contain only whitespace.
SELECT customer_id, email, status, created_at
FROM customers
WHERE nullif(btrim(email), '') IS NULL
   OR status IS NULL
   OR created_at IS NULL;

-- Duplicate email addresses after normalizing case and surrounding spaces.
SELECT lower(btrim(email)) AS normalized_email, count(*) AS duplicate_count
FROM customers
GROUP BY lower(btrim(email))
HAVING count(*) > 1;
