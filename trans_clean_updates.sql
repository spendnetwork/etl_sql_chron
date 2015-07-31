-- Updates the supplier_id of any files posted today and the previous day

UPDATE trans_clean
SET supplier_id = usm3.sid
FROM usm3
WHERE usm3.sss = trans_clean.supplier_source_string
AND usm3.mm = 'true'
AND trans_clean.supplier_id is null
AND trans_clean.created_at > now()::date - 1
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
