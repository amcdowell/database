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
insert into system.br(id, technical_type_code, technical_description) 
values('generate-cadastre-object-lastpart', 'sql', 
'It accepts parameters #{geom} = The geometry of the new cadastre object and #{cadastre_object_type} = The type of the cadastre object.');
 
insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-cadastre-object-lastpart', now(), 'infinity', 
'SELECT cadastre.get_new_cadastre_object_identifier_last_part(#{geom}, #{cadastre_object_type}) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, technical_description) 
values('generate-cadastre-object-firstpart', 'sql',
'It accepts parameters #{last_part} = The last part of the identifier and #{cadastre_object_type} = The type of the cadastre object.');
 
insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-cadastre-object-firstpart', now(), 'infinity', 
'SELECT cadastre.get_new_cadastre_object_identifier_first_part(#{last_part}, #{cadastre_object_type}) AS vl');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, technical_description) 
values('generate-spatial-unit-group-name', 'sql',
'It accepts parameters: 
  #{geom_v} = The geometry of the new spatial unit group. It is in EWKB format.
  #{hierarchy_level_v} = The hierarchy level
  #{label_v} = The label
  ');
 
insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-spatial-unit-group-name', now(), 'infinity', 
'SELECT cadastre.generate_spatial_unit_group_name(get_geometry_with_srid(#{geom_v}), #{hierarchy_level_v}, #{label_v}) AS vl');

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

