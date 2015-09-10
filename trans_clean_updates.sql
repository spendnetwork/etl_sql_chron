-- Updates the supplier_id of any files posted today and the previous day

UPDATE trans_clean
SET supplier_id = usm3.sid
FROM usm3
WHERE usm3.sss = trans_clean.supplier_source_string
AND usm3.mm = 'true'
AND trans_clean.supplier_id is null
AND trans_clean.created_at > now()::date - 1
;

-- Updates usm3 with new supplier_source_strings added to trans_clean in the last 2 days.

INSERT INTO usm3 (sss, sss_created_at)
SELECT DISTINCT ON (supplier_source_string) supplier_source_string, CURRENT_DATE
FROM trans_clean
WHERE supplier_id is null
AND supplier_source_string ~* '[A-Z]'
AND updated_at > (CURRENT_DATE - 2)
AND NOT EXISTS (SELECT sss FROM usm3 WHERE sss = trans_clean.supplier_source_string)
ORDER BY supplier_source_string ASC
RETURNING sss, sss_created_at
;

-- Capgemini into hmrc

UPDATE trans_clean
SET supplier_id = '00943935_com'
WHERE 
trans_clean.supplier_source_string = 'ASPIRE' AND
entity_id = 'ILR041_HRAC_gov'
AND trans_clean.supplier_id is null
AND trans_clean.created_at > now()::date - 10
;

-- Updates the entity index in trans_clean

UPDATE 
trans_clean
SET 
entity_pk=e.pk from (select entity_id, pk from entity) as e 
WHERE 
entity_pk is null AND
trans_clean.entity_id=e.entity_id
;

REFRESH MATERIALIZED VIEW tc_slim;
