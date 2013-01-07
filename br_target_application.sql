----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br8-check-has-services', 'sql', 
'An application must have at least one service::::La Pratica ha almeno un documento allegato',
'Checks that an application has at least one service. When this rule fails you should add a service to the application or cancel the application.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br8-check-has-services', now(), 'infinity', 
'SELECT (COUNT(*) > 0) AS vl
FROM application.service sv 
WHERE sv.application_id = #{id}
AND sv.status_code != ''cancelled''');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br8-check-has-services', 'application', 'validate', 'critical', 260);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br7-check-sources-have-documents', 'sql', 
'Documents lodged with an application should have a scanned image file (or other source file) attached::::Alcuni dei documenti per questa pratica non hanno una immagine scannerizzata allegata',
'Checks that each document lodged with the application has a scanned image file (or other digital source file) stored in the SOLA database. To remedy the failure of the business rule add the scanned image to the document record through the Document Tab in the Application form or use the Document Toolbar item in the Main form.' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br7-check-sources-have-documents', now(), 'infinity', 
'SELECT ext_archive_id IS NOT NULL AS vl
FROM source.source 
WHERE id IN (SELECT source_id FROM application.application_uses_source WHERE application_id= #{id})');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br7-check-sources-have-documents', 'application', 'validate', 'warning', 570);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br1-check-required-sources-are-present', 'sql', 
'All documents required for the services in this application are present.::::Sono presenti tutti i documenti richiesti per il servizio',
'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br1-check-required-sources-are-present', now(), 'infinity', 
'WITH reqForAp AS 	(SELECT DISTINCT ON(r_s.source_type_code) r_s.source_type_code AS typeCode
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

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br1-check-required-sources-are-present', 'application', 'validate', 'critical', 210);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br2-check-title-documents-not-old', 'sql', 
'The scanned image of the title should be less than one week old.::::Tutte le immagini scannerizzate del titolo hanno al massimo una settimana',
'Checks recorded date (recordation) against date at time of validation. Current allowable date difference is one week.' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br2-check-title-documents-not-old', NOW(), 'infinity', 
'SELECT s.recordation + 1 * interval ''1 week'' > NOW() AS vl
FROM application.application_uses_source a_s 
	INNER JOIN source.source s ON (a_s.source_id= s.id)
WHERE a_s.application_id = #{id}
AND s.type_code = ''title''');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br2-check-title-documents-not-old', 'application', 'validate', 'medium', 510);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br3-check-properties-are-not-historic', 'sql', 
'All the titles identified for the application must be current.::::Tutte le proprieta identificate per la pratica non sono storiche',
'Checks the title reference recorded at lodgement against titles in the database and if there is a ba_unit record it checks if it is current (PASS)' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br3-check-properties-are-not-historic', now(), 'infinity', 
'WITH baUnitRecs AS	(SELECT ba.status_code AS status FROM application.application_property ap
				INNER JOIN administrative.ba_unit ba ON ((ap.name_lastpart = ba.name_lastpart) AND (ap.name_firstpart = ba.name_firstpart))
			WHERE application_id= #{id})

SELECT	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM baUnitRecs) THEN NULL
		WHEN (COUNT(*) = 0) THEN TRUE
		ELSE  FALSE
	END AS vl FROM baUnitRecs
WHERE status = ''historic''
ORDER BY 1
LIMIT 1 ');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br3-check-properties-are-not-historic', 'application', 'validate', 'critical', 180);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br4-check-sources-date-not-in-the-future', 'sql', 
'Documents should have dates formalised by source agency that are not in the future.::::Nessun documento ha le date di inoltro per il futuro',
'Checks the date of the document as recorded at lodgement (source.recordation) and checks it is not a date in the future' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br4-check-sources-date-not-in-the-future', now(), 'infinity', 
'SELECT ss.recordation < NOW() as vl FROM application.application_uses_source a_s
	INNER JOIN source.source ss ON (a_s.source_id = ss.id)
	WHERE a_s.application_id = #{id}
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br4-check-sources-date-not-in-the-future', 'application', 'validate', 'warning', 710);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br5-check-there-are-front-desk-services', 'sql', 
'There are services in this application that should  be dealt in the front office. These services are of type: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::Ci sono servizi che dovrebbero essere svolti dal front office. Questi servizi sono di tipo:Richiesta Servizio, Copia Documento, Stampa Catastale, Copia Piano Perizia, Ricerca Titolo',
'Checks the services in the applications to see if they are amongst services considered as front office services' );
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br5-check-there-are-front-desk-services', now(), 'infinity', 
'SELECT CASE WHEN (COUNT(*)= 0) THEN NULL
	ELSE FALSE 
	end AS vl
