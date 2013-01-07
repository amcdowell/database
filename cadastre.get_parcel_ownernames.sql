-- Function: cadastre.get_parcel_ownernames(character varying)

-- DROP FUNCTION cadastre.get_parcel_ownernames(character varying);

CREATE OR REPLACE FUNCTION cadastre.get_parcel_ownernames(baunit_id character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
           select pp.name||' '||pp.last_name as value
		from party.party pp,
		     administrative.party_for_rrr  pr,
		     administrative.rrr rrr
		where pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and   rrr.ba_unit_id= baunit_id
		and   (rrr.type_code='ownership'
		       or rrr.type_code='apartment'
		       or rrr.type_code='commonOwnership'
		       or rrr.type_code='stateOwnership')
		
	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = 'No claimant identified ';
       end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.get_parcel_ownernames(character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION cadastre.get_parcel_ownernames(character varying) IS 'This function returns the concatenated list of owners of parcels. Where mo ownership claimant has been identified,
the family name field should be No claimant identified';

