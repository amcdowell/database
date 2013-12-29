INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br2-check-title-documents-not-old', 'sql', 'The scanned image of the title should be less than one week old.::::Отсканированная копия права собственности должна быть сделана менее недели назад.', 'Checks recorded date (recordation) against date at time of validation. Current allowable date difference is one week.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br2-check-title-documents-not-old', now(), 'infinity', 'SELECT s.recordation + 1 * interval ''1 week'' > NOW() AS vl
FROM application.application_uses_source a_s 
	INNER JOIN source.source s ON (a_s.source_id= s.id)
WHERE a_s.application_id = #{id}
AND s.type_code = ''title''');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br2-check-title-documents-not-old', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 510);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br4-check-sources-date-not-in-the-future', 'sql', 'Documents should have dates formalised by source agency that are not in the future.::::Документы должны иметь дату документа меньше текущей.', 'Checks the date of the document as recorded at lodgement (source.recordation) and checks it is not a date in the future');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br4-check-sources-date-not-in-the-future', now(), 'infinity', 'SELECT ss.recordation < NOW() as vl FROM application.application_uses_source a_s
	INNER JOIN source.source ss ON (a_s.source_id = ss.id)
	WHERE a_s.application_id = #{id}
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br4-check-sources-date-not-in-the-future', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 710);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br5-check-there-are-front-desk-services', 'sql', 'There are services in this application that should  be dealt in the front office. These services are of type: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::В заявлении имеются услуги, которые должны предоставляться в отделе приема документов. У ним относятся: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.', 'Checks the services in the applications to see if they are amongst services considered as front office services');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br5-check-there-are-front-desk-services', now(), 'infinity', 'SELECT CASE WHEN (COUNT(*)= 0) THEN NULL
	ELSE FALSE 
	end AS vl
FROM application.service
WHERE application_id = #{id} 
AND action_code != ''cancel''
AND request_type_code IN (''serviceEnquiry'', ''documentCopy'', ''cadastrePrint'', ''surveyPlanCopy'', ''titleSearch'')');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br5-check-there-are-front-desk-services', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 740);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br6-check-new-title-service-is-needed', 'sql', 'An application can be associated with a property which should have a digital title record.::::Заявление должно содержать недвижимость которая имеет электронную запись в базе.', 'Rule checks to see if there is a ba_unit record for the property identified for the application at lodgement');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br6-check-new-title-service-is-needed', now(), 'infinity', 'SELECT	CASE	WHEN (name_firstpart, name_lastpart) NOT IN (SELECT name_firstpart, name_lastpart FROM administrative.ba_unit)
			THEN (SELECT (COUNT(*) > 0) FROM application.service WHERE request_type_code = ''newFreehold'')
		ELSE TRUE
	END AS vl
FROM application.application_property  
WHERE application_id=#{id}
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br6-check-new-title-service-is-needed', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 730);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('applicant-name-to-owner-name-check', 'sql', 'The applicants name should be the same as (one of) the current owner(s)::::Имя заявителя должно быть таким же как у одного из текущих владельцев.', '#{id}(application.application.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('applicant-name-to-owner-name-check', now(), 'infinity', 'WITH apStr AS (SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS searchStr FROM party.party pty
		INNER JOIN application.application ap ON (ap.contact_person_id = pty.id)
		WHERE ap.id = #{id}),
     apStr2 AS (SELECT  COALESCE(last_name, '''') AS searchStr FROM party.party pty
		INNER JOIN application.application ap ON (ap.contact_person_id = pty.id)
		WHERE ap.id = #{id}),
    poaQuery AS (SELECT pty.name AS firstName, pty.last_name AS lastName FROM application.application_property ap
			INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
			INNER JOIN administrative.rrr rr ON ((ba.id = rr.ba_unit_id) AND (rr.status_code = ''current'') AND rr.is_primary)
			INNER JOIN administrative.rrr_share rs ON (rr.id = rs.rrr_id)
			INNER JOIN administrative.party_for_rrr pr ON (rs.rrr_id = pr.rrr_id)
			INNER JOIN party.party pty ON (pr.party_id = pty.id)
		WHERE ap.application_id = #{id})

SELECT CASE WHEN (COUNT(*) > 0) THEN TRUE
		ELSE NULL
	END AS vl FROM poaQuery
WHERE (compare_strings((SELECT searchStr FROM apStr), COALESCE(firstName, '''') || '' '' || COALESCE(lastName, '''')) OR compare_strings((SELECT searchStr FROM apStr2), COALESCE(firstName, '''') || '' '' || COALESCE(lastName, '''')))
ORDER BY vl
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('applicant-name-to-owner-name-check', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 410);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('app-current-caveat-and-no-remove-or-vary', 'sql', 'The identified property has a current or pending caveat registered on the title. The application must include a cancel or waiver/vary caveat service for registration to proceed.::::Выбранная недвижимость имеет арест. Заявление должно включать услугу снятия ареста для того чтобы продолжить регистрацию.', '#{id}(application.application.id) is requested. It checks if there is a caveat (pending or current) registered
 on the title and if the application does not have any service of type remove or vary caveat');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('app-current-caveat-and-no-remove-or-vary', now(), 'infinity', 'SELECT (SELECT (COUNT(*) > 0) FROM application.service sv 
  WHERE ((sv.application_id = ap.application_id) AND (sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')))) AS vl
FROM application.application_property ap 
  INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
  LEFT JOIN administrative.rrr ON (rrr.ba_unit_id = ba.id)
WHERE ((ap.application_id = #{id}) AND (rrr.type_code = ''caveat'') AND (rrr.status_code IN (''pending'', ''current'')))
ORDER BY 1 desc
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('app-current-caveat-and-no-remove-or-vary', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 550);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-on-approve-check-public-display', 'sql', 'The publication period must be completed.::::Период публикации должен быть завершен.', 'Checks the completion of the public display period for all instances of systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-on-approve-check-public-display', now(), 'infinity', '  SELECT (COUNT(*) = 0)  AS vl
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s, source.source ss
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = ''officialArea''::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = ''systematicRegn''::text AND s.status_code::text = ''completed''::text
   AND COALESCE(co.land_use_code, ''residential''::character varying)::text = lu.code::text
  and ss.reference_nr = co.name_lastpart
  and ss.reference_nr = co.name_lastpart and ss.expiration_date >= now() 
  and s.application_id = #{id};');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-on-approve-check-public-display', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 601);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('app-check-title-ref', 'sql', 'Invalid identifier for title::::Неверный идентификатор права собственности', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('app-check-title-ref', now(), 'infinity', 'WITH 	convertTitleApp	AS	(SELECT se.id FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newDigitalTitle''),
	titleRefChk	AS	(SELECT aprp.application_id FROM application.application_property aprp
				WHERE aprp.application_id= #{id} 
				AND SUBSTR(aprp.name_firstpart, 1) != ''N''
				AND NOT(aprp.name_lastpart ~ ''^[0-9]+$''))--isnumeric test
	
SELECT CASE 	WHEN (SELECT (COUNT(*) = 0) FROM convertTitleApp) THEN NULL
		WHEN (SELECT (COUNT(*) = 0) FROM titleRefChk) THEN TRUE
		ELSE FALSE
	END AS vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('app-check-title-ref', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 750);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br3-check-properties-are-not-historic', 'sql', 'All the titles identified for the application must be current.::::Все права собственности, относящиеся к заявлению должны иметь текущий (активный) статус.', 'Checks the title reference recorded at lodgement against titles in the database and if there is a ba_unit record it checks if it is current (PASS)');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br3-check-properties-are-not-historic', now(), 'infinity', 'WITH baUnitRecs AS	(SELECT ba.status_code AS status FROM application.application_property ap
				INNER JOIN administrative.ba_unit ba ON ((ap.name_lastpart = ba.name_lastpart) AND (ap.name_firstpart = ba.name_firstpart))
			WHERE application_id= #{id})

SELECT	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM baUnitRecs) THEN NULL
		WHEN (COUNT(*) = 0) THEN TRUE
		ELSE  FALSE
	END AS vl FROM baUnitRecs
WHERE status = ''historic''
ORDER BY 1
LIMIT 1 ');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br3-check-properties-are-not-historic', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 180);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br1-check-required-sources-are-present', 'sql', 'All documents required for the services in this application are present.::::Все документы, необходимые для указанных услуг должны присутствовать в заявлении.', 'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br1-check-required-sources-are-present', now(), 'infinity', 'WITH reqForAp AS 	(SELECT DISTINCT ON(r_s.source_type_code) r_s.source_type_code AS typeCode
			FROM application.request_type_requires_source_type r_s 
				INNER JOIN application.service sv ON((r_s.request_type_code = sv.request_type_code) AND (sv.status_code != ''cancelled''))
			WHERE sv.application_id = #{id}),
     inclInAp AS	(SELECT DISTINCT ON (sc.id) sc.id FROM reqForAp req
				INNER JOIN source.source sc ON (req.typeCode = sc.type_code)
				INNER JOIN application.application_uses_source a_s ON ((sc.id = a_s.source_id) AND (a_s.application_id = #{id})))
SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM reqForAp) THEN NULL
		WHEN ((SELECT COUNT(*) FROM inclInAp) - (SELECT COUNT(*) FROM reqForAp) >= 0) THEN TRUE
		ELSE FALSE
	END AS vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br1-check-required-sources-are-present', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 210);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br8-check-has-services', 'sql', 'An application must have at least one service::::Заявление должно иметь хотя бы одну услугу.', 'Checks that an application has at least one service. When this rule fails you should add a service to the application or cancel the application.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br8-check-has-services', now(), 'infinity', 'SELECT (COUNT(*) > 0) AS vl
FROM application.service sv 
WHERE sv.application_id = #{id}
AND sv.status_code != ''cancelled''');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br8-check-has-services', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 260);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-br7-check-sources-have-documents', 'sql', 'Documents lodged with an application should have a scanned image file (or other source file) attached::::Документы присутствующие в заявлении должны иметь прикрепленную отсканированную копию.', 'Checks that each document lodged with the application has a scanned image file (or other digital source file) stored in the SOLA database. To remedy the failure of the business rule add the scanned image to the document record through the Document Tab in the Application form or use the Document Toolbar item in the Main form.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-br7-check-sources-have-documents', now(), 'infinity', 'SELECT ext_archive_id IS NOT NULL AS vl
FROM source.source 
WHERE id IN (SELECT source_id FROM application.application_uses_source WHERE application_id= #{id})');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-br7-check-sources-have-documents', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 570);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-approve-cancel-old-titles', 'sql', 'An application including a new freehold service must also terminate the parent title(s) with a cancel title service.::::Identificati titoli esistenti. Prego terminare i titoli esistenti usando il servizio di Cancellazione Titolo', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-approve-cancel-old-titles', now(), 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
	parent_titles	AS	(SELECT DISTINCT ON (ba.id) ba.id AS liveTitle, ba.status_code FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE s.application_id = #{id}
				AND ba.status_code = ''pending'')
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(liveTitle) FROM parent_titles) > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-approve-cancel-old-titles', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 250);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-cancel-property-service-before-new-title', 'sql', 'New Freehold title service must come before Cancel Title service in the application.::::Услуга нового права собственности (свободное) должна быть перед услугой отмены права собственности.
system.br.application-approve-cancel-old-titles.feedback Заявление с услугой нового права собственности (свободное) должно также включать услугу ликвидации родительского права собственности.', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-cancel-property-service-before-new-title', now(), 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
 	orderCancel	AS	(SELECT service_order + 1 AS cancelSequence FROM application.service sv 
				WHERE sv.application_id = #{id}
				AND sv.request_type_code = ''cancelProperty'' LIMIT 1),	
 	orderNew	AS	(SELECT service_order + 1 AS newSequence FROM application.service sv 
				WHERE sv.application_id = #{id}
				AND sv.request_type_code = ''newFreehold'' LIMIT 1)
				
SELECT CASE WHEN fhCheck IS TRUE THEN ((SELECT cancelSequence FROM orderCancel) - (SELECT newSequence FROM orderNew)) > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-cancel-property-service-before-new-title', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 390);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('cancel-title-check-rrr-cancelled', 'sql', 'All rights and restrictions on the title to be cancelled must be transfered or cancelled in this application.::::Все права и ограничения недвижимости, которая будет ликвидирована должны быть переданы или ликвидированы в этом же заявлении.', '#{id}(application_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('cancel-title-check-rrr-cancelled', now(), 'infinity', 'WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rr1.nr) rr1.nr FROM administrative.rrr rr1 
				INNER JOIN transaction.transaction tn ON (rr1.transaction_id = tn.id)
				INNER JOIN application.service sv1 ON (tn.from_service_id = sv1.id) 
				WHERE sv1.application_id = #{id}
				AND rr1.status_code = ''pending''),
								
	target_title	AS	(SELECT prp.ba_unit_id AS liveTitle FROM application.application_property prp
				WHERE prp.application_id = #{id}),
				
	cancelPropApp	AS	(SELECT sv3.id AS fhCheck, sv3.request_type_code FROM application.service sv3
				WHERE sv3.application_id = #{id}
				AND sv3.request_type_code = ''cancelProperty''),
					
	current_rrr AS 		(SELECT DISTINCT ON(rr2.nr) rr2.nr FROM administrative.rrr rr2 
				WHERE rr2.status_code = ''current''
				AND rr2.ba_unit_id IN (SELECT liveTitle FROM target_title)),

	rem_property_rrr AS	(SELECT nr FROM current_rrr WHERE nr NOT IN (SELECT nr FROM pending_property_rrr))
				
SELECT CASE 	WHEN (SELECT (COUNT(*) = 0) FROM cancelPropApp) THEN NULL
		WHEN (SELECT (COUNT(*) = 0) FROM pending_property_rrr) THEN FALSE
		WHEN (SELECT (COUNT(*) = 0) FROM rem_property_rrr) THEN TRUE
		ELSE FALSE
	END AS vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cancel-title-check-rrr-cancelled', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 150);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('app-title-has-primary-right', 'sql', 'A single primary right (such as ownership) must be identified whenever a new title record is created::::Единственное право собственности должно быть зарегистрировано для нового объекта недвижимости.', '#{id}(application.application.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('app-title-has-primary-right', now(), 'infinity', 'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code IN (''newFreehold'', ''newApartment'', ''newState'')),
	start_titles	AS	(SELECT DISTINCT ON (pt.from_ba_unit_id) pt.from_ba_unit_id, s.application_id FROM administrative.rrr rr 
				INNER JOIN administrative.required_relationship_baunit pt ON (rr.ba_unit_id = pt.to_ba_unit_id)
				INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}),
	start_primary_rrr AS 	(SELECT DISTINCT ON(pp.nr) pp.nr FROM administrative.rrr pp 
				WHERE pp.status_code != ''cancelled''
				AND pp.is_primary
				AND pp.ba_unit_id IN (SELECT from_ba_unit_id  FROM start_titles))

SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT sum(1) FROM start_primary_rrr) = 1
		ELSE NULL
	END AS vl FROM newTitleApp');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('app-title-has-primary-right', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 100);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-verifies-identification', 'sql', 'Personal identification verification should be attached to the application.::::Персональный идентификационный документ должен быть прикреплен к заявлению.', '#{id}(application.application.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-verifies-identification', now(), 'infinity', 'SELECT (CASE 	WHEN app.id is  NULL THEN NULL
		ELSE COUNT(1) > 0
	 END) as vl
FROM application.application app
  LEFT JOIN application.application_uses_source aus ON (aus.application_id = app.id)
  LEFT JOIN source.source sc ON ((sc.id = aus.source_id) AND (sc.type_code = ''idVerification''))
WHERE app.id= #{id}
GROUP BY app.id
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-verifies-identification', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 530);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('app-allowable-primary-right-for-new-title', 'sql', 'An allowable primary right (ownership, apartment, State ownership, lease) must be identified for a new title::::Одно из допустимых прав собственности такое как - право собственности, право собственности на квартиру, государственное право собственности, аренда, должно быть зарегистрировано для нового объекта недвижимости.', '#{id}(application.application.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('app-allowable-primary-right-for-new-title', now(), 'infinity', 'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code IN (''newFreehold'', ''newApartment'', ''newState'')),
	existTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.application_property prp1
					INNER JOIN application.service sv ON (prp1.application_id = sv.application_id)
				WHERE prp1.application_id = #{id}
				AND sv.request_type_code = ''newDigitalTitle'')
				
 SELECT CASE WHEN (SELECT ((SELECT * FROM newTitleApp) OR (SELECT * FROM existTitleApp)) IS NULL) THEN NULL 
	WHEN ((SELECT COUNT(*) FROM existTitleApp) = 0) THEN	(SELECT (COUNT(*) = 0) FROM application.application_property prp2
									INNER JOIN administrative.rrr rr2 
										ON ((prp2.ba_unit_id = rr2.ba_unit_id) AND NOT(rr2.is_primary OR (rr2.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease''))))
								 WHERE prp2.application_id = #{id} )
	ELSE	(SELECT (COUNT(*) = 0) FROM application.service sv2 
			 INNER JOIN transaction.transaction tn2 ON (sv2.id = tn2.from_service_id) 
			 INNER JOIN administrative.ba_unit ba2 ON (tn2.id = ba2.transaction_id) 
			 INNER JOIN administrative.rrr rr3 
				ON ((ba2.id = rr3.ba_unit_id) AND NOT(rr3.is_primary OR (rr3.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease''))))
			 WHERE sv2.application_id = #{id} )
	END AS vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('app-allowable-primary-right-for-new-title', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 10);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-on-approve-check-services-status', 'sql', 'All services in the application must have the status ''cancelled'' or ''completed''.::::Все услуги в заявлении должны иметь статус ''Отменен'' или ''Завершен''.', 'Checks the service.status_code for all instances of service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-on-approve-check-services-status', now(), 'infinity', 'SELECT (COUNT(*) = 0)  AS vl FROM application.service sv 
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-on-approve-check-services-status', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 270);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-on-approve-check-services-without-transaction', 'sql', 'Within an application,all services making changes to core records must be completed and have utilised an instance of transaction before application can be approved.::::Все услуги в заявлении, которые внесли изменения в основные данные, должны быть завершены перед тем как заявление может быть одобрено.', 'Checks that all services have the status of completed and that there is a transaction record referring to each service record through the field from_service_id');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-on-approve-check-services-without-transaction', now(), 'infinity', 'SELECT (COUNT(*) = 0) AS vl FROM application.service sv 
	INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-on-approve-check-services-without-transaction', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 330);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-on-approve-check-systematic-reg-no-objection', 'sql', 'There must be no objection against the systematic registration::::Не должно быть каких-либо обжалований по системной регистрации.', 'Checks the absence of objections for systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-on-approve-check-systematic-reg-no-objection', now(), 'infinity', '  SELECT (COUNT(*) = 0)  AS vl
   FROM  application.application aa, 
   application.service s
  WHERE  s.application_id::text = aa.id::text 
  AND s.application_id::text in (select s.application_id 
                                 FROM application.service s
                                 where s.request_type_code::text = ''systematicRegn''::text
                                 and s.application_id = #{id}) 
  AND s.request_type_code::text = ''lodgeObjection''::text
  AND s.status_code::text != ''cancelled''::text
  and s.application_id = #{id};');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-on-approve-check-systematic-reg-no-objection', 'application', 'approve', NULL, NULL, NULL, NULL, 'critical', 600);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('newtitle-br24-check-rrr-accounted', 'sql', 'All rights and restrictions from existing title(s) must be accounted for in the new titles created in this application.::::Все права и ограничения существующих объектов недвижимости должны быть учтены в новых объектах недвижимости, создаваемых в этом заявлении.', '#{id}(application_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('newtitle-br24-check-rrr-accounted', now(), 'infinity', '
WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rp.nr) rp.nr FROM administrative.rrr rp 
				INNER JOIN transaction.transaction tn ON (rp.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}
				AND rp.status_code = ''pending''),
								
	parent_titles	AS	(SELECT DISTINCT ON (ba.id) ba.id AS liveTitle, from_ba_unit_id FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE s.application_id = #{id}),
				
	new_titles	AS	(SELECT DISTINCT ON (rr.ba_unit_id) rr.ba_unit_id FROM administrative.rrr rr 
				INNER JOIN administrative.ba_unit nt ON (rr.ba_unit_id = nt.id)
				INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}),
	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
					
	prior_property_rrr AS 	(SELECT DISTINCT ON(pp.nr) pp.nr FROM administrative.rrr pp 
				WHERE pp.status_code = ''current''
				AND pp.ba_unit_id IN (SELECT from_ba_unit_id  FROM parent_titles)),

	rem_property_rrr AS	(SELECT nr FROM prior_property_rrr WHERE nr NOT IN (SELECT nr FROM pending_property_rrr))
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(nr) FROM rem_property_rrr) = 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('newtitle-br24-check-rrr-accounted', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 160);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('application-for-new-title-has-cancel-property-service', 'sql', 'When a new title is created there must be a cancel title service in the application for the parent title.::::Когда создается новый объект недвижимости, должна присутствовать услуга ликвидации недвижимости в заявлении родительской недвижимости.', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('application-for-new-title-has-cancel-property-service', now(), 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold'')
					
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(id) FROM application.service sv 
					WHERE sv.application_id = #{id}
					AND sv.request_type_code = ''cancelProperty'') > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('application-for-new-title-has-cancel-property-service', 'application', 'validate', NULL, NULL, NULL, NULL, 'critical', 1);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('app-other-app-with-caveat', 'sql', 'The identified property is affected by another live application that includes a service to register a caveat. An application with a cancel or waiver/vary caveat service must be registered before this application can proceed.::::Выбранная недвижимость используется в другом заявлении, находящемся в обработке и включающее регистрацию ареста. Заявление с услугой отмены ареста должно быть зарегистрировано для того чтобы продолжить с текущим заявлением.', '#{id}(application.application.id) is requested.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('app-other-app-with-caveat', now(), 'infinity', 'SELECT (SELECT COUNT(*) > 0 FROM application.service sv WHERE sv.application_id = ap.application_id AND sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')) AS vl
FROM application.application_property ap
	INNER JOIN application.application_property ap2 ON (((ap.name_firstpart, ap.name_lastpart) = (ap2.name_firstpart, ap2.name_lastpart)) AND (ap.id != ap2.id))
	INNER JOIN application.application app2 ON (ap2.application_id = app2.id)
	INNER JOIN application.service sv2 ON ((app2.id = sv2.application_id) AND (sv2.request_type_code = ''caveat'') AND (sv2.status_code != ''cancelled'') AND (app2.status_code NOT IN (''completed'', ''annulled'')))
WHERE ap.application_id = #{id} 
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('app-other-app-with-caveat', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 590);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
