----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br8-check-has-services', 'sql', 
'Application has at least one service attached::::La Pratica ha almeno un documento allegato');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br8-check-has-services', now(), 'infinity', 
'select count(*)>0 as vl
from application.service s where s.application_id = #{id}');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br8-check-has-services', 'critical', 'validate', 'application', 1);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br7-check-sources-have-documents', 'sql', 
'Some of the documents for this application do not have an attached scanned image::::Alcuni dei documenti per questa pratica non hanno una immagine scannerizzata allegata' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br7-check-sources-have-documents', now(), 'infinity', 
'select ext_archive_id is not null as vl
from source.source 
where id in (select source_id 
    from application.application_uses_source
    where application_id= #{id})');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br7-check-sources-have-documents', 'warning', 'validate', 'application', 2);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br1-check-required-sources-are-present', 'sql', 
'All documents required for the services are present.::::Sono presenti tutti i documenti richiesti per il servizio' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br1-check-required-sources-are-present', now(), 'infinity', 
'select count(*) =0  as vl
from application.request_type_requires_source_type r_s 
where request_type_code in (
  select request_type_code 
  from application.service where application_id=#{id} and status_code != ''cancelled'')
and not exists (
  select s.type_code
  from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
  where a_s.application_id= #{id} and s.type_code = r_s.source_type_code
)');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br1-check-required-sources-are-present', 'critical', 'validate', 'application', 3);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br2-check-title-documents-not-old', 'sql', 
'All scanned images of titles are less than one week old.::::Tutte le immagini scannerizzate del titolo hanno al massimo una settimana' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br2-check-title-documents-not-old', now(), 'infinity', 
'select s.submission + 1 * interval ''1 week'' > now() as vl
from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
where a_s.application_id = #{id}
and s.type_code in (''title'')');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br2-check-title-documents-not-old', 'medium', 'validate', 'application', 4);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br3-check-properties-are-not-historic', 'sql', 
'All properties identified for the application are not historic.::::Tutte le proprieta identificate per la pratica non sono storiche' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br3-check-properties-are-not-historic', now(), 'infinity', 
'select false as vl
from application.application_property  
where application_id=#{id}
and (name_firstpart, name_lastpart) 
    in (select name_firstpart, name_lastpart 
      from administrative.ba_unit where status_code in (''historic''))
order by 1
limit 1
');


insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br3-check-properties-are-not-historic', 'critical', 'validate', 'application', 5);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br4-check-sources-date-not-in-the-future', 'sql', 
'No documents have submission dates for the future.::::Nessun documento ha le date di inoltro per il futuro' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br4-check-sources-date-not-in-the-future', now(), 'infinity', 
'select s.submission < now() as vl
from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
where a_s.application_id = #{id}
order by 1
limit 1
');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br4-check-sources-date-not-in-the-future', 'warning', 'validate', 'application', 6);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br5-check-there-are-front-desk-services', 'sql', 
'There are services that should  be dealt in the front office. These services are of type: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::Ci sono servizi che dovrebbero essere svolti dal front office. Questi servizi sono di tipo:Richiesta Servizio, Copia Documento, Stampa Catastale, Copia Piano Perizia, Ricerca Titolo' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br5-check-there-are-front-desk-services', now(), 'infinity', 
'select count(*)=0 as vl
from application.service
where application_id = #{id} 
  and request_type_code in (''serviceEnquiry'', ''documentCopy'', ''cadastrePrint'', 
    ''surveyPlanCopy'', ''titleSearch'')
');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br5-check-there-are-front-desk-services', 'warning', 'validate', 'application', 7);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br6-check-new-title-service-is-needed', 'sql', 
'There is no digital record for this property. Add a New Digital Title service to your application.::::Non esiste un formato digitale per questa proprieta. Aggiungere un Nuovo Titolo Digitale alla vostra pratica' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br6-check-new-title-service-is-needed', now(), 'infinity', 
'select 
      case 
        when (name_firstpart, name_lastpart) not
            in (select name_firstpart, name_lastpart from administrative.ba_unit)
        then (select count(*)>0 from application.service
            where request_type_code = ''newFreehold'')
        else true
      end as vl
