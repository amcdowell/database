--TO POPULATE THE SOLA DATABASE WITH LINZ DATA for Waiheke Island (FROM SHAPEFILES)
--INTO LADM RELATED TABLES


--Change SRID dependent constraints to NZTM projection srid = 2193
--ALTER TABLE cadastre.spatial_unit DROP CONSTRAINT enforce_srid_geom;
--ALTER TABLE cadastre.spatial_unit DROP CONSTRAINT enforce_srid_reference_point;
--ALTER TABLE cadastre.spatial_unit ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 2193);
--ALTER TABLE cadastre.spatial_unit ADD CONSTRAINT enforce_srid_reference_point CHECK (st_srid(reference_point) = 2193);
--ALTER TABLE cadastre.parcel DROP CONSTRAINT enforce_srid_geom;
--ALTER TABLE cadastre.parcel ADD CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 2193);

DROP SCHEMA IF EXISTS test_etl CASCADE;
CREATE SCHEMA test_etl;

CREATE OR REPLACE FUNCTION test_etl.load_parcel() RETURNS varchar
 AS
$BODY$
DECLARE 
    rec record;
    first_part varchar;
    last_part varchar;
    transaction_id_vl varchar;
BEGIN
    transaction_id_vl = 'cadastre-transaction';
    delete from transaction.transaction where id = transaction_id_vl;
    insert into transaction.transaction(id, status_code, approval_datetime, change_user) values(transaction_id_vl, 'approved', now(), 'test-id');

    FOR rec IN EXECUTE 'SELECT id, appellatio, affected_s AS last_part, titles, survey_are AS area, 
        ST_GeometryN(the_geom, 1) AS the_geom, parcel_int,  ''current'' AS parcel_status FROM testdata."waiheke-parcels" WHERE (ST_GeometryN(the_geom, 1) IS NOT NULL)'
	LOOP
		IF rec.parcel_int not in ('Hydro', 'Road') THEN
			IF POSITION(rec.last_part in rec.appellatio) > 0 THEN
				first_part = TRIM(SUBSTRING(rec.appellatio FROM 1 FOR CHAR_LENGTH(rec.appellatio) - (CHAR_LENGTH(rec.last_part) + 1)));
			ELSE
				first_part = rec.appellatio;
			END IF;
			IF first_part IS NULL THEN
				first_part = 'QCcheck';
			END IF;
            first_part = SUBSTRING(first_part FROM 1 FOR 20);
			IF rec.last_part IS NULL THEN 
				last_part = rec.id;
            ELSE
                last_part = SUBSTRING(rec.last_part FROM 1 FOR 39) || ' ' || rec.id;
			END IF;
			INSERT INTO cadastre.cadastre_object (id, transaction_id, name_firstpart, name_lastpart, geom_polygon, status_code, change_user)
				VALUES (rec.id, transaction_id_vl, first_part, last_part, rec.the_geom, rec.parcel_status, 'test');  
		END IF;
	END LOOP;
    RETURN 'ok';
END;
$BODY$
  LANGUAGE plpgsql;

-- disable triggers in the database
--select fn_triggerall(false);

--remove any existing Test Data
delete from cadastre.spatial_unit;

--INSERT VALUES FOR WAIHEKE SURVEY CONTROL POINTS


INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
                VALUES ( uuid_generate_v1(), 'Survey Control', 'all', 'point', 'geographicLocator', 'test');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
SELECT uuid_generate_v1(), '2D', current_ma, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Survey Control') As l_id, 'test' AS ch_user 
FROM testdata."waiheke-survey-control";


--INSERT VALUES FOR WAIHEKE PLACE NAMES


INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
                VALUES (uuid_generate_v1(), 'Place Names', 'all', 'point', 'geographicLocator', 'test');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', name, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Place Names') As l_id, 'test' AS ch_user 
	FROM testdata."waiheke-geographic-names";

--INSERT VALUES FOR WAIHEKE ROAD POLYGONS

INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
VALUES (uuid_generate_v1(), 'Roads', 'all', 'point', 'primaryRight', 'test');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, geom, level_id, change_user) 
	SELECT uuid_generate_v1(), '2D', parcel_int, 'onSurface', the_geom, (SELECT id FROM cadastre.level WHERE name='Roads') As l_id, 'test' AS ch_user 
	FROM testdata."waiheke-road-parcels";

--INSERT VALUES FOR THE WAIHEKE PARCELS


INSERT INTO cadastre.level (id, name, register_type_code, structure_code, type_code, change_user)
                VALUES (uuid_generate_v1(), 'Parcels', 'all', 'polygon', 'primaryRight', 'test');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, level_id, change_user) 
	SELECT id, '2D', appellatio, 'onSurface',  
	(SELECT id FROM cadastre.level WHERE name='Parcels') As l_id, 'test' AS ch_user
	FROM testdata."waiheke-parcels" WHERE ST_GeometryN(the_geom, 1) IS NOT NULL;

SELECT test_etl.load_parcel();

UPDATE cadastre.spatial_unit SET level_id = (SELECT id FROM cadastre.level WHERE name = 'Parcels') 
			WHERE (level_id IS NULL);

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
	SELECT 	id, 'officialArea', survey_are, 'test' AS ch_user FROM testdata."waiheke-parcels";

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
	SELECT 	id, 'calculatedArea', st_area(geom_polygon), 'test' AS ch_user FROM cadastre.cadastre_object;


INSERT INTO source.archive (id, name, change_user) VALUES ('archive-id', 'Land Information New Zealand Landonline', 'test'); 

INSERT INTO source.source (id, archive_id, la_nr, submission, maintype, type_code, content, availability_status_code, change_user)
VALUES (uuid_generate_v1(), 'archive-id', 'Landonline', '2011-06-29', 'mapDigital', 'cadastralMap', 'Land Information New Zealand Landonline', 'available', 'test');

-- enable triggers in the database
--select fn_triggerall(true);

--COMMIT;

DROP SCHEMA IF EXISTS test_etl CASCADE;

