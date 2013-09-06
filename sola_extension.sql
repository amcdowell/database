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
  
