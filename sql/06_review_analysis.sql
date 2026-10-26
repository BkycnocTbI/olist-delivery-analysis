-- order_score is already averaged within each order: orders have equal weight.
-- A low score means a per-order mean <= 2, not an individual raw review <= 2.
WITH scored AS (
    SELECT
        order_score,
        order_delivered_customer_date::date
            - order_estimated_delivery_date::date AS delay_days
    FROM public.orders_enriched
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_score IS NOT NULL
)
SELECT
    CASE WHEN delay_days > 0 THEN 'late' ELSE 'on_time' END AS delivery_result,
    COUNT(*) AS orders_with_score,
    ROUND(AVG(order_score), 2) AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN order_score <= 2 THEN 1.0 ELSE 0 END), 2) AS low_score_pct
FROM scored
GROUP BY delivery_result
ORDER BY delivery_result;

WITH scored AS (
    SELECT
        order_score,
        order_delivered_customer_date::date
            - order_estimated_delivery_date::date AS delay_days
    FROM public.orders_enriched
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_score IS NOT NULL
)
SELECT
    CASE
        WHEN delay_days <= 0 THEN '0. On time'
        WHEN delay_days <= 3 THEN '1. Late 1–3 days'
        WHEN delay_days <= 7 THEN '2. Late 4–7 days'
        WHEN delay_days <= 14 THEN '3. Late 8–14 days'
        ELSE '4. Late 15+ days'
    END AS delay_group,
    COUNT(*) AS orders_with_score,
    ROUND(AVG(order_score), 2) AS avg_review_score
FROM scored
GROUP BY delay_group
ORDER BY delay_group;

-- Descriptive comparison within two large states; not causal adjustment.
WITH scored AS (
    SELECT
        customer_state,
        order_score,
        order_delivered_customer_date::date
            - order_estimated_delivery_date::date AS delay_days
    FROM public.orders_enriched
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
      AND order_score IS NOT NULL
      AND customer_state IN ('SP', 'RJ')
)
SELECT
    customer_state,
    CASE WHEN delay_days > 0 THEN 'late' ELSE 'on_time' END AS delivery_result,
    COUNT(*) AS orders_with_score,
    ROUND(AVG(order_score), 2) AS avg_review_score,
    ROUND(100.0 * AVG(CASE WHEN order_score <= 2 THEN 1.0 ELSE 0 END), 2) AS low_score_pct
FROM scored
GROUP BY customer_state, delivery_result
ORDER BY customer_state, delivery_result;
