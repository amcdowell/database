--delete from system.br_definition where br_id = 'source-attach-in-transaction-no-pendings';
--delete from system.br_validation where br_id = 'source-attach-in-transaction-no-pendings';
--delete from system.br where id = 'source-attach-in-transaction-no-pendings';
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('source-attach-in-transaction-no-pendings', 'sql', 'Document (source file) must not have pending status::::Documento non deve avere stato pendente',
 '#{id}(source.source.id) is requested. It checks if the source has already a record with the status pending.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('source-attach-in-transaction-no-pendings', now(), 'infinity', 
'select count(*)=0 as vl 
from source.source
where la_nr in (select la_nr 
    from source.source where id = #{id})
and status_code is not null and status_code in (''pending'')');

INSERT INTO system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
VALUES ('source-attach-in-transaction-no-pendings', 'critical', 'pending', 'source', 'regnPowerOfAttorney', 4);

----------------------------------------------------------------------------------------------------
--delete from system.br_definition where br_id = 'source-attach-in-transaction-allowed-type';
--delete from system.br_validation where br_id = 'source-attach-in-transaction-allowed-type';
--delete from system.br where id = 'source-attach-in-transaction-allowed-type';
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('source-attach-in-transaction-allowed-type', 'sql', 'Document to be registered must have an allowable current source type::::Documento deve essere di tipo consentito per la transazione',
 '#{id}(source.source.id) is requested. It checks if the source has a type which has the is_for_registration attribute true.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('source-attach-in-transaction-allowed-type', now(), 'infinity', 
'SELECT (COUNT(*) > 0) AS vl FROM source.source ss
INNER JOIN source.administrative_source_type st ON (ss.type_code = st.code)
WHERE id = #{id} 
AND is_for_registration
AND st.status = ''c''');

INSERT INTO system.br_validation(br_id, severity_code, target_code,  order_of_execution) 
VALUES('source-attach-in-transaction-allowed-type', 'warning', 'source', 2);

--INSERT INTO system.br_validation(br_id, severity_code, target_code, target_request_type_code, order_of_execution) 
--VALUES('source-attach-in-transaction-allowed-type', 'warning', 'source', 'regnStandardDocument', 5);

INSERT INTO system.br_validation(br_id, severity_code, target_code,  order_of_execution) 
VALUES('source-attach-in-transaction-allowed-type', 'critical', 'source',  6);

--INSERT INTO system.br_validation(br_id, severity_code, target_code, target_request_type_code, order_of_execution) 
--VALUES('source-attach-in-transaction-allowed-type', 'critical', 'source', 'regnStandardDocument', 7);

--------------------------------------------------------------------------------------
update system.br set display_name = id where display_name !=id;
