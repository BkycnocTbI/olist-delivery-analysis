-- psql-only alternative to pgAdmin CSV import. Run from the repository root.
-- Paths are client-side. Source tables must be empty; the import is atomic.
\set ON_ERROR_STOP on
BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.orders)
       OR EXISTS (SELECT 1 FROM public.customers)
       OR EXISTS (SELECT 1 FROM public.reviews) THEN
        RAISE EXCEPTION 'Source tables are not empty. Skip import when using an already loaded database.';
    END IF;
END;
$$;

\copy public.orders FROM 'data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy public.customers FROM 'data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy public.reviews FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

COMMIT;
