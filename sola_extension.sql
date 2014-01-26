-- Script to extend sola.sql. It should be run immediately at the completion of sola.sql. 

-- #325 - Add change tracking to approle_appgroup and appgroup_appuser tables. This will ensure
-- any changes to these tables are auditied. 
DROP TRIGGER IF EXISTS __track_changes ON system.approle_appgroup CASCADE;
DROP TRIGGER IF EXISTS __track_history ON system.approle_appgroup CASCADE;
DROP TABLE IF EXISTS system.approle_appgroup_historic CASCADE;

ALTER TABLE system.approle_appgroup
DROP COLUMN IF EXISTS rowidentifier,
DROP COLUMN IF EXISTS rowversion,
DROP COLUMN IF EXISTS change_action,
DROP COLUMN IF EXISTS change_user,
DROP COLUMN IF EXISTS change_time;

ALTER TABLE system.approle_appgroup
ADD rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
ADD rowversion integer NOT NULL DEFAULT 0,
ADD change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
ADD change_user character varying(50),
ADD change_time timestamp without time zone NOT NULL DEFAULT now();

UPDATE system.approle_appgroup 
SET rowversion = 1,
    change_user = 'db:postgres'; 

CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON system.approle_appgroup FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    
----Table system.approle_appgroup_historic used for the history of data of table system.approle_appgroup ---
CREATE TABLE system.approle_appgroup_historic
(
    approle_code character varying(20),
    appgroup_id character varying(40),
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);

-- Index appuser_historic_index_on_rowidentifier  --
CREATE INDEX approle_appgroup_historic_index_on_rowidentifier ON system.approle_appgroup_historic (rowidentifier);
    
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON system.approle_appgroup FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();
   

DROP TRIGGER IF EXISTS __track_changes ON system.appuser_appgroup CASCADE;
DROP TRIGGER IF EXISTS __track_history ON system.appuser_appgroup CASCADE;
DROP TABLE IF EXISTS system.appuser_appgroup_historic CASCADE;

ALTER TABLE system.appuser_appgroup
DROP COLUMN IF EXISTS rowidentifier,
DROP COLUMN IF EXISTS rowversion,
DROP COLUMN IF EXISTS change_action,
DROP COLUMN IF EXISTS change_user,
DROP COLUMN IF EXISTS change_time;

ALTER TABLE system.appuser_appgroup
ADD rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
ADD rowversion integer NOT NULL DEFAULT 0,
ADD change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
ADD change_user character varying(50),
ADD change_time timestamp without time zone NOT NULL DEFAULT now();

UPDATE system.appuser_appgroup 
SET rowversion = 1,
    change_user = 'db:postgres'; 

CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON system.appuser_appgroup FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    
----Table system.appuser_appgroup_historic used for the history of data of table system.appuser_appgroup ---
CREATE TABLE system.appuser_appgroup_historic
(
    appuser_id character varying(40),
    appgroup_id character varying(40),
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);

-- Index appuser_historic_index_on_rowidentifier  --
CREATE INDEX appuser_appgroup_historic_index_on_rowidentifier ON system.appuser_appgroup_historic (rowidentifier);
    
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON system.appuser_appgroup FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();
   
-- #383 - Change label for public-display-parcels-next layer
UPDATE "system".config_map_layer
   SET title='Other Systematic Registration Parcels'
 WHERE "name"= 'public-display-parcels-next';
   
   
-- #326 - Add password expiry functionality to SOLA
INSERT INTO system.setting (name, vl, active, description)
SELECT 'pword-expiry-days', '90', TRUE, 'The number of days a users password remains valid'
WHERE NOT EXISTS (SELECT name FROM system.setting WHERE name = 'pword-expiry-days'); 
 
CREATE OR REPLACE VIEW system.user_pword_expiry AS 
WITH pw_change_all AS
  (SELECT u.username, u.change_time, u.change_user, u.rowversion
   FROM   system.appuser u
   WHERE NOT EXISTS (SELECT uh2.id FROM system.appuser_historic uh2
                     WHERE  uh2.username = u.username
                     AND    uh2.rowversion = u.rowversion - 1
                     AND    uh2.passwd = u.passwd)
   UNION
   SELECT uh.username, uh.change_time, uh.change_user, uh.rowversion
   FROM   system.appuser_historic uh
   WHERE NOT EXISTS (SELECT uh2.id FROM system.appuser_historic uh2
                     WHERE  uh2.username = uh.username
                     AND    uh2.rowversion = uh.rowversion - 1
                     AND    uh2.passwd = uh.passwd)),
pw_change AS
  (SELECT pall.username AS uname, 
          pall.change_time AS last_pword_change, 
          pall.change_user AS pword_change_user
   FROM   pw_change_all pall
   WHERE  pall.rowversion = (SELECT MAX(p2.rowversion)
                             FROM   pw_change_all p2
                             WHERE  p2.username = pall.username))

SELECT p.uname, p.last_pword_change, p.pword_change_user,
  CASE WHEN EXISTS (SELECT username FROM system.user_roles r
                    WHERE r.username = p.uname
                    AND   r.rolename IN ( 'ManageSecurity', 'NoPasswordExpiry')) THEN TRUE 
       ELSE FALSE END AS no_pword_expiry, 
  CASE WHEN s.vl IS NULL THEN NULL::INTEGER 
       ELSE (p.last_pword_change::DATE - now()::DATE) + s.vl::INTEGER END AS pword_expiry_days 
FROM pw_change p LEFT OUTER JOIN system.setting s ON s.name = 'pword-expiry-days' AND s.active;

COMMENT ON VIEW system.user_pword_expiry
  IS 'Determines the number of days until the users password expires. Once the number of days reaches 0, users will not be able to log into SOLA unless they have the ManageSecurity role (i.e. role to change manage user accounts) or the NoPasswordExpiry role. To configure the number of days before a password expires, set the pword-expiry-days setting in system.setting table. If this setting is not in place, then a password expiry does not apply.';


CREATE OR REPLACE VIEW system.active_users AS 
SELECT u.username, u.passwd 
FROM system.appuser u,
     system.user_pword_expiry ex
WHERE u.active = TRUE
AND   ex.uname = u.username
AND   (COALESCE(ex.pword_expiry_days, 1) > 0
OR    ex.no_pword_expiry = TRUE); 

COMMENT ON VIEW system.active_users
  IS 'Identifies the users currently active in the system. If the users password has expired, then they are treated as inactive users, unless they are System Administrators. This view is intended to replace the system.appuser table in the SolaRealm configuration in Glassfish.';
  
-- Update the setpassword function to set the change_user field 
DROP FUNCTION IF EXISTS system.setpassword(character varying, character varying);
 
CREATE OR REPLACE FUNCTION system.setpassword(usrname character varying, pass character varying, changeuser character varying)
  RETURNS integer AS
$BODY$
DECLARE
  result int;
BEGIN
  update system.appuser set passwd = pass,
   change_user = changeuser  where username=usrName;
  GET DIAGNOSTICS result = ROW_COUNT;
  return result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
COMMENT ON FUNCTION system.setpassword(character varying, character varying, character varying) IS 'This function changes the password of the user.';

-- Set the change_user on the default test user account to avoid being prompted on every login
ALTER TABLE system.appuser DISABLE TRIGGER ALL; 
UPDATE system.appuser SET change_user = 'test' 
WHERE username = 'test'; 
ALTER TABLE system.appuser ENABLE TRIGGER ALL;
  
-- Add the ChangePassword role to every group if it doesn't already exist  
INSERT INTO system.approle (code, display_value, status, description) 
SELECT 'ChangePassword', 'Admin - Change Password', 'c', 'Allows a user to change their password and edit thier user name. This role should be included in every security group.' 
WHERE NOT EXISTS (SELECT code from system.approle WHERE code = 'ChangePassword'); 

