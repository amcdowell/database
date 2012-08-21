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

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('documents-present', 'sql', 'Documents associated with a service must have a scanned image file (or other source file) attached::::Vi sono documenti allegati',
 '#{id}(service_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('documents-present', now(), 'infinity', 
 'WITH cadastreDocs AS 	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN transaction.transaction_source ts ON (ss.id = ts.source_id)
				INNER JOIN transaction.transaction tn ON(ts.transaction_id = tn.id)
				WHERE tn.from_service_id = #{id}
				ORDER BY 1),
	rrrDocs AS	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN administrative.source_describes_rrr sr ON (ss.id = sr.source_id)
				INNER JOIN administrative.rrr rr ON (sr.rrr_id = rr.id)
				INNER JOIN transaction.transaction tn ON(rr.transaction_id = tn.id)
				WHERE tn.from_service_id = #{id}
				ORDER BY 1),
     titleDocs AS	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN administrative.source_describes_ba_unit su ON (ss.id = su.source_id)
				WHERE su.ba_unit_id IN (SELECT  ba_unit_id FROM rrrDocs)
				ORDER BY 1),
     regDocs AS		(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN transaction.transaction tn ON (ss.transaction_id = tn.id)
				INNER JOIN application.service sv ON (tn.from_service_id = sv.id)
				WHERE sv.id = #{id}
				AND sv.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'', ''cnclPowerOfAttorney'', ''cnclStandardDocument'')
				ORDER BY 1),
     serviceDocs AS	((SELECT * FROM rrrDocs) UNION (SELECT * FROM cadastreDocs) UNION (SELECT * FROM titleDocs) UNION (SELECT * FROM regDocs))
     
     
 SELECT (((SELECT COUNT(*) FROM serviceDocs) - (SELECT COUNT(*) FROM serviceDocs WHERE ext_archive_id IS NOT NULL)) = 0) AS vl');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('documents-present', 'critical', 'complete', 'service', 5);

--------------------------------------------------------------------------------------
update system.br set display_name = id where display_name !=id;
