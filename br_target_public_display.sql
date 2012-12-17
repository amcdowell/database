
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('public-display-rule-1', 'sql', 'Test test',
 '#{lastPart}(name_lastpart) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('public-display-rule-1', now(), 'infinity', 
 'select count(1)>0 as vl
from cadastre.cadastre_object t
where name_lastpart = #{lastPart}
');

insert into system.br_validation(br_id, severity_code, target_code, order_of_execution) 
values('public-display-rule-1', 'critical', 'public_display', 1);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

