# Metric definitions and model decisions

## Unit of analysis

The final view contains one row per order, including all statuses. Customer state is added through `customer_id`; review scores are aggregated by `order_id` before the join. Both joins are left joins.

`review_scores.order_score` is the mean of all available ratings for one order. A subsequent average across orders gives each rated order equal weight. This is a chosen aggregation policy; selecting the first or latest review would answer a different question.

## Populations

| Analysis | Inclusion criteria | Full-dataset count |
|---|---|---:|
| All orders | Every order in the source | 99,441 |
| Delivered-order KPI | `order_status = 'delivered'` | 96,478 |
| Delivery duration | Delivered, known purchase and actual delivery timestamps | 96,470 |
| Timeliness and lateness | Delivered, known actual and estimated delivery dates | 96,470 |
| Review comparison | Timeliness population, known mean order score | 95,824 |

The equal counts for duration and timeliness are a property of this dataset, not interchangeable definitions. Mean delivery time does not require an estimated date; timeliness does not require a purchase timestamp.

Eight delivered orders lack an actual delivery date. These records are retained in the delivered count. Of the timeliness-eligible orders, 646 have no score: 153 late and 493 on time. Across all statuses, 768 orders lack a score.

## Time definitions

- **Delivery duration:** actual customer-delivery timestamp minus purchase timestamp. Convert elapsed seconds to fractional days in SQL, and use datetime subtraction in DAX. Preserve the time of day.
- **Delay days:** actual delivery calendar date minus estimated delivery calendar date. Positive means late, zero means delivered on the promised day, negative means early.
- **On time:** delay days <= 0.
- **Late rate:** late eligible orders / all eligible orders. The delivered-order KPI, which includes eight orders without an actual date, is not the denominator.
- **Purchase-date filter:** selects orders according to purchase time, even if delivery happened in a later period.

All timestamps are used as supplied, without timezone conversion. No business-day calendar is applied.

## Rating definitions

- Ratings comparison uses the per-order mean score, not raw review rows.
- Missing scores are excluded, not converted to zero.
- Low-score percentage in the SQL analysis means per-order mean score <= 2.
- Delay buckets are early/on time, 1–3 days late, 4–7, 8–14, and 15+.
- Blank `Delay Days` values remain blank in the bucket column so excluded orders cannot become on-time orders.

## Power BI model and visuals

Import `public.orders_enriched`. The Power BI table name used in the formulas is `public orders_enriched` (with a space after `public`). No additional joins are needed in Power BI.

Create `Delay Days`, then `Delay Group`, followed by the measures in dependency order. Keep date fields as Date/Time and `order_score` as a numeric field.

| Visual | Categories / field | Value | Tooltips / order |
|---|---|---|---|
| Card | — | Delivered Orders | Whole number; display units None |
| Card | — | Late Delivery Rate | Percentage, 2 decimals |
| Card | — | Avg Delivery Days | Decimal, 2 decimals |
| Clustered bar | customer_state | Late Orders | Analyzed Deliveries; descending by Late Orders |
| Clustered bar | customer_state | Late Delivery Rate | Analyzed Deliveries, Late Orders; descending by rate |
| Clustered column | Delay Group | Avg Review Score | Orders With Score; ascending by Delay Group |
| Between slicer | order_purchase_timestamp | — | Use the column itself, not its date hierarchy |

In horizontal bar chart field wells, customer state is the category/Y axis and the measure is the value/X axis. All 27 customer states are displayed. When new-card display units are hidden, choose the specific measure under Callout > Apply settings to instead of All.

The `0.`–`4.` prefixes make bucket order deterministic. They are labels, not numerical measurements. State-bar selections filter cards; other charts can cross-highlight according to their interaction settings.

## Interpretation

The project describes associations in a historical delivered-order sample. Destination state is not evidence of a cause. Geographic distances, sellers, carriers, product mix, customer characteristics and review timing were not controlled for. Small state samples and missing reviews affect interpretation. The final two late buckets have similar scores, with a slight increase in the 15+ group; do not describe the relationship as strictly monotonic.
