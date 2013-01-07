-- View: cadastre.systematic_registration_listing

-- DROP VIEW cadastre.systematic_registration_listing;

CREATE OR REPLACE VIEW cadastre.systematic_registration_listing AS 
 SELECT co.id, co.name_firstpart, co.name_lastpart, sa.size, 
 coalesce(ap.land_use_code, 'residential') land_use_code,
 su.ba_unit_id
   FROM cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
        administrative.ba_unit_contains_spatial_unit su, 
        application.application_property ap, application.application aa,
	application.service s
  WHERE sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text 
  AND aa.id::text = ap.application_id::text
  AND s.application_id::text = aa.id::text
  AND s.status_code::text = 'completed'::text; 

  --AND aa.status_code::text = 'completed'::text;

ALTER TABLE cadastre.systematic_registration_listing
  OWNER TO postgres;
GRANT ALL ON TABLE cadastre.systematic_registration_listing TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE cadastre.systematic_registration_listing TO sola_super_role;

