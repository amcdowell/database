SET client_encoding = 'UTF8';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('ba_unit-has-several-mortgages-with-same-rank', 'sql', 'The rank of a new mortgage must not be the same as an existing mortgage registered on the same title::::Рейтинг новой ипотеки не должен быть таким же как у существующей ипотеки для данной недвижимости.::::رتبة الرهن يجب ان لا تساوي نفس رتبة الرهن  الحالي::::Le rang de la nouvelle hypothèque ne doit pas être le même qu''une hypothèque existante enregistrée sur le même titre.', '#{id}(administrative.rrr.id) is requested.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('ba_unit-has-several-mortgages-with-same-rank', now(), 'infinity', 'WITH	simple	AS	(SELECT rr1.id, rr1.nr FROM administrative.rrr rr1
				INNER JOIN administrative.ba_unit ba1 ON (rr1.ba_unit_id = ba1.id)
				INNER JOIN administrative.rrr rr2 ON ((ba1.id = rr2.ba_unit_id) AND (rr1.mortgage_ranking = rr2.mortgage_ranking))
			WHERE rr2.id = #{id}
			AND rr1.type_code = ''mortgage''
			AND rr1.status_code = ''current''
			AND (rr1.mortgage_ranking = rr2.mortgage_ranking)),
	complex	AS	(SELECT rr3.id, rr3.nr FROM administrative.rrr rr3
				INNER JOIN administrative.ba_unit ba2 ON (rr3.ba_unit_id = ba2.id)
				INNER JOIN administrative.rrr rr4 ON (ba2.id = rr4.ba_unit_id)
			WHERE rr4.id = #{id}
			AND rr3.type_code = ''mortgage''
			AND rr3.status_code != ''current''
			AND rr3.mortgage_ranking = rr4.mortgage_ranking
			AND rr3.nr IN (SELECT nr FROM simple))

SELECT CASE 	WHEN	((SELECT rr5.id FROM administrative.rrr rr5 WHERE rr5.id = #{id} AND rr5.type_code = ''mortgage'') IS NULL) THEN NULL
		WHEN 	(SELECT (COUNT(*) = 0) FROM simple) THEN TRUE
		WHEN 	(((SELECT COUNT(*) FROM simple) - (SELECT COUNT(*) FROM complex) = 0)) THEN TRUE
		ELSE	FALSE
	END AS vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('ba_unit-has-several-mortgages-with-same-rank', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 170);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('rrr-must-have-parties', 'sql', 'These rights (and restrictions) must have a recorded party (or parties)::::Данные права (или ограничения) должны иметь правообладателей.::::هذه الحقوق او القيود يجب ان يكون عليها اطراف معرفون::::Ces droits (et restrictions) doivent avoir une partie ou des parties enregistrées', '');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('rrr-must-have-parties', now(), 'infinity', 'select count(*) = 0 as vl
from administrative.rrr r
where r.id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('rrr-must-have-parties', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 110);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('rrr-has-pending', 'sql', 'There are no other pending actions on the rights and restrictions being changed or removed on this application::::Нет никаких изменений в правах и ограничениях, сделанных из текущего заявления::::لا يوجد حركات بحاجة لتنفيذ على الحقوق او القيود لهذا الطلب::::Il n''y a pas d''autre actions en attente sur les droits et restrictions en cours de changement ou supprimé de cette application.', '#{id}(administrative.rrr.id) is requested. It checks if for the target rrr there is already a pending edit or record.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('rrr-has-pending', now(), 'infinity', 'select count(*) = 0 as vl
from administrative.rrr rrr1 inner join administrative.rrr rrr2 on (rrr1.ba_unit_id, rrr1.nr) = (rrr2.ba_unit_id, rrr2.nr)
where rrr1.id = #{id} and rrr2.id!=rrr1.id and rrr2.status_code = ''pending''
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('rrr-has-pending', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 290);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('rrr-shares-total-check', 'sql', 'The sum of the shares (in ownership rights) must total to 1::::Сумма долей права собственности должна ровняться 1.::::مجموع الحصص في اصحاب الحقوق يجب ان يساوي واحد صحيح::::La somme des parts (du droit de propriété) doit être égale à 1.', '#{id}(administrative.rrr.id) is requested');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('rrr-shares-total-check', now(), 'infinity', 'SELECT (SUM(nominator::DECIMAL/denominator::DECIMAL)*10000)::INT = 10000  AS vl
FROM   administrative.rrr_share 
WHERE  rrr_id = #{id}
AND    denominator != 0');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('rrr-shares-total-check', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 40);

----------------------------------------------------------------------------------------------------

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES ('ba_unit-has-caveat', 'sql', 'Caveat should not prevent registration proceeding.::::Арест не должен ограничивать дальнейшую регистрацию.::::القيود لا يجب ان تعطل عملية التسجيل::::Un caveat ne doit pas empêcher de procéder à l''enregistrement.', '#{id}(administrative.rrr.id) is requested.');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES ('ba_unit-has-caveat', now(), 'infinity', 'WITH caveatCheck AS	(SELECT COUNT(*) AS present FROM administrative.rrr rr2 
				 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id)
				 INNER JOIN administrative.rrr rr1 ON ((ba.id = rr1.ba_unit_id) AND (rr1.type_code = ''caveat'') AND (rr1.status_code IN (''pending'', ''current'')))
			 WHERE rr2.id = #{id}
			 ORDER BY 1
			 LIMIT 1),
    changeCheck AS	(SELECT (COUNT(*) > 0) AS caveatChange FROM administrative.rrr rr2 
				 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id)
				 INNER JOIN administrative.rrr rr3 ON ((ba.id = rr3.ba_unit_id) AND (rr3.type_code = ''caveat'') AND (rr3.status_code = ''current''))
				 INNER JOIN transaction.transaction tn ON (rr3.transaction_id = tn.id)
				 INNER JOIN application.service sv1 ON ((tn.from_service_id = sv1.id) AND sv1.request_type_code IN (''varyCaveat'', ''removeCaveat'') AND sv1.status_code IN (''lodged'', ''pending''))
			 WHERE rr2.id = #{id}),
	varyCheck AS 	(SELECT ((SELECT present FROM caveatCheck) - (SELECT SUM(1) FROM (SELECT DISTINCT ON (rr4.nr) rr4.nr FROM administrative.rrr rr2 
									 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id) 
									 INNER JOIN administrative.rrr rr3 ON ((ba.id = rr3.ba_unit_id) AND (rr3.type_code = ''caveat'') AND (rr3.status_code = ''current''))
									 INNER JOIN transaction.transaction tn ON (rr3.transaction_id = tn.id) 
									 INNER JOIN application.service sv1 ON ((tn.from_service_id = sv1.id) AND (sv1.request_type_code = ''varyCaveat''))
									 INNER JOIN administrative.rrr rr4 ON ((ba.id = rr4.ba_unit_id) AND (rr3.nr = rr4.nr))
								WHERE rr2.id = #{id}) AS vary) = 0) AS withoutVary), 
     caveatRegn AS	(SELECT (COUNT(*) > 0) AS caveat FROM administrative.rrr rr4
				 INNER JOIN transaction.transaction tn ON ((rr4.transaction_id = tn.id)	AND (rr4.status_code IN (''pending'', ''current'')) AND (rr4.type_code = ''caveat''))
				 INNER JOIN application.service sv2 ON (tn.from_service_id = sv2.id)
			WHERE rr4.id = #{id}
			AND (SELECT (COUNT(*) = 0) FROM application.service sv3 WHERE ((sv3.application_id = sv2.application_id) AND (sv3.status_code != ''cancelled'') AND (sv3.request_type_code NOT IN (''caveat'', ''varyCaveat'', ''removeCaveat''))))
			ORDER BY 1
			LIMIT 1)
			
SELECT (SELECT	CASE 	WHEN (SELECT caveat FROM caveatRegn) THEN TRUE
			WHEN (SELECT caveatChange FROM changeCheck) THEN TRUE
			WHEN (SELECT withoutVary FROM varyCheck) THEN TRUE
			WHEN (SELECT (present = 0) FROM caveatCheck)THEN NULL
			WHEN (SELECT (present > 0) FROM caveatCheck) THEN FALSE
			ELSE TRUE
		END) AS vl');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) 
VALUES ('ba_unit-has-caveat', 'rrr', NULL, NULL, 'current', NULL, NULL, 'critical', 30);

----------------------------------------------------------------------------------------------------

update system.br set display_name = id where display_name !=id;
