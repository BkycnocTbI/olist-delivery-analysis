-- Duration retains hours, minutes and seconds. It is not a calendar-day count.
WITH durations AS (
    SELECT order_delivered_customer_date - order_purchase_timestamp AS duration
    FROM public.orders
    WHERE order_status = 'delivered'
      AND order_purchase_timestamp IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
)
SELECT
    COUNT(*) AS analyzed_orders,
    MIN(duration) AS min_delivery_time,
    AVG(duration) AS avg_delivery_time,
    MAX(duration) AS max_delivery_time,
    ROUND(AVG(EXTRACT(EPOCH FROM duration) / 86400.0), 2) AS avg_delivery_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration) AS median_delivery_time,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY duration) AS p90_delivery_time
FROM durations;

-- Timeliness uses calendar dates: delivery on the promised day is on time.
WITH eligible AS (
    SELECT
        order_delivered_customer_date::date
            - order_estimated_delivery_date::date AS delay_days
    FROM public.orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    COUNT(*) AS analyzed_deliveries,
    COUNT(*) FILTER (WHERE delay_days <= 0) AS on_time_orders,
    COUNT(*) FILTER (WHERE delay_days > 0) AS late_orders,
    ROUND(
        100.0 * (COUNT(*) FILTER (WHERE delay_days > 0))
            / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_pct,
    ROUND(AVG(delay_days) FILTER (WHERE delay_days > 0), 2) AS avg_delay_days,
    MAX(delay_days) FILTER (WHERE delay_days > 0) AS max_delay_days
FROM eligible;
