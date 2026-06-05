# ingest

Normalize common analysis inputs into the row/history shapes used by the rest of the toolkit.

Examples:

- `examples/demo.ns` shows records, columns, histories, and windowing in one run.
- `examples/infer_and_rows.ns` focuses on `inferStreamNames()` and `rowsFromRecords()`.
- `examples/column_and_series.ns` shows `rowsFromColumns()` and `rowsFromSeries()`.
- `examples/records_to_history.ns` shows the direct record-to-history path.
- `examples/window_rows.ns` shows `historyFromRows()`, `windowRows()`, and `windowHistory()`.