FROM application.service
WHERE application_id = #{id} 
AND action_code != ''cancel''
AND request_type_code IN (''serviceEnquiry'', ''documentCopy'', ''cadastrePrint'', ''surveyPlanCopy'', ''titleSearch'')');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br5-check-there-are-front-desk-services', 'application', 'validate', 'warning', 740);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-br6-check-new-title-service-is-needed', 'sql', 
'An application can be associated with a property which should have a digital title record.::::Non esiste un formato digitale per questa proprieta. Aggiungere un Nuovo Titolo Digitale alla vostra pratica',
'Rule checks to see if there is a ba_unit record for the property identified for the application at lodgement' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-br6-check-new-title-service-is-needed', now(), 'infinity', 
'SELECT	CASE	WHEN (name_firstpart, name_lastpart) NOT IN (SELECT name_firstpart, name_lastpart FROM administrative.ba_unit)
			THEN (SELECT (COUNT(*) > 0) FROM application.service WHERE request_type_code = ''newFreehold'')
		ELSE TRUE
	END AS vl
FROM application.application_property  
WHERE application_id=#{id}
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-br6-check-new-title-service-is-needed', 'application', 'validate', 'warning', 730);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('applicant-name-to-owner-name-check', 'sql', 
'The applicants name should be the same as (one of) the current owner(s)::::Il nome del richiedente differisce da quello dei proprietari registrati',
 '#{id}(application.application.id) is requested');