from application.application_property  
where application_id=#{id}
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br6-check-new-title-service-is-needed', 'warning', 'validate', 'application', 8);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('applicant-name-to-owner-name-check', 'sql', 
'Applicant name is different from current recorded owners::::Il nome del richiedente differisce da quello dei proprietari registrati',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('applicant-name-to-owner-name-check', now(), 'infinity', 
'select (select string_agg(name || '' '' || last_name, ''#'') 
  from party.party inner join administrative.party_for_rrr prrr on party.id= prrr.party_id) = 
  (cp.name || '' '' || cp.last_name) as vl
from application.application a inner join party.party cp on a.contact_person_id= cp.id
inner join application.application_property ap on a.id = ap.application_id 
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  INNER JOIN administrative.rrr ON rrr.ba_unit_id = ba.id and rrr.status_code in (''current'') and rrr.is_primary
where a.id=#{id}
order by vl
limit 1
');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('applicant-name-to-owner-name-check', 'warning', 'validate', 'application', 25);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-current-caveat-and-no-remove-or-vary', 'sql', 
'There is a current or pending caveat registered on this title and this application does not include a cancel or waiver/vary caveat service::::ITALIANO',
 '#{id}(application.application.id) is requested. It checks if there is a caveat (pending or current) registered
 on the title and if the application does not have any service of type remove or vary caveat');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-current-caveat-and-no-remove-or-vary', now(), 'infinity', 
'SELECT (select count(*) > 0 from application.service s 
  where s.application_id= ap.application_id and s.request_type_code in (''varyCaveat'', ''removeCaveat'')) as vl
FROM application.application_property ap 
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE ap.application_id = #{id} and rrr.type_code = ''caveat'' and rrr.status_code != ''historic''
order by 1 desc
limit 1');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-current-caveat-and-no-remove-or-vary', 'medium', 'validate', 'application', 1);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-title-has-primary-right', 'sql', 'Title that is part of this application must have a primary right::::Il titolo deve avere un diritto primario',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-title-has-primary-right', now(), 'infinity', 
'select (select count(*)>0 from administrative.rrr 
  where rrr.ba_unit_id = ba.id and rrr.status_code in (''current'') and rrr.is_primary) as vl
from application.application_property ap 
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
where ap.application_id = #{id}
  and ap.application_id in 
    (select application_id from application.service s
      where s.application_id= #{id} and s.status_code != ''cancelled'' and request_type_code not 
        in (''newFreeHold'', ''newApartment'', ''newState'', ''newDigitalProperty'', ''newDigitalTitle''))
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-title-has-primary-right', 'critical', 'validate', 'application', 1);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback) 
values('application-on-approve-check-services-status', 'sql', 'All services in the application must have the status cancelled or completed::::Tutti i servizi devono avere lo stato di cancellato o completato');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-on-approve-check-services-status', now(), 'infinity', 
'select count(*)=0  as vl
from application.service s where s.application_id = #{id} and status_code not in (''completed'', ''cancelled'')');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-on-approve-check-services-status', 'critical', 'approve', 'application', 1);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-on-approve-check-services-without-transaction', 'sql', 'All services with the status ''completed'' must have done changes in the system::::Tutti i servizi con stato completato devono aver prodotto modifiche nel sistema');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-on-approve-check-services-without-transaction', now(), 'infinity', 
'select count(*)=0 as vl 
from application.service s where s.application_id = #{id} and status_code = ''completed'' 
and id not in (select from_service_id from transaction.transaction)');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-on-approve-check-services-without-transaction', 'critical', 'approve', 'application', 20);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('applicant-identification-check', 'sql', 'No personal identification details recorded for application::::Non esistono dettagli identificativi registrati per la pratica',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('applicant-identification-check', now(), 'infinity', 
'Select count(*) > 0 as vl 
FROM application.application
WHERE id = #{id} and contact_person_id is not null');

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('applicant-identification-check', 'medium', 'approve', 'application', 13);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

