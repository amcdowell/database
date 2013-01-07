-- View: cadastre.sys_reg_owner_name
-- DROP VIEW cadastre.sys_reg_owner_name;
 
CREATE OR REPLACE VIEW cadastre.sys_reg_owner_name AS 
 SELECT pp.name||' '||coalesce(pp.last_name,'') as value,
       co.id, co.name_firstpart, co.name_lastpart, 
 coalesce(ap.land_use_code, 'residential') land_use_code,
 su.ba_unit_id,
 CASE when coalesce(ap.land_use_code, 'residential') = 'residential' THEN sa.size 
        else 0
   END AS    residential,
   CASE when coalesce(ap.land_use_code, 'residential') = 'agricultural' THEN sa.size 
        else 0
   END AS    agricultural,
   CASE when coalesce(ap.land_use_code, 'residential') = 'commercial' THEN sa.size 
        else 0
   END AS    commercial,
   CASE when coalesce(ap.land_use_code, 'residential') = 'industrial' THEN sa.size 
        else 0
   END AS    industrial
   
   FROM cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
        administrative.ba_unit_contains_spatial_unit su, 
        application.application_property ap, application.application aa,
        application.service s,
        party.party pp,
	administrative.party_for_rrr  pr,
	administrative.rrr rrr
  WHERE sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text 
  AND aa.id::text = ap.application_id::text
  AND s.application_id = aa.id
  AND s.status_code::text = 'completed'::text
  AND pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and   rrr.ba_unit_id= su.ba_unit_id
		and   (rrr.type_code='ownership'
		       or rrr.type_code='apartment'
		       or rrr.type_code='commonOwnership'
		       ) 
union
SELECT distinct 'No Claimant ' as value,
co.id, co.name_firstpart, co.name_lastpart, 
  coalesce(ap.land_use_code, 'residential') land_use_code,
   su.ba_unit_id,
   CASE when coalesce(ap.land_use_code, 'residential') = 'residential' THEN sa.size 
        else 0
   END AS    residential,
   CASE when coalesce(ap.land_use_code, 'residential') = 'agricultural' THEN sa.size 
        else 0
   END AS    agricultural,
   CASE when coalesce(ap.land_use_code, 'residential') = 'commercial' THEN sa.size 
        else 0
   END AS    commercial,
   CASE when coalesce(ap.land_use_code, 'residential') = 'industrial' THEN sa.size 
        else 0
   END AS    industrial
   FROM cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
        administrative.ba_unit_contains_spatial_unit su, 
        application.application_property ap, application.application aa,
        party.party pp,
	administrative.party_for_rrr  pr,
	administrative.rrr rrr,
	application.service s
  WHERE sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text 
  AND aa.id::text = ap.application_id::text
  AND su.ba_unit_id not in ( select rrr.ba_unit_id
                             from administrative.rrr rrr,
                                  party.party pp,
                                  administrative.party_for_rrr pr
                             where (rrr.type_code='ownership'
		                    or rrr.type_code='apartment'
		                    or rrr.type_code='commonOwnership'
		                    or rrr.type_code='stateOwnership'
		                    )
                             AND pp.id=pr.party_id
		             and pr.rrr_id=rrr.id 
		             )
  AND s.application_id = aa.id
  AND s.status_code::text = 'completed'::text
order by value;
            
  --AND aa.status_code::text = 'completed'::text;


ALTER TABLE cadastre.sys_reg_owner_name
  OWNER TO postgres;
GRANT ALL ON TABLE cadastre.sys_reg_owner_name TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE cadastre.sys_reg_owner_name TO sola_super_role;

