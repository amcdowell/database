insert into system.br(id, technical_type_code, feedback) 
values('rrr-must-have-parties', 'sql', 'Rrr that must have parties have parties::::RRR per cui sono previste parti, le devono avere');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('rrr-must-have-parties', now(), 'infinity', 
'select count(*) = 0 as vl
from administrative.rrr r
where id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-must-have-parties', 'critical', 'current', 'rrr', 3);

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

insert into system.br_validation(br_id, severity_code, target_reg_moment, target_code, order_of_execution) 
values('rrr-shares-total-check', 'critical', 'current', 'rrr', 16);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;