INSERT INTO system.approle (code, display_value, status, description) 
SELECT 'NoPasswordExpiry', 'Admin - No Password Expiry', 'c', 'Users with this role will not be subject to a password expiry if one is in place. This role can be assigned to user accounts used by other systems to integrate with the SOLA web services.' 
WHERE NOT EXISTS (SELECT code from system.approle WHERE code = 'NoPasswordExpiry');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
SELECT 'ChangePassword',  id FROM system.appgroup
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup
				WHERE approle_code = 'ChangePassword'
				AND   appgroup_id = id); 
				
				
-- Ticket #327 Improved function for Lodgement Statistics Report 
CREATE OR REPLACE FUNCTION application.get_work_summary(from_date DATE, to_date DATE)
  RETURNS TABLE (
      req_type VARCHAR(100), -- The service request type
      req_cat VARCHAR(100), -- The service request category type
      group_idx INT, -- Used for grouping/sorting the services by request category
      in_progress_from INT, -- Count of the services in progress as at the from_date
      on_requisition_from INT, -- Count of the services on requisition as at the from_date
      lodged INT, -- Count of the services lodged during the reporting period
      requisitioned INT, -- Count of the services requisitioned during the reporting period
      registered INT, -- Count of the services registered during the reporting period
      cancelled INT, -- Count of the services cancelled + the services associated to applications that have been rejected or lapsed
      withdrawn INT, -- Count of the serices associated to an application that was withdrawn 
      in_progress_to INT, -- Count of the services in progress as at the to_date
      on_requisition_to INT, -- Count of the services on requisition as at the to_date
      overdue INT, -- Count of the services exceeding their expected_completion_date at end of the reporting period
      overdue_apps TEXT, -- The list of applications that are overdue
      requisition_apps TEXT -- The list of applications on Requisition
) AS
$BODY$
DECLARE 
   tmp_date DATE; 
BEGIN

   IF to_date IS NULL OR from_date IS NULL THEN
      RETURN;
   END IF; 

   -- Swap the dates so the to date is after the from date
   IF to_date < from_date THEN 
      tmp_date := from_date; 
      from_date := to_date; 
      to_date := tmp_date; 
   END IF; 
   
   -- Go through to the start of the next day. 
   to_date := to_date + 1; 

   RETURN query 
   
      -- Identifies all services lodged during the reporting period. Uses the
	  -- change_time instead of lodging_datetime to ensure all datetime comparisons 
	  -- across all subqueries yield consistent results 
      WITH service_lodged AS
	   ( SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.rowversion = 1
		 UNION
         SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code
         FROM   application.service_historic ser_hist
         WHERE  ser_hist.change_time BETWEEN from_date AND to_date
		 AND    ser_hist.rowversion = 1),
		 
      -- Identifies all services cancelled during the reporting period. 	  
	  service_cancelled AS 
        (SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )
	 -- Check the history data for cancelled services as applications returned
	 -- from requisition can cause the cancelled service record to be updated. 
		UNION
		SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service_historic ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status. 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )),
		
      -- All services in progress at the end of the reporting period		
      service_in_progress AS (  
         SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= to_date
	 AND ser.status_code IN ('pending', 'lodged')
      UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= to_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > to_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= to_date )),
	
    -- All services in progress at the start of the reporting period	
	service_in_progress_from AS ( 
     SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= from_date
	 AND ser.status_code IN ('pending', 'lodged')
     UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= from_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the from_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > from_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= from_date )),
				      
    app_changed AS ( -- All applications that changed status during the reporting period
	                 -- If the application changed status more than once, it will be listed
					 -- multiple times
         SELECT app.id, 
	 -- Flag if the application was withdrawn
	 app.status_code,
	 CASE app.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
	 FROM   application.application app
	 WHERE  app.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist.status_code 
			  FROM application.application_historic app_hist
			  WHERE app_hist.id = app.id
			  AND  (app.rowversion - 1) = app_hist.rowversion
			  AND  app.status_code = app_hist.status_code )
      UNION  
	 SELECT app_hist.id, 
	 app_hist.status_code,
	 CASE app_hist.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
	 FROM  application.application_historic app_hist
	 WHERE app_hist.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist2.status_code 
			  FROM application.application_historic app_hist2
			  WHERE app_hist.id = app_hist2.id
			  AND  (app_hist.rowversion - 1) = app_hist2.rowversion
			  AND  app_hist.status_code = app_hist2.status_code )), 
                          
     app_in_progress AS ( -- All applications in progress at the end of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= to_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist, 
	       application.application app
	 WHERE app_hist.change_time <= to_date
	 AND   app.id = app_hist.id
	 -- Filter out any applications that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   app.change_time > to_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= to_date)),
					  
	app_in_progress_from AS ( -- All applications in progress at the start of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= from_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist,
	       application.application app
	 WHERE app_hist.change_time <= from_date
	 AND   app.id = app_hist.id
	-- Filter out any applications that have not been changed since the from_date as these
	-- would have been picked up in the first select if they were still active
	 AND   app.change_time > from_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= from_date))
   -- MAIN QUERY                         
   SELECT get_translation(req.display_value, null) AS req_type,
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN get_translation(cat.display_value, null)
	     WHEN 'cadastralServices' THEN get_translation(cat.display_value, null)
	     ELSE 'Information Services'  END AS req_cat,
	     
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN 1
             WHEN 'cadastralServices' THEN 2
	     ELSE 3 END AS group_idx,
		 
	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the start of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code)::INT AS in_progress_from,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code)::INT AS on_requisition_from,
	     
	  -- Count the services lodged during the reporting period.
	 (SELECT COUNT(s.id) FROM service_lodged s
	  WHERE s.request_type_code = req.code)::INT AS lodged,
	  
      -- Count the applications that were requisitioned during the
	  -- reporting period. All of the services on the application
 	  -- are requisitioned unless they are cancelled. Use the
	  -- current set of services on the application, but ensure
	  -- the services where lodged before the end of the reporting
	  -- period and that they were not cancelled during the 
	  -- reporting period. 
	 (SELECT COUNT(s.id) FROM app_changed a, application.service s
          WHERE s.application_id = a.id
	  AND   a.status_code = 'requisitioned'
	  AND   s.lodging_datetime < to_date
	  AND   NOT EXISTS (SELECT can.id FROM service_cancelled can
                        WHERE s.id = can.id)	  
          AND   s.request_type_code = req.code)::INT AS requisitioned, 
          
	  -- Count the services on applications approved/completed 
	  -- during the reporting period. Note that services cannot be
	  -- changed after the application is approved, so checking the
	  -- current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'approved'
	  AND   s.status_code = 'completed'
	  AND   s.request_type_code = req.code)::INT AS registered,
	  
	  -- Count of the services associated with applications 
	  -- that have been lapsed or rejected + the count of 
	  -- services cancelled during the reporting period. Note that
      -- once annulled changes to the services are not possible so
      -- checking the current state of the services is valid.
      (SELECT COUNT(tmp.id) FROM  	  
        (SELECT s.id FROM app_changed a, application.service s
		  WHERE s.application_id = a.id
		  AND   a.status_code = 'annulled'
		  AND   a.withdrawn = FALSE
		  AND   s.request_type_code = req.code
          UNION		  
		  SELECT s.id FROM app_changed a, service_cancelled s
		  WHERE s.application_id = a.id
		  AND   a.status_code != 'annulled'
		  AND   s.request_type_code = req.code) AS tmp)::INT AS cancelled, 
	  
	  -- Count of the services associated with applications
	  -- that have been withdrawn during the reporting period
	  -- Note that once annulled changes to the services are
      -- not possible so checking the current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'annulled'
	  AND   a.withdrawn = TRUE
	  AND   s.status_code != 'cancelled'
	  AND   s.request_type_code = req.code)::INT AS withdrawn,

	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code)::INT AS in_progress_to,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code)::INT AS on_requisition_to,

	  -- Count of the services that have exceeded thier expected
	  -- completion date and are overdue. Only counts the service 
	  -- as overdue if both the application and the service are overdue. 
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'              
	  AND   a.expected_completion_date < to_date
	  AND   s.expected_completion_date < to_date
	  AND   s.request_type_code = req.code)::INT AS overdue,  

	  -- The list of overdue applications 
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'lodged' 
          AND   a.expected_completion_date < to_date
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.expected_completion_date < to_date
                        AND   s.request_type_code = req.code)) AS overdue_apps,   

	  -- The list of applications on Requisition
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'requisitioned' 
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.request_type_code = req.code)) AS requisition_apps 						
   FROM  application.request_type req, 
	 application.request_category_type cat
   WHERE req.status = 'c'
   AND   cat.code = req.request_category_code					 
   ORDER BY group_idx, req_type;
	
   END; $BODY$
   LANGUAGE plpgsql VOLATILE;


