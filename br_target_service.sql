insert into system.br(id, technical_type_code, feedback) 
values('service-on-complete-without-transaction', 'sql', 'Service ''req_type'' must have been started and some changes made in the system::::Service must have been started and some changes made in the system');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('service-on-complete-without-transaction', now(), 'infinity', 
'select id in (select from_service_id from transaction.transaction where from_service_id is not null) as vl, 
  get_translation(r.display_value, #{lng}) as req_type
from application.service s inner join application.request_type r on s.request_type_code = r.code and request_category_code=''registrationServices''
and s.id= #{id}');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
values('service-on-complete-without-transaction', 'critical', 'complete', 'service', 1);
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
values('service-check-no-previous-digital-title-service', 'warning', 'complete', 'service', 'newDigitalTitle', 10);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-multiple-mortgages', 'sql', 'For the Register Mortgage service the identified title has no existing mortgages::::Il titolo ha una ipoteca corrente',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-multiple-mortgages', now(), 'infinity', 
'SELECT (select count(*)=0 from administrative.rrr 
  where rrr.ba_unit_id = ba.id and rrr.type_code= ''mortgage'' and rrr.status_code =''current'' ) AS vl 
  from application.service s inner join application.application_property ap on s.application_id = ap.application_id 
 INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
WHERE s.id =#{id}
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('baunit-has-multiple-mortgages', 'warning', 'complete', 'service', 'mortgage', 1);

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
values('mortgage-value-check', 'warning', 'complete', 'service', 'mortgage', 2);

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('mortgage-value-check', 'warning', 'complete', 'service', 'varyMortgage', 2);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('current-rrr-for-variation-or-cancellation-check', 'sql', 'For cancellation or variation of rights (or restrictions), there must be existing rights or restriction (in addition to the primary (ownership) right)::::Il titolo non include diritti o restrizioni correnti (oltre al diritto primario). Confermare la richiesta di variazione o cancellazione e verificare il titolo identificativo',
 '#{id}(application.service.id)');


INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('current-rrr-for-variation-or-cancellation-check', now(), 'infinity', 
'SELECT (SUM(1)) AS vl FROM application.service sv 
			INNER JOINT application.application_property ap ON (sv.application_id = ap.application_id )
			  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
			  INNER JOIN administrative.rrr rr ON rr.ba_unit_id = ba.id
			  WHERE sv.id = #{id}
			  AND sv.request_type_code IN (SELECT code FROM application.request_type WHERE ((status = ''c'') AND (type_action_code IN (''vary'', ''cancel''))))
			  AND NOT(rr.is_primary)
			  AND rr.status_code = ''current''
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
VALUES('current-rrr-for-variation-or-cancellation-check', 'medium', 'complete', 'service', 11);

----------------------------------------------------------------------------------------------------
--PROBABLY REDUNDANT BR

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('power-of-attorney-service-has-document', 'sql', 'Service ''req_type'' must have must have an associated Power of Attorney document::::ITALIANO',
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
VALUES('power-of-attorney-service-has-document', 'critical', 'complete', 'service', 'regnPowerOfAttorney', 1);

--------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
	VALUES('document-supporting-rrr-is-current', 'sql', 'Documents supporting rights (or restrictions) must have current status::::ITALIANO',
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
VALUES('document-supporting-rrr-is-current', 'critical', 'complete', 'service',  1);
--------------------------------------------------------------------------------------------------
update system.br set display_name = id where display_name is null;
