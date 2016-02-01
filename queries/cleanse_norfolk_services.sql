-- cleanse services for Norfolk
update trans_clean set service = 'Other Inc Agency' where service like '%nc Agency' and entity_id = 'E2620_NCC_gov';
update trans_clean set service = 'Environment, Transport & Development' where service like '% Transport & Development' and entity_id = 'E2620_NCC_gov';
update trans_clean set service = 'Children''s Services' where service like '%s Services' and service like 'Children%' and entity_id = 'E2620_NCC_gov';
