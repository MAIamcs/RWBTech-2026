BEGIN;

CREATE SCHEMA IF NOT EXISTS core;

CREATE SCHEMA IF NOT EXISTS mart;

DROP VIEW IF EXISTS mart.answer_01;
DROP VIEW IF EXISTS mart.ans1;
DROP VIEW IF EXISTS mart.answer_02;
DROP VIEW IF EXISTS mart.ans2;
DROP VIEW IF EXISTS mart.answer_03;
DROP VIEW IF EXISTS mart.ans3;
DROP VIEW IF EXISTS mart.answer_04;
DROP VIEW IF EXISTS mart.ans4;
DROP VIEW IF EXISTS mart.answer_05;
DROP VIEW IF EXISTS mart.ans5;
DROP VIEW IF EXISTS mart.data_quality;
DROP VIEW IF EXISTS mart.order_summary;
DROP TABLE IF EXISTS core.order_reviews;
DROP TABLE IF EXISTS core.order_payments;
DROP TABLE IF EXISTS core.order_items;
DROP TABLE IF EXISTS core.orders;
DROP TABLE IF EXISTS core.products;
DROP TABLE IF EXISTS core.customers;
DROP TABLE IF EXISTS core.sellers;
DROP TABLE IF EXISTS core.product_category_translation;
DROP TABLE IF EXISTS core.categories;
DROP TABLE IF EXISTS core.buyers;

CREATE TABLE core.buyers (
    customer_unique_id text PRIMARY KEY
);

INSERT INTO core.buyers
SELECT DISTINCT customer_unique_id FROM raw.customers;

CREATE TABLE core.customers (
    customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix text,
    customer_city text,
    customer_state text,
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (customer_id)
);

INSERT INTO core.customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    _source_file,
    _loaded_at
)
SELECT NULLIF(customer_id, ''),
    NULLIF(customer_unique_id, ''),
    NULLIF(customer_zip_code_prefix, ''),
    NULLIF(customer_city, ''),
    NULLIF(customer_state, ''),
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.customers;

CREATE TABLE core.sellers (
    seller_id text NOT NULL,
    seller_zip_code_prefix text,
    seller_city text,
    seller_state text,
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (seller_id)
);

INSERT INTO core.sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    _source_file,
    _loaded_at
)
SELECT NULLIF(seller_id, ''),
    NULLIF(seller_zip_code_prefix, ''),
    NULLIF(seller_city, ''),
    NULLIF(seller_state, ''),
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.sellers;

CREATE TABLE core.product_category_translation (
    product_category_name text NOT NULL,
    product_category_name_english text,
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (product_category_name)
);

INSERT INTO core.product_category_translation (
    product_category_name,
    product_category_name_english,
    _source_file,
    _loaded_at
)
SELECT NULLIF(product_category_name, ''),
    NULLIF(product_category_name_english, ''),
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.product_category_translation;

CREATE TABLE core.products (
    product_id text NOT NULL,
    product_category_name text,
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm integer,
    product_height_cm integer,
    product_width_cm integer,
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (product_id)
);

INSERT INTO core.products (
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    _source_file,
    _loaded_at
)
SELECT NULLIF(product_id, ''),
    NULLIF(product_category_name, ''),
    NULLIF(product_name_lenght, '')::integer,
    NULLIF(product_description_lenght, '')::integer,
    NULLIF(product_photos_qty, '')::integer,
    NULLIF(product_weight_g, '')::integer,
    NULLIF(product_length_cm, '')::integer,
    NULLIF(product_height_cm, '')::integer,
    NULLIF(product_width_cm, '')::integer,
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.products;

CREATE TABLE core.orders (
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp timestamp,
    order_approved_at timestamp,
    order_delivered_carrier_date timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_delivery_date timestamp,
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (order_id)
);

INSERT INTO core.orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    _source_file,
    _loaded_at
)
SELECT NULLIF(order_id, ''),
    NULLIF(customer_id, ''),
    NULLIF(order_status, ''),
    NULLIF(order_purchase_timestamp, '')::timestamp,
    NULLIF(order_approved_at, '')::timestamp,
    NULLIF(order_delivered_carrier_date, '')::timestamp,
    NULLIF(order_delivered_customer_date, '')::timestamp,
    NULLIF(order_estimated_delivery_date, '')::timestamp,
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.orders;

CREATE TABLE core.order_items (
    order_id text NOT NULL,
    order_item_id integer NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date timestamp,
    price numeric(18, 2),
    freight_value numeric(18, 2),
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (order_id, order_item_id)
);

