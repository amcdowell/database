-- Script to load Waiheke Application data into SOLA
--Modified by Neil 27 July 2011

-- Prepare environment
--select fn_triggerall(false);
-- End prepare environment

--Clear previously loaded application details
DELETE FROM application.application_property;
DELETE FROM application.service;
DELETE FROM application.application;
DELETE FROM party.party_role;
DELETE FROM party.party;
DELETE FROM address.address;

 -- INSERT VALUES INTO address SCHEMA TABLE 
INSERT INTO address.address (id, description)
	SELECT id, description FROM testdata.address_
	WHERE id NOT IN (SELECT id FROM address.address);
 
 -- INSERT VALUES INTO party SCHEMA TABLES for Agents and Contact Persons
-- check out why partyid was added to party.party
INSERT INTO party.party (id, "name", type_code, address_id, email, mobile, phone, preferred_communication_code, change_user)
    SELECT id, "name", 'nonNaturalPerson', address_id, email, mobile, phone, preferred_communication_code, 'test' AS ch_user
    FROM testdata.agent_
    WHERE id NOT IN (SELECT id FROM party.party);

INSERT INTO party.party_role (party_id, type_code)
                SELECT id, 'lodgingAgent' FROM testdata.agent_
                WHERE id NOT IN (SELECT party_id FROM party.party_role);

INSERT INTO party.party_role (party_id, type_code)
                SELECT id, 'bank' FROM testdata.agent_ LIMIT 5;

INSERT INTO party.party (id, "name", last_name, type_code, address_id, email, mobile, phone, preferred_communication_code, change_user)
    SELECT id, firstname, lastname, 'naturalPerson', address_id, email, mobile, phone, preferred_communication_code, 'test' AS ch_user
    FROM testdata.contactperson_
    WHERE id NOT IN (SELECT id FROM party.party);

INSERT INTO party.party_role (party_id, type_code)
                SELECT id, 'citizen' FROM testdata.contactperson_
                WHERE id NOT IN (SELECT party_id FROM party.party_role);

INSERT INTO application.application (id, nr, agent_id, contact_person_id, lodging_datetime, expected_completion_date, status_code, action_code, change_user)
SELECT SUBSTRING(id FROM 1 FOR 20), SUBSTRING(nr FROM 1 FOR 20), SUBSTRING(agent_id FROM 1 FOR 20), SUBSTRING(contact_person_id FROM 1 FOR 20), lodging_datetime, now(), 'lodged' AS status_code, 'lodge' AS ac_code, 'test' AS ch_user
FROM testdata.application_
WHERE id NOT IN (SELECT id FROM application.application);

INSERT INTO application.service (id, application_id, request_type_code, lodging_datetime, expected_completion_date, service_order, status_code, action_code, change_user)
SELECT id, application_id, case when request_type_code='mortgageCertificate' then 'varyMortgage' else request_type_code end, now(), now(), service_order, 'lodged' AS status_code, 'lodge' AS ac_code, 'test' AS ch_user 
FROM testdata.service_
WHERE application_id IN (SELECT id FROM application.application)
AND id NOT IN (SELECT id FROM application.service); 

UPDATE application.service SET lodging_datetime = (SELECT lodging_datetime FROM application.application WHERE application_id = id);

INSERT INTO application.application_property (id, application_id, name_firstpart, name_lastpart, area, total_value, change_user)
SELECT SUBSTRING(id FROM 1 FOR 20), SUBSTRING(application_id FROM 1 FOR 20), SUBSTRING(name_firstpart FROM 1 FOR 20), 
SUBSTRING(name_lastpart FROM 1 FOR 20), area, total_land__value, 'test' AS ch_user 
FROM testdata.application_property_
WHERE application_id IN (SELECT id FROM application.application)
AND id NOT IN (SELECT id FROM application.application_property); 

-- Set env back
--select fn_triggerall(true);
-- End
