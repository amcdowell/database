delete from system.br_validation;
delete from system.br_definition;
delete from system.br;

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code) values('generate-application-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-application-nr', now(), 'infinity', 
'SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''application.application_nr_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code) values('generate-notation-reference-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-notation-reference-nr', now(), 'infinity', 
'SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code) values('generate-rrr-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-rrr-nr', now(), 'infinity', 
'SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code) values('generate-source-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-source-nr', now(), 'infinity', 
'SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''source.source_la_nr_seq''), ''000000000'')) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code) values('generate-baunit-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-baunit-nr', now(), 'infinity', 
'SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
|| ''/'' || trim(to_char(nextval(''administrative.ba_unit_last_name_part_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code) values('calculate-application-expected_date', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('calculate-application-expected_date', now(), 'infinity', 
'select ''request'' as discriminator_type, code, now() + nr_days_to_complete * interval ''1 day'' as expected_date 
from application.request_type where code in (#{services_list})
union 
select ''application'', ''n/a'', now() + (select max(nr_days_to_complete) 
from application.request_type where code in (#{services_list})) * interval ''1 day''');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br8-check-has-services', 'sql', 'Application has at least one service attached::::La Pratica ha almeno un documento allegato');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br8-check-has-services', now(), 'infinity', 
'select count(*)>0 as vl
from application.service s where s.application_id = #{id}');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br7-check-sources-have-documents', 'sql', 
'Some of the documents for this application do not have an attached scanned image::::Alcuni dei documenti per questa pratica non hanno una immagine scannerizzata allegata' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br7-check-sources-have-documents', now(), 'infinity', 
'select count(*)=0 as vl
from source.source 
where ext_archive_id is null 
and id in (select source_id 
    from application.application_uses_source
    where application_id= #{id})');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br1-check-required-sources-are-present', 'sql', 
'All documents required for the services are present.::::Sono presenti tutti i documenti richiesti per il servizio' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br1-check-required-sources-are-present', now(), 'infinity', 
'select count(*) =0  as vl
from application.request_type_requires_source_type r_s 
where request_type_code in (select request_type_code from application.service where application_id=#{id})
and not exists (
  select s.type_code
  from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
  where a_s.application_id= #{id} and s.type_code = r_s.source_type_code
)');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br2-check-title-documents-not-old', 'sql', 
'All scanned images of titles are less than one week old.::::Tutte le immagini scannerizzate del titolo hanno al massimo una settimana' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br2-check-title-documents-not-old', now(), 'infinity', 
'select case when count(*)>0 then 
    (select count(*)>0 from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
     where a_s.application_id = #{id}
         and s.type_code in (''title'') and s.submission + 1 * interval ''1 week'' > now())
     else true
     end as vl
from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
where a_s.application_id = #{id}
and s.type_code in (''title'')');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br3-check-properties-are-not-historic', 'sql', 
'All properties identified for the application are not historic.::::Tutte le proprieta identificate per la pratica non sono storiche' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br3-check-properties-are-not-historic', now(), 'infinity', 
'select count(*)=0 as vl
from application.application_property  
where application_id=#{id}
and (name_firstpart, name_lastpart) 
    in (select name_firstpart, name_lastpart from administrative.ba_unit where status_code in (''historic''))
');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br4-check-sources-date-not-in-the-future', 'sql', 
'No documents have submission dates for the future.::::Nessun documento ha le date di inoltro per il futuro' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br4-check-sources-date-not-in-the-future', now(), 'infinity', 
'select count(*)=0 as vl
from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
where a_s.application_id = #{id} and s.submission > now()
');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br5-check-there-are-front-desk-services', 'sql', 
'There are services that should  be dealt in the front office. These services are of type: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::Ci sono servizi che dovrebbero essere svolti dal front office. Questi servizi sono di tipo:Richiesta Servizio, Copia Documento, Stampa Catastale, Copia Piano Perizia, Ricerca Titolo' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br5-check-there-are-front-desk-services', now(), 'infinity', 
'select count(*)=0 as vl
from application.service
where application_id = #{id} 
  and request_type_code in (''serviceEnquiry'', ''documentCopy'', ''cadastrePrint'', ''surveyPlanCopy'', ''titleSearch'')
');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-br6-check-new-title-service-is-needed', 'sql', 
'There is no digital record for this property. Add a New Digital Title service to your application.::::Non esiste un formato digitale per questa proprieta. Aggiungere un Nuovo Titolo Digitale alla vostra pratica' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-br6-check-new-title-service-is-needed', now(), 'infinity', 
'select 
      case when count(*)=0 then (select count(*)>0 from application.service where request_type_code = ''newFreehold'')
           else true
      end as vl
from application.application_property  
where application_id=#{id}
and (name_firstpart, name_lastpart) not
    in (select name_firstpart, name_lastpart from administrative.ba_unit)
');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('request-newfreehold-br1-check-title-source-not-old', 'sql', 
'The copy of the title is less than one month old.::::La copia del titolo ha meno di un mese' );

insert into system.br_definition(br_id, active_from, active_until, body) 
values('request-newfreehold-br1-check-title-source-not-old', now(), 'infinity', 
'select count(*)>0 as vl
from application.application_uses_source a_s inner join source.source s on a_s.source_id= s.id
where a_s.application_id in (select application_id from application.service where id= #{id})
and s.type_code in (''title'')
and s.submission + 1 * interval ''1 month'' > now()
');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-on-approve-check-services-status', 'sql', 'All services in the application must have the status cancelled or completed::::ITALIANO');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-on-approve-check-services-status', now(), 'infinity', 
'select count(*)=0  as vl
from application.service s where s.application_id = #{id} and status_code not in (''completed'', ''cancelled'')');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('application-on-approve-check-services-without-transaction', 'sql', 'All services with the status ''completed'' must have done changes in the system::::ITALIANO');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-on-approve-check-services-without-transaction', now(), 'infinity', 
'select count(*)=0 as vl 
from application.service s where s.application_id = #{id} and status_code = ''completed'' 
and id not in (select from_service_id from transaction.transaction)');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('service-on-complete-without-transaction', 'sql', 'Service must have been started and done some changes in the system::::ITALIANO');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('service-on-complete-without-transaction', now(), 'infinity', 
'select count(*)=0 as vl 
from application.service s where id= #{id} and id not in (select from_service_id from transaction.transaction)');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('rrr-must-have-parties', 'sql', 'Rrr that must have parties have parties::::ITALIANO');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-must-have-parties', now(), 'infinity', 
'select count(*) = 0 as vl
from administrative.rrr r
where id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');

-----------Cadastre Change [Floss 634 (subtask of Floss 555)]-----------------------------------------------------------------------------------------

--------------Check the union of target parcels is a polygon (not a multipolygon) (CRITICAL)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-parcels-check-isapolygon', 'sql', 'The union of target parcels must be a polygon::::La unione di Particelle deve essere un poligono unico',
 '#{id}(cadastre.cadastre_object.transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('target-parcels-check-isapolygon', now(), 'infinity', 
'select coalesce(St_GeometryType(ST_Union(co.geom_polygon)), ''ST_Polygon'') = ''ST_Polygon'' as vl
 from cadastre.cadastre_object co 
  inner join cadastre.cadastre_object_target co_target
   on co.id = co_target.cadastre_object_id
    where co_target.transaction_id = #{id}');

--------------Check there are no pending changes that overlap the union of the target parcels (CRITICAL)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-parcels-check-nopending', 'sql', 'There are pending changes that overlap the union of the target parcels::::Vi sono modifiche pendenti che bloccano la unione delle Particelle',
 '#{id}(cadastre.cadastre_object.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('target-parcels-check-nopending', now(), 'infinity', 
 'select count(*) = 0 as vl
from cadastre.cadastre_object_target co_target, cadastre.cadastre_object_target co_target_also
where co_target.transaction_id = #{id}
and co_target.transaction_id != co_target_also.transaction_id
and co_target.cadastre_object_id = co_target_also.cadastre_object_id
and co_target_also.transaction_id  in (select id from transaction.transaction 
                                        where status_code not in (''approved''))
 ');

--------------Check the union of target co is the same as the union of the new co
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-and-new-union-the-same', 'sql', 'The union of new cadastral objects is the same with the union of target cadastral objects::::ITALIANO',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('target-and-new-union-the-same', now(), 'infinity', 
 'select coalesce(st_equals(geom_to_snap,target_geom), true) as vl
from snap_geometry_to_geometry(
(select st_union(co.geom_polygon) 
from cadastre.cadastre_object co where transaction_id = #{id})
, (select st_union(co.geom_polygon)
from cadastre.cadastre_object co 
where id in (select cadastre_object_id 
  from cadastre.cadastre_object_target  where transaction_id = #{id})), 
  coalesce((select cast(vl as float) from system.setting where name=''map-tolerance''), 0.01), true)
 ');

--------------Check the union of new co has the same area as the sum of all areas of new co-s, which means the new co-s don't overlap
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('new-cadastre-objects-dont-overlap', 'sql', 'The new cadastral objects don''t overlap::::ITALIANO',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('new-cadastre-objects-dont-overlap', now(), 'infinity', 
 'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object co where transaction_id = #{id}
 ');

--------------Check new official areas - old official areas / old official areas in percentage (Give WARNING if percentage > 0%)
insert into system.br(id, technical_type_code, feedback) 
values('area-check-percentage-newareas-oldareas', 'sql', 'New official areas - old official areas / old official areas in percentage should not be > 0.1%::::Il valore delle nuove aree ufficiali -  quello delle vecchie / 
il valore delle vecchie aree ufficiali in percentuale non dovrebbe essere superiore allo 0.1%');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('area-check-percentage-newareas-oldareas', now(), 'infinity', 
'select abs((select coalesce(cast(sum(a.size)as float),0)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
        and a.spatial_unit_id in (
	   select co_new.id
		from cadastre.cadastre_object co_new 
		where co_new.transaction_id = #{id}))
 -
   (select coalesce(cast(sum(a.size)as float),0)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 ) /(select coalesce(cast(sum(a.size)as float),1)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 < 0.001 as vl');

--------------Check new official area - calculated new area / new official area in percentage (Give in WARNING description, percentage & parcel if percentage > 1%)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('area-check-percentage-newofficialarea-calculatednewarea', 'sql', 'New official area - calculated new area / new official area in percentage should not be > 1%::::Il valore della nuova area ufficiale -  quello CALCOLATO della nuova area / 
il valore della nuova area ufficiale in percentuale non dovrebbe essere superiore all 1%',
 '#{id}(cadastre.cadastre_object.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('area-check-percentage-newofficialarea-calculatednewarea', now(), 'infinity', 
'select count(*) = 0 as vl
from cadastre.cadastre_object co 
  left join cadastre.spatial_value_area sa_calc on (co.id= sa_calc.spatial_unit_id and sa_calc.type_code =''calculatedArea'')
  left join cadastre.spatial_value_area sa_official on (co.id= sa_official.spatial_unit_id and sa_official.type_code =''officialArea'')
where co.transaction_id = #{id} and
(abs(coalesce(sa_official.size, 0) - coalesce(sa_calc.size, 0)) 
/ 
(case when sa_official.size is null or sa_official.size = 0 then 1 else sa_official.size end)) > 0.01');

--------------Check BA Unit area != Official Parcels Area (WARNING)---------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-baunit-check-area', 'sql', 'Ba Unit has not the same area as its belonging parcels::::La Area della BA Unit (Unita Amministrativa di Base) non ha la stessa estensione di quella delle sue particelle',
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

-------------BA Unit has Parcels (CRITICAL)-----------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-baunit-has-parcels', 'sql', 'Ba Unit must have Parcels::::La BA Unit (Unita Amministrativa di Base) deve avere particelle',
 '#{id}(ba_unit_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-baunit-has-parcels', now(), 'infinity', 
'select count(*)>0  as vl
from administrative.ba_unit_contains_spatial_unit a
inner join administrative.ba_unit ba
	      on a.ba_unit_id = ba.id
	      where ba.transaction_id = #{id}
       and a.spatial_unit_id in 
( select id 
  from cadastre.cadastre_object co
  where  co.type_code =  ''parcel'' and co.geom_polygon is not null 
)');

--------------Check there are survey points attached with the cadastre change (CRITICAL)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('survey-points-present', 'sql', 'There are at least 3 survey points present::::ITALIANO',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('survey-points-present', now(), 'infinity', 
 'select count (*) > 2  as vl from cadastre.survey_point where transaction_id= #{id}');

--------------Check there are target parcels attached with the cadastre change (CRITICAL)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-parcels-present', 'sql', 'There are target parcels selected::::ITALIANO',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('target-parcels-present', now(), 'infinity', 
 'select count (*) > 0 as vl from cadastre.cadastre_object_target where transaction_id= #{id}');

--------------Check there are documents (sources) attached with the cadastre change (WARNING)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('documents-present', 'sql', 'There are documents/ sources attached::::ITALIANO',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('documents-present', now(), 'infinity', 
 'select count (*) > 0 as vl from transaction.transaction_source where transaction_id= #{id}');

--------------Check there are new cadastral objects with the cadastre change (WARNING)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('new-cadastre-objects-present', 'sql', 'There are new cadastral objects defined::::ITALIANO',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('new-cadastre-objects-present', now(), 'infinity', 
 'select count (*) > 0 as vl from cadastre.cadastre_object where transaction_id= #{id}');
-------------End Cadastre Change [Floss 634 (subtask of Floss 555)]---------------------------------

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('source-attach-in-transaction-no-pendings', 'sql', 'Source must not have pending status::::ITALIANO',
 '#{id} of the source is requested. It checks if the source has already a record with the status pending.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('source-attach-in-transaction-no-pendings', now(), 'infinity', 
'select count(*)=0 as vl 
from source.source
where la_nr in (select la_nr 
    from source.source where id = #{id})
and status_code is not null and status_code in (''pending'')');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('source-attach-in-transaction-allowed-type', 'sql', 'Source must be of a type for which the transaction is allowed::::ITALIANO',
 '#{id} of the source is requested. It checks if the source has a type which has the has_status attribute true.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('source-attach-in-transaction-allowed-type', now(), 'infinity', 
'select count(*)>0 as vl 
from source.source
where id= #{id} 
    and type_code in (select code 
        from source.administrative_source_type  
        where has_status)');
-------------Start ba_unit and other business rules - Neil 01 November 2011-------------------------
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-check-name', 'sql', 'Invalid identifier for title::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-check-name', now(), 'infinity', 
'SELECT count(*) > 0 as vl 
FROM administrative.ba_unit 
WHERE id= #{id} 
	AND name_firstpart IS NULL
	OR name_lastpart IS NULL
	OR SUBSTR(name_firstpart, 1) = ''N''
	OR TO_NUMBER(name_lastpart, ''9999'') = 0');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-check-no-previous-digital-title-service', 'sql', 'Checks to see if a digital title already exists for requested property::::ITALIANO',
 '#{id}(application.application.id) is requested where service is for newDigitalTitle or newDigitalProperty');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-check-no-previous-digital-title-service', now(), 'infinity', 
'SELECT  count(*) > 0 as vl
FROM application.application_property 
	INNER JOIN administrative.ba_unit ON application.application_property.name_firstpart || ''/'' || application.application_property.name_lastpart = administrative.ba_unit.name
	INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
WHERE application.application_property.application_id = #{id}
	AND administrative.rrr.is_primary');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('mortgage-value-check', 'sql', 'Mortgage is for more than reported value::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('mortgage-value-check', now(), 'infinity', 
'SELECT (total_value < mortgage_amount) AS vl from application.application_property 
	INNER JOIN administrative.ba_unit ON application.application_property.name_firstpart || ''/'' || application.application_property.name_lastpart = administrative.ba_unit.name
	INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
WHERE application.application_property.application_id = #{id}');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit_shares-total-check', 'sql', 'Shares do not total to 1::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit_shares-total-check', now(), 'infinity', 
'Select ABS(1 - SUM(TO_NUMBER(TO_CHAR(nominator, ''9.99999''), ''9.99999'')/TO_NUMBER(TO_CHAR(denominator, ''9.99999''), ''9.99999''))) < 0.01  as vl 
FROM administrative.ba_unit
INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
INNER JOIN administrative.rrr_share ON administrative.rrr.id = administrative.rrr_share.rrr_id
WHERE administrative.ba_unit.id = #{id}
AND administrative.rrr.is_primary
AND administrative.rrr.status_code != ''cancelled''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('current-caveat-check', 'sql', 'There is a current caveat registered on this title::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('current-caveat-check', now(), 'infinity', 
'SELECT COUNT(*) > 0 as vl FROM administrative.rrr 
WHERE ba_unit_id = #{id}
AND type_code = ''caveat''
AND status_code != ''cancelled''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('current-caveat-and-no-withdrawal-or-waiver', 'sql', 'There is a current caveat registered on this title and application does not include withdrawal or waiver document::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('current-caveat-and-no-withdrawal-or-waiver', now(), 'infinity', 
'SELECT COUNT(*) = 0 as vl FROM administrative.rrr 
	INNER JOIN application.application_property ON administrative.rrr.ba_unit_id = application.application_property.ba_unit_id
	INNER JOIN application.application ON application.application_property.application_id = application.application.id
	INNER JOIN application.application_uses_source ON application.application.id = application.application_uses_source.application_id
	INNER JOIN source.source ON application.application_uses_source.source_id = source.id
WHERE administrative.rrr.ba_unit_id = #{id}
	AND administrative.rrr.type_code = ''caveat''
	AND administrative.rrr.status_code != ''cancelled''
	AND application.application.status_code = ''pending''
	AND source.source.type_code = ''waiver''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('current-rrr-for-variation-or-cancellation-check', 'sql', 'Title includes no current right or restriction (apart from primary right). Confirm request for variation or cancellation and check title identifier::::ITALIANO',
 '#{id}(application.application.id) is requested where there is a service that varies or extinguishes an existing rrr');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('current-rrr-for-variation-or-cancellation-check', now(), 'infinity', 
'Select count(*) > 0 as vl FROM application.application
	INNER JOIN application.application_property ON application.application.id = application.application_property.application_id
	INNER JOIN administrative.ba_unit ON application.application_property.name_firstpart || ''/'' || application.application_property.name_lastpart = administrative.ba_unit.name
	INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
WHERE application.application.id = #{id}
AND administrative.rrr.status_code = ''current''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('applicant-name-to-owner-name-check', 'sql', 'Applicant name is different from current recorded owners::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('applicant-name-to-owner-name-check', now(), 'infinity', 
'Select count(*) > 0 as vl FROM application.application
	INNER JOIN application.application_property ON application.application.id = application.application_property.application_id
	INNER JOIN administrative.ba_unit ON application.application_property.name_firstpart || ''/'' || application.application_property.name_lastpart = administrative.ba_unit.name
	INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
	INNER JOIN administrative.rrr_share ON administrative.rrr.id = administrative.rrr_share.rrr_id
	INNER JOIN administrative.party_for_rrr ON administrative.rrr_share.id = administrative.party_for_rrr.share_id
	INNER JOIN party.party ON administrative.party_for_rrr.party_id = party.party.id
	INNER JOIN party.party_role ON party.party.id = party.party_role.party_id
WHERE application.application.id = #{id}
	AND administrative.rrr.is_primary
	AND administrative.rrr.status_code = ''current''
	AND party.name IN (Select party.name FROM application.application
		   INNER JOIN party.party ON application.application.contact_person_id = party.party.id
		   INNER JOIN party.party_role ON party.party.id = party.party_role.party_id
	   WHERE application.application.id = #{id}
	   AND party.party_role.type_code = ''applicant'')
	AND party.last_name IN (Select party.last_name FROM application.application
		   INNER JOIN party.party ON application.application.contact_person_id = party.party.id
		   INNER JOIN party.party_role ON party.party.id = party.party_role.party_id
	   WHERE application.application.id = #{id}
	   AND party.party_role.type_code = ''applicant'')');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('applicant-identification-check', 'sql', 'No personal identification details recorded for application::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('applicant-identification-check', now(), 'infinity', 
'Select count(*) > 0 as vl FROM application.application
	INNER JOIN party.party ON application.application.contact_person_id = party.party.id
WHERE application.application.id = #{id}');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-multiple-mortgages', 'sql', 'Title already has current mortgage::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-multiple-mortgages', now(), 'infinity', 
'SELECT COUNT(*) = 0 as vl FROM administrative.rrr 
WHERE ba_unit_id = #{id}
	AND type_code = ''mortgage''
	AND status_code != ''cancelled''
	AND id IN (SELECT id FROM administrative.rrr WHERE ba_unit_id = #{id} AND type_code = ''mortgage'' AND status_code = ''pending'')');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-several-mortgages-with-same-rank', 'sql', 'Title already has a current mortgage with this ranking::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-several-mortgages-with-same-rank', now(), 'infinity', 
'SELECT COUNT(*) = 0 as vl 
 FROM   administrative.rrr rrr1,
        administrative.rrr rrr2
 WHERE  rrr1.type_code = ''mortgage''
 AND    rrr1.status_code != ''cancelled''
 AND    rrr1.ba_unit_id = #{id}
 AND    rrr2.ba_unit_id = rrr1.ba_unit_id
 AND    rrr2.type_code = rrr1.type_code
 AND    rrr2.status_code = ''pending''
 AND    rrr2.mortgage_ranking = rrr1.mortgage_ranking
 AND    rrr2.id != rrr1.id');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-primary-right', 'sql', 'Title must have a primary right::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-primary-right', now(), 'infinity', 
'SELECT COUNT(*) = 1 as vl FROM administrative.rrr 
WHERE ba_unit_id = #{id}
	AND is_primary
	AND status_code != ''cancelled''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-area-compares-to-related-parcel-area', 'sql', 'Title area differs from parcel area(s) by more than 1%::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-area-compares-to-related-parcel-area', now(), 'infinity', 
'SELECT coalesce((abs(sum(administrative.ba_unit_area.size) - sum(cadastre.spatial_value_area.size))/sum(administrative.ba_unit_area.size)) < 0.01, true) as vl
FROM administrative.ba_unit_area 
	 INNER JOIN administrative.ba_unit ON ba_unit_id = administrative.ba_unit.id
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit.id = administrative.ba_unit_contains_spatial_unit.ba_unit_id
	 INNER JOIN cadastre.spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.spatial_unit.id
	 INNER JOIN cadastre.spatial_value_area ON cadastre.spatial_unit.id = cadastre.spatial_value_area.spatial_unit_id
	 INNER JOIN cadastre.cadastre_object ON cadastre.spatial_unit.id = cadastre.cadastre_object.id
WHERE administrative.ba_unit.id = #{id}
	AND cadastre.cadastre_object.type_code = ''parcel''
	AND administrative.ba_unit_area.type_code = ''officialArea''
	AND cadastre.spatial_value_area.type_code = ''officialArea''');		   
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-cadastre-object-check', 'sql', 'Title must have an associated parcel (or cadastre object)::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-cadastre-object-check', now(), 'infinity', 
'SELECT count(*) != 0 as vl FROM administrative.ba_unit 
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit.id = administrative.ba_unit_contains_spatial_unit.ba_unit_id
	 INNER JOIN cadastre.spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.spatial_unit.id
	 INNER JOIN cadastre.cadastre_object ON cadastre.spatial_unit.id = cadastre.cadastre_object.id
WHERE administrative.ba_unit.id = #{id}');		   
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-compatible-cadastre-object', 'sql', 'Title appears to have incompatible parcel (or cadastre object)::::ITALIANO',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-compatible-cadastre-object', now(), 'infinity', 
'SELECT count(*) != 0 as vl FROM administrative.ba_unit 
	 INNER JOIN administrative.rrr ON administrative.ba_unit.id = administrative.rrr.ba_unit_id
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit.id = administrative.ba_unit_contains_spatial_unit.ba_unit_id
	 INNER JOIN cadastre.spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.spatial_unit.id
	 INNER JOIN cadastre.cadastre_object ON cadastre.spatial_unit.id = cadastre.cadastre_object.id
WHERE administrative.ba_unit.id = #{id}
	AND administrative.ba_unit.type_code = ''basicPropertyUnit''
	AND administrative.rrr.type_code = ''ownership''
	AND cadastre.cadastre_object.type_code = ''parcel''');	
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cadastre-object-check-name', 'sql', 'Invalid identifier for parcel (cadastre object)::::ITALIANO',
 '#{id}(cadastre.cadastre_object.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cadastre-object-check-name', now(), 'infinity', 
'Select Count(*) = 1 as vl 
FROM cadastre.cadastre_object
WHERE transaction_id = #{id} and type_code = ''parcel''
	AND ((SUBSTRING(name_firstpart from 1 for 4) = ''Lot ''))
	AND (SUBSTRING(name_lastpart from 1 for 3) = ''DP '') 
	AND TO_NUMBER(SUBSTRING(name_firstpart from 5 for (CHAR_LENGTH(name_firstpart) - 4)), ''999'') > 0
	AND TO_NUMBER(SUBSTRING(name_lastpart from 4 for POSITION('' '' IN SUBSTRING(name_lastpart from 4 for (CHAR_LENGTH(name_lastpart) - 4)))), ''9999'') > 0');	   		   
-------------End ba_unit and other business rules - Neil 01 November 2011-------------------------
----------------------------------------------------------------------------------------------------
-------------Start application business rules - Neil 18 November 2011-------------------------
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-baunit-name-check', 'sql', 'Invalid identifier for title::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-baunit-name-check', now(), 'infinity', 
'SELECT count(*) > 0 as vl 
FROM application.application_property 
WHERE application_id= #{id} 
	AND name_firstpart IS NULL
	OR name_lastpart IS NULL
	OR SUBSTR(name_firstpart, 1) = ''N''
	OR TO_NUMBER(name_lastpart, ''9999'') = 0');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-shares-total-check', 'sql', 'Shares do not total to 1::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-shares-total-check', now(), 'infinity', 
'Select ABS(1 - SUM(TO_NUMBER(TO_CHAR(nominator, ''9.99999''), ''9.99999'')/TO_NUMBER(TO_CHAR(denominator, ''9.99999''), ''9.99999''))) < 0.01 as vl 
FROM administrative.ba_unit
	INNER JOIN application.application_property ON application.application_property.ba_unit_id = administrative.ba_unit.id
	INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
	INNER JOIN administrative.rrr_share ON administrative.rrr.id = administrative.rrr_share.rrr_id
WHERE application.application_property.application_id = #{id}
AND administrative.rrr.is_primary
AND administrative.rrr.status_code != ''cancelled''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-current-caveat-check', 'sql', 'There is a current caveat registered on the title for this application::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-current-caveat-check', now(), 'infinity', 
'SELECT COUNT(*) > 0 as vl FROM administrative.rrr 
	INNER JOIN administrative.ba_unit ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
	INNER JOIN application.application_property ON application.application_property.ba_unit_id = administrative.ba_unit.id
WHERE application.application_property.application_id = #{id}
AND administrative.rrr.type_code = ''caveat''
AND administrative.rrr.status_code != ''cancelled''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-current-caveat-and-no-withdrawal-or-waiver', 'sql', 'There is a current caveat registered on this title and application does not include withdrawal or waiver document::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-current-caveat-and-no-withdrawal-or-waiver', now(), 'infinity', 
'SELECT COUNT(*) > 0 as vl FROM administrative.rrr 
	INNER JOIN application.application_property ON administrative.rrr.ba_unit_id = application.application_property.ba_unit_id
	INNER JOIN application.application ON application.application_property.application_id = application.application.id
	INNER JOIN application.application_uses_source ON application.application.id = application.application_uses_source.application_id
	INNER JOIN source.source ON application.application_uses_source.source_id = source.id
WHERE application.application_property.application_id = #{id}
	AND administrative.rrr.type_code = ''caveat''
	AND administrative.rrr.status_code != ''cancelled''
	AND application.application.status_code = ''pending''
	AND source.source.type_code = ''waiver''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-for-title-with-mortgage', 'sql', 'Title already has current mortgage::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-for-title-with-mortgage', now(), 'infinity', 
'SELECT COUNT(*) = 0 as vl FROM administrative.rrr 
	INNER JOIN application.application_property ON administrative.rrr.ba_unit_id = application.application_property.ba_unit_id
WHERE application.application_property.application_id = #{id}
	AND type_code = ''mortgage''
	AND status_code != ''cancelled''
	AND administrative.rrr.id IN 
		(SELECT administrative.rrr.id FROM administrative.rrr 
			INNER JOIN application.application_property ON administrative.rrr.ba_unit_id = application.application_property.ba_unit_id
		WHERE application_id = #{id} AND type_code = ''mortgage'' AND status_code = ''pending'')');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-has-title-several-mortgages-with-same-rank', 'sql', 'Title already has a current mortgage with this ranking::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-has-title-several-mortgages-with-same-rank', now(), 'infinity', 
'SELECT COUNT(*) > 0 as vl FROM administrative.rrr 
WHERE type_code = ''mortgage''
	AND status_code != ''cancelled''
	AND administrative.rrr.id || to_char(mortgage_ranking, ''999'') IN 
		(SELECT administrative.rrr.id || to_char(mortgage_ranking, ''999'') FROM administrative.rrr 
			INNER JOIN application.application_property ON administrative.rrr.ba_unit_id = application.application_property.ba_unit_id
		WHERE application_id = #{id}
			AND type_code = ''mortgage'' 
			AND status_code = ''pending'')');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-title-has-primary-right', 'sql', 'Title that is part of this application must have a primary right::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-title-has-primary-right', now(), 'infinity', 
'SELECT COUNT(*) = 1 as vl 
FROM administrative.rrr INNER JOIN administrative.ba_unit on rrr.ba_unit_id= ba_unit.id 
INNER JOIN application.application_property ap ON ba_unit.name_firstpart = ap.name_firstpart and ba_unit.name_lastpart= ap.name_lastpart
WHERE application_id = #{id}
	AND rrr.is_primary
	AND rrr.status_code != ''historic''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-area-comparison', 'sql', 'Title area differs from parcel area(s) by more than 1%::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-area-comparison', now(), 'infinity', 
'SELECT (abs(sum(administrative.ba_unit_area.size) - sum(cadastre.spatial_value_area.size))/sum(administrative.ba_unit_area.size)) < 0.01 as vl 
FROM administrative.ba_unit_area 
	 INNER JOIN administrative.ba_unit ON administrative.ba_unit_area.ba_unit_id = administrative.ba_unit.id
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit.id = administrative.ba_unit_contains_spatial_unit.ba_unit_id
	 INNER JOIN cadastre.spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.spatial_unit.id
	 INNER JOIN cadastre.spatial_value_area ON cadastre.spatial_unit.id = cadastre.spatial_value_area.spatial_unit_id
	 INNER JOIN cadastre.cadastre_object ON cadastre.spatial_unit.id = cadastre.cadastre_object.id
	 INNER JOIN application.application_property ON administrative.ba_unit.id = application.application_property.ba_unit_id
WHERE application.application_property.application_id = #{id}
	AND cadastre.cadastre_object.type_code = ''parcel''
	AND administrative.ba_unit_area.type_code = ''officialArea''
	AND cadastre.spatial_value_area.type_code = ''officialArea''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-title-has-cadastre-object', 'sql', 'Title must have an associated parcel (or cadastre object)::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-title-has-cadastre-object', now(), 'infinity', 
'SELECT count(*) != 0 as vl 
FROM administrative.ba_unit 
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit.id = administrative.ba_unit_contains_spatial_unit.ba_unit_id
	 INNER JOIN cadastre.spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.spatial_unit.id
	 INNER JOIN cadastre.cadastre_object ON cadastre.spatial_unit.id = cadastre.cadastre_object.id
	 INNER JOIN application.application_property ON administrative.ba_unit.id = application.application_property.ba_unit_id
WHERE application.application_property.application_id = #{id}');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-title-has-compatible-cadastre-object', 'sql', 'Title appears to have incompatible parcel (or cadastre object)::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-title-has-compatible-cadastre-object', now(), 'infinity', 
'SELECT count(*) != 0 as vl 
FROM administrative.ba_unit 
	 INNER JOIN administrative.rrr ON administrative.ba_unit.id = administrative.rrr.ba_unit_id
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit.id = administrative.ba_unit_contains_spatial_unit.ba_unit_id
	 INNER JOIN cadastre.spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.spatial_unit.id
	 INNER JOIN cadastre.cadastre_object ON cadastre.spatial_unit.id = cadastre.cadastre_object.id
	 INNER JOIN application.application_property ON administrative.ba_unit.id = application.application_property.ba_unit_id
WHERE application.application_property.application_id = #{id}
	AND administrative.ba_unit.type_code = ''basicPropertyUnit''
	AND administrative.rrr.type_code = ''ownership''
	AND cadastre.cadastre_object.type_code = ''parcel''');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('app-cadastre-object-name', 'sql', 'Invalid identifier for parcel (cadastre object)::::ITALIANO',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('app-cadastre-object-name', now(), 'infinity', 
'SELECT Count(*) = 1 as vl 
FROM cadastre.cadastre_object
	 INNER JOIN administrative.ba_unit_contains_spatial_unit ON administrative.ba_unit_contains_spatial_unit.spatial_unit_id = cadastre.cadastre_object.id
	 INNER JOIN application.application_property ON administrative.ba_unit_contains_spatial_unit.ba_unit_id = application.application_property.ba_unit_id
WHERE application.application_property.application_id = #{id}
	AND cadastre.cadastre_object.type_code = ''parcel''
	AND ((SUBSTRING(cadastre.cadastre_object.name_firstpart from 1 for 4) = ''Lot ''))
	AND (SUBSTRING(cadastre.cadastre_object.name_lastpart from 1 for 3) = ''DP '') 
	AND TO_NUMBER(SUBSTRING(cadastre.cadastre_object.name_firstpart from 5 for (CHAR_LENGTH(cadastre.cadastre_object.name_firstpart) - 4)), ''999'') > 0
	AND TO_NUMBER(SUBSTRING(cadastre.cadastre_object.name_lastpart from 4 for POSITION('' '' IN SUBSTRING(cadastre.cadastre_object.name_lastpart from 4 for (CHAR_LENGTH(cadastre.cadastre_object.name_lastpart) - 4)))), ''9999'') > 0');	   		   
-------------End application business rules - Neil 18 November 2011-------------------------

----Business rules that are used for the cadastre redefinition--------------------------------------
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cadastre-redefinition-union-old-new-the-same', 'sql', 
    'The union of the new polygons must be the same with the union of the old polygons::::ITALIANO',
 '#{id} is the parameter asked. It is the transaction id.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cadastre-redefinition-union-old-new-the-same', now(), 'infinity', 
'select coalesce(st_equals(geom_to_snap,target_geom), true) as vl
from snap_geometry_to_geometry(
(select st_union(co.geom_polygon) 
from cadastre.cadastre_object co 
where id in (select cadastre_object_id from cadastre.cadastre_object_target co_t 
              where transaction_id = #{id}))
, (select st_union(co_t.geom_polygon)
from cadastre.cadastre_object_target co_t 
where transaction_id = #{id}), 
  coalesce(system.get_setting(''map-tolerance'')::double precision, 0.01), true)');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cadastre-redefinition-target-geometries-dont-overlap', 'sql', 
    'New polygons do not overlap with each other.::::ITALIANO',
 '#{id} is the parameter asked. It is the transaction id.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cadastre-redefinition-target-geometries-dont-overlap', now(), 'infinity', 
'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object_target co where transaction_id = #{id}');

----End - Business rules that are used for the cadastre redefinition--------------------------------


--------------Check new properties/title owners are not the same as underlying properties/titles owners (Give WARNING if > 0)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-br22-check-different-owners', 'sql', 'Owners of new properties/titles are not the same as owners of underlying properties/titles::::Gli aventi diritto delle nuove proprieta/titoli non sono gli stessi delle proprieta/titoli sottostanti',
'#{id}(baunit_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-br22-check-different-owners', now(), 'infinity', 
'with prior_property_owner as (
	select po.name
	from   
	party.party po,
	administrative.party_for_rrr pfro,
	administrative.rrr ro
	where 
	po.id = pfro.party_id
	and
	pfro.rrr_id = ro.id
	and
	ro.ba_unit_id = #{id})
select  count (pn.name)= 0 as vl
from   
	party.party pn,
	administrative.party_for_rrr pfro,
	administrative.rrr ro
	where 
	pn.id = pfro.party_id
	and
	pfro.rrr_id = ro.id
	and
	ro.ba_unit_id in
	(select administrative.required_relationship_baunit.to_ba_unit_id
	 from   administrative.required_relationship_baunit
	 where  administrative.required_relationship_baunit.from_ba_unit_id = #{id})
   and
        pn.name not in (select name from prior_property_owner)
    ');

--- ## ALREADY IMPLEMENTED BY "ba_unit_shares-total-check" TBVD ## ----------
--------------Check shares total = 100% (Give critical if not) 
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-br23-check-share-100%', 'sql', 'Ownership Shares for some property/title not equal to 100%::::il totale delle suddivisioni per qualche titolo e uguale al 100%', '#{id}(application_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-br23-check-share-100%', now(), 'infinity', 
'with all_property_ownership as (
Select (TO_NUMBER(TO_CHAR(nominator, ''9.99999''), ''9.99999'')/TO_NUMBER(TO_CHAR(denominator, ''9.99999''), ''9.99999'')) as share,
administrative.rrr.id as id
FROM administrative.ba_unit
INNER JOIN administrative.rrr ON administrative.rrr.ba_unit_id = administrative.ba_unit.id
INNER JOIN administrative.rrr_share ON administrative.rrr.id = administrative.rrr_share.rrr_id
WHERE administrative.ba_unit.id in (
		 select ba_unit_id from administrative.rrr
		 where transaction_id in (
			select id from transaction.transaction
			where from_service_id in (select id from application.service
		where application_id = #{id}
		)
		)
	)	
AND administrative.rrr.status_code != ''cancelled''
AND administrative.rrr.is_primary 
)
select ABS(
        (Select count (distinct(id)) from all_property_ownership) -
         (Select SUM(share) from all_property_ownership)
      )<0.01 as vl');

--------------Check rrr transferred to new titles/properties (Critical if > 0)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-br24-check-rrr-accounted', 'sql', 'Not all rights and restrictions have been accounted for the new title/property::::non tutti i diritti e le restrizioni sono stati trasferiti al nuovo titolo', '#{id}(baunit_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-br24-check-rrr-accounted', now(), 'infinity', 
'
with prior_property_rrr as (
select ro.id
from administrative.rrr ro
where ro.ba_unit_id = #{id}
AND ro.status_code != ''cancelled'')
select (
 (select count (id) from prior_property_rrr)
-
  (select count (rn.id) 
    from administrative.rrr rn
    where rn.ba_unit_id in
	(select administrative.required_relationship_baunit.to_ba_unit_id
	 from   administrative.required_relationship_baunit
	 where  administrative.required_relationship_baunit.from_ba_unit_id = #{id})
     and
        rn.id in (select id from prior_property_rrr)
  )      

) = 0 as vl
');

--------------Check there is only one pending transaction per property/title [ba_unit_id] (Critical if > 0)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-brNew-check-pending-transaction', 'sql', 'property/title should have only one pending transaction::::per ogni titolo/proprieta deve esserci solo una transazione in corso', '#{id}(baunit_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-brNew-check-pending-transaction', now(), 'infinity', 
'
select count (*) <= 1 as vl
from administrative.ba_unit_target,
transaction.transaction
where administrative.ba_unit_target.transaction_id = transaction.transaction.id
and transaction.transaction.status_code=''pending''
and administrative.ba_unit_target.ba_unit_id  = #{id}
');

----------------------------------------------------------------------------------------------------
insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br8-check-has-services', 'critical', 'validate', 'application', 1);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br7-check-sources-have-documents', 'warning', 'validate', 'application', 2);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br1-check-required-sources-are-present', 'critical', 'validate', 'application', 3);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br2-check-title-documents-not-old', 'medium', 'validate', 'application', 4);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br3-check-properties-are-not-historic', 'critical', 'validate', 'application', 5);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br4-check-sources-date-not-in-the-future', 'warning', 'validate', 'application', 6);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br5-check-there-are-front-desk-services', 'warning', 'validate', 'application', 7);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-br6-check-new-title-service-is-needed', 'warning', 'validate', 'application', 8);

--modified 1 November request_type from newTitle to newDigitalTitle-------------
insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('request-newfreehold-br1-check-title-source-not-old', 'critical', 'start', 'service', 'newDigitalTitle',  3);

-- Business rules running before approval of application
insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-on-approve-check-services-status', 'critical', 'approve', 'application', 1);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-on-approve-check-services-without-transaction', 'critical', 'approve', 'application', 20);

-- Business rules running before complete of service
insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, order_of_execution) 
values('service-on-complete-without-transaction', 'critical', 'complete', 'service', 1);

-- Business rules running before complete of rrr
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-must-have-parties', 'critical', 'current', 'rrr', 3);

-- Business rules running before source can be attached to a transaction
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('source-attach-in-transaction-no-pendings', 'critical', 'pending', 'source', 4);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('source-attach-in-transaction-allowed-type', 'critical', 'pending', 'source', 2);

-----------Cadastre Transactions common-----------------------------------------------------------------------------------------
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-present', 'warning', 'pending', 'cadastre_object', 2);

----Check there are no pending changes that overlap the union of the target parcels (CRITICAL)
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-check-nopending', 'critical', 'pending', 'cadastre_object', 3);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('documents-present', 'warning', 'pending', 'cadastre_object', 5);


insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-present', 'warning', 'current', 'cadastre_object', 2);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-check-nopending', 'critical', 'current', 'cadastre_object', 3);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('documents-present', 'warning', 'current', 'cadastre_object', 5);

-----------Cadastre Redefinition -------------------------------------------------------------------

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-union-old-new-the-same', 'warning', 'pending', 'cadastre_object', 'redefineCadastre', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-union-old-new-the-same', 'warning', 'current', 'cadastre_object', 'redefineCadastre', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-target-geometries-dont-overlap', 'critical', 'current', 'cadastre_object', 'redefineCadastre', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-target-geometries-dont-overlap', 'warning', 'pending', 'cadastre_object', 'redefineCadastre', 1);

-----------Cadastre Change [Floss 634 (subtask of Floss 555)]---------------------------------------
--- TBVD -----------------

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('application-baunit-has-parcels', 'critical', null, 'service', 'cadastreChange', 1);

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('application-baunit-check-area', 'warning', null, 'service', 'cadastreChange', 9);

---------------------------------CADASTRE CHANGE - PENDING -----------------------------------------
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('survey-points-present', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 1);

----the union of target parcels is a polygon (not a multipolygon) (CRITICAL)
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-parcels-check-isapolygon', 'critical', 'pending', 'cadastre_object', 'cadastreChange', 4);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-present', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 6);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-and-new-union-the-same', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 7);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-dont-overlap', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 8);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newofficialarea-calculatednewarea', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 10);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-object-check-name', 'medium', 'pending', 'cadastre_object', 'cadastreChange', 11);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newareas-oldareas', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 12);

---------------------------------CADASTRE CHANGE - APPROVE -----------------------------------------
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('survey-points-present', 'critical', 'current', 'cadastre_object', 'cadastreChange', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-parcels-check-isapolygon', 'critical', 'current', 'cadastre_object', 'cadastreChange', 4);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-present', 'critical', 'current', 'cadastre_object', 'cadastreChange', 6);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-and-new-union-the-same', 'warning', 'current', 'cadastre_object', 'cadastreChange', 7);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-dont-overlap', 'critical', 'current', 'cadastre_object', 'cadastreChange', 8);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newofficialarea-calculatednewarea', 'warning', 'current', 'cadastre_object', 'cadastreChange', 10);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-object-check-name', 'medium', 'current', 'cadastre_object', 'cadastreChange', 11);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newareas-oldareas', 'warning', 'current', 'cadastre_object', 'cadastreChange', 12);

-----------END  Cadastre Change [Floss 634 (subtask of Floss 555)]-----------------------------------------------------------------------------------------
-------------Start ba_unit and other business Validation Rules - Neil 01 November 2011-------------------------
--insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
--values('baunit-check-name', 'medium', 'validate', 'application', 9);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('application-check-no-previous-digital-title-service', 'warning', 'validate', 'application', 10);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('mortgage-value-check', 'warning', 'validate', 'application', 2);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit_shares-total-check', 'critical', 'pending', 'rrr', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('current-caveat-check', 'medium', 'pending', 'ba_unit', 17);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('current-caveat-and-no-withdrawal-or-waiver', 'critical', 'current', 'ba_unit', 2);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('current-rrr-for-variation-or-cancellation-check', 'medium', 'validate', 'application', 11);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('applicant-name-to-owner-name-check', 'warning', 'validate', 'application', 25);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('applicant-identification-check', 'medium', 'approve', 'application', 13);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('baunit-has-multiple-mortgages', 'warning', 'validate', 'application', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-several-mortgages-with-same-rank', 'critical', 'current', 'ba_unit', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-primary-right', 'critical', 'current', 'ba_unit', 6);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-area-compares-to-related-parcel-area', 'medium', 'current', 'ba_unit', 5);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-cadastre-object-check', 'medium', 'current', 'ba_unit', 3);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-compatible-cadastre-object', 'medium', 'current', 'ba_unit', 4);

-------------End ba_unit and other business Validation Rules - Neil 01 November 2011-------------------------
-------------Start application Validation Rules - Neil 18 November 2011-------------------------
--insert into system.br_validation(br_id, severity_code, moment_code, target_code, order_of_execution) 
--values('application-valid-property-name', 'app-baunit-name-check', 'medium', 'start', 'application', 9);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-shares-total-check', 'critical', 'validate', 'application', 16);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-current-caveat-check', 'medium', null, 'application', 1);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-current-caveat-and-no-withdrawal-or-waiver', 'critical', null, 'application', 21);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-for-title-with-mortgage', 'warning', 'validate', 'application', 18);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-has-title-several-mortgages-with-same-rank', 'critical', null, 'application', 19);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-title-has-primary-right', 'critical', null, 'application', 1);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-area-comparison', 'medium', 'validate', 'application', 25);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-title-has-cadastre-object', 'medium', 'validate', 'application', 3);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-title-has-compatible-cadastre-object', 'medium', 'validate', 'application', 23);

insert into system.br_validation(br_id, severity_code, target_application_moment, target_code, order_of_execution) 
values('app-cadastre-object-name', 'medium', 'validate', 'application', 5);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('newtitle-br22-check-different-owners', 'warning', 'current', 'ba_unit', 2);

--- ## ALREADY IMPLEMENTED BY "ba_unit_shares-total-check" TBVD## ----------
insert into system.br_validation(br_id, severity_code,   target_application_moment, target_code, order_of_execution) 
values('newtitle-br23-check-share-100%', 'critical', 'validate', 'application', 26);
--- ########################################################## ----------


--- new target code and moment for br24n =  RRR
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_request_type_code, target_code, order_of_execution) 
values('newtitle-br24-check-rrr-accounted', 'critical', 'current', 'newFreehold', 'rrr', 10);

insert into system.br_validation(br_id, severity_code,  target_request_type_code, target_code, order_of_execution) 
values('newtitle-br24-check-rrr-accounted', 'critical',  'newApartment', 'rrr', 10);

insert into system.br_validation(br_id, severity_code, target_request_type_code, target_code, order_of_execution) 
values('newtitle-br24-check-rrr-accounted', 'critical', 'newOwnership', 'rrr', 10);

---insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
---values('newtitle-br24-check-rrr-accounted', 'critical', 'current', 'ba_unit', 10);
--- ###### ---

--- new target code and moment for newtitle-brNew-check-pending-transaction = RRR
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_request_type_code, target_code, order_of_execution) 
values('newtitle-brNew-check-pending-transaction', 'critical', 'current', 'newFreehold', 'rrr', 18);

insert into system.br_validation(br_id, severity_code,  target_request_type_code, target_code, order_of_execution) 
values('newtitle-brNew-check-pending-transaction', 'critical',  'newApartment', 'rrr', 18);

insert into system.br_validation(br_id, severity_code, target_request_type_code, target_code, order_of_execution) 
values('newtitle-brNew-check-pending-transaction', 'critical', 'newOwnership', 'rrr', 18);

---insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
---values('newtitle-brNew-check-pending-transaction', 'critical', 'current', 'ba_unit', 18);
--- ### ---

-------------End application Validation Rules - Neil 18 November 2011-------------------------

update system.br set display_name = id;
