INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-application-nr', 'sql', '', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-application-nr', now(), 'infinity', 'SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''application.application_nr_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-notation-reference-nr', 'sql', '', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-notation-reference-nr', now(), 'infinity', 'SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-rrr-nr', 'sql', '', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-rrr-nr', now(), 'infinity', 'SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-source-nr', 'sql', '', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-source-nr', now(), 'infinity', 'SELECT to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''source.source_la_nr_seq''), ''000000000'')) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-baunit-nr', 'sql', '', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-baunit-nr', now(), 'infinity', 'SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
|| ''/'' || trim(to_char(nextval(''administrative.ba_unit_last_name_part_seq''), ''0000'')) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-cadastre-object-lastpart', 'sql', '', 'It accepts parameters #{geom} = The geometry of the new cadastre object and #{cadastre_object_type} = The type of the cadastre object.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-cadastre-object-lastpart', now(), 'infinity', 'SELECT cadastre.get_new_cadastre_object_identifier_last_part(#{geom}, #{cadastre_object_type}) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-cadastre-object-firstpart', 'sql', '', 'It accepts parameters #{last_part} = The last part of the identifier and #{cadastre_object_type} = The type of the cadastre object.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-cadastre-object-firstpart', now(), 'infinity', 'SELECT cadastre.get_new_cadastre_object_identifier_first_part(#{last_part}, #{cadastre_object_type}) AS vl');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('generate-spatial-unit-group-name', 'sql', '', 'It accepts parameters: 
  #{geom_v} = The geometry of the new spatial unit group. It is in EWKB format.
  #{hierarchy_level_v} = The hierarchy level
  #{label_v} = The label
  ');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('generate-spatial-unit-group-name', now(), 'infinity', 'SELECT cadastre.generate_spatial_unit_group_name(get_geometry_with_srid(#{geom_v}), #{hierarchy_level_v}, #{label_v}) AS vl');

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
