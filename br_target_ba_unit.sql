
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('newtitle-br22-check-different-owners', 'sql', 
'Owners of new titles should be the same as owners of underlying titles::::Gli aventi diritto delle nuove titoli non sono gli stessi delle proprieta/titoli sottostanti',
'#{id}(baunit_id) is requested.
Check that new title owners are the same as underlying titles owners (Give WARNING if > 0)');
--delete from system.br_definition where br_id = 'newtitle-br22-check-different-owners'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('newtitle-br22-check-different-owners', now(), 'infinity', 
'WITH new_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS newOwnerStr FROM party.party po
		INNER JOIN administrative.party_for_rrr pfr1 ON (po.id = pfr1.party_id)
		INNER JOIN administrative.rrr rr1 ON (pfr1.rrr_id = rr1.id)
	WHERE rr1.ba_unit_id = #{id}),
	
  prior_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS priorOwnerStr FROM party.party pn
		INNER JOIN administrative.party_for_rrr pfr2 ON (pn.id = pfr2.party_id)
		INNER JOIN administrative.rrr rr2 ON (pfr2.rrr_id = rr2.id)
		INNER JOIN administrative.required_relationship_baunit rfb ON (rr2.ba_unit_id = rfb.from_ba_unit_id)
	WHERE	rfb.to_ba_unit_id = #{id}
	LIMIT 1	)

SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM prior_property_owner) THEN NULL
		WHEN (SELECT (COUNT(*) != 0) FROM new_property_owner npo WHERE compare_strings((SELECT priorOwnerStr FROM prior_property_owner), npo.newOwnerStr)) THEN TRUE
		ELSE FALSE
	END AS vl
ORDER BY vl
LIMIT 1');

INSERT INTO system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
VALUES('newtitle-br22-check-different-owners', 'warning', 'current', 'ba_unit', 680);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('ba_unit-spatial_unit-area-comparison', 'sql', 'Title area should only differ from parcel area(s) by less than 1%::::Area indicata nel titolo differisce da quella delle particelle per piu del 1%',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit-spatial_unit-area-comparison', now(), 'infinity', 
'SELECT (abs(coalesce(ba_a.size,0.001) - 
 (select coalesce(sum(sv_a.size), 0.001) 
  from cadastre.spatial_value_area sv_a inner join administrative.ba_unit_contains_spatial_unit ba_s 
    on sv_a.spatial_unit_id= ba_s.spatial_unit_id
  where sv_a.type_code = ''officialArea'' and ba_s.ba_unit_id= ba.id))/coalesce(ba_a.size,0.001)) < 0.001 as vl
FROM administrative.ba_unit ba left join administrative.ba_unit_area ba_a 
  on ba.id= ba_a.ba_unit_id and ba_a.type_code = ''officialArea''
