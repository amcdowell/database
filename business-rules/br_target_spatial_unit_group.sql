
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('spatial-unit-group-name-unique', 'sql', 'Spatial unit groups must be unique.',
 'There is no parameter required.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('spatial-unit-group-name-unique', now(), 'infinity', 
 'select count(*)=0 as vl
from (
select count(*)
from cadastre.spatial_unit_group
group by name
having count(*)>1) as tmp');

insert into system.br_validation(br_id, severity_code, target_code, order_of_execution) 
values('spatial-unit-group-name-unique', 'critical', 'spatial_unit_group', 1);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('spatial-unit-group-not-overlap', 'sql', 'Spatial unit groups of the same hierarchy must not overlap with each other. Tolerance of 0.5 m is applied.',
 'There is no parameter required.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('spatial-unit-group-not-overlap', now(), 'infinity', 
 'select count(*) =0 as vl
from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
where sug1.hierarchy_level = sug2.hierarchy_level and sug1.id > sug2.id
  and st_intersects(sug1.geom, st_buffer(sug2.geom, -0.5))');

insert into system.br_validation(br_id, severity_code, target_code, order_of_execution) 
values('spatial-unit-group-not-overlap', 'critical', 'spatial_unit_group', 2);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('spatial-unit-group-inside-other-spatial-unit-group', 'sql', 
'Spatial unit groups that are not of the top hierarchy must be spatially inside another spatial unit group with hierarchy which is a level up. Tolerance of 0.5 m is applied.',
 'There is no parameter required.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('spatial-unit-group-inside-other-spatial-unit-group', now(), 'infinity', 
 'select count(*)= 0 as vl
from cadastre.spatial_unit_group 
where hierarchy_level !=0 and id not in (
  select sug1.id
  from cadastre.spatial_unit_group sug1, cadastre.spatial_unit_group sug2
  where sug1.hierarchy_level = sug2.hierarchy_level + 1
    and st_within(st_buffer(sug1.geom, -0.5), sug2.geom)
)');

insert into system.br_validation(br_id, severity_code, target_code, order_of_execution) 
values('spatial-unit-group-inside-other-spatial-unit-group', 'critical', 'spatial_unit_group', 2);
