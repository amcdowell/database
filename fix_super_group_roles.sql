insert into system.approle (code, display_value, description, status)
values ('ApplnEdit', 'Application Edit', 'Allows editing of Applications', 'c');

insert into system.approle_appgroup (approle_code, appgroup_id)
SELECT r.code, 'super-group-id' FROM system.approle r 
where r.code not in (select approle_code from system.approle_appgroup g where appgroup_id = 'super-group-id')
