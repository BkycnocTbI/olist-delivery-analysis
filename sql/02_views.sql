-- One score per order prevents a one-to-many reviews join from reweighting orders.
BEGIN;

CREATE OR REPLACE VIEW public.review_scores AS
SELECT
    order_id,
    AVG(review_score) AS order_score,
    COUNT(*) AS review_count
FROM public.reviews
GROUP BY order_id;

-- Keep all orders, including orders without a review or actual delivery date.
CREATE OR REPLACE VIEW public.orders_enriched AS
SELECT
    o.*,
    c.customer_state,
    r.order_score
FROM public.orders AS o
LEFT JOIN public.customers AS c
    ON o.customer_id = c.customer_id
LEFT JOIN public.review_scores AS r
    ON o.order_id = r.order_id;

COMMIT;