WHERE ba.id = #{id}
');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, severity_code, order_of_execution)
VALUES ('ba_unit-spatial_unit-area-comparison', 'ba_unit', 'current', 'medium', 490);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('ba_unit-has-cadastre-object', 'sql', 'Title must have an associated parcel (or cadastre object)::::Il titolo deve avere particelle (oggetti catastali) associati',
 '#{id}(administrative.ba_unit.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('ba_unit-has-cadastre-object', now(), 'infinity', 
'SELECT count(*)>0 vl
from administrative.ba_unit_contains_spatial_unit ba_s 
WHERE ba_s.ba_unit_id = #{id}');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, severity_code, order_of_execution)
VALUES ('ba_unit-has-cadastre-object', 'ba_unit', 'current', 'medium', 500);

----------------------------------------------------------------------------------------------------
INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('ba_unit-has-compatible-cadastre-object', 'sql', 'Title should have compatible parcel (or cadastre object) description (appellation)::::Il titolo ha particelle (oggetti catastali) incompatibili',
 '#{id}(administrative.ba_unit.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('ba_unit-has-compatible-cadastre-object', now(), 'infinity', 
'SELECT  co.type_code = ''parcel'' as vl
from administrative.ba_unit ba 
  inner join administrative.ba_unit_contains_spatial_unit ba_s on ba.id= ba_s.ba_unit_id
  inner join cadastre.cadastre_object co on ba_s.spatial_unit_id= co.id
WHERE ba.id = #{id} and ba.type_code= ''basicPropertyUnit''
order by case when co.type_code = ''parcel'' then 0 
		else 1 
	end
limit 1');


INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, severity_code, order_of_execution)
VALUES ('ba_unit-has-compatible-cadastre-object', 'ba_unit', 'current', 'medium', 540);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('target-ba_unit-check-if-pending', 'sql', 
'Pending registration actions (from other applications) affecting the title to be cancelled should be cancelled::::Non esistono modifiche pendenti per il titolo origine',
 '#{id}(baunit_id) is requested. It checks if there is no pending transaction for target ba_unit (a ba_unit flagged for cancellation).
 It checks if the administrative.ba_unit_target table has a record of this ba_unit which is different
 from the transaction that has flagged the ba_unit for cancellation, that this transaction record is not yet approved,
 that this ba_unit has an associated rrr record which is pending and that there are no other applications with intended or pending changes to this ba_unit.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('target-ba_unit-check-if-pending', now(), 'infinity', 
'WITH	otherCancel AS	(SELECT (SELECT (COUNT(*) = 0)FROM administrative.ba_unit_target ba_t2 
				INNER JOIN transaction.transaction tn ON (ba_t2.transaction_id = tn.id)
				WHERE ba_t2.ba_unit_id = ba_t.ba_unit_id
				AND ba_t2.transaction_id != ba_t.transaction_id
				AND tn.status_code != ''approved'') AS chkOther
			FROM administrative.ba_unit_target ba_t
			WHERE ba_t.ba_unit_id = #{id}), 
	cancelAp AS	(SELECT ap.id FROM administrative.ba_unit_target ba_t 
			INNER JOIN application.application_property pr ON (ba_t.ba_unit_id = pr.ba_unit_id)
			INNER JOIN application.service sv ON (pr.application_id = sv.application_id)
			INNER JOIN application.application ap ON (pr.application_id = ap.id)
			WHERE ba_t.ba_unit_id = #{id}
			AND sv.request_type_code = ''cancelProperty''
			AND sv.status_code != ''cancelled''
			AND ap.status_code NOT IN (''annulled'', ''approved'')),
	otherAps AS	(SELECT (SELECT (count(*) = 0) FROM administrative.ba_unit ba
			INNER JOIN administrative.rrr rr ON (ba.id = rr.ba_unit_id)
			INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
			INNER JOIN application.service sv ON (tn.from_service_id = sv.id)
			INNER JOIN application.application ap ON (sv.application_id = ap.id)
			WHERE ba.id = #{id} 
			AND ap.status_code = ''lodged''
			AND ap.id NOT IN (SELECT id FROM cancelAp)) AS chkNoOtherAps),

	pendingRRR AS	(SELECT (SELECT (count(*) = 0) FROM administrative.rrr rr
				INNER JOIN administrative.ba_unit_target ba_t2 ON (rr.ba_unit_id = ba_t2.ba_unit_id)
				INNER JOIN transaction.transaction t2 ON (ba_t2.transaction_id = t2.id)
				INNER JOIN application.service s2 ON (t2.from_service_id = s2.id) 
				WHERE ba_t2.ba_unit_id = ba_t.ba_unit_id
				AND s2.application_id != s1.application_id
				AND ba_t2.transaction_id != ba_t.transaction_id
				AND rr.status_code = ''pending'') AS chkPend 
			FROM administrative.ba_unit_target ba_t
			INNER JOIN transaction.transaction t1 ON (ba_t.transaction_id = t1.id)
			INNER JOIN application.service s1 ON (t1.from_service_id = s1.id) 
			WHERE ba_t.ba_unit_id = #{id})
SELECT ((SELECT chkPend  FROM pendingRRR) AND (SELECT chkOther FROM otherCancel)  AND (SELECT chkNoOtherAps FROM otherAps)) AS vl 
FROM administrative.ba_unit_target tg
WHERE tg.ba_unit_id  = #{id}');

INSERT INTO system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
VALUES('target-ba_unit-check-if-pending', 'critical', 'current', 'ba_unit', 280);
----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('ba_unit-has-a-valid-primary-right', 'sql', 
'A title must have a valid primary right::::Un titolo deve avere un diritto primario',
 '#{id}(baunit_id) is requested.');
--delete from system.br_definition where br_id = 'ba_unit-has-a-valid-primary-right'
INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('ba_unit-has-a-valid-primary-right', now(), 'infinity', 
'SELECT (COUNT(*) = 1) AS vl FROM administrative.rrr rr1 
	 INNER JOIN administrative.ba_unit ba ON (rr1.ba_unit_id = ba.id)
	 INNER JOIN transaction.transaction tn ON (rr1.transaction_id = tn.id)
	 INNER JOIN application.service sv ON ((tn.from_service_id = sv.id) AND (sv.request_type_code != ''cancelProperty''))
 WHERE ba.id = #{id}
 AND rr1.status_code != ''cancelled''
 AND rr1.is_primary
 AND rr1.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease'')');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, severity_code, order_of_execution)
VALUES ('ba_unit-has-a-valid-primary-right', 'ba_unit', 'current', 'critical', 20);

----------------------------------------------------------------------------------------------------

UPDATE system.br SET display_name = id WHERE display_name !=id;

