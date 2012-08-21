insert into system.br(id, technical_type_code, feedback, technical_description) 
values('source-attach-in-transaction-no-pendings', 'sql', 'Document (source file) must not have pending status::::Documento non deve avere stato pendente',
 '#{id} of the source is requested. It checks if the source has already a record with the status pending.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('source-attach-in-transaction-no-pendings', now(), 'infinity', 
'select count(*)=0 as vl 
from source.source
where la_nr in (select la_nr 
    from source.source where id = #{id})
and status_code is not null and status_code in (''pending'')');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('source-attach-in-transaction-no-pendings', 'critical', 'pending', 'source', 4);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('source-attach-in-transaction-allowed-type', 'sql', 'Document to be registered must have an allowable current source type::::Documento deve essere di tipo consentito per la transazione',
 '#{id} of the source is requested. It checks if the source has a type which has the is_for_registration attribute true.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('source-attach-in-transaction-allowed-type', now(), 'infinity', 
'SELECT (COUNT(*) > 0) AS vl 
INNER JOIN source.administrative_source_type st ON (ss.type_code = st.code)
WHERE id = #{id} 
AND is_for_registration
AND st.status = ''c''');

INSERT INTO system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
VALUES('source-attach-in-transaction-allowed-type', 'critical', 'pending', 'source', 2);


--------------------------------------------------------------------------------------
update system.br set display_name = id where display_name !=id;
