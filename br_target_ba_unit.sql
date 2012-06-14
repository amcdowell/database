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

