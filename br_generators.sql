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

update system.br set display_name = id where display_name !=id;

