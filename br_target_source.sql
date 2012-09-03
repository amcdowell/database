
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('source-attach-in-transaction-no-pendings', 'sql', 'Document (source file) must not be duplicated::::Documento non deve avere stato pendente',
 '#{id}(source.source.id) is requested. It checks if the source has already a record with the status pending.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('source-attach-in-transaction-no-pendings', now(), 'infinity', 
'WITH checkServiceType	AS	(SELECT COUNT(*) AS cnt FROM application.service sv1
					INNER JOIN transaction.transaction tn ON (sv1.id = tn.from_service_id)
					INNER JOIN source.source sc1 ON (tn.id = sc1.transaction_id)
				 WHERE sc1.id = #{id}
				 AND sv1.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'')),
	checkSource	AS	(SELECT COUNT(*) AS cnt FROM source.source sc2
				 WHERE sc2.id = #{id}
				 AND sc2.status_code = ''pending'')

SELECT	CASE 	WHEN (SELECT (cnt = 0) FROM checkServiceType) THEN NULL
		WHEN (SELECT (cnt = 0) FROM checkSource) THEN TRUE
		ELSE FALSE
	END AS vl');

INSERT INTO system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
VALUES ('source-attach-in-transaction-no-pendings', 'critical', 'pending', 'source', 220);

----------------------------------------------------------------------------------------------------


INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('source-attach-in-transaction-allowed-type', 'sql', 'Document to be registered must have an allowable and current source type::::Documento deve essere di tipo consentito per la transazione',
 '#{id}(source.source.id) is requested. It checks if the source has a type which has the is_for_registration attribute true.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('source-attach-in-transaction-allowed-type', now(), 'infinity', 
'WITH checkServiceType	AS	(SELECT COUNT(*) AS cnt FROM application.service sv1
					INNER JOIN transaction.transaction tn ON (sv1.id = tn.from_service_id)
					INNER JOIN source.source sc1 ON (tn.id = sc1.transaction_id)
				 WHERE tn.id = #{id}
				 AND sv1.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'')),
	allSource	AS	(SELECT sc2.id AS sid FROM source.source sc2
				 WHERE sc2.transaction_id = #{id}),
	checkSource	AS	(SELECT sid FROM allSource
				 WHERE sid IN (SELECT sc3.id FROM source.source sc3
							INNER JOIN source.administrative_source_type st ON (sc3.type_code = st.code)
						WHERE sc3.id = #{id}
						AND st.is_for_registration
						AND st.status = ''c''))

SELECT	CASE 	WHEN (SELECT (cnt = 0) FROM checkServiceType) THEN NULL
		WHEN (SELECT ((SELECT COUNT(*) FROM allSource) - (SELECT COUNT(*) FROM checkSource)) = 0) THEN TRUE
		ELSE FALSE
	END AS vl');

INSERT INTO system.br_validation(br_id, severity_code, target_code, target_reg_moment, order_of_execution) 
VALUES('source-attach-in-transaction-allowed-type', 'critical', 'source', 'pending',  560);


--------------------------------------------------------------------------------------
update system.br set display_name = id where display_name !=id;
