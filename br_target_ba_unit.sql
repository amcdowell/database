insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-br22-check-different-owners', 'sql', 
'Owners of new properties/titles are not the same as owners of underlying properties/titles::::Gli aventi diritto delle nuove proprieta/titoli non sono gli stessi delle proprieta/titoli sottostanti',
'#{id}(baunit_id) is requested.
Check new properties/title owners are not the same as underlying properties/titles owners (Give WARNING if > 0)');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-br22-check-different-owners', now(), 'infinity', 
'with prior_property_owner as (
	select po.name
	from   
	party.party po,
	administrative.party_for_rrr pfro,
	administrative.rrr ro
	where 
	po.id = pfro.party_id
	and
	pfro.rrr_id = ro.id
	and
	ro.ba_unit_id = #{id})
select  count (pn.name)= 0 as vl
from   
	party.party pn,
	administrative.party_for_rrr pfro,
	administrative.rrr ro
	where 
	pn.id = pfro.party_id
	and
	pfro.rrr_id = ro.id
	and
	ro.ba_unit_id in
	(select administrative.required_relationship_baunit.to_ba_unit_id
	 from   administrative.required_relationship_baunit
	 where  administrative.required_relationship_baunit.from_ba_unit_id = #{id})
   and
        pn.name not in (select name from prior_property_owner)
    ');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('newtitle-br22-check-different-owners', 'warning', 'current', 'ba_unit', 1);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit-spatial_unit-area-comparison', 'sql', 'Title area differs from parcel area(s) by more than 1%::::Area indicata nel titolo differisce da quella delle particelle per piu del 1%',
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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit-spatial_unit-area-comparison', 'medium', 'current', 'ba_unit', 2);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-primary-right', 'sql', 'Title must have a primary right::::Il titolo deve avere un diritto primario',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-primary-right', now(), 'infinity', 
'SELECT COUNT(*) > 0 as vl FROM administrative.rrr 
WHERE ba_unit_id = #{id}
	AND is_primary
	AND status_code in (''pending'', ''current'')');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-primary-right', 'critical', 'current', 'ba_unit', 6);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit-has-cadastre-object', 'sql', 'Title must have an associated parcel (or cadastre object)::::Il titolo deve avere particelle (oggetti catastali) associati',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit-has-cadastre-object', now(), 'infinity', 
'SELECT count(*)>0 vl
from administrative.ba_unit_contains_spatial_unit ba_s 
WHERE ba_s.ba_unit_id = #{id}');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit-has-cadastre-object', 'medium', 'current', 'ba_unit', 3);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit-has-compatible-cadastre-object', 'sql', 'Title appears to have incompatible parcel (or cadastre object)::::Il titolo ha particelle (oggetti catastali) incompatibili',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit-has-compatible-cadastre-object', now(), 'infinity', 
'SELECT  co.type_code = ''parcel'' as vl
from administrative.ba_unit ba inner join administrative.ba_unit_contains_spatial_unit ba_s on ba.id= ba_s.ba_unit_id
  inner join cadastre.cadastre_object co on ba_s.spatial_unit_id= co.id
WHERE ba.id = #{id} and ba.type_code= ''basicPropertyUnit''
order by case when co.type_code = ''parcel'' then 0 else 1 end
limit 1');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit-has-compatible-cadastre-object', 'medium', 'current', 'ba_unit', 4);

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-br24-check-rrr-accounted', 'sql', 
'Not all rights and restrictions have been accounted for the new title/property::::non tutti i diritti e le restrizioni sono stati trasferiti al nuovo titolo', 
'#{id}(baunit_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-br24-check-rrr-accounted', now(), 'infinity', 
'
with prior_property_rrr as (
select ro.id
from administrative.rrr ro
where ro.ba_unit_id = #{id}
AND ro.status_code != ''cancelled'')
select (
 (select count (id) from prior_property_rrr)
-
  (select count (rn.id) 
    from administrative.rrr rn
    where rn.ba_unit_id in
	(select administrative.required_relationship_baunit.to_ba_unit_id
	 from   administrative.required_relationship_baunit
	 where  administrative.required_relationship_baunit.from_ba_unit_id = #{id})
     and
        rn.id in (select id from prior_property_rrr)
  )      

) = 0 as vl
');

--insert into system.br_validation(br_id, severity_code, target_reg_moment, target_request_type_code, target_code, order_of_execution) 
--values('newtitle-br24-check-rrr-accounted', 'critical', 'current', 'newFreehold', 'rrr', 10);

--insert into system.br_validation(br_id, severity_code,  target_request_type_code, target_code, order_of_execution) 
--values('newtitle-br24-check-rrr-accounted', 'critical',  'newApartment', 'rrr', 10);

--insert into system.br_validation(br_id, severity_code, target_request_type_code, target_code, order_of_execution) 
--values('newtitle-br24-check-rrr-accounted', 'critical', 'newOwnership', 'rrr', 10);

----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('target-ba_unit-check-if-pending', 'sql', 
'There are no pending edits for target title::::ITALIANO',
 '#{id}(baunit_id) is requested. It checks if there is no pending transaction for target ba_unit.
 It checks if the administrative.ba_unit_target has a record of this ba_unit which is different
 from the transaction that is targeting ba_unit and that record is of a transaction not approved yet
 and if the ba_unit has an rrr which is pending.');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('target-ba_unit-check-if-pending', now(), 'infinity', 
'
select (select count(*) =0
  from administrative.ba_unit_target ba_t2 inner join transaction.transaction t 
    on ba_t2.transaction_id= t.id and t.status_code != ''approved''
  where ba_t2.ba_unit_id= ba_t.ba_unit_id and ba_t2.transaction_id!= ba_t.transaction_id)
  and (select count(*)= 0 from administrative.rrr 
    where ba_t.ba_unit_id= rrr.ba_unit_id and rrr.status_code = ''pending'') as vl
from administrative.ba_unit_target ba_t
where ba_t.ba_unit_id = #{id}
order by 1
limit 1');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('target-ba_unit-check-if-pending', 'critical', 'current', 'ba_unit', 18);
----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

