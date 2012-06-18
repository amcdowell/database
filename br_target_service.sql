insert into system.br(id, technical_type_code, feedback) 
values('service-on-complete-without-transaction', 'sql', 'Service ''req_type'' must have been started and done some changes in the system::::Service must have been started and done some changes in the system');

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
'Digital title should not exist for requested property (having no primary right it means also that does not exist)::::ITALIANO',
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
values('baunit-has-multiple-mortgages', 'sql', 'Title already has current mortgage::::Il titolo ha una ipoteca corrente',
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
values('mortgage-value-check', 'sql', 'Mortgage is for more than reported value::::Ipoteca superiore al valore riportato',
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

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('current-rrr-for-variation-or-cancellation-check', 'sql', 'Title includes no current right or restriction (apart from primary right). Confirm request for variation or cancellation and check title identifier::::Il titolo non include diritti o restrizioni correnti (oltre al diritto primario). Confermare la richiesta di variazione o cancellazione e verificare il titolo identificativo',
 '#{id}(application.service.id) It is requested where there is a service that varies or extinguishes an existing rrr');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('current-rrr-for-variation-or-cancellation-check', now(), 'infinity', 
'Select (rrr.status_code = ''current'' and not rrr.is_primary) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id 
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  INNER JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id}
  and s.request_type_code in (
    select code from application.request_type 
    where rrr_type_code is not null and type_action_code in (''vary'', ''cancel''))
order by rrr.is_primary, rrr.status_code
limit 1');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
values('current-rrr-for-variation-or-cancellation-check', 'medium', 'complete', 'service', 11);

----------------------------------------------------------------------------------------------------

--update system.br set display_name = id where display_name is null;
