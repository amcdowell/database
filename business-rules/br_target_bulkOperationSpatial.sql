INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('bulk-spatial-name-unique', 'sql', 'Cadastre objects with must have unique names.::::Кадастровые объекты должны иметь уникальные коды.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('bulk-spatial-name-unique', now(), 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary 
  where transaction_id = t.id
   and (name_firstpart, name_lastpart) in (select name_firstpart, name_lastpart 
    from cadastre.cadastre_object)) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('bulk-spatial-name-unique', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('bulk-spatial-geom-overlaps-with-loading-geom', 'sql', 'New cadastre objects must not overlap with other new cadastre objects. ::::Новые кадастровые объекты не должны пересекаться с другими новыми объектами.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('bulk-spatial-geom-overlaps-with-loading-geom', now(), 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary tmp, bulk_operation.spatial_unit_temporary tmp2
  where tmp.transaction_id = tmp2.transaction_id and tmp.id != tmp2.id and tmp.geom && tmp2.geom 
    and st_intersects(tmp.geom, st_buffer(tmp2.geom, - system.get_setting(''map-tolerance'')::double precision))) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('bulk-spatial-geom-overlaps-with-loading-geom', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('bulk-spatial-geom-overlaps-with-existing', 'sql', 'Cadastre objects must not overlap with existing cadastre objects. ::::Кадастровые объекты не должны пересекаться с существующими кадастровыми объектами.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('bulk-spatial-geom-overlaps-with-existing', now(), 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary tmp, cadastre.cadastre_object co
  where tmp.transaction_id = t.id and tmp.geom && co.geom_polygon 
    and st_intersects(co.geom_polygon, st_buffer(tmp.geom, - system.get_setting(''map-tolerance'')::double precision))) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('bulk-spatial-geom-overlaps-with-existing', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('bulk-spatial-geom-not-valid', 'sql', 'Cadastre objects must have a valid closed polygon. ::::Кадастровые объекты должны иметь корректный завершенный полигон.', '#{id}(transaction_id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('bulk-spatial-geom-not-valid', now(), 'infinity', 'select (select count(1)=0
  from bulk_operation.spatial_unit_temporary tmp
  where tmp.transaction_id = t.id 
    and not (st_isvalid(tmp.geom) 
    and st_geometrytype(tmp.geom) = ''ST_Polygon'')) as vl
from transaction.transaction t
where id = #{id}
  and id in (select transaction_id 
    from bulk_operation.spatial_unit_temporary 
    where type_code = ''cadastre_object'')
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('bulk-spatial-geom-not-valid', 'bulkOperationSpatial', NULL, NULL, 'pending', NULL, NULL, 'warning', 440);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
