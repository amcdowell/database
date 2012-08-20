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

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('source-attach-in-transaction-allowed-type', 'sql', 'Document (source file) must have an allowable current source type::::Documento deve essere di tipo consentito per la transazione',
 '#{id} of the source is requested. It checks if the source has a type which has the has_status attribute true.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('source-attach-in-transaction-allowed-type', now(), 'infinity', 
'select count(*)>0 as vl 
from source.source
where id= #{id} 
    and type_code in (select code 
        from source.administrative_source_type  
        where has_status)');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('source-attach-in-transaction-allowed-type', 'critical', 'pending', 'source', 2);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('documents-present', 'sql', 'Documents associated with a service must have a scanned image file (or other source file) attached::::Vi sono documenti allegati',
 '#{id}(service_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('documents-present', now(), 'infinity', 
 'SELECT (SUM(1) > 0) AS vl FROM transaction.transaction_source ts
	INNER JOIN transaction.transaction tn ON(ts.transaction_id = tn.id)
	WHERE tn.from_service_id= #{id}');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('documents-present', 'critical', 'complete', 'service', 5);

--------------------------------------------------------------------------------------
update system.br set display_name = id where display_name !=id;