--delete from system.br_definition where br_id = 'applicant-name-to-owner-name-check'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('applicant-name-to-owner-name-check', NOW(), 'infinity', 
'WITH apStr AS (SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS searchStr FROM party.party pty
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

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('applicant-name-to-owner-name-check', 'application', 'validate', 'warning', 410);


----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('app-current-caveat-and-no-remove-or-vary', 'sql', 
'The identified property has a current or pending caveat registered on the title. The application must include a cancel or waiver/vary caveat service for registration to proceed.::::Per questo titolo siste un diritto di prelazione pendente o corrente e la pratica non include un servizio di cancellazione o di variazione prelazione ',
 '#{id}(application.application.id) is requested. It checks if there is a caveat (pending or current) registered
 on the title and if the application does not have any service of type remove or vary caveat');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('app-current-caveat-and-no-remove-or-vary', now(), 'infinity', 
'SELECT (SELECT (COUNT(*) > 0) FROM application.service sv 
  WHERE ((sv.application_id = ap.application_id) AND (sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')))) AS vl
FROM application.application_property ap 
  INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
  LEFT JOIN administrative.rrr ON (rrr.ba_unit_id = ba.id)
WHERE ((ap.application_id = #{id}) AND (rrr.type_code = ''caveat'') AND (rrr.status_code IN (''pending'', ''current'')))
ORDER BY 1 desc
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('app-current-caveat-and-no-remove-or-vary', 'application', 'validate', 'medium', 550);


----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('app-other-app-with-caveat', 'sql', 
'The identified property is affected by another live application that includes a service to register a caveat. An application with a cancel or waiver/vary caveat service must be registered before this application can proceed.::::La proprieta é gravata da una pratica attiva che include un servizio per registrare un diritto di prelazione. Perche questa pratia possa procedere deve essere registrata una pratica per richiedere la cancellazione o la variazione della prelazione',
 '#{id}(application.application.id) is requested.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('app-other-app-with-caveat', now(), 'infinity', 
'SELECT (SELECT COUNT(*) > 0 FROM application.service sv WHERE sv.application_id = ap.application_id AND sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')) AS vl
FROM application.application_property ap
	INNER JOIN application.application_property ap2 ON (((ap.name_firstpart, ap.name_lastpart) = (ap2.name_firstpart, ap2.name_lastpart)) AND (ap.id != ap2.id))
	INNER JOIN application.application app2 ON (ap2.application_id = app2.id)
	INNER JOIN application.service sv2 ON ((app2.id = sv2.application_id) AND (sv2.request_type_code = ''caveat'') AND (sv2.status_code != ''cancelled'') AND (app2.status_code NOT IN (''completed'', ''annulled'')))
WHERE ap.application_id = #{id} 
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('app-other-app-with-caveat', 'application', 'validate', 'medium', 590);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-title-has-primary-right', 'sql', 'A single primary right (such as ownership) must be identified whenever a new title record is created::::Il titolo originario del nuovo titolo deve avere un diritto primario',
 '#{id}(application.application.id) is requested');


insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-title-has-primary-right', now(), 'infinity', 
'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
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

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('app-title-has-primary-right', 'application', 'validate', 'critical', 100);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('app-allowable-primary-right-for-new-title', 'sql', 'An allowable primary right (ownership, apartment, State ownership, lease) must be identified for a new title::::Un diritto primario disponibile (proprieta, appartamento o proprieta statale) deve essere identificato per un nuovo titolo',
 '#{id}(application.application.id) is requested');
--delete from system.br_definition where br_id = 'app-allowable-primary-right-for-new-title'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('app-allowable-primary-right-for-new-title', now(), 'infinity', 
'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
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

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('app-allowable-primary-right-for-new-title', 'application', 'validate', 'critical', 10);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-services-status', 'sql', 'All services in the application must have the status ''cancelled'' or ''completed''.::::Tutti i servizi devono avere lo stato di cancellato o completato',
'Checks the service.status_code for all instances of service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-services-status', now(), 'infinity', 
'SELECT (COUNT(*) = 0)  AS vl FROM application.service sv 
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-services-status', 'application', 'approve', 'critical', 270);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-services-without-transaction', 'sql', 
'Within an application,all services making changes to core records must be completed and have utilised an instance of transaction before application can be approved.::::Tutti i servizi con stato completato devono aver prodotto modifiche nel sistema',
'Checks that all services have the status of completed and that there is a transaction record referring to each service record through the field from_service_id');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-services-without-transaction', NOW(), 'infinity', 
'SELECT (COUNT(*) = 0) AS vl FROM application.service sv 
	INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-services-without-transaction', 'application', 'approve', 'critical', 330);
----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-public-display', 'sql', 'The publication period must be completed.::::Il periodo di pubblica notifica deve essere completato',
'Checks the completion of the public display period for all instances of systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-public-display', now(), 'infinity', 
'  SELECT (COUNT(*) = 0)  AS vl
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application_property ap, application.application aa, application.service s, source.source ss
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = ''officialArea''::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = ''systematicRegn''::text AND s.status_code::text = ''completed''::text
   AND COALESCE(co.land_use_code, ''residential''::character varying)::text = lu.code::text
  and ss.reference_nr = co.name_lastpart
  and ss.reference_nr = co.name_lastpart and ss.expiration_date >= now() 
  and s.application_id = #{id};');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-public-display', 'application', 'approve', 'critical', 600);


----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-verifies-identification', 'sql', 'Personal identification verification should be attached to the application.::::Non esistono dettagli identificativi registrati per la pratica',
 '#{id}(application.application.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-verifies-identification', now(), 'infinity', 
'SELECT (CASE 	WHEN app.id is  NULL THEN NULL
		ELSE COUNT(1) > 0
	 END) as vl
FROM application.application app
  LEFT JOIN application.application_uses_source aus ON (aus.application_id = app.id)
  LEFT JOIN source.source sc ON ((sc.id = aus.source_id) AND (sc.type_code = ''idVerification''))
WHERE app.id= #{id}
GROUP BY app.id
LIMIT 1');


INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-verifies-identification', 'application', 'validate', 'medium', 530);


----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('newtitle-br24-check-rrr-accounted', 'sql', 
'All rights and restrictions from existing title(s) must be accounted for in the new titles created in this application.::::non tutti i diritti e le restrizioni sono stati trasferiti al nuovo titolo', 
'#{id}(application_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('newtitle-br24-check-rrr-accounted', now(), 'infinity', 
'
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

INSERT INTO system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
VALUES('newtitle-br24-check-rrr-accounted', 'critical', 'validate', 'application', 160);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback) 
VALUES('application-for-new-title-has-cancel-property-service', 'sql', 
'When a new title is created there must be a cancel title service in the application for the parent title.::::Non esiste nella pratica un servizio di cancellazione titolo. Aggiungere questo servizio alla pratica' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-for-new-title-has-cancel-property-service', now(), 'infinity', 
'
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold'')
					
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(id) FROM application.service sv 
					WHERE sv.application_id = #{id}
					AND sv.request_type_code = ''cancelProperty'') > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-for-new-title-has-cancel-property-service', 'application', 'validate', 'critical', 1);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback) 
VALUES('application-cancel-property-service-before-new-title', 'sql', 
'New Freehold title service must come before Cancel Title service in the application.::::Il servizio di cancellazione titolo deve venire prima di quello di creazione nuovo titolo. Cambiare ordine servizi nella pratica' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-cancel-property-service-before-new-title', now(), 'infinity', 
'
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

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-cancel-property-service-before-new-title', 'application', 'validate', 'critical', 390);


----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback) 
VALUES('application-approve-cancel-old-titles', 'sql', 
'An application including a new freehold service must also terminate the parent title(s) with a cancel title service.::::Identificati titoli esistenti. Prego terminare i titoli esistenti usando il servizio di Cancellazione Titolo' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-approve-cancel-old-titles', now(), 'infinity', 
'
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


INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-approve-cancel-old-titles', 'application', 'approve', 'critical', 250);


----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('cancel-title-check-rrr-cancelled', 'sql', 
'All rights and restrictions on the title to be cancelled must be transfered or cancelled in this application.::::Tutti i diritti e le restrizioni sul titolo da cancellare devono essere trasferiti o cancellati in questa pratica', 
'#{id}(application_id) is requested');
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('cancel-title-check-rrr-cancelled', now(), 'infinity', 
'WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rr1.nr) rr1.nr FROM administrative.rrr rr1 
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

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('cancel-title-check-rrr-cancelled', 'application', 'validate', 'critical', 150);
----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, description) 
VALUES('app-check-title-ref', 'sql', 'Invalid identifier for title::::ITALIANO',
 '#{id}(application.application_property.application_id) is requested');

--delete from system.br_definition where br_id = 'app-check-title-ref'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('app-check-title-ref', NOW(), 'infinity', 
'WITH 	convertTitleApp	AS	(SELECT se.id FROM application.service se
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

INSERT INTO system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
VALUES ('app-check-title-ref', 'medium', 'validate', 'application', 750);

----------------------------------------------------------------------------------------------------------------------
UPDATE system.br SET display_name = id WHERE display_name !=id;

----------------------------------------------------------------------------------------------------