COMMENT ON FUNCTION application.get_work_summary(DATE,DATE)
IS 'Returns a summary of the services processed for a specified reporting period';

-- Create indexes to improve performance of the Lodgement Report
DROP INDEX IF EXISTS application.service_historic_id_idx;
DROP INDEX IF EXISTS application.application_historic_id_idx;

 CREATE INDEX service_historic_id_idx
  ON application.service_historic
  USING btree
  (id COLLATE pg_catalog."default");

CREATE INDEX application_historic_id_idx
  ON application.application_historic
  USING btree
  (id COLLATE pg_catalog."default");




-- #338 - New Service for Mapping existing Parcel (existing Title)
--  added to the reference data new service and its required document 
DELETE from application.request_type where code = 'mapExistingParcel';
INSERT INTO application.request_type(
            code, request_category_code, display_value, description, status, 
            nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template)
    VALUES ('mapExistingParcel','registrationServices', 'Map Existing Parcel', '', 'c', 30, 
            0.00, 0.00, 0.00, 0, 
            'Allows to make changes to the cadastre');
DELETE FROM application.request_type_requires_source_type WHERE request_type_code = 'mapExistingParcel';
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('cadastralSurvey', 'mapExistingParcel');
DELETE FROM application.request_type_requires_source_type WHERE request_type_code = 'newDigitalTitle';
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code) VALUES('newDigitalTitle', 'title');





--- #345 - CHANGES FOR SYSTEMATIC REGISTRATION -----------------------------------------

UPDATE application.request_type SET nr_properties_required = 0 WHERE code = 'systematicRegn';


ALTER TABLE source.source ALTER reference_nr TYPE character varying(255);
ALTER TABLE source.source_historic ALTER reference_nr TYPE character varying(255);

---------   VIEW administrative.systematic_registration_listing -----------------
CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, sa.size, 
get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, 
(bu.name_firstpart::text || '/'::text) || bu.name_lastpart::text AS name
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, 
   application.application aa, application.service s, administrative.ba_unit bu,
   transaction.transaction t
  WHERE sa.spatial_unit_id::text = co.id::text 
   AND bu.transaction_id = t.id
   AND t.from_service_id = s.id
   AND sa.type_code::text = 'officialArea'::text
   AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
   AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text 
   AND s.status_code::text = 'completed'::text 
   AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text;

ALTER TABLE administrative.systematic_registration_listing OWNER TO postgres;

--------  VIEW administrative.sys_reg_owner_name -------------
CREATE OR REPLACE VIEW administrative.sys_reg_owner_name AS 
         SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ''::character varying)::text AS value, pp.name::text AS name, COALESCE(pp.last_name, ''::character varying)::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'residential'::text THEN sa.size
                    ELSE 0::numeric
                END AS residential, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'agricultural'::text THEN sa.size
                    ELSE 0::numeric
                END AS agricultural, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'commercial'::text THEN sa.size
                    ELSE 0::numeric
                END AS commercial, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'industrial'::text THEN sa.size
                    ELSE 0::numeric
                END AS industrial
           FROM cadastre.land_use_type lu, cadastre.cadastre_object co, 
           cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
           application.application aa, application.service s,
            party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, administrative.ba_unit bu,
          transaction.transaction t
           WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text
           AND bu.transaction_id = t.id
           AND t.from_service_id = s.id
   
           AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text AND (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text) AND bu.id::text = su.ba_unit_id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text
UNION 
         SELECT DISTINCT 'No Claimant '::text AS value, 'No Claimant '::text AS name, 'No Claimant '::text AS last_name, co.id, co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'residential'::text THEN sa.size
                    ELSE 0::numeric
                END AS residential, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'agricultural'::text THEN sa.size
                    ELSE 0::numeric
                END AS agricultural, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'commercial'::text THEN sa.size
                    ELSE 0::numeric
                END AS commercial, 
                CASE
                    WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'industrial'::text THEN sa.size
                    ELSE 0::numeric
                END AS industrial
           FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su,
           application.application aa, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, application.service s, administrative.ba_unit bu,
           transaction.transaction t
          WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND sa.type_code::text = 'officialArea'::text 
          AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
          AND bu.transaction_id = t.id
          AND t.from_service_id = s.id
          AND NOT (su.ba_unit_id::text IN ( SELECT rrr.ba_unit_id
                   FROM administrative.rrr rrr, party.party pp, administrative.party_for_rrr pr
                  WHERE (rrr.type_code::text = 'ownership'::text OR rrr.type_code::text = 'apartment'::text OR rrr.type_code::text = 'commonOwnership'::text OR rrr.type_code::text = 'stateOwnership'::text) AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text)) AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text
  ORDER BY 3, 2;

ALTER TABLE administrative.sys_reg_owner_name OWNER TO postgres;


