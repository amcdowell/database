INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('target-parcels-check-isapolygon', 'sql', 'The union of the target parcels must be a polygon::::Объединение целевых участков должно быть полигоном.', '#{id}(cadastre.cadastre_object.transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('target-parcels-check-isapolygon', now(), 'infinity', 'select St_GeometryType(ST_Union(co.geom_polygon)) = ''ST_Polygon'' as vl
 from cadastre.cadastre_object co 
  inner join cadastre.cadastre_object_target co_target
   on co.id = co_target.cadastre_object_id
    where co_target.transaction_id = #{id}');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-parcels-check-isapolygon', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'critical', 90);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-parcels-check-isapolygon', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 80);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('target-parcels-present', 'sql', 'Target parcel(s) must be selected::::Целевые участки должны быть выбраны.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('target-parcels-present', now(), 'infinity', 'select count (*) > 0 as vl from cadastre.cadastre_object_target where transaction_id= #{id}');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-parcels-present', 'cadastre_object', NULL, NULL, 'pending', NULL, NULL, 'warning', 450);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-parcels-present', 'cadastre_object', NULL, NULL, 'current', NULL, NULL, 'warning', 440);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('target-parcels-check-nopending', 'sql', 'There should be no pending changes for any of target parcels::::Целевые участки не должны иметь каких-либо незавершенных изменений.', '#{id}(cadastre.cadastre_object.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('target-parcels-check-nopending', now(), 'infinity', 'select (select count(*)=0 
  from cadastre.cadastre_object_target target_also inner join transaction.transaction t 
    on target_also.transaction_id = t.id and t.status_code not in (''approved'')
  where co_target.transaction_id != target_also.transaction_id
    and co_target.cadastre_object_id= target_also.cadastre_object_id) as vl
