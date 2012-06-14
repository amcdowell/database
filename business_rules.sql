delete from system.br_validation;
delete from system.br_definition;
delete from system.br;

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback) 
values('rrr-must-have-parties', 'sql', 'Rrr that must have parties have parties::::RRR per cui sono previste parti, le devono avere');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-must-have-parties', now(), 'infinity', 
'select count(*) = 0 as vl
from administrative.rrr r
where id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');

----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-check-name', 'sql', 'Invalid identifier for title::::Invalido titolo ientificativo',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-check-name', now(), 'infinity', 
'SELECT count(*) > 0 as vl 
FROM administrative.ba_unit 
WHERE id= #{id} 
	AND name_firstpart IS NULL
	OR name_lastpart IS NULL
	OR SUBSTR(name_firstpart, 1) = ''N''
	OR TO_NUMBER(name_lastpart, ''9999'') = 0');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-several-mortgages-with-same-rank', 'sql', 'Title already has a current mortgage with this ranking::::Il titolo ha gia una ipoteca con lo stesso ordine priorita',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-several-mortgages-with-same-rank', now(), 'infinity', 
'SELECT COUNT(*) = 0 as vl 
 FROM   administrative.rrr rrr1,
        administrative.rrr rrr2
 WHERE  rrr1.type_code = ''mortgage''
 AND    rrr1.status_code != ''cancelled''
 AND    rrr1.ba_unit_id = #{id}
 AND    rrr2.ba_unit_id = rrr1.ba_unit_id
 AND    rrr2.type_code = rrr1.type_code
 AND    rrr2.status_code = ''pending''
 AND    rrr2.mortgage_ranking = rrr1.mortgage_ranking
 AND    rrr2.id != rrr1.id');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('baunit-has-primary-right', 'sql', 'Title must have a primary right::::Il titolo deve avere un diritto primario',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('baunit-has-primary-right', now(), 'infinity', 
'SELECT COUNT(*) = 1 as vl FROM administrative.rrr 
WHERE ba_unit_id = #{id}
	AND is_primary
	AND status_code != ''cancelled''');
----------------------------------------------------------------------------------------------------

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('rrr-shares-total-check', 'sql', 'Shares of rights have to total to 1::::Le quote non raggiungono 1',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-shares-total-check', now(), 'infinity', 
'select 
  sum(((select multiply_agg(rrrsh2.denominator) 
    from administrative.rrr_share rrrsh2 where rrrsh1.rrr_id = rrrsh2.rrr_id) /rrrsh1.denominator)*rrrsh1.nominator) = 
  (select multiply_agg(rrrsh2.denominator) 
    from administrative.rrr_share rrrsh2 where rrr_id = #{id}) as vl
from administrative.rrr_share rrrsh1 where rrr_id = #{id}');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit-has-cadastre-object', 'sql', 'Title must have an associated parcel (or cadastre object)::::Il titolo deve avere particelle (oggetti catastali) associati',
 '#{id}(administrative.ba_unit.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit-has-cadastre-object', now(), 'infinity', 
'SELECT count(*)>0 vl
from administrative.ba_unit_contains_spatial_unit ba_s 
WHERE ba_s.ba_unit_id = #{id}');
----------------------------------------------------------------------------------------------------
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('ba_unit-has-compatible-cadastre-object', 'sql', 'Title appears to have incompatible parcel (or cadastre object)::::Il titolo ha particelle (oggetti catastali) incompatibili',
 '#{id}(application.application.id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('ba_unit-has-compatible-cadastre-object', now(), 'infinity', 
'SELECT  co.type_code = ''parcel'' as vl
from administrative.ba_unit ba inner join administrative.ba_unit_contains_spatial_unit ba_s on ba.id= ba_s.ba_unit_id
  inner join cadastre.cadastre_object co on ba_s.spatial_unit_id= co.id
WHERE ba.id = #{id} and ba.type_code= ''basicPropertyUnit''
order by case when co.type_code = ''parcel'' then 0 else 1 end
limit 1');
-------------End application business rules - Neil 18 November 2011-------------------------

----Business rules that are used for the cadastre redefinition--------------------------------------
----------------------------------------------------------------------------------------------------

----End - Business rules that are used for the cadastre redefinition--------------------------------


--------------Check new properties/title owners are not the same as underlying properties/titles owners (Give WARNING if > 0)

--------------Check rrr transferred to new titles/properties (Critical if > 0)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-br24-check-rrr-accounted', 'sql', 'Not all rights and restrictions have been accounted for the new title/property::::non tutti i diritti e le restrizioni sono stati trasferiti al nuovo titolo', '#{id}(baunit_id) is requested');

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

--------------Check there is only one pending transaction per property/title [ba_unit_id] (Critical if > 0)
insert into system.br(id, technical_type_code, feedback, technical_description) 
values('newtitle-brNew-check-pending-transaction', 'sql', 
'property/title should have only one pending transaction::::per ogni titolo/proprieta deve esserci solo una transazione in corso',
 '#{id}(baunit_id) is requested. Check there is only one pending transaction per property/title [ba_unit_id] (Critical if > 0)');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('newtitle-brNew-check-pending-transaction', now(), 'infinity', 
'
select count (*) <= 1 as vl
from administrative.ba_unit_target,
transaction.transaction
where administrative.ba_unit_target.transaction_id = transaction.transaction.id
and transaction.transaction.status_code=''pending''
and administrative.ba_unit_target.ba_unit_id  = #{id}
');



-------------------- Target: ba_unit ---------------------------------------------------------------


insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit-has-cadastre-object', 'medium', 'current', 'ba_unit', 3);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-several-mortgages-with-same-rank', 'critical', 'current', 'ba_unit', 1);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('baunit-has-primary-right', 'critical', 'current', 'ba_unit', 6);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('ba_unit-has-compatible-cadastre-object', 'medium', 'current', 'ba_unit', 4);

--------------------------- End Target: ba_unit ----------------------------------------------------

--------------------------- Target: rrr ------------------------------------------------------------
insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-must-have-parties', 'critical', 'current', 'rrr', 3);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_request_type_code, target_code, order_of_execution) 
values('newtitle-br24-check-rrr-accounted', 'critical', 'current', 'newFreehold', 'rrr', 10);

insert into system.br_validation(br_id, severity_code,  target_request_type_code, target_code, order_of_execution) 
values('newtitle-br24-check-rrr-accounted', 'critical',  'newApartment', 'rrr', 10);

insert into system.br_validation(br_id, severity_code, target_request_type_code, target_code, order_of_execution) 
values('newtitle-br24-check-rrr-accounted', 'critical', 'newOwnership', 'rrr', 10);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-shares-total-check', 'critical', 'current', 'rrr', 16);

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_request_type_code, target_code, order_of_execution) 
values('newtitle-brNew-check-pending-transaction', 'critical', 'current', 'newFreehold', 'rrr', 18);

insert into system.br_validation(br_id, severity_code,  target_request_type_code, target_code, order_of_execution) 
values('newtitle-brNew-check-pending-transaction', 'critical',  'newApartment', 'rrr', 18);

insert into system.br_validation(br_id, severity_code, target_request_type_code, target_code, order_of_execution) 
values('newtitle-brNew-check-pending-transaction', 'critical', 'newOwnership', 'rrr', 18);

--------------------------- End Target: rrr --------------------------------------------------------


update system.br set display_name = id;
