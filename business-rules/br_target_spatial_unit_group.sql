SET client_encoding = 'UTF8';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('spatial-unit-group-not-overlap', 'sql', 'Spatial unit groups of the same hierarchy must not overlap with each other. Tolerance of 0.5 m is applied.::::Пространственные группы одной и той же иерархии не должны пересекаться друг с другом. Погрешность не должна превышать 0.5 м', 'There is no parameter required.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('spatial-unit-group-not-overlap', now(), 'infinity', 'select count(*) =0 as vl
from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
where sug1.hierarchy_level = sug2.hierarchy_level and sug1.id > sug2.id
  and st_intersects(sug1.geom, st_buffer(sug2.geom, -0.5))');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('spatial-unit-group-not-overlap', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'critical', 2);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('spatial-unit-group-inside-other-spatial-unit-group', 'sql', 'Spatial unit groups that are not of the top hierarchy must be spatially inside another spatial unit group with hierarchy which is a level up. Tolerance of 0.5 m is applied.::::Пространственные группы, которые не находятся на самой вершине иерархии, должны быть расположены внутри других пространственных групп с более высшим уровнем иерархии. Погрешность может составлять 0.5 м.', 'There is no parameter required.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('spatial-unit-group-inside-other-spatial-unit-group', now(), 'infinity', 'select count(*)= 0 as vl
from cadastre.spatial_unit_group 
where hierarchy_level !=0 and id not in (
  select sug1.id
  from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
  where sug1.hierarchy_level = sug2.hierarchy_level + 1
    and st_within(st_buffer(sug1.geom, -0.5), sug2.geom)
)');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('spatial-unit-group-inside-other-spatial-unit-group', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'critical', 2);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('spatial-unit-group-name-unique', 'sql', 'Spatial unit groups must be unique.::::Пространственные группы должны быть уникальны.', 'There is no parameter required.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('spatial-unit-group-name-unique', now(), 'infinity', 'select count(*)=0 as vl
from (
select count(*)
from cadastre.spatial_unit_group
group by name
having count(*)>1) as tmp');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('spatial-unit-group-name-unique', 'spatial_unit_group', NULL, NULL, NULL, NULL, NULL, 'critical', 1);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
