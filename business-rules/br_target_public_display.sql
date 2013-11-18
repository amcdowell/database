
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('public-display-check-complete-status', 'sql', 'At least 90% of the parcels must have an associated Systematic Application with complete status.::::Almeno il 90% delle particelle devono avere una Pratica Sistematica con stato completato',
 '#{lastPart}(name_lastpart) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('public-display-check-complete-status', now(), 'infinity', 
 'select
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

insert into system.br_validation(br_id, severity_code, target_code, order_of_execution) 
values('public-display-check-complete-status', 'warning', 'public_display', 1);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('public-display-check-baunit-has-co', 'sql', 'All property must have an associated cadastre object.::::Tutte le proprieta devono avere un oggetto catastale associato',
 '#{lastPart}(name_lastpart) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('public-display-check-baunit-has-co', now(), 'infinity', 
 'SELECT count(bu.id) = 0 as vl
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

insert into system.br_validation(br_id, severity_code, target_code, order_of_execution) 
values('public-display-check-baunit-has-co', 'warning', 'public_display', 2);

----------------------------------------------------------------------------------------------------
update system.br set display_name = id where display_name !=id;

