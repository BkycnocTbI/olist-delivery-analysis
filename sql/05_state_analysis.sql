-- Destination state, not seller state. Eligible counts accompany every rate.
WITH eligible AS (
    SELECT
        customer_state,
        order_delivered_customer_date::date
            - order_estimated_delivery_date::date AS delay_days
    FROM public.orders_enriched
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    customer_state,
    COUNT(*) AS analyzed_deliveries,
    COUNT(*) FILTER (WHERE delay_days > 0) AS late_orders,
    ROUND(
        100.0 * (COUNT(*) FILTER (WHERE delay_days > 0))
            / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_pct
FROM eligible
GROUP BY customer_state
ORDER BY late_delivery_pct DESC, customer_state;

-- Absolute-volume ranking answers a different question from the rate ranking.
SELECT customer_state, COUNT(*) AS late_orders
FROM public.orders_enriched
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date::date > order_estimated_delivery_date::date
GROUP BY customer_state
ORDER BY late_orders DESC, customer_state;

SELECT
    COUNT(*) FILTER (WHERE customer_state IN ('SP', 'RJ')) AS sp_rj_late_orders,
    COUNT(*) AS all_late_orders,
    ROUND(
        100.0 * (COUNT(*) FILTER (WHERE customer_state IN ('SP', 'RJ')))
            / NULLIF(COUNT(*), 0),
        1
    ) AS sp_rj_share_pct
FROM public.orders_enriched
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date::date > order_estimated_delivery_date::date;
