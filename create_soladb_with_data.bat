@echo off

set psql_path=%~dp0
set psql_path="%psql_path%psql\psql.exe"
set host=localhost
set dbname=sola

set username=postgres
set password=?

set createDB=NO

set populateWaihekeApplications=YES

set populateWaihekeTitles=YES

set populateWaihekeShape=YES

set testDataPath=test-data\waiheke\


set /p host= Host name [%host%] :

set /p dbname= Database name [%dbname%] :

set /p username= Username [postgres] :

set /p password= Password [%password%] :


CHOICE /T 10 /C yn /CS /D n /M "Create DB? [n] "


IF %ERRORLEVEL%==1 (

set createDB=YES
)ELSE (
set createDB=NO
)



CHOICE /T 10 /C yn /CS /D y /M "Populate Waiheke applications [y]?"


IF %ERRORLEVEL%==1 (

set populateWaihekeApplications=YES
)ELSE (
set populateWaihekeApplications=NO
)


CHOICE /T 10 /C yn /CS /D n /M "Populate Waiheke spatial [n]?"


IF %ERRORLEVEL%==1 (

set populateWaihekeShape=YES
)ELSE (
set populateWaihekeShape=NO
)


CHOICE /T 10 /C yn /CS /D y /M "Populate Waiheke titles [y]?"


IF %ERRORLEVEL%==1 (

set populateWaihekeTitles=YES
)ELSE (
set populateWaihekeTitles=NO
)
echo
echo
echo Starting Build at %time%
echo Starting Build at %time% > build.log 2>&1

IF %createDB%==YES (
echo Creating database...
echo Creating database... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% %password% --dbname=%dbname% --command="create database %dbname% with encoding='UTF8' template=postgistemplate connection limit=-1;" >> build.log 2>&1
)

echo Running sola.sql...
echo Running sola.sql... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=sola.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=test_data.sql >> build.log 2>&1

echo Loading business rules...
echo Loading business rules... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=business_rules.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_generators.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_application.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_ba_unit.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_cadastre_object.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_rrr.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_service.sql >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=br_target_source.sql >> build.log 2>&1

IF %populateWaihekeApplications%==YES (
echo Loading Waiheke Applications...
echo Loading Waiheke Applications... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_applications.sql >> build.log 2>&1
)

IF %populateWaihekeShape%==YES (
echo Loading Waiheke Shape Data - this can take up to 7 minutes...
echo Loading Waiheke Shape Data... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_shapefiles.sql >> build.log 2>&1
)

IF %populateWaihekeTitles%==YES (
echo Loading Waiheke Titles...
echo Loading Waiheke Titles... >> build.log 2>&1
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_title.sql >> build.log 2>&1
)

echo Finished at %time% - Check build.log for errors!
echo Finished at %time% >> build.log 2>&1
pause