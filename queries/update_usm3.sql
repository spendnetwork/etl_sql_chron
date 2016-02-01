-- Updates usm3 with new supplier_source_strings added to trans_clean in the last 2 days.

SELECT 'Inserting new sss into usm3', CURRENT_TIMESTAMP;

INSERT INTO usm3 (sss, sss_created_at)
SELECT DISTINCT ON (supplier_source_string) supplier_source_string, CURRENT_DATE
FROM tc_slim
WHERE supplier_id is null
AND supplier_source_string ~* '[A-Z]'
AND NOT EXISTS (SELECT 1 FROM usm3 WHERE sss = supplier_source_string)
RETURNING sss, sss_created_at
;