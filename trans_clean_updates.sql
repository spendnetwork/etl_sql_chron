
-- Updates the supplier_id of any files posted today and the previous day

SELECT 'Updating trans_clean supplier_ids.', CURRENT_TIMESTAMP;

UPDATE trans_clean
SET supplier_id = usm3.sid
FROM usm3
WHERE usm3.sss = trans_clean.supplier_source_string
AND usm3.mm = 'true'
AND trans_clean.supplier_id is null
AND trans_clean.created_at > now()::date - 1
;


-- Capgemini into hmrc

SELECT 'Updating trans_clean - Capgemini into hmrc.', CURRENT_TIMESTAMP;

UPDATE trans_clean
SET supplier_id = '00943935_com'
WHERE 
trans_clean.supplier_source_string = 'ASPIRE' AND
entity_id = 'ILR041_HRAC_gov'
AND trans_clean.supplier_id is null
AND trans_clean.created_at > now()::date - 10
;


-- Updates the entity index in trans_clean

SELECT 'Updating entity index.', CURRENT_TIMESTAMP;

UPDATE 
trans_clean
SET 
entity_pk=e.pk from (select entity_id, pk from entity) as e 
WHERE 
entity_pk is null AND
trans_clean.entity_id=e.entity_id
RETURNING entity_pk, e.entity_id
;


SELECT 'Refreshing tc_slim.', CURRENT_TIMESTAMP;

REFRESH MATERIALIZED VIEW tc_slim;


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


-- End time
SELECT 'Finished', CURRENT_TIMESTAMP;