# Validation record

## Reference results

`expected_results.csv` records results observed during the project's PostgreSQL and Power BI walkthrough. SQL outputs were supplied from pgAdmin; dashboard values, tooltip counts and filter behavior were confirmed in Power BI.

The packaged SQL files consolidate that analysis into reproducible scripts. They have not yet been rerun against the user's PostgreSQL database as a complete file sequence during packaging. Do not interpret this record as a new end-to-end database execution.

## Reconciliation

- All orders: 99,441 rows and distinct order IDs.
- Customers join: 99,441 rows, 99,441 matches, zero unmatched orders.
- Enriched view: 99,441 rows and distinct order IDs; 98,673 nonempty order scores.
- Delivered status: 96,478 = 96,470 with an actual date + 8 without one.
- Timeliness: 96,470 = 89,936 on time + 6,534 late.
- Rated eligible orders: 95,824 = 89,443 on time + 6,381 late.
- Missing eligible scores: 646 = 493 on time + 153 late.
- Late rating groups: 6,381 = 1,852 + 1,748 + 1,446 + 1,335.
- SP and RJ: 3,315 / 6,534 = 50.7% of late orders, rounded to one decimal.

## Interactive checks confirmed in the walkthrough

- KPI cards show 96,478, 6.77%, and 12.56 with the full date range and no state selection.
- State rates start with AL 21.41%, MA 17.43%, and SE 15.22%.
- State late counts start with SP 1,820, RJ 1,495, and MG 519.
- Review-group means match the expected results.
- Selecting RJ changes the late-rate card to 12.11%; clearing the selection restores 6.77%.
- Narrowing the purchase-date range changes the visuals; restoring the range restores the headline values.

## Packaging checks

The PBIX was inspected read-only as a ZIP container. Its report definition contains three KPI cards, two state bar charts, one delay-group column chart, a purchase-date Between slicer, a definitions text box and a report-title text box. Chart titles, hidden subtitles and visual field references were confirmed from that definition.

The source DAX files document the formulas used in the walkthrough. The binary semantic model has not been independently decompiled to compare every formula byte for byte. Reconcile the formulas in Power BI when modifying the model.

The package check report is stored in `package_checks.json`. It covers file integrity, local document links, expected-result arithmetic and report visual metadata. These checks do not replace rerunning SQL or refreshing the report against a rebuilt database.
