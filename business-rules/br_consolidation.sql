INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('consolidation-db-structure-the-same', 'sql', 'The structure of the tables in the source and target database are the same.', 'It controls if every source table in consolidation schema is the same as the corresponding target table.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('consolidation-db-structure-the-same', now(), 'infinity', '
with def_of_tables as (select source_table_name, target_table_name, (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') 
        || case when udt_name = ''numeric'' then ''('' || numeric_precision || '','' || numeric_scale  || '')'' else '''' end as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.source_table_name) as ttt) as source_def,
      (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') 
        || case when udt_name = ''numeric'' then ''('' || numeric_precision || '','' || numeric_scale  || '')'' else '''' end as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.target_table_name) as ttt) as target_def      
from consolidation.config config)
select count(*)=0 as vl from def_of_tables where source_def != target_def
');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('consolidation-db-structure-the-same', 'consolidation',  NULL, NULL, NULL, NULL, 'critical', 570);