from cadastre.cadastre_object_target co_target
where co_target.transaction_id = #{id}
 ');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-parcels-check-nopending', 'cadastre_object', NULL, NULL, 'pending', NULL, NULL, 'critical', 310);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-parcels-check-nopending', 'cadastre_object', NULL, NULL, 'current', NULL, NULL, 'critical', 300);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('cadastre-redefinition-union-old-new-the-same', 'sql', 'The union of the new polygons must be the same as the union of the old polygons::::Объединение новых полигонов должно быть таким же как объединение старых полигонов.', '#{id} is the parameter asked. It is the transaction id.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('cadastre-redefinition-union-old-new-the-same', now(), 'infinity', 'select st_equals(geom_to_snap,target_geom) as vl from cadastre.snap_geometry_to_geometry((select st_union(co.geom_polygon) from cadastre.cadastre_object co 
 where id in (select cadastre_object_id from cadastre.cadastre_object_target co_t where transaction_id = #{id})), 
(select st_union(co_t.geom_polygon) from cadastre.cadastre_object_target co_t where transaction_id = #{id}), 
 system.get_setting(''map-tolerance'')::double precision, true)');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cadastre-redefinition-union-old-new-the-same', 'cadastre_object', NULL, NULL, 'current', 'redefineCadastre', NULL, 'warning', 400);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cadastre-redefinition-union-old-new-the-same', 'cadastre_object', NULL, NULL, 'pending', 'redefineCadastre', NULL, 'warning', 420);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('cadastre-redefinition-target-geometries-dont-overlap', 'sql', 'New polygons do not overlap with each other.::::Новые полигоны не пересекаются друг с другом.', '#{id} is the parameter asked. It is the transaction id.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('cadastre-redefinition-target-geometries-dont-overlap', now(), 'infinity', 'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object_target co where transaction_id = #{id}');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cadastre-redefinition-target-geometries-dont-overlap', 'cadastre_object', NULL, NULL, 'current', 'redefineCadastre', NULL, 'critical', 120);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cadastre-redefinition-target-geometries-dont-overlap', 'cadastre_object', NULL, NULL, 'pending', 'redefineCadastre', NULL, 'warning', 430);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('survey-points-present', 'sql', 'There are at least 3 survey points present::::По крайней мере должны быть определены 3 точки съемки.', '#{id}(transaction_id) is requested. Check there are survey points attached with the cadastre change.
 At least 3 points has to be attached to complete a polygon.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('survey-points-present', now(), 'infinity', 'select count (*) > 2  as vl from cadastre.survey_point where transaction_id= #{id}');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('survey-points-present', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 380);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('survey-points-present', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 70);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('area-check-percentage-newofficialarea-calculatednewarea', 'sql', 'The difference between the new official parcel area and the new calculated area should be less than 1%::::Разница между новой официальной площади участка и новой вычисленной площади не должны быть более 1%.', '#{id}(cadastre.cadastre_object.id) is requested. 
 Check new official area - calculated new area / new official area in percentage (Give in WARNING description, percentage & parcel if percentage > 1%)');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('area-check-percentage-newofficialarea-calculatednewarea', now(), 'infinity', 'select count(*) = 0 as vl
from cadastre.cadastre_object co 
  left join cadastre.spatial_value_area sa_calc on (co.id= sa_calc.spatial_unit_id and sa_calc.type_code =''calculatedArea'')
  left join cadastre.spatial_value_area sa_official on (co.id= sa_official.spatial_unit_id and sa_official.type_code =''officialArea'')
where co.transaction_id = #{id} and
(abs(coalesce(sa_official.size, 0) - coalesce(sa_calc.size, 0)) 
/ 
(case when sa_official.size is null or sa_official.size = 0 then 1 else sa_official.size end)) > 0.01');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('area-check-percentage-newofficialarea-calculatednewarea', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 610);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('area-check-percentage-newofficialarea-calculatednewarea', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 620);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('new-cadastre-objects-do-not-overlap', 'sql', 'The new parcel polygons must not overlap::::Новые участки не должны пересекаться.', '#{id}(transaction_id) is requested. Check the union of new co has the same area as the sum of all areas of new co-s, which means the new co-s don''t overlap');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('new-cadastre-objects-do-not-overlap', now(), 'infinity', 'WITH tolerance AS (SELECT CAST(ABS(LOG((CAST (vl AS NUMERIC)^2))) AS INT) AS area FROM system.setting where name = ''map-tolerance'' LIMIT 1)

SELECT COALESCE(ROUND(CAST (ST_AREA(ST_UNION(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)) = 
		ROUND(CAST(SUM(ST_AREA(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)), 
		TRUE) AS vl
FROM cadastre.cadastre_object co 
WHERE transaction_id = #{id} ');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('new-cadastre-objects-do-not-overlap', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 60);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('new-cadastre-objects-do-not-overlap', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 480);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('cadastre-object-check-name', 'sql', 'The parcel (cadastre object) should have a valid form of description (appellation)::::Участок (кадастровый объект) должен иметь корректное описание (наименование).', '#{id}(cadastre.cadastre_object.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('cadastre-object-check-name', now(), 'infinity', 'Select cadastre.cadastre_object_name_is_valid(name_firstpart, name_lastpart) as vl 
FROM cadastre.cadastre_object
WHERE transaction_id = #{id} and type_code = ''parcel''
order by 1
limit 1');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cadastre-object-check-name', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 600);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('cadastre-object-check-name', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'medium', 660);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('area-check-percentage-newareas-oldareas', 'sql', 'The difference between the total of the new parcels official areas and the total of the old parcels official areas should not be greater than 0.1%::::Разница между общей официальной площадью новых участков и площадью старых участков не должна превышать 0.1%.', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('area-check-percentage-newareas-oldareas', now(), 'infinity', 'select abs((select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
        and a.spatial_unit_id in (
	   select co_new.id
		from cadastre.cadastre_object co_new 
		where co_new.transaction_id = #{id}))
 -
   (select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 ) /(select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 < 0.001 as vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('area-check-percentage-newareas-oldareas', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 640);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('area-check-percentage-newareas-oldareas', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 630);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('new-cadastre-objects-present', 'sql', 'New cadastral objects must be defined::::Новые кадастровые объекты должны быть определены.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('new-cadastre-objects-present', now(), 'infinity', 'select count (*) > 0 as vl from cadastre.cadastre_object where transaction_id= #{id}');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('new-cadastre-objects-present', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 370);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('new-cadastre-objects-present', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 50);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('target-and-new-union-the-same', 'sql', 'The union of new parcel polygons is the same with the union of the target parcel polygons::::Объединение полигонов новых участков должно быть таким же как форма полигонов целевых участков.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('target-and-new-union-the-same', now(), 'infinity', 'select st_equals(geom_to_snap,target_geom) as vl
from cadastre.snap_geometry_to_geometry(
(select st_union(co.geom_polygon) 
from cadastre.cadastre_object co where transaction_id = #{id})
, (select st_union(co.geom_polygon)
from cadastre.cadastre_object co 
where id in (select cadastre_object_id 
  from cadastre.cadastre_object_target  where transaction_id = #{id})), 
  system.get_setting(''map-tolerance'')::double precision, true)
 ');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-and-new-union-the-same', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 470);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('target-and-new-union-the-same', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 460);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
