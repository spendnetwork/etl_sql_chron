-- Refresh tc_slim materialized view.

SELECT 'Refreshing tc_slim.', CURRENT_TIMESTAMP;

REFRESH MATERIALIZED VIEW tc_slim;