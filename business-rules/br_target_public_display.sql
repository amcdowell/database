SET client_encoding = 'UTF8';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('public-display-check-baunit-has-co', 'sql', 'All property must have an associated cadastre object.::::Все объекты недвижимости должны иметь соответствующие кадастровые объекты.', '#{lastPart}(name_lastpart) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('public-display-check-baunit-has-co', now(), 'infinity', 'SELECT count(bu.id) = 0 as vl
   FROM  application.application_property ap, 
   application.application aa, 
   application.service s,
   administrative.ba_unit bu
  WHERE 
   ap.ba_unit_id::text = bu.id::text 
   AND aa.id::text = ap.application_id::text 
   AND s.application_id::text = aa.id::text
   AND aa.id::text in (
   SELECT 
    aa.id id
   FROM 
   cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, 
   application.application aa, application.service s
  WHERE sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = ''officialArea''::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND ap.ba_unit_id::text = su.ba_unit_id::text AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text
   AND s.request_type_code::text = ''systematicRegn''::text AND s.status_code::text = ''completed''::text 
   AND co.name_lastpart = #{lastPart}
    )
   AND s.request_type_code::text = ''systematicRegn''::text 
   AND s.status_code::text = ''completed''::text 
   AND  bu.id not in (
   select su.ba_unit_id
   from  
   administrative.ba_unit_contains_spatial_unit su
   )');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('public-display-check-baunit-has-co', 'public_display', NULL, NULL, NULL, NULL, NULL, 'warning', 2);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('public-display-check-complete-status', 'sql', 'At least 90% of the parcels must have an associated Systematic Application with complete status.::::По крайней мере 90% участков должны иметь соответствующие заявления на системную регистрацию с завершенным статусом.', '#{lastPart}(name_lastpart) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('public-display-check-complete-status', now(), 'infinity', 'select
(select count(*)
from cadastre.cadastre_object co 
  INNER JOIN administrative.ba_unit_contains_spatial_unit ba_su on (co.id= ba_su.spatial_unit_id)
  INNER JOIN administrative.ba_unit bu on (bu.id= ba_su.ba_unit_id)
  INNER JOIN application.application_property ap on (bu.id= ap.ba_unit_id)
  INNER JOIN application.application a on (a.id= ap.application_id)
  INNER JOIN application.service s on (a.id= s.application_id and s.request_type_code=''systematicRegn'')
  where co.name_lastpart = #{lastPart})
/
(case when (select count(*)
from cadastre.cadastre_object co 
  INNER JOIN administrative.ba_unit_contains_spatial_unit ba_su on (co.id= ba_su.spatial_unit_id)
  INNER JOIN administrative.ba_unit bu on (bu.id= ba_su.ba_unit_id)
  INNER JOIN application.application_property ap on (bu.id= ap.ba_unit_id)
  INNER JOIN application.application a on (a.id= ap.application_id)
  INNER JOIN application.service s on (a.id= s.application_id and s.request_type_code=''systematicRegn'' and s.status_code=''completed'')
  where co.name_lastpart = #{lastPart}) = 0 then 1
  else  (select count(*)
from cadastre.cadastre_object co 
  INNER JOIN administrative.ba_unit_contains_spatial_unit ba_su on (co.id= ba_su.spatial_unit_id)
  INNER JOIN administrative.ba_unit bu on (bu.id= ba_su.ba_unit_id)
  INNER JOIN application.application_property ap on (bu.id= ap.ba_unit_id)
  INNER JOIN application.application a on (a.id= ap.application_id)
  INNER JOIN application.service s on (a.id= s.application_id and s.request_type_code=''systematicRegn'' and s.status_code=''completed'')
  where co.name_lastpart = #{lastPart})
 end 
  ) * 100
> 90 as vl
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('public-display-check-complete-status', 'public_display', NULL, NULL, NULL, NULL, NULL, 'warning', 1);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
