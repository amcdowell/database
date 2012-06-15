insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-parcels-present', 'sql', 'There are target parcels selected::::Esistono particelle originarie selezionate',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('target-parcels-present', now(), 'infinity', 
 'select count (*) > 0 as vl from cadastre.cadastre_object_target where transaction_id= #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-present', 'warning', 'pending', 'cadastre_object', 2);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-present', 'warning', 'current', 'cadastre_object', 2);

----------------------------------------------------------------------------------------------------

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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-check-nopending', 'critical', 'pending', 'cadastre_object', 3);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-parcels-check-nopending', 'critical', 'current', 'cadastre_object', 3);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('documents-present', 'sql', 'There are documents/ sources attached::::Vi sono documenti allegati',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('documents-present', now(), 'infinity', 
 'select count (*) > 0 as vl from transaction.transaction_source where transaction_id= #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('documents-present', 'warning', 'pending', 'cadastre_object', 5);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('documents-present', 'warning', 'current', 'cadastre_object', 5);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cadastre-redefinition-union-old-new-the-same', 'sql', 
    'The union of the new polygons must be the same with the union of the old polygons::::La unione dei nuovi poligoni deve esser la stessa di quella dei vecchi poligoni',
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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-union-old-new-the-same', 'warning', 'pending', 'cadastre_object', 'redefineCadastre', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-union-old-new-the-same', 'warning', 'current', 'cadastre_object', 'redefineCadastre', 1);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cadastre-redefinition-target-geometries-dont-overlap', 'sql', 
    'New polygons do not overlap with each other.::::I nuovi poligoni non devono sovrapporsi',
 '#{id} is the parameter asked. It is the transaction id.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cadastre-redefinition-target-geometries-dont-overlap', now(), 'infinity', 
'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object_target co where transaction_id = #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-target-geometries-dont-overlap', 'critical', 'current', 'cadastre_object', 'redefineCadastre', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-redefinition-target-geometries-dont-overlap', 'warning', 'pending', 'cadastre_object', 'redefineCadastre', 1);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-baunit-has-parcels', 'sql', 'Ba Unit must have Parcels::::La BA Unit (Unita Amministrativa di Base) deve avere particelle',
 '#{id}(application.service.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-baunit-has-parcels', now(), 'infinity', 
'select (select count(*)>0 
  from administrative.ba_unit_contains_spatial_unit ba_su inner join cadastre.cadastre_object co on ba_su.spatial_unit_id= co.id
  where co.status_code in (''current'') and co.geom_polygon is not null and ba_su.ba_unit_id= ba.id) as vl
from application.service s inner join application.application_property ap on (s.application_id= ap.application_id)
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
where s.id = #{id}
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('application-baunit-has-parcels', 'critical', 'complete', 'service', 'cadastreChange', 1);

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('application-baunit-has-parcels', 'critical', 'complete', 'service', 'redefineCadastre', 1);

----------------------------------------------------------------------------------------------------

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

insert into system.br_validation(br_id, severity_code, target_service_moment, target_code, target_request_type_code, order_of_execution) 
values('application-baunit-check-area', 'warning', null, 'service', 'cadastreChange', 9);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('survey-points-present', 'sql', 'There are at least 3 survey points present::::Devono esservi almeno 3 punti di controllo',
 '#{id}(transaction_id) is requested. Check there are survey points attached with the cadastre change.
 At least 3 points has to be attached to complete a polygon.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('survey-points-present', now(), 'infinity', 
 'select count (*) > 2  as vl from cadastre.survey_point where transaction_id= #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('survey-points-present', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('survey-points-present', 'critical', 'current', 'cadastre_object', 'cadastreChange', 1);

----------------------------------------------------------------------------------------------------

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
    
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-parcels-check-isapolygon', 'critical', 'pending', 'cadastre_object', 'cadastreChange', 4);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-parcels-check-isapolygon', 'critical', 'current', 'cadastre_object', 'cadastreChange', 4);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('new-cadastre-objects-present', 'sql', 'There are new cadastral objects defined::::Vi sono nuovi oggetti catastali definiti',
 '#{id}(transaction_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('new-cadastre-objects-present', now(), 'infinity', 
 'select count (*) > 0 as vl from cadastre.cadastre_object where transaction_id= #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-present', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 6);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-present', 'critical', 'current', 'cadastre_object', 'cadastreChange', 6);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-and-new-union-the-same', 'sql', 'The union of new cadastral objects is the same with the union of target cadastral objects::::La unione dei nuovi oggetti catastali deve corrispondere alla unione di quelli originari',
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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-and-new-union-the-same', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 7);


insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('target-and-new-union-the-same', 'warning', 'current', 'cadastre_object', 'cadastreChange', 7);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('new-cadastre-objects-dont-overlap', 'sql', 'The new cadastral objects don''t overlap::::I nuovi oggetti catastali non devono sovrapporsi',
 '#{id}(transaction_id) is requested. Check the union of new co has the same area as the sum of all areas of new co-s, which means the new co-s don''t overlap');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('new-cadastre-objects-dont-overlap', now(), 'infinity', 
 'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object co where transaction_id = #{id}
 ');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-dont-overlap', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 8);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('new-cadastre-objects-dont-overlap', 'critical', 'current', 'cadastre_object', 'cadastreChange', 8);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('area-check-percentage-newofficialarea-calculatednewarea', 'sql', 'New official area - calculated new area / new official area in percentage should not be > 1%::::Il valore della nuova area ufficiale -  quello CALCOLATO della nuova area / 
il valore della nuova area ufficiale in percentuale non dovrebbe essere superiore all 1%',
 '#{id}(cadastre.cadastre_object.id) is requested. 
 Check new official area - calculated new area / new official area in percentage (Give in WARNING description, percentage & parcel if percentage > 1%)');

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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newofficialarea-calculatednewarea', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 10);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newofficialarea-calculatednewarea', 'warning', 'current', 'cadastre_object', 'cadastreChange', 10);


----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cadastre-object-check-name', 'sql', 'Invalid identifier for parcel (cadastre object)::::Identificativo per la particella (oggetto catastale) invalido',
 '#{id}(cadastre.cadastre_object.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cadastre-object-check-name', now(), 'infinity', 
'Select cadastre.cadastre_object_name_is_valid(name_firstpart, name_lastpart) as vl 
FROM cadastre.cadastre_object
WHERE transaction_id = #{id} and type_code = ''parcel''
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-object-check-name', 'medium', 'pending', 'cadastre_object', 'cadastreChange', 11);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('cadastre-object-check-name', 'medium', 'current', 'cadastre_object', 'cadastreChange', 11);

----------------------------------------------------------------------------------------------------

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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newareas-oldareas', 'warning', 'pending', 'cadastre_object', 'cadastreChange', 12);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, target_request_type_code, order_of_execution) 
values('area-check-percentage-newareas-oldareas', 'warning', 'current', 'cadastre_object', 'cadastreChange', 12);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

