-- Updates the supplier_id of any files posted today and the previous day.
-- ~30 mins

SELECT 'Updating trans_clean supplier_ids.', CURRENT_TIMESTAMP;

UPDATE trans_clean
SET supplier_id = usm3.sid
FROM usm3
WHERE usm3.sss = trans_clean.supplier_source_string
AND usm3.mm = 'true'
AND trans_clean.supplier_id is null
--AND trans_clean.created_at > now()::date - 1
;