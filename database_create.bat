set host=exlprcadreg3.ext.fao.org
set psql_path=psql\
set script_folder=
set dbname=sola
set nopass=
set extra_options=--single-transaction --quiet -v ON_ERROR_STOP=1
%psql_path%psql %extra_options% --host=%host% --port=5432 --username=postgres %nopass% --dbname=%dbname% --command="create database %dbname% with encoding='UTF8' template=postgistemplate connection limit=-1;"
%psql_path%psql %extra_options% --host=%host% --port=5432 --username=postgres %nopass% --dbname=%dbname% --file=%script_folder%sola.sql
%psql_path%psql %extra_options% --host=%host% --port=5432 --username=postgres %nopass% --dbname=%dbname% --file=%script_folder%test_data.sql
%psql_path%psql %extra_options% --host=%host% --port=5432 --username=postgres %nopass% --dbname=%dbname% --file=%script_folder%business_rules.sql