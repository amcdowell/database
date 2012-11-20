@echo off

set psql_path=%~dp0
set psql_path="%psql_path%psql\psql.exe"
set host=localhost
set dbname=sola

set username=postgres

set createDB=NO

set testDataPath=test-data\waiheke\

set /p host= Host name [%host%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [%username%] :


echo Creating database...
echo Creating database... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=sola.sql > build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=test_data.sql >> build.log 2>&1

echo Loading business rules...
echo Loading SOLA business rules... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=business_rules.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_generators.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_application.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_service.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_ba_unit.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_cadastre_object.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_rrr.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_source.sql >> build.log 2>&1


echo Loading Waiheke Shape Data - this can take up to 7 minutes...
echo Loading Waiheke Shape Data... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_shapefiles.sql >> build.log 2>&1


echo Loading Waiheke Titles...
echo Loading Waiheke Titles... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_title.sql >> build.log 2>&1


echo Loading Roles and Privileges...
echo Loading Roles and Privileges... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%add_user_role_priv.sql >> build.log 2>&1


echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> build.log 2>&1
pause