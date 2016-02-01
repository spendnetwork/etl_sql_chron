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