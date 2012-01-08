DROP SCHEMA IF EXISTS extra_spatial_functions CASCADE;
CREATE SCHEMA extra_spatial_functions;

DROP FUNCTION IF EXISTS extra_spatial_functions.split_polygon(character varying, character varying, character varying, character varying, character varying);

-- Usage 
-- select * from extra_spatial_functions.split_polygon(
--    'MULTILINESTRING((x1 y1, x2 y2))', 
--    'public.spatial_unit', 'id', 'geom_polygon', 'level_id = ''e48395b6-676b-11e0-b4fd-005056ae6ab3''') 
-- as result(id varchar, geom geometry, status varchar);
--------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION extra_spatial_functions.split_polygon(
    splittingGeomAsText character varying, -- This is a valid multilinestring that will be used for splitting
    tableName character varying, -- The target table
    rowIdName character varying, -- The column that will be used to identify the target geometry
    geometryColumnName character varying, -- the target geometry column
    extraCondition character varying -- extra condition that the record in the table must fullfil
    )
  RETURNS setof record AS
$BODY$
DECLARE 
    resultGeometries varchar;
    splittingGeom geometry;
    splittingGeomAsTextWithSRID varchar;
    targetGeometry geometry;
    tmpTargetGeom geometry;
    rec     record;
    targetrowid varchar;
    sridVl varchar;
    sqlSt varchar;
    geometryIsSplit boolean;
    recToReturn record;
BEGIN
    resultGeometries :='';
    -- Find the srid of the target column in target table
    select srid into sridVl 
        from geometry_columns where f_table_schema || '.' || f_table_name =tableName and f_geometry_column=geometryColumnName;
    -- Create the splitting geometry from its WKT combined with the srid
    splittingGeom:= st_geomfromtext(splittingGeomAsText,sridVl::int);
    --raise exception '%',sridVl;
    -- Make a WKT presentation of the splitting geometry combined with the srid
    splittingGeomAsTextWithSRID:= 'ST_geomfromtext(' || quote_literal(splittingGeomAsText) || ',' || sridVl || ')';
    -- Build the sql statement to search for any geometry that intersects with the linestring
    sqlSt:= '';
    if (extraCondition != '') then
        sqlSt := extraCondition || ' and ';
    end if;    
    sqlSt:= 'select ' || rowidName || ' as row_id, ' || geometryColumnName || ' as the_geom from ' || tableName 
        || ' where ' || sqlSt || geometryColumnName || ' is not null and (SetSRID(ST_box3d(' || geometryColumnName || '),' || sridVl 
        || ') && SetSRID(ST_box3d(' || splittingGeomAsTextWithSRID  || '), ' || sridVl || ')) '
        || ' AND ST_Intersects(' || geometryColumnName || ', ' || splittingGeomAsTextWithSRID  
        || ') and st_isvalid(' || geometryColumnName || ')';
    --raise exception '%',sqlSt;
    geometryIsSplit = false;
    -- Loop through geometries that fullfil the condition
    FOR rec in EXECUTE sqlSt loop
        targetrowid := rec.row_id::text;
        targetGeometry := rec.the_geom;
        if (GeometryType(targetGeometry) not in ('POLYGON')) then
            RAISE EXCEPTION 'geometrytype_not_supported_for_split';    
        end if;
        resultGeometries := '';
        tmpTargetGeom := st_polygonize(st_union(st_boundary(targetGeometry), splittingGeom));
        if (abs(st_area(targetGeometry) - st_area(tmpTargetGeom)) <0.001) and (select count(*) from dump ((select tmpTargetGeom AS mpoly)))>1 then
          FOR rec in SELECT geom as the_geom FROM dump ((select tmpTargetGeom AS mpoly)) loop
            select into recToReturn ''::varchar, rec.the_geom::geometry, 'new'::varchar;
            return next recToReturn;
          end loop;
          select into recToReturn targetrowid::varchar, null::geometry, 'source'::varchar;
          return next recToReturn;
          geometryIsSplit = true;
          exit;
        end if;
    end loop;
    if (not geometryIsSplit) then
        RAISE EXCEPTION 'no_geometry_found_to_be_split';
    end if;
    return;
END;
$BODY$
  LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS extra_spatial_functions.merge_polygon(character varying, character varying, character varying);
-- USAGE 
--select extra_spatial_functions.merge_polygon('public.spatial_unit', 'geom_polygon', 'id in (''wewqeqwewqe'',''qwewqewewqewqewqeqwewq'')')
--------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION extra_spatial_functions.merge_polygon(
  tableName character varying, --target table name
  geometryColumnName character varying, -- target column namme
  conditionToTargets character varying -- the condition that the rows where the geometries to be merged are, must fullfill
  )
  RETURNS geometry AS
$BODY$
DECLARE 
    resultGeometry geometry;
    targetGeometryType varchar;
    rec record;
    sqlSt varchar;
BEGIN
    select type into targetGeometryType from geometry_columns 
        where f_table_name=tableName and f_geometry_column=geometryColumnName;

    if (targetGeometryType is null) then
        RAISE EXCEPTION 'geometrycolumn_notfound_in_geometry_columns_table';
    end if;

    if (targetGeometryType not in ('POLYGON')) then
        RAISE EXCEPTION 'geometrytype_not_supported_for_merge';
    end if;
    
    sqlSt:= 'select st_union(' || geometryColumnName || ') as the_geom from ' 
        || tableName || ' where ' || conditionToTargets;
    
    FOR rec in EXECUTE sqlSt loop
        resultGeometry := rec.the_geom; 
        exit;
    end loop;

    if (geometryType(resultGeometry) not in ('POLYGON')) then
        RAISE EXCEPTION 'geometries_cannot_be_merged_in_one_polygon';
    end if;

    return resultGeometry;
END;
$BODY$
  LANGUAGE plpgsql;
