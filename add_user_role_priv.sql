create or replace function db_user_role_and_privs(user_name varchar, user_password varchar, user_role varchar) returns void
as
$body$
declare
  rec record;
begin
 --Create role
  if (select count(*) from pg_roles where rolname = user_role)=0 then
    execute 'create role ' || user_role;
  end if;
  -- Create user
  if (select count(*) from pg_roles where rolname = user_role)=0 then
    execute 'create user ' || user_name || ' with password ''' || user_password || ''' in role ' || user_role;
  end if;

  for rec in 
    select distinct table_schema 
    from information_schema.tables 
    where table_schema not in ('pg_catalog', 'information_schema') loop
    execute 'GRANT USAGE ON schema "'  || rec.table_schema || '" TO ' || user_role;
  end loop;
  -- For each table found in db, assign priv.
  for rec in 
    select table_schema, table_name 
    from information_schema.tables 
    where table_schema not in ('pg_catalog', 'information_schema') loop

    if rec.table_name like '%_historic' then
      execute 'GRANT SELECT, INSERT ON "'  || rec.table_schema || '"."' ||  rec.table_name || '" TO ' || user_role;
    else
      execute 'GRANT SELECT, INSERT, UPDATE, DELETE ON "'  || rec.table_schema || '"."' ||  rec.table_name || '" TO ' || user_role;
    end if;
  end loop;
  for rec in select sequence_schema, sequence_name from information_schema.sequences loop
    execute 'GRANT USAGE ON "'  || rec.sequence_schema || '"."' || rec.sequence_name || '" TO ' || user_role;
  end loop;
end;
$body$
language plpgsql;

select db_user_role_and_privs('sola_super_user', 'sola', 'sola_super_role');