INSERT INTO core.order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    _source_file,
    _loaded_at
)
SELECT NULLIF(order_id, ''),
    NULLIF(order_item_id, '')::integer,
    NULLIF(product_id, ''),
    NULLIF(seller_id, ''),
    NULLIF(shipping_limit_date, '')::timestamp,
    NULLIF(price, '')::numeric(18, 2),
    NULLIF(freight_value, '')::numeric(18, 2),
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.order_items;

CREATE TABLE core.order_payments (
    order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value numeric(18, 2),
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (order_id, payment_sequential)
);

INSERT INTO core.order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    _source_file,
    _loaded_at
)
SELECT NULLIF(order_id, ''),
    NULLIF(payment_sequential, '')::integer,
    NULLIF(payment_type, ''),
    NULLIF(payment_installments, '')::integer,
    NULLIF(payment_value, '')::numeric(18, 2),
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.order_payments;

CREATE TABLE core.order_reviews (
    review_id text NOT NULL,
    order_id text NOT NULL,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp,
    review_answer_timestamp timestamp,
    _source_file text,
    _loaded_at timestamptz,
    PRIMARY KEY (review_id, order_id)
);

INSERT INTO core.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    _source_file,
    _loaded_at
)
SELECT NULLIF(review_id, ''),
    NULLIF(order_id, ''),
    NULLIF(review_score, '')::integer,
    NULLIF(review_comment_title, ''),
    NULLIF(review_comment_message, ''),
    NULLIF(review_creation_date, '')::timestamp,
    NULLIF(review_answer_timestamp, '')::timestamp,
    NULLIF(_source_file, ''),
    _loaded_at
FROM raw.order_reviews;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM core.products
        WHERE product_category_name = '__UNKNOWN__'
    ) THEN
        RAISE EXCEPTION 'Reserved category key collision';
    END IF;
END;
$$;

CREATE TABLE core.categories (
    category_key text PRIMARY KEY,
    name_pt text,
    name_en text,
    is_missing boolean NOT NULL
);

INSERT INTO core.categories
SELECT p.name,
    p.name,
    t.product_category_name_english,
    FALSE
FROM
    (SELECT DISTINCT product_category_name AS name
    FROM core.products
    WHERE product_category_name IS NOT NULL
    UNION SELECT product_category_name
    FROM core.product_category_translation) p
LEFT JOIN core.product_category_translation t ON t.product_category_name=p.name;

INSERT INTO core.categories
VALUES ('__UNKNOWN__',NULL,NULL,TRUE);

ALTER TABLE core.products ADD COLUMN category_key text;

UPDATE core.products
SET category_key=COALESCE(product_category_name, '__UNKNOWN__');

ALTER TABLE core.products
    ALTER COLUMN category_key SET NOT NULL;

ALTER TABLE core.customers
    ADD FOREIGN KEY (customer_unique_id) REFERENCES core.buyers(customer_unique_id);

CREATE INDEX ON core.customers (customer_unique_id);

ALTER TABLE core.orders
    ADD FOREIGN KEY (customer_id) REFERENCES core.customers(customer_id);

CREATE INDEX ON core.orders (customer_id);

ALTER TABLE core.products
    ADD FOREIGN KEY (category_key) REFERENCES core.categories(category_key);

CREATE INDEX ON core.products (category_key);

ALTER TABLE core.order_items
    ADD FOREIGN KEY (order_id) REFERENCES core.orders(order_id);

ALTER TABLE core.order_items
    ADD FOREIGN KEY (product_id) REFERENCES core.products(product_id);

CREATE INDEX ON core.order_items (product_id);

ALTER TABLE core.order_items
    ADD FOREIGN KEY (seller_id) REFERENCES core.sellers(seller_id);

CREATE INDEX ON core.order_items (seller_id);

ALTER TABLE core.order_payments
    ADD FOREIGN KEY (order_id) REFERENCES core.orders(order_id);

ALTER TABLE core.order_reviews
    ADD FOREIGN KEY (order_id) REFERENCES core.orders(order_id);

CREATE INDEX ON core.order_reviews (order_id);

ALTER TABLE core.order_items ADD CHECK (price >= 0
    AND freight_value >= 0
    AND order_item_id > 0);

ALTER TABLE core.order_reviews ADD CHECK (review_score BETWEEN 1 AND 5);

ALTER TABLE core.order_payments ADD CHECK (payment_value >= 0
    AND payment_installments >= 0
    AND payment_sequential > 0);