-----  VIEW administrative.sys_reg_state_land  --------------
CREATE OR REPLACE VIEW administrative.sys_reg_state_land AS 
 SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text AS value, co.id, co.name_firstpart, co.name_lastpart, get_translation(lu.display_value, NULL::character varying) AS land_use_code, su.ba_unit_id, sa.size, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'residential'::text THEN sa.size
            ELSE 0::numeric
        END AS residential, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'agricultural'::text THEN sa.size
            ELSE 0::numeric
        END AS agricultural, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'commercial'::text THEN sa.size
            ELSE 0::numeric
        END AS commercial, 
        CASE
            WHEN COALESCE(co.land_use_code, 'residential'::character varying)::text = 'industrial'::text THEN sa.size
            ELSE 0::numeric
        END AS industrial
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application aa, application.service s, party.party pp, administrative.party_for_rrr pr, administrative.rrr rrr, administrative.ba_unit bu,
   transaction.transaction t
  WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
  AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND bu.transaction_id = t.id
  AND t.from_service_id = s.id
   AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text
  ORDER BY (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text;

ALTER TABLE administrative.sys_reg_state_land OWNER TO postgres;


---#383 Public Display and Related Issues (issues on certificates) 
---------- VIEW application.systematic_registration_certificates -----------
CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id
   FROM application.application_status_type ast, 
   cadastre.cadastre_object co, administrative.ba_unit bu, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application aa, application.service s,
   transaction.transaction t
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND su.ba_unit_id = bu.id
  AND bu.transaction_id = t.id
  AND t.from_service_id = s.id
  AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = 'systematicRegn'::text 
  AND aa.status_code::text = ast.code::text AND aa.status_code::text = 'approved'::text 
  ;


ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;

-- #384 Systematic Registration Report Issues.
CREATE OR REPLACE FUNCTION administrative.getsysregprogress(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	block  			varchar;	
       	TotAppLod		decimal:=0 ;	
        TotParcLoaded		varchar:='none' ;	
        TotRecObj		decimal:=0 ;	
        TotSolvedObj		decimal:=0 ;	
        TotAppPDisp		decimal:=0 ;	
        TotPrepCertificate      decimal:=0 ;	
        TotIssuedCertificate	decimal:=0 ;	


        Total  			varchar;	
       	TotalAppLod		decimal:=0 ;	
        TotalParcLoaded		varchar:='none' ;	
        TotalRecObj		decimal:=0 ;	
        TotalSolvedObj		decimal:=0 ;	
        TotalAppPDisp		decimal:=0 ;	
        TotalPrepCertificate      decimal:=0 ;	
        TotalIssuedCertificate	decimal:=0 ;	


  
      
       rec     record;
       sqlSt varchar;
       workFound boolean;
       recToReturn record;

       recTotalToReturn record;

        -- From Neil's email 9 march 2013
	    -- PROGRESS REPORT
		--0. Block	
		--1. Total Number of Applications Lodged	
		--2. No of Parcel loaded	
		--3. No of Objections received
		--4. No of Objections resolved
		--5. No of Applications in Public Display	               
		--6. No of Applications with Prepared Certificate	
		--7. No of Applications with Issued Certificate	
		
    
BEGIN  


   sqlSt:= '';
    
  
 sqlSt:= 'select  distinct (co.name_lastpart)   as area
                   FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    
    ';
    
    if namelastpart != '' then
         -- sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', co.name_lastpart) ';
          sqlSt:= sqlSt|| ' AND  co.name_lastpart =  '''||namelastpart||'''';  --1. block
   
    end if;
    --raise exception '%',sqlSt;
       workFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) + 
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   aa.action_code='lodge'
			    AND   s.request_type_code::text = 'systematicRegn'::text
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp
          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.cadastre_object co, 
		 cadastre.spatial_value_area sa, 
		 administrative.ba_unit_contains_spatial_unit su,
		 application.application aa, 
		 application.service s, 
		 administrative.ba_unit bu, 
		 transaction.transaction t 
		    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
		            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		            AND  co.name_lastpart = ''|| rec.area ||''
            AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
	    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	    AND s.status_code::text = 'completed'::text 
	    AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
			    AND  co.name_lastpart = ''|| rec.area ||''
                            --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
                    	    
	     )

	   )
                 ,  ---TotParcelLoaded
                  
               (
                  SELECT 
                  (
	            (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			  -- AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
                          AND  co.name_lastpart = ''|| rec.area ||'' 
			   AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        ) +
		        (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service_historic s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			   --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
                           AND  co.name_lastpart = ''|| rec.area ||'' 
			   AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        )  
		   )  
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa, 
		   application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
			    AND  co.name_lastpart = ''|| rec.area ||''
		            AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text = 'cancelled'::text
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		), --TotSolvedObj
			
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart) 
			    AND  co.name_lastpart = ''|| rec.area ||''
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in (
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                     )
                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, 
                   application.application aa, 
                   cadastre.cadastre_object co,
		   administrative.ba_unit_contains_spatial_unit su,
		   administrative.ba_unit bu,
                   transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart = ''|| rec.area ||'' 
			    AND s.request_type_code::text = 'systematicRegn'::text
		            AND co.name_lastpart in (
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                                      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										  where ss.type_code='title'
										  and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										  and ss.reference_nr = ''|| rec.area ||''
                                                                                )   
					           )
	
                 ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                   application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes = ''|| rec.area ||'')  --TotCertificatesIssued

                    
              INTO       TotAppLod,
                         TotParcLoaded,
                         TotRecObj,
                         TotSolvedObj,
                         TotAppPDisp,
                         TotPrepCertificate,
                         TotIssuedCertificate
          ;        

                block = rec.area;
                TotAppLod = TotAppLod;
                TotParcLoaded = TotParcLoaded;
                TotRecObj = TotRecObj;
                TotSolvedObj = TotSolvedObj;
                TotAppPDisp = TotAppPDisp;
                TotPrepCertificate = TotPrepCertificate;
                TotIssuedCertificate = TotIssuedCertificate;
	  
	  select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;	
		                         
		return next recToReturn;
		workFound = true;
          
    end loop;
   
    if (not workFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotAppLod::  		decimal,	
		TotParcLoaded::  	varchar,	
		TotRecObj::  		decimal,	
		TotSolvedObj::  	decimal,	
		TotAppPDisp::  		decimal,	
		TotPrepCertificate::  	decimal,	
		TotIssuedCertificate::  decimal;		
		                         
		return next recToReturn;

    end if;

------ TOTALS ------------------
                
              select  (      
                  ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ) +
	           ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application_historic aa,
			  application.service s
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND   aa.action_code='lodge'
                            AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    )
		    

	      ),  --- TotApp

		   
	          (           
	   
	   (
	    SELECT count (DISTINCT co.id)
	    FROM cadastre.land_use_type lu, 
	    cadastre.spatial_value_area sa, 
	    application.application aa, 
	    application.service s, 
            cadastre.cadastre_object co,
	    administrative.ba_unit_contains_spatial_unit su,
	    administrative.ba_unit bu,
            transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND sa.type_code::text = 'officialArea'::text 
			    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
	                    AND s.request_type_code::text = 'systematicRegn'::text 
	                    AND s.status_code::text = 'completed'::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text
	    )
            ||'/'||
	    (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
	    )

	   ),  ---TotParcelLoaded
                  
                    (
                  SELECT 
                  (
	            (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service s
			  WHERE  s.application_id::text = aa.id::text 
			  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        ) +
		        (SELECT (COUNT(*)) 
			FROM  application.application aa, 
			   application.service_historic s
			  WHERE  s.application_id::text = aa.id::text 
			  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
			  AND s.request_type_code::text = 'lodgeObjection'::text
			  AND s.status_code::text = 'lodged'::text
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		        )  
		   )  
		),  --TotLodgedObj

                (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa, 
		   application.service s
		  WHERE  s.application_id::text = aa.id::text 
		  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text = 'cancelled'::text
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		), --TotSolvedObj
		
		
		(
		SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s, 
			    cadastre.cadastre_object co,
			    administrative.ba_unit_contains_spatial_unit su,
			    administrative.ba_unit bu,
			    transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in ( select ss.reference_nr 
		 				      from   source.source ss 
							where ss.type_code='publicNotification'
							AND ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                                     )
                 ),  ---TotAppPubDispl


                 (
                  select count(distinct (aa.id))
                   from application.service s, 
                   application.application aa, 
			    cadastre.cadastre_object co,
			    administrative.ba_unit_contains_spatial_unit su,
			    administrative.ba_unit bu,
			    transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    AND co.name_lastpart in ( select ss.reference_nr 
					              from   source.source ss 
					              where ss.type_code='publicNotification'
					              and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                                      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										 where ss.type_code='title'
										 and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										)   
					            ) 
	         ),  ---TotCertificatesPrepared
                 (select count (distinct(s.id))
                   FROM 
                       application.service s   --,
		   WHERE s.request_type_code::text = 'documentCopy'::text
		   AND s.lodging_datetime between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                   AND s.action_notes is not null )  --TotCertificatesIssued

      

                     
              INTO       TotalAppLod,
                         TotalParcLoaded,
                         TotalRecObj,
                         TotalSolvedObj,
                         TotalAppPDisp,
                         TotalPrepCertificate,
                         TotalIssuedCertificate
               ;        
                Total = 'Total';
                TotalAppLod = TotalAppLod;
                TotalParcLoaded = TotalParcLoaded;
                TotalRecObj = TotalRecObj;
                TotalSolvedObj = TotalSolvedObj;
                TotalAppPDisp = TotalAppPDisp;
                TotalPrepCertificate = TotalPrepCertificate;
                TotalIssuedCertificate = TotalIssuedCertificate;
	  
	  select into recTotalToReturn
                Total::                 varchar, 
                TotalAppLod::  		decimal,	
		TotalParcLoaded::  	varchar,	
		TotalRecObj::  		decimal,	
		TotalSolvedObj::  	decimal,	
		TotalAppPDisp::  	decimal,	
		TotalPrepCertificate:: 	decimal,	
		TotalIssuedCertificate::  decimal;	

	                         
		return next recTotalToReturn;

                
    return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregprogress(character varying, character varying, character varying) OWNER TO postgres;


----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION administrative.getsysregstatus(fromdate character varying, todate character varying, namelastpart character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE 

       	block  			varchar;	
       	appLodgedNoSP 		decimal:=0 ;	
       	appLodgedSP   		decimal:=0 ;	
       	SPnoApp 		decimal:=0 ;	
       	appPendObj		decimal:=0 ;	
       	appIncDoc		decimal:=0 ;	
       	appPDisp		decimal:=0 ;	
       	appCompPDispNoCert	decimal:=0 ;	
       	appCertificate		decimal:=0 ;
       	appPrLand		decimal:=0 ;	
       	appPubLand		decimal:=0 ;	
       	TotApp			decimal:=0 ;	
       	TotSurvPar		decimal:=0 ;	



      
       rec     record;
       sqlSt varchar;
       statusFound boolean;
       recToReturn record;

        -- From Neil's email 9 march 2013
	    -- STATUS REPORT
		--Block	
		--1. Total Number of Applications	
		--2. No of Applications Lodged with Surveyed Parcel	
		--3. No of Applications Lodged no Surveyed Parcel	     
		--4. No of Surveyed Parcels with no application	
		--5. No of Applications with pending Objection	        
		--6. No of Applications with incomplete Documentation	
		--7. No of Applications in Public Display	               
		--8. No of Applications with Completed Public Display but Certificates not Issued	 
		--9. No of Applications with Issued Certificate	
		--10. No of Applications for Private Land	
		--11. No of Applications for Public Land 	
		--12. Total Number of Surveyed Parcels	

    
BEGIN  


    sqlSt:= '';
    
  
 sqlSt:= 'select   distinct (co.name_lastpart)   as area
                   FROM   application.application aa,     
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    
    ';
    
    if namelastpart != '' then
          --sqlSt:= sqlSt|| ' AND compare_strings('''||namelastpart||''', co.name_lastpart) ';
          sqlSt:= sqlSt|| ' AND  co.name_lastpart =  '''||namelastpart||'''';  --1. block
    
    end if;

    --raise exception '%',sqlSt;
       statusFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

    
    select        ( SELECT  
		    count (distinct(aa.id)) 
		    FROM  application.application aa,
			  application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
			    ),

		    (SELECT count (distinct(aa.id))
		     FROM application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			 AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),

	          (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
			    AND   co.id not in (SELECT su.spatial_unit_id FROM administrative.ba_unit_contains_spatial_unit su)
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
	          ),

                 (
	          SELECT (COUNT(*)) 
		   FROM  application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
		  AND s.application_id::text in (select s.application_id 
						 FROM application.service s
						 where s.request_type_code::text = 'systematicRegn'::text
						 ) 
		  AND s.request_type_code::text = 'lodgeObjection'::text
		  AND s.status_code::text != 'cancelled'::text
		  --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
		  AND  co.name_lastpart =  ''|| rec.area ||''
		  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )
		),


		  ( WITH appSys AS 	(SELECT  
		    distinct on (aa.id) aa.id as id
		    FROM  application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			  AND  (
		          (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		           or
		          (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		          )),
		     sourceSys AS	
		     (
		     SELECT  DISTINCT (sc.id) FROM  application.application_uses_source a_s,
							   source.source sc,
							   appSys app
						where sc.type_code='systematicRegn'
						 and  sc.id = a_s.source_id
						 and a_s.application_id=app.id
						 AND  (
						  (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
						   or
						  (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
						  )
						
				)
		      SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM appSys) THEN 0
				WHEN ((SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys) >= 0) THEN (SELECT COUNT(*) FROM appSys) - (SELECT COUNT(*) FROM sourceSys)
				ELSE 0
			END 
				  ),
     
                 (select count(distinct (aa.id))
                   from application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
		                             select ss.reference_nr from   source.source ss 
					     where ss.type_code='publicNotification'
					     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
                                             and ss.reference_nr = ''|| rec.area ||''   
					   )
		 ),

                 ( 
                   select count(distinct (aa.id))
                   from application.application aa,
		     application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
						      select ss.reference_nr 
						       from   source.source ss 
						       where ss.type_code='publicNotification'
						       and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
						       and   ss.reference_nr not in ( select ss.reference_nr from   source.source ss 
										     where ss.type_code='title'
										     and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										     and ss.reference_nr = ''|| rec.area ||''
	 								           )   
		                                     )
                 ),

                 (
                   select count(distinct (aa.id))
                   from application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND co.name_lastpart in ( 
						      select ss.reference_nr 
						      from   source.source ss 
						      where ss.type_code='publicNotification'
						      and ss.expiration_date < to_date(''|| toDate ||'','yyyy-mm-dd')
						      and   ss.reference_nr in ( select ss.reference_nr from   source.source ss 
										   where ss.type_code='title'
										   and ss.recordation  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd')
										   and ss.reference_nr = ''|| rec.area ||''
									        )   
					            )  
                ),
		 (SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, 
			cadastre.spatial_value_area sa, 
			party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr, 
			application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			    AND sa.type_code::text = 'officialArea'::text 
			    AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			    AND s.status_code::text = 'completed'::text 
			    AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			    AND rrr.ba_unit_id::text = su.ba_unit_id::text
			    AND  (
		            (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		              or
		             (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		            )
			    AND 
			    (rrr.type_code::text = 'ownership'::text 
			     OR rrr.type_code::text = 'apartment'::text 
			     OR rrr.type_code::text = 'commonOwnership'::text 
			     ) 
		 ),		
		 ( SELECT count (distinct (aa.id) )
			FROM cadastre.land_use_type lu, 
			cadastre.spatial_value_area sa, 
			party.party pp, administrative.party_for_rrr pr, 
			administrative.rrr rrr,
			application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			    AND   sa.spatial_unit_id::text = co.id::text AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text 
			    AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
			    AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text 
			    AND rrr.ba_unit_id::text = su.ba_unit_id::text AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text
			    AND  (
		            (aa.lodging_datetime  between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd'))
		             or
		            (aa.change_time  between to_date(''|| fromDate ||'','yyyy-mm-dd')  and to_date(''|| toDate ||'','yyyy-mm-dd'))
		            ) 
	  	 ), 	
                 (SELECT count (*)
	            FROM cadastre.cadastre_object co
			    WHERE co.type_code='parcel'
		    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
	         )    
              INTO       TotApp,
                         appLodgedSP,
                         SPnoApp,
                         appPendObj,
                         appIncDoc,
                         appPDisp,
                         appCompPDispNoCert,
                         appCertificate,
                         appPrLand,
                         appPubLand,
                         TotSurvPar
                
              FROM        application.application aa,
		          application.service s,
			  cadastre.cadastre_object co,
			  administrative.ba_unit_contains_spatial_unit su,
			  administrative.ba_unit bu,
                          transaction.transaction t             
			    WHERE s.application_id = aa.id
			    AND   bu.transaction_id = t.id
                            AND   t.from_service_id = s.id
                            AND   su.spatial_unit_id::text = co.id::text 
			    AND   su.ba_unit_id = bu.id
			    AND   bu.transaction_id = t.id
			    AND   t.from_service_id = s.id
			    AND   s.request_type_code::text = 'systematicRegn'::text
			    --AND compare_strings(''|| rec.area ||'', co.name_lastpart)
			    AND  co.name_lastpart =  ''|| rec.area ||''
			  
	  ;        

                block = rec.area;
                TotApp = TotApp;
		appLodgedSP = appLodgedSP;
		SPnoApp = SPnoApp;
                appPendObj = appPendObj;
		appIncDoc = appIncDoc;
		appPDisp = appPDisp;
		appCompPDispNoCert = appCompPDispNoCert;
		appCertificate = appCertificate;
		appPrLand = appPrLand;
		appPubLand = appPubLand;
		TotSurvPar = TotSurvPar;
		appLodgedNoSP = TotApp-appLodgedSP;
		


	  
	  select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;
          statusFound = true;
          
    end loop;
   
    if (not statusFound) then
         block = 'none';
                
        select into recToReturn
	       	block::			varchar,
		TotApp::  		decimal,
		appLodgedSP::  		decimal,
		SPnoApp::  		decimal,
		appPendObj::  		decimal,
		appIncDoc::  		decimal,
		appPDisp::  		decimal,
		appCompPDispNoCert::  	decimal,
		appCertificate::  	decimal,
		appPrLand::  		decimal,
		appPubLand::  		decimal,
		TotSurvPar::  		decimal,
		appLodgedNoSP::  	decimal;

		                         
          return next recToReturn;

    end if;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION administrative.getsysregstatus(character varying, character varying, character varying) OWNER TO postgres;


-- #389 Consolidation functionality.

-- Insert a new setting called system-id. This must be a unique number that identifies the installed system.
insert into system.setting(name, vl, active, description) values('system-id', '', true, 'A unique number that identifies the installed SOLA system. This unique number is used in the br that generate unique identifiers.');

-- Insert a new setting called zip-pass. This holds a password that is used only in server side.
insert into system.setting(name, vl, active, description) values('zip-pass', 'wownow3nnZv3r', true, 'A password that is used during the consolidation process. It is used only in server side.');

DROP TABLE IF EXISTS system.consolidation_config;

CREATE TABLE system.consolidation_config
(
  id character varying(100) NOT NULL,
  schema_name character varying(100) NOT NULL,
  table_name character varying(100) NOT NULL,
  condition_description character varying(1000) NOT NULL,
  condition_sql character varying(1000),
  remove_before_insert boolean NOT NULL DEFAULT false,
  order_of_execution integer NOT NULL,
  CONSTRAINT consolidation_config_pkey PRIMARY KEY (id ),
  CONSTRAINT consolidation_config_lkey UNIQUE (schema_name , table_name )
);

COMMENT ON TABLE system.consolidation_config
  IS 'This table contains the list of instructions to run the consolidation process.';

insert into system.consolidation_config values('application.application','application','application','Applications that have a service of type  “recordTransfer” and that has the status ''Lodged'', or ''Requisitioned''.','id in (select application_id from application.service where request_type_code=''recordTransfer''  and status_code in (''lodged'', ''requisitioned''))','f',1);
insert into system.consolidation_config values('application.service','application','service','Every service that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',2);
insert into system.consolidation_config values('transaction.transaction','transaction','transaction','Every record that references a record in consolidation.service.','from_service_id in (select id from consolidation.service)','f',3);
insert into system.consolidation_config values('transaction.transaction_source','transaction','transaction_source','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',4);
insert into system.consolidation_config values('cadastre.cadastre_object_target','cadastre','cadastre_object_target','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',5);
insert into system.consolidation_config values('cadastre.cadastre_object_node_target','cadastre','cadastre_object_node_target','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',6);
insert into system.consolidation_config values('application.application_uses_source','application','application_uses_source','Every record that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',7);
insert into system.consolidation_config values('application.application_property','application','application_property','Every record that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',8);
insert into system.consolidation_config values('application.application_spatial_unit','application','application_spatial_unit','Every record that belongs to the application being selected for transfer.','application_id in (select id from consolidation.application)','f',9);
insert into system.consolidation_config values('cadastre.spatial_unit','cadastre','spatial_unit','Every record that is referenced from application_spatial_unit in consolidation schema.','id in (select spatial_unit_id from consolidation.application_spatial_unit)','f',10);
insert into system.consolidation_config values('cadastre.spatial_unit_in_group','cadastre','spatial_unit_in_group','Every record that references a record in consolidation.spatial_unit','spatial_unit_id in (select id from consolidation.spatial_unit)','f',11);
insert into system.consolidation_config values('cadastre.cadastre_object','cadastre','cadastre_object','Every record that is also in consolidation.spatial_unit','id in (select id from consolidation.spatial_unit)','f',12);
insert into system.consolidation_config values('cadastre.spatial_unit_address','cadastre','spatial_unit_address','Every record that references a record in consolidation.spatial_unit.','spatial_unit_id in (select id from consolidation.spatial_unit)','f',13);
insert into system.consolidation_config values('cadastre.spatial_value_area','cadastre','spatial_value_area','Every record that references a record in consolidation.spatial_unit.','spatial_unit_id in (select id from consolidation.spatial_unit)','f',14);
insert into system.consolidation_config values('cadastre.survey_point','cadastre','survey_point','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',15);
insert into system.consolidation_config values('cadastre.legal_space_utility_network','cadastre','legal_space_utility_network','Every record that is also in consolidation.spatial_unit','id in (select id from consolidation.spatial_unit)','f',16);
insert into system.consolidation_config values('cadastre.spatial_unit_group','cadastre','spatial_unit_group','Every record','','t',17);
insert into system.consolidation_config values('administrative.ba_unit_contains_spatial_unit','administrative','ba_unit_contains_spatial_unit','Every record that references a record in consolidation.cadastre_object.','spatial_unit_id in (select id from consolidation.cadastre_object)','f',18);
insert into system.consolidation_config values('administrative.ba_unit_target','administrative','ba_unit_target','Every record that references a record in consolidation.transaction.','transaction_id in (select id from consolidation.transaction)','f',19);
insert into system.consolidation_config values('administrative.ba_unit','administrative','ba_unit','Every record that is referenced by consolidation.application_property or consolidation.ba_unit_contains_spatial_unit or consolidation.ba_unit_target.','id in (select ba_unit_id from consolidation.application_property) or id in (select ba_unit_id from consolidation.ba_unit_contains_spatial_unit) or id in (select ba_unit_id from consolidation.ba_unit_target)','f',20);
insert into system.consolidation_config values('administrative.required_relationship_baunit','administrative','required_relationship_baunit','Every record that references a record in consolidation.ba_unit.','from_ba_unit_id in (select id from consolidation.ba_unit)','f',21);
insert into system.consolidation_config values('administrative.ba_unit_area','administrative','ba_unit_area','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',22);
insert into system.consolidation_config values('administrative.ba_unit_as_party','administrative','ba_unit_as_party','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',23);
insert into system.consolidation_config values('administrative.source_describes_ba_unit','administrative','source_describes_ba_unit','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',24);
insert into system.consolidation_config values('administrative.rrr','administrative','rrr','Every record that references a record in consolidation.ba_unit.','ba_unit_id in (select id from consolidation.ba_unit)','f',25);
insert into system.consolidation_config values('administrative.rrr_share','administrative','rrr_share','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',26);
insert into system.consolidation_config values('administrative.party_for_rrr','administrative','party_for_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',27);
insert into system.consolidation_config values('administrative.condition_for_rrr','administrative','condition_for_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',28);
insert into system.consolidation_config values('administrative.mortgage_isbased_in_rrr','administrative','mortgage_isbased_in_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',29);
insert into system.consolidation_config values('administrative.source_describes_rrr','administrative','source_describes_rrr','Every record that references a record in consolidation.rrr.','rrr_id in (select id from consolidation.rrr)','f',30);
insert into system.consolidation_config values('administrative.notation','administrative','notation','Every record that references a record in consolidation.ba_unit or consolidation.rrr or consolidation.transaction.','ba_unit_id in (select id from consolidation.ba_unit) or rrr_id in (select id from consolidation.rrr) or transaction_id in (select id from consolidation.transaction)','f',31);
insert into system.consolidation_config values('source.source','source','source','Every source that is referenced from the consolidation.application_uses_source 
or consolidation.transaction_source
or source that references consolidation.transaction or source that is referenced from consolidation.source_describes_ba_unit or source that is referenced from consolidation.source_describes_rrr.','id in (select source_id from consolidation.application_uses_source)
or id in (select source_id from consolidation.transaction_source)
or transaction_id in (select id from consolidation.transaction)
or id in (select source_id from consolidation.source_describes_ba_unit)
or id in (select source_id from consolidation.source_describes_rrr)','t',32);
insert into system.consolidation_config values('source.power_of_attorney','source','power_of_attorney','Every record that is also in consolidation.source.','id in (select id from consolidation.source)','t',33);
insert into system.consolidation_config values('source.spatial_source','source','spatial_source','Every record that is also in consolidation.source.','id in (select id from consolidation.source)','t',34);
insert into system.consolidation_config values('source.spatial_source_measurement','source','spatial_source_measurement','Every record that references a record in consolidation.spatial_source.','spatial_source_id in (select id from consolidation.spatial_source)','t',35);
insert into system.consolidation_config values('source.archive','source','archive','Every record that is referenced from a record in consolidation.source.','id in (select archive_id from consolidation.source)','t',36);
insert into system.consolidation_config values('document.document','document','document','Every record that is referenced by consolidation.source.','id in (select ext_archive_id from consolidation.source)','t',37);
insert into system.consolidation_config values('party.party','party','party','Every record that is referenced by consolidation.application or consolidation.ba_unit_as_party or consolidation.party_for_rrr.','id in (select agent_id from consolidation.application) or id in (select contact_person_id from consolidation.application) or id in (select agent_id from consolidation.application) or id in (select party_id from consolidation.party_for_rrr) or id in (select party_id from consolidation.ba_unit_as_party)','t',38);
insert into system.consolidation_config values('party.group_party','party','group_party','Every record that is also in consolidation.party.','id in (select id from consolidation.party)','t',39);
insert into system.consolidation_config values('party.party_member','party','party_member','Every record that references a record in consolidation.party.','party_id in (select id from consolidation.party)','t',40);
insert into system.consolidation_config values('party.party_role','party','party_role','Every record that references a record in consolidation.party.','party_id in (select id from consolidation.party)','t',41);
insert into system.consolidation_config values('address.address','address','address','Every record that is referenced by consolidation.party or consolidation.spatial_unit_address.','id in (select address_id from consolidation.party) or id in (select address_id from consolidation.spatial_unit_address)','t',42);
insert into system.consolidation_config values('source.source_historic','source','source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.source)','t',43);
insert into system.consolidation_config values('cadastre.survey_point_historic','cadastre','survey_point_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.survey_point)','f',44);
insert into system.consolidation_config values('cadastre.spatial_value_area_historic','cadastre','spatial_value_area_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_value_area)','f',45);
insert into system.consolidation_config values('cadastre.spatial_unit_address_historic','cadastre','spatial_unit_address_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit_address)','f',46);
insert into system.consolidation_config values('source.spatial_source_measurement_historic','source','spatial_source_measurement_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_source_measurement)','f',47);
insert into system.consolidation_config values('source.spatial_source_historic','source','spatial_source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_source)','t',48);
insert into system.consolidation_config values('administrative.source_describes_rrr_historic','administrative','source_describes_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.source_describes_rrr)','f',49);
insert into system.consolidation_config values('administrative.rrr_historic','administrative','rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.rrr)','f',50);
insert into system.consolidation_config values('administrative.required_relationship_baunit_historic','administrative','required_relationship_baunit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.required_relationship_baunit)','f',51);
insert into system.consolidation_config values('source.power_of_attorney_historic','source','power_of_attorney_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.power_of_attorney)','t',52);
insert into system.consolidation_config values('party.party_role_historic','party','party_role_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party_role)','t',53);
insert into system.consolidation_config values('party.party_member_historic','party','party_member_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party_member)','t',54);
insert into system.consolidation_config values('administrative.party_for_rrr_historic','administrative','party_for_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party_for_rrr)','f',55);
insert into system.consolidation_config values('cadastre.legal_space_utility_network_historic','cadastre','legal_space_utility_network_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.legal_space_utility_network)','f',56);
insert into system.consolidation_config values('party.group_party_historic','party','group_party_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.group_party)','t',57);
insert into system.consolidation_config values('administrative.condition_for_rrr_historic','administrative','condition_for_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.condition_for_rrr)','f',58);
insert into system.consolidation_config values('cadastre.cadastre_object_historic','cadastre','cadastre_object_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.cadastre_object)','f',59);
insert into system.consolidation_config values('administrative.ba_unit_target_historic','administrative','ba_unit_target_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit_target)','f',60);
insert into system.consolidation_config values('administrative.ba_unit_contains_spatial_unit_historic','administrative','ba_unit_contains_spatial_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit_contains_spatial_unit)','f',61);
insert into system.consolidation_config values('administrative.ba_unit_area_historic','administrative','ba_unit_area_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit_area)','f',62);
insert into system.consolidation_config values('source.archive_historic','source','archive_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.archive)','t',63);
insert into system.consolidation_config values('application.application_property_historic','application','application_property_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application_property)','f',64);
insert into system.consolidation_config values('application.application_historic','application','application_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application)','f',65);
insert into system.consolidation_config values('transaction.transaction_source_historic','transaction','transaction_source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.transaction_source)','f',66);
insert into system.consolidation_config values('transaction.transaction_historic','transaction','transaction_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.transaction)','f',67);
insert into system.consolidation_config values('cadastre.spatial_unit_in_group_historic','cadastre','spatial_unit_in_group_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit_in_group)','f',68);
insert into system.consolidation_config values('cadastre.spatial_unit_group_historic','cadastre','spatial_unit_group_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit_group)','f',69);
insert into system.consolidation_config values('cadastre.spatial_unit_historic','cadastre','spatial_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.spatial_unit)','f',70);
insert into system.consolidation_config values('administrative.source_describes_ba_unit_historic','administrative','source_describes_ba_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.source_describes_ba_unit)','f',71);
insert into system.consolidation_config values('application.service_historic','application','service_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.service)','f',72);
insert into system.consolidation_config values('administrative.rrr_share_historic','administrative','rrr_share_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.rrr_share)','f',73);
insert into system.consolidation_config values('party.party_historic','party','party_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.party)','t',74);
insert into system.consolidation_config values('administrative.notation_historic','administrative','notation_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.notation)','f',75);
insert into system.consolidation_config values('administrative.mortgage_isbased_in_rrr_historic','administrative','mortgage_isbased_in_rrr_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.mortgage_isbased_in_rrr)','f',76);
insert into system.consolidation_config values('document.document_historic','document','document_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.document)','t',77);
insert into system.consolidation_config values('cadastre.cadastre_object_target_historic','cadastre','cadastre_object_target_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.cadastre_object_target)','f',78);
insert into system.consolidation_config values('cadastre.cadastre_object_node_target_historic','cadastre','cadastre_object_node_target_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.cadastre_object_node_target)','f',79);
insert into system.consolidation_config values('administrative.ba_unit_historic','administrative','ba_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.ba_unit)','f',80);
insert into system.consolidation_config values('application.application_uses_source_historic','application','application_uses_source_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application_uses_source)','f',81);
insert into system.consolidation_config values('application.application_spatial_unit_historic','application','application_spatial_unit_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.application_spatial_unit)','f',82);
insert into system.consolidation_config values('address.address_historic','address','address_historic','Every record that references a record in the main table in consolidation schema.','rowidentifier in (select rowidentifier from consolidation.address)','f',83);

CREATE OR REPLACE FUNCTION system.get_text_from_schema(
  schema_name varchar -- Schema name to backup
)
  RETURNS text AS
$BODY$
DECLARE
  table_rec record;
  sql_to_run varchar;
  total_script varchar;
  sql_part varchar;
  new_line_command varchar;
  new_line_values varchar;
BEGIN
  
  total_script = '';
  
  -- Delimiter to separate commands from each other
  new_line_command = '#$#$#';
  -- Delimiter to separate records of data 
  new_line_values = '#$#';
  
  -- Drop schema if exists.
  sql_part = 'DROP SCHEMA IF EXISTS ' || schema_name || ' CASCADE';        
  total_script = sql_part;  
  
  -- Make the schema empty.
  sql_part = 'CREATE SCHEMA ' || schema_name;
  total_script = total_script || new_line_command || sql_part;  
  
  -- Loop through all tables in the schema
  for table_rec in select table_name from information_schema.tables where table_schema = schema_name loop

    -- Make the create statement for the table
    sql_part = (select 'create table ' || schema_name || '.' || table_rec.table_name || '(' 
      || string_agg('  ' || col_definition, ',') || ')'
    from (select column_name || ' ' 
      || udt_name 
      || coalesce('(' || character_maximum_length || ')', '') 
        || case when udt_name = 'numeric' then '(' || numeric_precision || ',' || numeric_scale  || ')' else '' end as col_definition
      from information_schema.columns
      where table_schema = schema_name and table_name = table_rec.table_name
      order by ordinal_position) as cols);
    total_script = total_script || new_line_command || sql_part;

    -- Get the select columns from the source.
    sql_to_run = (select string_agg(col_definition, ' || '','' || ')
      from (select 
        case 
          when udt_name in ('bpchar', 'varchar') then 'quote_nullable(' || column_name || ')'
          when udt_name in ('date', 'bool', 'timestamp', 'geometry', 'bytea') then 'quote_nullable(' || column_name || '::text)'
          else column_name 
        end as col_definition
       from information_schema.columns
       where table_schema = schema_name and table_name = table_rec.table_name
       order by ordinal_position) as cols);

    -- Add the function to concatenate all rows with the delimiter
    sql_to_run = 'string_agg(' || sql_to_run || ', ''' || new_line_values || ''')';

    -- Add the insert part in the beginning of the dump of the table
    sql_to_run = '''insert into ' || schema_name || '.' || table_rec.table_name || new_line_values || ''' || ' || sql_to_run;

    -- Move the data to the consolidation schema.
    sql_to_run = 'select ' || sql_to_run || ' from ' ||  schema_name || '.' || table_rec.table_name;
    raise notice '%', sql_to_run;

    -- Get the rows 
    execute sql_to_run into sql_part;
    if sql_part is not null then
      total_script = total_script || new_line_command || sql_part;    
    end if;

  end loop;

  return total_script;
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.get_text_from_schema(character varying) IS 'It generates from a schema a coded script. It is used for backing up a schema.';

CREATE OR REPLACE FUNCTION system.consolidation_extract(
  admin_user varchar -- The id of the user running the consolidation
)
  RETURNS text AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar;
  sql_to_run varchar;
  order_of_exec int;
BEGIN

  -- Set constants.
  consolidation_schema = 'consolidation';
  
  -- Make sola not accessible from all other users except the user running the consolidation.
  update system.appuser set active = false where id != admin_user;
  
  -- Drop schema consolidation if exists.
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
      
  -- Make the schema.
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  
  --Make table to define configuration for the the consolidation to the target database.
  execute 'create table ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';

  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'create table ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name;

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then
      
      sql_to_run = sql_to_run || ' where ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute sql_to_run;

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    order_of_exec = order_of_exec + 1;
  end loop;

  -- Set the status of all services of type 'recordTransfer' to 'completed'
  update application.service set status_code = 'completed', change_user = admin_user 
  where id in (select id from consolidation.service where request_type_code = 'recordTransfer' and status_code in ('lodged', 'requisitioned'));
  
  -- Make sola accessible from all users.
  update system.appuser set active = false where id != admin_user;

  return system.get_text_from_schema(consolidation_schema);
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.consolidation_extract(character varying) IS 'This function is used to extract in a script the consolidated records that are marked to be transferred.';

CREATE OR REPLACE FUNCTION system.script_to_schema(extraction_script text)
  RETURNS varchar AS
$BODY$
DECLARE
  rec record;
  rec_inside record;
  new_line_command varchar;
  new_line_values varchar;
  insert_into_part varchar;
BEGIN

  new_line_command = '#\$#\$#';
  new_line_values = '#\$#';
  
  -- Loop through all commands found in the script
  for rec in select cmd from regexp_split_to_table(extraction_script, new_line_command) AS cmd loop
    if rec.cmd like 'insert into %' then
      -- It is an insert into command start. Check for rows and make the insert statement.
      insert_into_part = '';
      for rec_inside in SELECT cmd from regexp_split_to_table(rec.cmd, new_line_values) AS cmd loop
        if insert_into_part = '' then 
          insert_into_part = rec_inside.cmd;
        else
          execute insert_into_part || ' values(' || rec_inside.cmd || ')';
        end if;
      end loop;
    else
      -- It is a valid standalone sql command.
      execute rec.cmd;
    end if;
  end loop;
  return 't';
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.script_to_schema(text) IS 'This function is used to convert a coded script to a schema.';

CREATE OR REPLACE FUNCTION system.consolidation_consolidate(
  admin_user varchar -- The id of the user running the consolidation
)
  RETURNS varchar AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar;
  cols varchar;
  log varchar;
  new_line varchar;
  
BEGIN
  
  new_line = '
';
  log = '-------------------------------------------------------------------------------------------';
  -- It is presumed that the consolidation schema is already present.

  -- Set constants.
  consolidation_schema = 'consolidation';

  log = log || new_line || 'making users inactive...';
  -- Make sola not accessible from all other users except the user running the consolidation.
  update system.appuser set active = false where id != admin_user;
  log = log || 'done.' || new_line;

  -- Disable triggers.
  log = log || new_line || 'disabling all triggers...';
  perform fn_triggerall(false);
  log = log || 'done.' || new_line;

  -- For each table that is extracted and that has rows, insert the records into the main tables.
  for table_rec in select * from consolidation.config order by order_of_execution loop

    log = log || new_line || 'loading records from table "' || table_rec.source_table_name || '" to table "' || table_rec.target_table_name || '"... ' ;
    if table_rec.remove_before_insert then
      log = log || new_line || '    deleting matching records in target table ...';
      execute 'delete from ' || table_rec.target_table_name ||
      ' where rowidentifier in (select rowidentifier from ' || table_rec.source_table_name || ')';
      log = log || 'done.' || new_line;
    end if;
    cols = (select string_agg(column_name, ',')
      from information_schema.columns
      where table_schema || '.' || table_name = table_rec.target_table_name);

    log = log || new_line || '    inserting records to target table ...';
    execute 'insert into ' || table_rec.target_table_name || '(' || cols || ') select ' || cols || ' from ' || table_rec.source_table_name;
    log = log || 'done.' || new_line;
    log = log || 'table loaded.'  || new_line;
    
  end loop;
  
  -- Enable triggers.
  log = log || new_line || 'enabling all triggers...';
  perform fn_triggerall(true);
  log = log || 'done.' || new_line;

  -- Make sola accessible for all users.
  log = log || new_line || 'making users active...';
  update system.appuser set active = true where id != admin_user;
  log = log || 'done.' || new_line;
  log = log || 'Finished with success!';
  log = log || new_line || '-------------------------------------------------------------------------------------------';

  return log;
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.consolidation_consolidate(character varying) IS 'It moves the records from the temporary consolidation schema to the main tables.';

-- #388 Business Rule - False Failure - Convert to Digital Title service completion 
UPDATE "system".br_definition
   SET body='SELECT coalesce(not rrr.is_primary, true) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} 
AND ba.status_code != ''pending''
order by 1 desc
limit 1'
 WHERE br_id= 'service-check-no-previous-digital-title-service';


