DROP SCHEMA IF EXISTS qa_demo CASCADE;
CREATE SCHEMA qa_demo;
SET search_path TO qa_demo;

CREATE TABLE customers (
    customer_id bigint PRIMARY KEY,
    email text NOT NULL,
    status text NOT NULL CHECK (status IN ('active', 'inactive')),
    created_at date NOT NULL
);

CREATE UNIQUE INDEX uq_customers_email_ci ON customers (lower(email));

CREATE TABLE orders (
    order_id bigint PRIMARY KEY,
    customer_id bigint NOT NULL REFERENCES customers(customer_id),
    order_date date NOT NULL,
    status text NOT NULL CHECK (status IN ('processing', 'completed', 'cancelled')),
    subtotal numeric(12,2) NOT NULL CHECK (subtotal >= 0),
    tax_amount numeric(12,2) NOT NULL CHECK (tax_amount >= 0),
    total_amount numeric(12,2) NOT NULL CHECK (total_amount >= 0),
    updated_at timestamp NOT NULL
);

CREATE TABLE order_items (
    order_id bigint NOT NULL REFERENCES orders(order_id),
    line_number integer NOT NULL,
    product_sku text NOT NULL,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
    line_total numeric(12,2) NOT NULL CHECK (line_total >= 0),
    PRIMARY KEY (order_id, line_number)
);

CREATE TABLE payments (
    payment_id bigint PRIMARY KEY,
    order_id bigint NOT NULL REFERENCES orders(order_id),
    amount numeric(12,2) NOT NULL CHECK (amount >= 0),
    status text NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    paid_at timestamp
);

CREATE TABLE staging_order_summary (
    order_id bigint NOT NULL,
    customer_email text NOT NULL,
    item_total numeric(12,2) NOT NULL,
    payment_total numeric(12,2) NOT NULL,
    load_date date NOT NULL
);

CREATE TABLE warehouse_order_summary (
    order_id bigint PRIMARY KEY,
    customer_email text NOT NULL,
    item_total numeric(12,2) NOT NULL,
    payment_total numeric(12,2) NOT NULL,
    load_date date NOT NULL
);

CREATE TABLE qa_test_results (
    check_name text PRIMARY KEY,
    category text NOT NULL,
    passed boolean NOT NULL,
    violation_count bigint NOT NULL,
    executed_at timestamp NOT NULL DEFAULT current_timestamp
);
