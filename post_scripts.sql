 -- Data for the table cadastre.level -- 
insert into cadastre.level(id, name, register_type_code, structure_code, type_code) values('cadastreObject', 'Cadastre object', 'all', 'polygon', 'primaryRight');

 -- Data for the table application.request_type_requires_source_type -- 
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('cadastralSurvey', 'cadastreChange');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('cadastralSurvey', 'redefineCadastre');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('mortgage', 'varyMortgage');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'varyMortgage');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'regnOnTitle');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'regnDeeds');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('lease', 'registerLease');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('powerOfAttorney', 'regnPowerOfAttorney');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('standardDocument', 'regnStandardDocument');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'noteOccupation');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'noteOccupation');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'usufruct');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'waterRights');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('mortgage', 'mortgage');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'buildingRestriction');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'servitude');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'lifeEstate');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'lifeEstate');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'newApartment');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'newState');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'caveat');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'removeCaveat');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'removeCaveat');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'historicOrder');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'limitedRoadAccess');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('lease', 'varyLease');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'varyLease');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'varyRight');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'varyRight');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'removeRight');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'removeRight');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'removeRestriction');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('title', 'removeRestriction');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'cnclPowerOfAttorney');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('deed', 'cnclStandardDocument');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('caveat', 'caveat');

 -- Data for the table system.appgroup -- 
insert into system.appgroup(id, name, description) values('super-group-id', 'Super group', 'This is a group of users that has right in anything. It is used in developement. In production must be removed.');

 -- Data for the table system.appuser -- 
insert into system.appuser(id, username, first_name, last_name, passwd, active) values('test-id', 'test', 'Test', 'The BOSS', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true);

 -- Data for the table system.appuser_appgroup -- 
insert into system.appuser_appgroup(appuser_id, appgroup_id) values('test-id', 'super-group-id');

insert into system.approle_appgroup (approle_code, appgroup_id)
SELECT r.code, 'super-group-id' FROM system.approle r
where r.code not in (select approle_code from system.approle_appgroup g where appgroup_id = 'super-group-id');