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


IF %createDB%==YES (
%psql_path% --host=%host% --port=5432 --username=%username% %password% --dbname=%dbname% --command="create database %dbname% with encoding='UTF8' template=postgistemplate connection limit=-1;"
)

%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=sola.sql

%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=test_data.sql
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=business_rules.sql



IF %populateWaihekeApplications%==YES (
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_applications.sql
)

IF %populateWaihekeShape%==YES (
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_shapefiles.sql
)

IF %populateWaihekeTitles%==YES (
%psql_path% --host=%host% --port=5432 --username=%username% --dbname=%dbname% --file=%testDataPath%sola_populate_waiheke_title.sql
)

echo Finished
pause