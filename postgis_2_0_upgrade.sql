-- Creates wrapper functions for those PostGIS 1.5 
-- functions used by SOLA that have been deprecated 
-- or removed from PostGIS 2.0
CREATE OR REPLACE FUNCTION ST_MakeBox3D(geometry, geometry)
RETURNS box3d
AS 'SELECT ST_3DMakeBox($1, $2)'
LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION SetSrid(geometry, integer)
RETURNS geometry
AS 'SELECT ST_SetSrid($1, $2)'
LANGUAGE 'sql' IMMUTABLE STRICT;
