CREATE VIEW mart.order_summary AS
WITH i AS
    (SELECT order_id,
        count(*) AS item_count,
        sum(price) AS item_revenue,
        sum(freight_value) AS freight
    FROM core.order_items
    GROUP BY order_id),
p AS
    (SELECT order_id,
        count(*) AS payment_count,
        sum(payment_value) AS paid
    FROM core.order_payments
    GROUP BY order_id),
r AS
    (SELECT order_id,
        count(*) AS review_count,
        avg(review_score) AS review_score
    FROM core.order_reviews
    GROUP BY order_id)
SELECT o.*,
    c.customer_unique_id,
    i.item_count,
    i.item_revenue,
    i.freight,
    i.item_revenue+i.freight AS order_total,
    p.payment_count,
    p.paid,
    r.review_count,
    r.review_score
FROM core.orders o
JOIN core.customers c USING(customer_id)
LEFT JOIN i USING(order_id)
LEFT JOIN p USING(order_id)
LEFT JOIN r USING(order_id);

CREATE VIEW mart.ans1 AS
WITH months AS
    (SELECT generate_series(date '2016-09-01',date '2018-08-01',interval '1 month')::date AS MONTH)
SELECT m.month,
    count(o.order_id) AS orders,
    COALESCE(sum(o.item_revenue), 0) AS revenue
FROM months m
LEFT JOIN mart.order_summary o ON o.order_purchase_timestamp>=m.month
AND o.order_purchase_timestamp<m.month+interval '1 month'
AND o.order_status='delivered'
GROUP BY m.month;

CREATE VIEW mart.ans2 AS
SELECT s.seller_id,
    s.seller_city,
    s.seller_state,
    count(DISTINCT i.order_id) AS orders,
    count(*) AS units,
    sum(i.price) AS revenue
FROM core.order_items i
JOIN core.orders o USING(order_id)
JOIN core.sellers s USING(seller_id)
WHERE o.order_status='delivered'
GROUP BY s.seller_id,
    s.seller_city,
    s.seller_state;

CREATE VIEW mart.ans3 AS
SELECT round(avg(order_total), 2) AS average_order_value,
    round(avg(item_count), 6) AS average_lines,
    round(avg(item_count), 6) AS average_units
FROM mart.order_summary
WHERE order_status='delivered';

CREATE VIEW mart.ans4 AS
WITH counts AS
    (SELECT b.customer_unique_id,
        count(o.order_id) AS n
    FROM core.buyers b
    LEFT JOIN core.customers c USING(customer_unique_id)
    LEFT JOIN core.orders o USING(customer_id)
    GROUP BY b.customer_unique_id)
SELECT count(*) AS buyers,
    count(*) FILTER (WHERE n >= 2) AS repeat_buyers,
    round(100.0*count(*) FILTER (WHERE n >= 2)/NULLIF(count(*), 0), 2) AS repeat_percent
FROM counts;

CREATE VIEW mart.ans5 AS
WITH totals AS
    (SELECT p.category_key,
        sum(i.price) AS revenue
    FROM core.order_items i
    JOIN core.orders o USING(order_id)
    JOIN core.products p USING(product_id)
    WHERE o.order_status='delivered'
    GROUP BY p.category_key)
SELECT t.category_key,
    COALESCE(c.name_en, c.name_pt, 'Не указана') AS category,
    t.revenue,
    round(100*t.revenue/NULLIF(sum(t.revenue) OVER(), 0), 6) AS revenue_percent
FROM totals t
JOIN core.categories c USING(category_key);

CREATE VIEW mart.data_quality AS
SELECT 'orders_without_items' AS ISSUE,
    count(*) AS affected
FROM mart.order_summary
WHERE item_count IS NULL
UNION ALL
SELECT 'orders_without_payments',
    count(*)
FROM mart.order_summary
WHERE payment_count IS NULL
UNION ALL
SELECT 'payment_total_difference_gt_cent',
    count(*)
FROM mart.order_summary
WHERE abs(order_total-paid)>0.01
UNION ALL
SELECT 'products_missing_category',
    count(*)
FROM core.products
WHERE product_category_name IS NULL
UNION ALL
SELECT 'categories_missing_translation',
    count(*)
FROM core.categories
WHERE NOT is_missing
    AND name_en IS NULL
UNION ALL
SELECT 'delivered_missing_delivery_time',
    count(*)
FROM core.orders
WHERE order_status='delivered'
    AND order_delivered_customer_date IS NULL;

COMMIT;
