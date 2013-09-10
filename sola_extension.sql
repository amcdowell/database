-- Script to extend sola.sql. It should be run immediately at the completion of sola.sql. 

-- #328 - Security Role Overhaul. Fixed the description for each security role, removed roles that were  
-- not used and added some extra roles required for recent changes to the application.  
DELETE FROM system.approle_appgroup;
DELETE FROM system.approle; 
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ManageBR', 'Admin - Business Rules', 'c', 'Allows system administrators to manage (edit and save) business rules.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ManageBR');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ChangePassword', 'Admin - Change Password', 'c', 'Allows a user to change their password and edit thier user name. This role should be included in every security group. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ChangePassword');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'NoPasswordExpiry', 'Admin - No Password Expiry', 'c', 'Users with this role will not be subject to a password expiry if one is in place. This role can be assigned to user accounts used by other systems to integrate with the SOLA web services. Note that password expiry can be configured using the pword-expiry-days system.setting'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'NoPasswordExpiry');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ManageRefdata', 'Admin - Reference Data', 'c', 'Allows system administrators to manage (edit and save) reference data details.  Users with this role will be able to login to the SOLA Admin application. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ManageRefdata');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ManageSettings', 'Admin - System Settings', 'c', 'Allows system administrators to manage (edit and save) system setting details. Users with this role will be able to login to the SOLA Admin application. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ManageSettings');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ManageSecurity', 'Admin - Users and Security', 'c', 'Allows system administrators to manage (edit and save) users, groups and roles. Users with this role will be able to login to the SOLA Admin application. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ManageSecurity');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnAssignOthers', 'Application - Assign to Other Users', 'c', 'Allows a user to assign an application to any other user in the same security groups they are in. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnAssignOthers');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnAssignSelf', 'Application - Assign to Self', 'c', 'Allows a user to assign an application to themselves.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnAssignSelf');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnEdit', 'Application - Edit & Save', 'c', 'Allows application details to be edited and saved. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnEdit');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnCreate', 'Application - Lodge', 'c', 'Allows new application details to be created (lodged). '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnCreate');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnView', 'Application - Search & View', 'c', 'Allows users to search and view application details.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnView');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnStatus', 'Application - Status Report', 'c', 'Allows the user to print a status report for the application.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnStatus');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnUnassignOthers', 'Application - Unassign from Others', 'c', 'Allows the user to unassign an application from any user. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnUnassignOthers');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnUnassignSelf', 'Application - Unassign from Self', 'c', 'Allows a user to unassign an application from themselves. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnUnassignSelf');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnApprove', 'Appln Action - Approval', 'c', 'Required to perform the Approve applicaiton action. The Approve action transitions the application into the Approved state. 
All services on the application must be completed before this action is available. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnApprove');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnArchive', 'Appln Action - Archive', 'c', 'Required to perform the Archive applicaiton action. The Archive action transitions the application into the Completed state.  '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnArchive');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnReject', 'Appln Action - Cancel', 'c', 'Required to perform the Cancel applicaiton action. The Cancel action transitions the application into the Annulled state.  '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnReject');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnDispatch', 'Appln Action - Dispatch', 'c', 'Required to perform the Dispatch application action. Used to indicate that documents have been dispatched to applicant along with any certificates/reports/map prints requested by applicant'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnDispatch');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnRequisition', 'Appln Action - Requisition', 'c', 'Required to perform the Requisition applicaiton action. The Requisition action transitions the application into the Requisitioned state. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnRequisition');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnResubmit', 'Appln Action - Resubmit', 'c', 'Required to perform the Resubmit applicaiton action. The Resubmit action transitions the application into the Lodged state if it is currently On Hold. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnResubmit');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnValidate', 'Appln Action - Validate', 'c', 'Required to perform the Validate applicaiton action. Allows the user to manually run the validation rules against the application. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnValidate');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ApplnWithdraw', 'Appln Action - Withdraw', 'c', 'Required to perform the Withdraw applicaiton action. The Withdraw action transitions the application into the Annulled state.  '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnWithdraw');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'BulkApplication', 'Bulk Operations - Login ', 'c', 'Allows the user to login and use the Bulk Operations application. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'BulkApplication');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'DashbrdViewAssign', 'Dashboard - View Assigned', 'c', 'Allows the user to view applications assigned to them in the Dashboard. To hide the Dashboard from the user, remove both this role and the Dashboard - View Unassigned role. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'DashbrdViewAssign');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'DashbrdViewUnassign', 'Dashboard - View Unassigned', 'c', 'Allows the user to view all unassigned applications in the Dashboard. To hide the Dashboard from the user, remove both this role and the Dashboard - View Assigned role. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'DashbrdViewUnassign');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'TransactionCommit', 'Doc Registration - Save', 'c', 'Allows documents for registration such as Power of Attorney and Standard Documents to be saved on the Document Registration screen. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'TransactionCommit');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'SourcePrint', 'Document - Print', 'c', 'Allows users to print documents directly from SOLA. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'SourcePrint');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'SourceSave', 'Document - Save', 'c', 'Allows document details to be edited and saved'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'SourceSave');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'SourceSearch', 'Document - Search & View', 'c', 'Allows users to search for documents.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'SourceSearch');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ExportMap', 'Map - KML Export', 'c', 'Allows the user to export selected features from the map as KML.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ExportMap');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'PrintMap', 'Map - Print', 'c', 'Allows the user to create printouts from the Map'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'PrintMap');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ViewMap', 'Map - View', 'c', 'Allows the user to view the map. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ViewMap');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ParcelSave', 'Parcel - Edit & Save', 'c', 'Allows parcel details to be edited and saved.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ParcelSave');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'PartySave', 'Party - Edit & Save', 'c', 'Allows party details to be edited and saved unless the party is a rightholder. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'PartySave');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'RHSave', 'Party - Save Rightholder', 'c', 'Allows parties that are rightholders to be edited and saved.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'RHSave');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'PartySearch', 'Party - Search & View', 'c', 'Allows user to search and view party details.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'PartySearch');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'BaunitSave', 'Property - Edit & Save', 'c', 'Allows property details to be edited and saved.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'BaunitSave');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'BaunitCertificate', 'Property - Print Certificate', 'c', 'Allows the user to generate a property certificate. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'BaunitCertificate');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'BaunitSearch', 'Property - Search', 'c', 'Allows users to search for properties. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'BaunitSearch');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'ReportGenerate', 'Reporting - Management Reports', 'c', 'Allows users to generate and view management reports (e.g. Lodgement Report)'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ReportGenerate');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'RightsExport', 'Reporting - Rights Export', 'c', 'Allows user to export rights informaiton into CSV format.  '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'RightsExport');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'cadastrePrint', 'Service - Cadastre Print', 'c', 'Supporting Service. Allows the Cadastre Print service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'cadastrePrint');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'cnclPowerOfAttorney', 'Service - Cancel Power of Attorney', 'c', 'Registration Service. Allows the Cancel Power of Attorney service to be started'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'cnclPowerOfAttorney');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'cancelProperty', 'Service - Cancel Title', 'c', 'Lease Service. Allows the Cancel Title to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'cancelProperty');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'newOwnership', 'Service - Chance of Ownership', 'c', 'Registration Service. Allows the Change of Ownership service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'newOwnership');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'cadastreChange', 'Service - Change to Cadastre', 'c', 'Survey Service. Allows the Change to Cadastre service to be started'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'cadastreChange');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'newDigitalTitle', 'Service - Convert Title', 'c', 'Registration Service. Allows the Convert Title service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'newDigitalTitle');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'documentCopy', 'Service - Document Copy', 'c', 'Supporting Service. Allows the Document Copy service to be started.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'documentCopy');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'newFreehold', 'Service - Freehold Title', 'c', 'Registration Service. Allows the Freehold Title service to be started.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'newFreehold');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'lodgeObjection', 'Service - Lodge Objection', 'c', 'Systematic Registration Service. Allows the Lodge Objection service to be started.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'lodgeObjection');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'newApartment', 'Service - New Apartment Title', 'c', 'Registration Service. Allows the New Apartment Title service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'newApartment');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'redefineCadastre', 'Service - Redefine Cadastre', 'c', 'Survey Service. Allows the Redefine Cadastre service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'redefineCadastre');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'buildingRestriction', 'Service - Register Building Restriction', 'c', 'Registration Service. Allows the Register Building Restriction service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'buildingRestriction');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'caveat', 'Service - Register Caveat', 'c', 'Registration Service. Allows the Register Caveat service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'caveat');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'historicOrder', 'Service - Register Historic Preservation Order', 'c', 'Registration Service. Allows the Register Historic Preservation Order service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'historicOrder');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'registerLease', 'Service - Register Lease', 'c', 'Registration Service. Allows the Register Lease service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'registerLease');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'limtedRoadAccess', 'Service - Register Limited Road Access', 'c', 'Registration Service. Allows the Register Limited Road Access service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'limtedRoadAccess');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'mortgage', 'Service - Register Mortgage', 'c', 'Registration Service. Allows the Register Mortgage service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'mortgage');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'servitude', 'Service - Register Servitude', 'c', 'Registration Service. Allows the Register Servitude service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'servitude');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'regnPowerOfAttorney', 'Service - Registration of Power of Attorney', 'c', 'Registration Service. Allows the Registration of Power of Attorney service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'regnPowerOfAttorney');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'regnStandardDocument', 'Service - Registration of Standard Document', 'c', 'Registration Service. Allows the Register of Standard Document service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'regnStandardDocument');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'regnOnTitle', 'Service - Registration on Title', 'c', 'Registration Service. Allows the Registration on Title service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'regnOnTitle');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'removeCaveat', 'Service - Remove Caveat', 'c', 'Registration Service. Allows the Remove Caveat service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'removeCaveat');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'removeRestriction', 'Service - Remove Restriction', 'c', 'Registration Service. Allows the Remove Restriction service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'removeRestriction');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'removeRight', 'Service - Remove Right (General)', 'c', 'Registration Service. Allows the Remove Right (General) service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'removeRight');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'serviceEnquiry', 'Service - Service Enquiry', 'c', 'Supporting Service. Allow the Service Enquiry service to be started.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'serviceEnquiry');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'surveyPlanCopy', 'Service - Survey Plan Copy', 'c', 'Supporting Service. Allows the Survey Plan Copy service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'surveyPlanCopy');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'systematicRegn', 'Service - Systematic Registration Claim', 'c', 'Systematic Registration Service - Allows the Systematic Registration Claim service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'systematicRegn');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'titleSearch', 'Service - Title Search', 'c', 'Supporting Service. Allows the Title Search service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'titleSearch');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'varyCaveat', 'Service - Vary Caveat', 'c', 'Registration Service. Allows the Vary Caveat service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'varyCaveat');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'varyLease', 'Service - Vary Lease', 'c', 'Registration Service. Allows the Vary Lease service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'varyLease');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'varyMortgage', 'Service - Vary Mortgage', 'c', 'Registration Service. Allows the Vary Mortgage service to be started.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'varyMortgage');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'varyRight', 'Service - Vary Right (General)', 'c', 'Registration Service. Allows the Vary Right (General) service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'varyRight');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'cnclStandardDocument', 'Service - Withdraw Standard Document', 'c', 'Registration Service. Allows the Withdraw Standard Document service to be started. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'cnclStandardDocument');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'CancelService', 'Service Action - Cancel', 'c', 'Allows any service to be cancelled.'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'CancelService');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'CompleteService', 'Service Action - Complete', 'c', 'Allows any service to be completed'
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'CompleteService');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'RevertService', 'Service Action - Revert', 'c', 'Allows any completed service to be reverted to a Pending status for further action. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'RevertService');
INSERT INTO system.approle (code, display_value, status, description)
   SELECT 'StartService', 'Service Action - Start', 'c', 'Allows any user to click the Start action. Note that the user must also have the appropraite Service role as well before they can successfully start the service. '
   WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'StartService');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id)
SELECT code, 'super-group-id' 
FROM system.approle
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup
                  WHERE  approle_code = code
				  AND    appgroup_id = 'super-group-id' ); 



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

  
