create or replace function snap_geometry_to_geometry(
  inout geom_to_snap geometry, -- Geometry that has to be snapped. It can be point, linestring or polygon
  inout target_geom geometry, -- Geometry that will be the target to used for snapping
  snap_distance float, -- The snap distance in meters
  change_target_if_needed boolean, -- It gives if it is allowed to change target during snapping
  out snapped boolean, -- An output value showing if the geometry is snapped. If it is a linestring or polygon, even if one point of them is snapped it returns true.
  out target_is_changed boolean -- It shows if the target changed during the snapping process
  ) 
returns record as
$BODY$
DECLARE
  i integer;
  nr_elements integer;
  rec record;
  point_location float;
  rings geometry[];
  
BEGIN
  target_is_changed = false;
  snapped = false;
  if st_geometrytype(geom_to_snap) not in ('ST_Point', 'ST_LineString', 'ST_Polygon') then
    raise exception 'geom_to_snap not supported. Only point, linestring and polygon is supported.';
  end if;
  if st_geometrytype(geom_to_snap) = 'ST_Point' then
    -- If the geometry to snap is POINT
    if st_geometrytype(target_geom) = 'ST_Point' then
      if st_dwithin(geom_to_snap, target_geom, snap_distance) then
        geom_to_snap = target_geom;
        snapped = true;
      end if;
    elseif st_geometrytype(target_geom) = 'ST_LineString' then
      -- Check first if there is any point of linestring where the point can be snapped.
      select t.* into rec from ST_DumpPoints(target_geom) t where st_dwithin(geom_to_snap, t.geom, snap_distance);
      if rec is not null then
        geom_to_snap = rec.geom;
        snapped = true;
        return;
      end if;
      --Check second if the point is within distance from linestring and get an interpolation point in the line.
      if st_dwithin(geom_to_snap, target_geom, snap_distance) then
        point_location = ST_Line_Locate_Point(target_geom, geom_to_snap);
        geom_to_snap = ST_Line_Interpolate_Point(target_geom, point_location);
        if change_target_if_needed then
          target_geom = ST_LineMerge(ST_Union(ST_Line_Substring(target_geom, 0, point_location), ST_Line_Substring(target_geom, point_location, 1)));
          target_is_changed = true;
        end if;
        snapped = true;  
      end if;
    elseif st_geometrytype(target_geom) = 'ST_Polygon' then
      select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(target_geom);
      nr_elements = array_upper(rings,1);
      i = 1;
      while i <= nr_elements loop
        select t.* into rec from snap_geometry_to_geometry(geom_to_snap, rings[i], snap_distance, change_target_if_needed) t;
        if rec.snapped then
          geom_to_snap = rec.geom_to_snap;
          snapped = true;
          if change_target_if_needed then
            rings[i] = rec.target_geom;
            target_geom = ST_MakePolygon(rings[1], rings[2:nr_elements]);
            target_is_changed = rec.target_is_changed;
            return;
          end if;
        end if;
        i = i+1;
      end loop;
    end if;
  elseif st_geometrytype(geom_to_snap) = 'ST_LineString' then
    nr_elements = st_npoints(geom_to_snap);
    i = 1;
    while i <= nr_elements loop
      select t.* into rec
        from snap_geometry_to_geometry(st_pointn(geom_to_snap,i), target_geom, snap_distance, change_target_if_needed) t;
      if rec.snapped then
        if rec.target_is_changed then
          target_geom= rec.target_geom;
          target_is_changed = true;
        end if;
        geom_to_snap = st_setpoint(geom_to_snap, i-1, rec.geom_to_snap);
        snapped = true;
      end if;
      i = i+1;
    end loop;    
  elseif st_geometrytype(geom_to_snap) = 'ST_Polygon' then
    select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(geom_to_snap);
    nr_elements = array_upper(rings,1);
    i = 1;
    while i <= nr_elements loop
      select t.* into rec
        from snap_geometry_to_geometry(rings[i], target_geom, snap_distance, change_target_if_needed) t;
      if rec.snapped then
        rings[i] = rec.geom_to_snap;
        if rec.target_is_changed then
          target_geom = rec.target_geom;
          target_is_changed = true;
        end if;
        snapped = true;
      end if;
      i= i+1;
    end loop;
    if snapped then
      geom_to_snap = ST_MakePolygon(rings[1], rings[2:nr_elements]);
    end if;
  end if;
  return;
END;
$BODY$
  LANGUAGE plpgsql;


select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('POLYGON((0 0, 0 4, 4 4, 8 4,0 0))'), geomfromtext('POLYGON((0 0, 0 8, 8 8, 8 0, 0 0))'), 1, true)

--select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('POLYGON((0.1 0, 0.1 5.7, 4 3, 4 5.7, 5.8 3, 0.1 0))'), geomfromtext('POLYGON((0 0, 0 6, 6 6, 6 0, 0 0),(1 1, 3 5, 4 5, 1 1))'), 1, true)

--select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('LINESTRING(-0.8 0, 2.5 3, 4 3, 0 0)'), geomfromtext('POLYGON((0 0, 0 6, 6 6, 6 0, 0 0),(1 1, 3 5, 4 5, 1 1))'), false, true, 1, true)

--select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('POINT(1 4)'), geomfromtext('POLYGON((0 0, 0 6, 6 6, 6 0, 0 0),(1 1, 3 5, 4 5, 1 1))'), false, true, 1, true)

--select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('POINT(1 4)'), geomfromtext('POLYGON((0 0, 0 6, 6 6, 6 0, 0 0))'), false, true, 1, true)

--select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('POINT(1 2.5)'), geomfromtext('LINESTRING(1 1, 3 5, 4 5)'), false, true, 1, true)

--select st_astext(geom_to_snap), st_astext(target_geom), snapped, target_is_changed FROM snap_geometry_to_geometry(geomfromtext('POINT(1.5 2)'), geomfromtext('POINT(1.5 2)'), false, true, 2)