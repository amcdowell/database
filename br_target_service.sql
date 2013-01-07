----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-baunit-has-parcels', 'sql', 'Title must have Parcels::::Titolo deve avere particelle',
 '#{id}(application.service.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-baunit-has-parcels', now(), 'infinity', 
'select (select count(*)>0 from administrative.ba_unit_contains_spatial_unit ba_su 
		inner join cadastre.cadastre_object co on ba_su.spatial_unit_id= co.id
	where co.status_code in (''current'') and co.geom_polygon is not null and ba_su.ba_unit_id= ba.id) as vl
from application.service s 
	inner join application.application_property ap on (s.application_id= ap.application_id)
	INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
where s.id = #{id}
order by 1
limit 1');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('application-baunit-has-parcels', 'service', 'complete', 'cadastreChange', 'critical', 130);

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('application-baunit-has-parcels', 'service', 'complete', 'redefineCadastre', 'critical', 140);

---------------------------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('service-on-complete-without-transaction', 'sql', 'Service ''req_type'' must have been started and some changes made in the system::::Service must have been started and some changes made in the system');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('service-on-complete-without-transaction', now(), 'infinity', 
'select id in (select from_service_id from transaction.transaction where from_service_id is not null) as vl, 
  get_translation(r.display_value, #{lng}) as req_type
from application.service s inner join application.request_type r on s.request_type_code = r.code and request_category_code=''registrationServices''
and s.id= #{id}');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
values('service-on-complete-without-transaction', 'critical', 'complete', 'service', 360);
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('service-check-no-previous-digital-title-service', 'sql', 
'For the Convert Title service there must be no existing digital title record (including the recording of a primary (ownership) right) for the identified title::::Un titolo digitale non dovrebbe esistere per la proprieta richiesta (non avere diritti primari significa anche che non esiste)',
 '#{id}(application.service.id) is requested where service is for newDigitalTitle or newDigitalProperty');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('service-check-no-previous-digital-title-service', now(), 'infinity', 
'SELECT coalesce(not rrr.is_primary, true) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} 
order by 1 desc
limit 1');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('service-check-no-previous-digital-title-service', 'warning', 'complete', 'service', 'newDigitalTitle', 720);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('baunit-has-multiple-mortgages', 'sql', 'For the Register Mortgage service the identified title has no existing mortgages::::Il titolo ha una ipoteca corrente',
 '#{id}(administrative.ba_unit.id) is requested');
--delete from system.br_definition where br_id = 'baunit-has-multiple-mortgages'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('baunit-has-multiple-mortgages', now(), 'infinity', 
'SELECT	(SELECT (COUNT(*) = 0) FROM application.service sv2
		 INNER JOIN transaction.transaction tn ON (sv2.id = tn.from_service_id)
		 INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id)
		 INNER JOIN administrative.rrr rr2 ON ((rr.ba_unit_id = rr2.ba_unit_id) AND (rr2.type_code = ''mortgage'') AND (rr2.status_code =''current'') ) 
	WHERE sv.id = #{id}) AS vl FROM application.service sv
WHERE sv.id = #{id}
AND sv.request_type_code = ''mortgage''
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('baunit-has-multiple-mortgages', 'service', 'complete', 'mortgage', 'warning', 670);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('mortgage-value-check', 'sql', 'For the Register Mortgage service, the new mortgage is for less than the reported value of property (at time application was received)::::Ipoteca superiore al valore riportato',
 '#{id}(application.service.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('mortgage-value-check', now(), 'infinity', 
'SELECT (ap.total_value < rrr.mortgage_amount) AS vl 
  from application.service s inner join application.application_property ap on s.application_id = ap.application_id 
 INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
 INNER JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} and rrr.type_code= ''mortgage'' and rrr.status_code in (''pending'')
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('mortgage-value-check', 'warning', 'complete', 'service', 'mortgage', 700);

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('mortgage-value-check', 'warning', 'complete', 'service', 'varyMortgage', 690);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('current-rrr-for-variation-or-cancellation-check', 'sql', 'For cancellation or variation of rights (or restrictions), there must be existing rights or restriction (in addition to the primary (ownership) right)::::Il titolo non include diritti o restrizioni correnti (oltre al diritto primario). Confermare la richiesta di variazione o cancellazione e verificare il titolo identificativo',
 '#{id}(application.service.id)');


INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('current-rrr-for-variation-or-cancellation-check', now(), 'infinity', 
'SELECT (SUM(1) > 0) AS vl FROM application.service sv 
			INNER JOIN application.application_property ap ON (sv.application_id = ap.application_id )
			  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
			  INNER JOIN administrative.rrr rr ON rr.ba_unit_id = ba.id
			  WHERE sv.id = #{id}
			  AND sv.request_type_code IN (SELECT code FROM application.request_type WHERE ((status = ''c'') AND (type_action_code IN (''vary'', ''cancel''))))
			  AND NOT(rr.is_primary)
			  AND rr.status_code = ''current''
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('current-rrr-for-variation-or-cancellation-check', 'medium', 'complete', 'service', 11);

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, severity_code, order_of_execution)
VALUES ('current-rrr-for-variation-or-cancellation-check', 'service', 'complete', 'medium', 650);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('power-of-attorney-service-has-document', 'sql', 'Service ''req_type'' must have must have one associated Power of Attorney document::::''req_type'' del Servizio deve avere un documento di procura legale allegato',
  '#{id}(application.service.id)');
 
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('power-of-attorney-service-has-document', now(), 'infinity', 
'SELECT (SUM(1) = 1) AS vl, get_translation(rt.display_value, #{lng}) as req_type FROM application.service sv
	 INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
	 INNER JOIN source.source sc ON (tn.id = sc.transaction_id)
	 INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code AND request_category_code = ''registrationServices'')
WHERE sv.id =#{id}
AND sc.type_code = ''powerOfAttorney''
GROUP BY rt.code
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
VALUES('power-of-attorney-service-has-document', 'critical', 'complete', 'service', 'regnPowerOfAttorney', 340);

--------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
	VALUES('document-supporting-rrr-is-current', 'sql', 'Documents supporting rights (or restrictions) must have current status::::I documenti che supportano diritti (o restrizioni) devono avere stato corrente',
		'#{id}(application.service.id)');
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
	VALUES('document-supporting-rrr-is-current', now(), 'infinity', 
	'WITH serviceDocs AS	(SELECT DISTINCT ON (sc.id) sv.id AS sv_id, sc.id AS sc_id, sc.status_code, sc.type_code FROM application.service sv
				INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
				INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id)
				INNER JOIN administrative.source_describes_rrr sr ON (rr.id = sr.rrr_id)
				INNER JOIN source.source sc ON (sr.source_id = sc.id)
				WHERE sv.id = #{id}),
    nullDocs AS		(SELECT sc_id, type_code FROM serviceDocs WHERE status_code IS NULL),
    transDocs AS	(SELECT sc_id, type_code FROM serviceDocs WHERE status_code = ''current'' AND ((type_code = ''powerOfAttorney'') OR (type_code = ''standardDocument'')))
SELECT ((SELECT COUNT(*) FROM serviceDocs) - (SELECT COUNT(*) FROM nullDocs) - (SELECT COUNT(*) FROM transDocs) = 0) AS vl
ORDER BY 1
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('document-supporting-rrr-is-current', 'critical', 'complete', 'service',  240);
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
VALUES('documents-present', 'critical', 'complete', 'service', 200);
--------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('power-of-attorney-owner-check', 'sql', 'Name of person identified in Power of Attorney should match a (one of the) current owner(s)::::Il nome della persona identificato nella procura legale deve corrispondere ad uno dei proprietari correnti',
  '#{id}(application.service.id)');
--delete from system.br_definition where br_id =  'power-of-attorney-owner-check'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('power-of-attorney-owner-check', NOW(), 'infinity', 
'WITH poaQuery AS (SELECT person_name, py.name AS firstName, py.last_name AS lastName FROM transaction.transaction tn
			INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id) 
			INNER JOIN administrative.ba_unit ba ON (rr.ba_unit_id = ba.id)
			INNER JOIN administrative.rrr r2 ON ((ba.id = r2.ba_unit_id) AND (r2.status_code = ''current'') AND r2.is_primary)
			INNER JOIN administrative.rrr_share rs ON (r2.id = rs.rrr_id)
			INNER JOIN administrative.party_for_rrr pr ON (rs.rrr_id = pr.rrr_id)
			INNER JOIN party.party py ON (pr.party_id = py.id)
			INNER JOIN administrative.source_describes_rrr sr ON (rr.id = sr.rrr_id)
			INNER JOIN source.power_of_attorney pa ON (sr.source_id = pa.id)
		WHERE tn.from_service_id = #{id})
SELECT CASE WHEN (COUNT(*) > 0) THEN TRUE
		ELSE NULL
	END AS vl FROM poaQuery
WHERE compare_strings(person_name, COALESCE(firstName, '''') || '' '' || COALESCE(lastName, ''''))
ORDER BY vl
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('power-of-attorney-owner-check', 'warning', 'complete', 'service', 580);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('required-sources-are-present', 'sql', 
'All documents required for the service ''req_type'' are present.::::Sono presenti tutti i documenti richiesti per il servizio',
'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents' );

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('required-sources-are-present', now(), 'infinity', 
'WITH reqForSv AS 	(SELECT r_s.source_type_code AS typeCode
			FROM application.request_type_requires_source_type r_s 
				INNER JOIN application.service sv ON((r_s.request_type_code = sv.request_type_code) AND (sv.status_code != ''cancelled''))
			WHERE sv.id = #{id}),
     inclInSv AS	(SELECT DISTINCT ON (sc.id) get_translation(rt.display_value, #{lng}) AS req_type FROM reqForSv req
				INNER JOIN source.source sc ON (req.typeCode = sc.type_code)
				INNER JOIN application.application_uses_source a_s ON (sc.id = a_s.source_id)
				INNER JOIN application.service sv ON ((a_s.application_id = sv.application_id) AND (sv.id = #{id}))
				INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code))

SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM reqForSv) THEN NULL
		WHEN ((SELECT COUNT(*) FROM inclInSv) - (SELECT COUNT(*) FROM reqForSv) >= 0) THEN TRUE
		ELSE FALSE
	END AS vl, req_type FROM inclInSv
ORDER BY vl
LIMIT 1');


INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('required-sources-are-present', 'critical', 'complete', 'service', 230);

------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('service-has-person-verification', 'sql', 'Within the application for the service a personal identification verification should be attached.::::Non esistono dettagli identificativi registrati per la pratica',
 '#{id}(application.service.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('service-has-person-verification', now(), 'infinity', 
'SELECT (CASE 	WHEN sv.application_id is  NULL THEN NULL
		ELSE COUNT(1) > 0
	 END) as vl
FROM application.service sv
  LEFT JOIN application.application_uses_source aus ON (aus.application_id = sv.application_id)
  LEFT JOIN source.source sc ON ((sc.id = aus.source_id) AND (sc.type_code = ''idVerification''))
WHERE sv.id= #{id}
GROUP BY sv.id
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('service-has-person-verification', 'critical', 'complete', 'service', 350);

------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('service-title-terminated', 'sql', 'For the service ''req_type'' the title must be terminated (after all rights recorded on the title are transferred or cancelled).::::Per il servizio ''req_type'' il titolo deve essere terminato (dopo che tutti i diritti registrati per il titolo sono stati trasferiti o cancellati)',
 '#{id}(application.service.id) is requested');
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('service-title-terminated', now(), 'infinity', 
'WITH reqForSv AS 	(SELECT sv.id, get_translation(rt.display_value, #{lng}) AS req_type FROM application.service sv 
				INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code)
			WHERE sv.id = #{id} 
			AND sv.request_type_code = ''cancelProperty''),
     checkTitle AS	(SELECT tg.ba_unit_id FROM application.service sv
				INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
				INNER JOIN administrative.ba_unit_target tg ON (tn.id = tg.transaction_id)
			WHERE sv.id = #{id})
SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM reqForSv) THEN NULL
		WHEN (SELECT (COUNT(*) > 0) FROM checkTitle) THEN TRUE
		ELSE FALSE
	END AS vl, req_type FROM reqForSv
ORDER BY vl
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('service-title-terminated', 'critical', 'complete', 'service', 190);

----------------------------------------------------------------------------------------------------


insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-baunit-check-area', 'sql', 'Title has the same area as the combined area of its associated parcels::::La Area della BA Unit (Unita Amministrativa di Base) non ha la stessa estensione di quella delle sue particelle',
 '#{id}(ba_unit_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-baunit-check-area', now(), 'infinity', 
'select
       ( 
         select coalesce(cast(sum(a.size)as float),0)
	 from administrative.ba_unit_area a
         inner join administrative.ba_unit ba
         on a.ba_unit_id = ba.id
         where ba.transaction_id = #{id}
         and a.type_code =  ''officialArea''
       ) 
   = 

       (
         select coalesce(cast(sum(a.size)as float),0)
	 from cadastre.spatial_value_area a
	 where  a.type_code = ''officialArea''
	 and a.spatial_unit_id in
           (  select b.spatial_unit_id
              from administrative.ba_unit_contains_spatial_unit b
              inner join administrative.ba_unit ba
	      on b.ba_unit_id = ba.id
	      where ba.transaction_id = #{id}
           )

        ) as vl');

INSERT INTO system.br_validation(br_id, target_code, target_request_type_code, severity_code, order_of_execution)
VALUES ('application-baunit-check-area', 'service', 'cadastreChange', 'warning', 520);
----------------------------------------------------------------------------------------------------


update system.br set display_name = id where display_name is null;
