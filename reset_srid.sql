-- This script resets the srid constraints in the whole database.
-- First it empties the table geometry_columns.
-- Then for each found constraint of name starting with enforce_srid, will drop it
-- and then re create it by using the srids found in system.crs.
do
$$
declare
  rec record;
  check_srid varchar;
begin
  delete from geometry_columns;
  check_srid = (select '(' || string_agg(srid::varchar,',') || ')' from system.crs);
  for rec in 
    select 
      'alter table "' || table_schema || '"."' || table_name || '" drop constraint ' || constraint_name || ';' as drop_ddl,
      'alter table "' || table_schema || '"."' || table_name || '" add constraint ' || constraint_name 
        || ' check (st_srid(' || substring(constraint_name from 14) || ') in ' || check_srid || ');' as create_ddl      
    from information_schema.table_constraints where constraint_name like 'enforce_srid%' loop
    execute rec.drop_ddl;
    execute rec.create_ddl;
  end loop;
end;
$$
