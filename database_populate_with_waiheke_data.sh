#!/bin/bash
host="localhost"
#host="exlprcadreg3.ext.fao.org"
script_folder="/home/soladev/NetBeansProjects/SOLA/trunk/database/test-data/waiheke/"
dbname="sola"
nopass=""
psql --host=$host --port=5432 --username=postgres $nopass --dbname=$dbname --file=$script_folder"sola_populate_waiheke_shapefiles.sql"
psql --host=$host --port=5432 --username=postgres $nopass --dbname=$dbname --file=$script_folder"sola_populate_waiheke_applications.sql"
psql --host=$host --port=5432 --username=postgres $nopass --dbname=$dbname --file=$script_folder"sola_populate_waiheke_title.sql"
