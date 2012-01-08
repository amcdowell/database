delete from system.config_map_layer;
INSERT INTO system.config_map_layer (name, type_code, pojo_query_name, pojo_query_name_for_select, 
    style, pojo_structure, active, used_for, item_order)
VALUES  ('Parcels', 'pojo', 'SpatialResult.getParcels', 'dynamic.informationtool.get_parcel', 
            'parcel.sld', 'theGeom:Polygon:srid=2193,label:""', true, 'parcel', 1),
        ('Pending parcels', 'pojo', 'SpatialResult.getParcelsPending', 'dynamic.informationtool.get_parcel_pending', 
            'pending_parcels.sld', 'theGeom:Polygon:srid=2193,label:""', true, 'parcelPending', 2),
        ('Roads', 'pojo', 'SpatialResult.getRoads', 'dynamic.informationtool.get_road', 
            'road.sld', 'theGeom:MultiPolygon:srid=2193,label:""', true, 'background', 3),
        ('Survey controls', 'pojo', 'SpatialResult.getSurveyControls', 'dynamic.informationtool.get_survey_control', 
            'survey_control.sld', 'theGeom:Point:srid=2193,label:""', true, 'background', 4),
        ('Place names', 'pojo', 'SpatialResult.getPlaceNames', 'dynamic.informationtool.get_place_name', 
            'place_name.sld', 'theGeom:Point:srid=2193,label:""', true, 'background', 5),
        ('Applications', 'pojo', 'SpatialResult.getApplications', 'dynamic.informationtool.get_application', 
            'application.sld', 'theGeom:MultiPoint:srid=2193,label:""', true, 'applicationLocation', 6);
