-- Read-only checks. Known reference outputs are in docs/expected_results.csv.

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(order_id) AS missing_order_ids,
    MIN(order_purchase_timestamp) AS first_purchase,
    MAX(order_purchase_timestamp) AS last_purchase
FROM public.orders;

SELECT order_status, COUNT(*) AS orders_count
FROM public.orders
GROUP BY order_status
ORDER BY orders_count DESC;

SELECT
    COUNT(*) AS customer_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(*) - COUNT(customer_id) AS missing_customer_ids
FROM public.customers;

SELECT
    COUNT(*) AS rows_after_join,
    COUNT(c.customer_id) AS matched_orders,
    COUNT(*) FILTER (WHERE c.customer_id IS NULL) AS unmatched_orders
FROM public.orders AS o
LEFT JOIN public.customers AS c ON o.customer_id = c.customer_id;

SELECT
    COUNT(*) AS review_rows,
    COUNT(DISTINCT order_id) AS unique_review_orders,
    COUNT(*) - COUNT(order_id) AS missing_review_order_ids,
    COUNT(order_id) - COUNT(DISTINCT order_id) AS extra_review_rows
FROM public.reviews;

-- Additional reviews are inspected, not automatically deleted as duplicates.
SELECT
    order_id,
    COUNT(*) AS review_count,
    COUNT(DISTINCT review_id) AS distinct_review_ids,
    MIN(review_score) AS min_review_score,
    MAX(review_score) AS max_review_score
FROM public.reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC, order_id
LIMIT 10;

-- Report these diagnostics if they return rows; no repairs are applied here.
SELECT review_score, COUNT(*) AS review_rows
FROM public.reviews
WHERE review_score IS NULL OR review_score NOT BETWEEN 1 AND 5
GROUP BY review_score;

SELECT
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_actual_delivery_date,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NOT NULL
          AND order_estimated_delivery_date IS NOT NULL
    ) AS analyzed_deliveries,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date < order_purchase_timestamp
    ) AS negative_delivery_durations
FROM public.orders
WHERE order_status = 'delivered';

SELECT
    COUNT(*) AS enriched_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(order_score) AS orders_with_score,
    COUNT(*) - COUNT(order_score) AS orders_without_score
FROM public.orders_enriched;

SELECT
    COUNT(*) AS eligible_deliveries,
    COUNT(order_score) AS eligible_orders_with_score,
    COUNT(*) - COUNT(order_score) AS eligible_orders_without_score
FROM public.orders_enriched
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
