-- Refresh tc_slim materialized view.
-- timeout after 54 mins.

SELECT 'Refreshing tc_slim.', CURRENT_TIMESTAMP;

REFRESH MATERIALIZED VIEW tc_slim;