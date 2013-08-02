
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
