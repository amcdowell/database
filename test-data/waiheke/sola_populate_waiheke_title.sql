-- A script to load Waiheke Island Title data (not owners or RRR) from the testdata table TitlesWaiheke_ which is derived from the Landonline Title map feature

--Modified by Neil 22 July 2011

DROP SCHEMA IF EXISTS test_etl CASCADE;
CREATE SCHEMA test_etl;


CREATE OR REPLACE FUNCTION test_etl.load_title() RETURNS varchar
 AS
$BODY$
DECLARE 
    rec record;
    first_part varchar;
    last_part varchar;
    transaction_id_vl varchar;
BEGIN
    transaction_id_vl = 'adm-transaction';
    delete from transaction.transaction where id = transaction_id_vl;
    insert into transaction.transaction(id, status_code, approval_datetime, change_user) values(transaction_id_vl, 'approved', now(), 'test');

    FOR rec IN EXECUTE 'SELECT trim(to_char(id::real, ''99999999'')) AS id, ''basicPropertyUnit'' AS type, title_no AS "name",''test'' AS change_user 
    FROM testdata.titleswaiheke_'
	LOOP
		IF POSITION('/' in rec.name) > 0 THEN
			first_part = TRIM(SUBSTRING(rec.name FROM 1 FOR (POSITION('/' in rec.name) - 1)));
			last_part = TRIM(SUBSTRING(rec.name FROM (POSITION('/' in rec.name) + 1) FOR CHAR_LENGTH (rec.name) - POSITION('/' in rec.name)));
		ELSE
			first_part = 'NZ';
			last_part = rec.name;
		END IF;
		INSERT INTO administrative.ba_unit (id, transaction_id, type_code, "name", name_firstpart, name_lastpart, status_code, change_user)
			VALUES (rec.id, transaction_id_vl, rec.type, rec.name, first_part, last_part, 'current', rec.change_user);
	END LOOP;
    RETURN 'ok';
END;
$BODY$
  LANGUAGE plpgsql;


-- Prepare environment
-- select fn_triggerall(false);
-- End prepare environment

DELETE FROM administrative.ba_unit_contains_spatial_unit;
DELETE FROM administrative.ba_unit;
        
SELECT test_etl.load_title();

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
                SELECT trim(to_char(id::real, '99999999')) as ba, trim(to_char(parcelid::real, '99999999')) AS su, 'test' AS change_user
                FROM testdata.titleswaiheke_
                WHERE trim(to_char(parcelid::real, '9999999')) IN (SELECT trim(id) FROM cadastre.cadastre_object)
                AND to_char(id::real, '99999999') NOT IN (SELECT ba_unit_id FROM administrative.ba_unit_contains_spatial_unit);
                
UPDATE administrative.ba_unit SET status_code = 'historic' WHERE name IN ('NA892/136', 'NA1679/69', 'NA34B/649', 'NA26B/1249', 'NA5A/1382');

-- Set env back
--select fn_triggerall(true);


DROP SCHEMA IF EXISTS test_etl CASCADE;
-- End
