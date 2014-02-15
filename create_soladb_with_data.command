#!/bin/bash
host="localhost"
script_folder="/Users/neilpullar/Documents/sola/solasource/sola/database/"
testDataPath="/Users/neilpullar/Documents/sola/solasource/sola/database/test-data/waiheke/"
dbname="sola_nz"
username="postgres"
port=5432
#-----------------------
#createDB=NO

#set /p host= Host name [%host%] :

#set /p port= Port [%port%] :

#set /p dbname= Database name [%dbname%] :

#set /p username= Username [%username%] :


#echo Creating database…
#---------------------------

psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"sola.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"reference_tables.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"post_scripts.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"sola_extension.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"test_data.sql"

echo Loading business rules…

psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/business_rules.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_generators.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_application.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_service.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_ba_unit.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_cadastre_object.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_rrr.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_source.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_bulkOperationSpatial.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_spatial_unit_group.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_public_display.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_target_consolidation.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$script_folder"business-rules/br_consolidation.sql"

echo Loading Waiheke Shapefile Data - this can take up to 7 minutes…

psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$testDataPath"sola_populate_waiheke_shapefiles.sql"

echo Loading Waiheke Titles…
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$testDataPath"sola_populate_waiheke_title.sql"

echo Loading Roles and Privileges…
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$testDataPath"add_user_role_priv.sql"

echo Loading Applications
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$testDataPath"sola_populate_waiheke_applications.sql"

#Install Keka and manually unzip the 7z file before running this script - see http://www.kekaosx.com/en/index.php
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$testDataPath"sola_populate_waiheke_rrr.sql"
psql --host=$host --port=$port --username=$username --dbname=$dbname --file=$testDataPath"data-fixes.sql"

echo Finished at %time% - Check build.log for errors!