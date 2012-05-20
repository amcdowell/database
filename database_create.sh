#!/bin/bash
host="localhost"
#host="exlprcadreg3.ext.fao.org"
script_folder="/home/soladev/NetBeansProjects/SOLA/trunk/database/"
dbname="sola"
nopass=""
psql --host=$host --port=5432 --username=postgres $nopass --dbname=$dbname --file=$script_folder"sola.sql"
psql --host=$host --port=5432 --username=postgres $nopass --dbname=$dbname --file=$script_folder"test_data.sql"
psql --host=$host --port=5432 --username=postgres $nopass --dbname=$dbname --file=$script_folder"business_rules.sql"

