# Source data

Download the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Follow the source page's license and attribution terms.

Create `data/raw/` and place these original files inside it:

| CSV | PostgreSQL table |
|---|---|
| `olist_orders_dataset.csv` | `public.orders` |
| `olist_customers_dataset.csv` | `public.customers` |
| `olist_order_reviews_dataset.csv` | `public.reviews` |

The rest of the download is not required for the current analysis. Keep the original CSV filenames and headers. Files in `data/raw/` are ignored by Git.

The analysis uses anonymized identifiers. `customer_id` is the order-to-customer-record join key; it is not a count of distinct people. `customer_unique_id` is available in the source but is not used as the join key in this project.

Dataset credit belongs to Olist and the dataset contributors. This repository is an independent educational analysis, not an official Olist report.
