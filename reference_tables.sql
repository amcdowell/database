INSERT INTO administrative.ba_unit_rel_type (code, display_value, description, status) 
VALUES ('priorTitle', 'Prior Title::::::::Предыдущая недвижимость', 'Prior Title::::::::Предыдущая недвижимость', 'c');

INSERT INTO administrative.ba_unit_rel_type (code, display_value, description, status) 
VALUES ('rootTitle', 'Root of Title::::::::Корневая недвижимость', 'Root of Title::::::::Корневая недвижимость', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO administrative.ba_unit_type (code, display_value, description, status) 
VALUES ('basicPropertyUnit', 'Basic Property Unit::::Unita base Proprieta::::Базовая единица недвижимости', 'This is the basic property unit that is used by default::::::::Это базовая единица недвижимости используемая по умолчанию', 'c');

INSERT INTO administrative.ba_unit_type (code, display_value, description, status) 
VALUES ('leasedUnit', 'Leased Unit::::Unita Affitto::::Единица для Аренды', '', 'x');

INSERT INTO administrative.ba_unit_type (code, display_value, description, status) 
VALUES ('propertyRightUnit', 'Property Right Unit::::Unita Diritto Proprieta::::Единица права недвижимости', '', 'x');

INSERT INTO administrative.ba_unit_type (code, display_value, description, status) 
VALUES ('administrativeUnit', 'Administrative Unit::::::::Административная единица', '', 'x');

----------------------------------------------------------------------------------------------------

INSERT INTO administrative.condition_type (code, display_value, description, status) 
VALUES ('c1', 'Condition 1::::::::Условие 1', 'Unless the Minister directs otherwise the Lessee shall fence the boundaries of the land within 6 (six) months of the date of the grant and the Lessee shall maintain the fence to the satisfaction of the Commissioner.::::::::Unless the Minister directs otherwise the Lessee shall fence the boundaries of the land within 6 (six) months of the date of the grant and the Lessee shall maintain the fence to the satisfaction of the Commissioner.', 'c');

INSERT INTO administrative.condition_type (code, display_value, description, status) 
VALUES ('c5', 'Condition 5::::::::Условие 5', 'Save with the written authority of the planning authority, no electrical power or telephone pole or line or water, drainage or sewer pipe being upon or passing through, over or under the land and no replacement thereof, shall be moved or in any way be interfered with and reasonable access thereto shall be preserved to allow for inspection, maintenance, repair, renewal and replacement.::::::::Save with the written authority of the planning authority, no electrical power or telephone pole or line or water, drainage or sewer pipe being upon or passing through, over or under the land and no replacement thereof, shall be moved or in any way be interfered with and reasonable access thereto shall be preserved to allow for inspection, maintenance, repair, renewal and replacement.', 'c');

INSERT INTO administrative.condition_type (code, display_value, description, status) 
VALUES ('c3', 'Condition 3::::::::Условие 3', 'Within a period of the time to be fixed by the planning authority, the Lessee shall provide at his own expense main drainage or main sewerage connections from the building erected on the land as the planning authority may require.::::::::Within a period of the time to be fixed by the planning authority, the Lessee shall provide at his own expense main drainage or main sewerage connections from the building erected on the land as the planning authority may require.', 'c');

INSERT INTO administrative.condition_type (code, display_value, description, status) 
VALUES ('c6', 'Condition 6::::::::Условие 6', 'The interior and exterior of any building erected on the land and all building additions thereto and all other buildings at any time erected or standing on the land and walls, drains and other appurtenances, shall be kept by the Lessee in good repair and tenantable condition to the satisfaction of the planning authority.::::::::The interior and exterior of any building erected on the land and all building additions thereto and all other buildings at any time erected or standing on the land and walls, drains and other appurtenances, shall be kept by the Lessee in good repair and tenantable condition to the satisfaction of the planning authority.', 'c');

INSERT INTO administrative.condition_type (code, display_value, description, status) 
VALUES ('c4', 'Condtion 4::::::::Условие 4', 'The Lessee shall use the land comprised in the lease only for the purpose specified in the lease or in any variation made to the original lease.::::::::The Lessee shall use the land comprised in the lease only for the purpose specified in the lease or in any variation made to the original lease.', 'c');

INSERT INTO administrative.condition_type (code, display_value, description, status) 
VALUES ('c2', 'Condition 2::::::::Условие 2', 'Unless special written authority is given by the Commissioner, the Lessee shall commence development of the land within 5 years of the date of the granting of a lease. This shall also apply to further development of the land held under a lease during the term of the lease.::::::::Unless special written authority is given by the Commissioner, the Lessee shall commence development of the land within 5 years of the date of the granting of a lease. This shall also apply to further development of the land held under a lease during the term of the lease.', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO administrative.mortgage_type (code, display_value, description, status) 
VALUES ('levelPayment', 'Level Payment::::Livello Pagamento::::Многоуровневый платеж', '', 'c');

INSERT INTO administrative.mortgage_type (code, display_value, description, status) 
VALUES ('linear', 'Linear::::Lineare::::Линейный', '', 'c');

INSERT INTO administrative.mortgage_type (code, display_value, description, status) 
VALUES ('microCredit', 'Micro Credit::::Micro Credito::::Микро кредит', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO administrative.rrr_group_type (code, display_value, description, status) 
VALUES ('rights', 'Rights::::Diritti::::Права', '', 'c');

INSERT INTO administrative.rrr_group_type (code, display_value, description, status) 
VALUES ('restrictions', 'Restrictions::::Restrizioni::::Ограничения', '', 'c');

INSERT INTO administrative.rrr_group_type (code, display_value, description, status) 
VALUES ('responsibilities', 'Responsibilities::::Responsabilita::::Ответственность', '', 'x');

----------------------------------------------------------------------------------------------------

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('superficies', 'rights', 'Superficies::::Superficie::::Superficies', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('customaryType', 'rights', 'Customary Right::::Diritto Abituale::::Традиционное право', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('lease', 'rights', 'Lease::::Affitto::::Аренда', 'f', 't', 't', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('waterwayMaintenance', 'responsibilities', 'Waterway Maintenance::::Mantenimento Acqurdotti::::Обслуживания каналов ирригации', 'f', 'f', 'f', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('ownership', 'rights', 'Ownership::::Proprieta::::Право собственности', 't', 't', 't', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('agriActivity', 'rights', 'Agriculture Activity::::Attivita Agricola::::Сельскохозяйственная деятельность', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('stateOwnership', 'rights', 'State Ownership::::Proprieta di Stato::::Государственное право собственности', 't', 'f', 'f', 'Extension to LADM::::::::Расширение LADM', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('occupation', 'rights', 'Occupation::::Occupazione::::Оккупация', 'f', 't', 't', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('servitude', 'restrictions', 'Servitude::::Servitu::::Сервитут', 'f', 'f', 'f', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('firewood', 'rights', 'Firewood Collection::::Collezione legna da ardere::::Сбор древисины', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('historicPreservation', 'restrictions', 'Historic Preservation::::Conservazione Storica::::Историческая резервация', 'f', 'f', 'f', 'Extension to LADM::::::::Расширение LADM', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('usufruct', 'rights', 'Usufruct::::Usufrutto::::Право использования для сбора урожая', 'f', 't', 't', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('adminPublicServitude', 'restrictions', 'Administrative Public Servitude::::Servitu  Amministrazione Pubblica::::Административный публичный сервитут', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('mortgage', 'restrictions', 'Mortgage::::Ipoteca::::Ипотека', 'f', 't', 't', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('ownershipAssumed', 'rights', 'Ownership Assumed::::Proprieta Assunta::::Принятое право собственности', 't', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('caveat', 'restrictions', 'Caveat::::Ammonizione::::Арест', 'f', 't', 't', 'Extension to LADM::::::::Расширение LADM', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('grazing', 'rights', 'Grazing Right::::Diritto di Pascolo::::Право выпаса', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('noBuilding', 'restrictions', 'Building Restriction::::Restrizione di Costruzione::::Ограничение на здание', 'f', 'f', 'f', '', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('apartment', 'rights', 'Apartment Ownership::::Proprieta Appartamento::::Право собственности на квартиру', 't', 't', 't', 'Extension to LADM::::::::Расширение LADM', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('tenancy', 'rights', 'Tenancy::::Locazione::::Арендаторство', 't', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('lifeEstate', 'rights', 'Life Estate::::Patrimonio vita::::Пожизненное право собственности', 't', 't', 't', 'Extension to LADM::::::::Расширение LADM', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('fishing', 'rights', 'Fishing Right::::Diritto di Pesca::::Рыболовное право', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('commonOwnership', 'rights', 'Common Ownership::::Proprieta Comune::::Общая собственность', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('limitedAccess', 'restrictions', 'Limited Access (to Road)::::Accesso limitato (su strada)::::Ограниченный доступ к дороге', 'f', 'f', 'f', 'Extension to LADM::::::::Расширение LADM', 'c');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('monumentMaintenance', 'responsibilities', 'Monument Maintenance::::Mantenimento Monumenti::::Обслуживание памятника', 'f', 'f', 'f', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('informalOccupation', 'rights', 'Informal Occupation::::Occupazione informale::::Неформальная оккупация', 'f', 'f', 'f', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('monument', 'restrictions', 'Monument::::Monumento::::Памятник', 'f', 't', 't', '', 'x');

INSERT INTO administrative.rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) 
VALUES ('waterrights', 'rights', 'Water Right::::Servitu di Acqua::::Право на водные ресурсы', 'f', 't', 't', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO application.service_action_type (code, display_value, status_to_set, status, description) 
VALUES ('cancel', 'Cancel::::Cancella la pratica::::Отмена', 'cancelled', 'c', 'Service is cancelled by Land Office (action is automatically logged when a service is cancelled)::::Pratica cancellata da Ufficio Territoriale::::Отмена услуги регистрационным офисом (отмена будет автоматически зафиксирована в журнале событий)');

INSERT INTO application.service_action_type (code, display_value, status_to_set, status, description) 
VALUES ('complete', 'Complete::::Completa::::Завершить', 'completed', 'c', 'Application is ready for approval (action is automatically logged when service is marked as complete::::Pratica pronta per approvazione::::Заявление готово к одобрению (событие будет автоматически записано в журнал событий)');

INSERT INTO application.service_action_type (code, display_value, status_to_set, status, description) 
VALUES ('revert', 'Revert::::Ripristino::::Вернуть на доработку', 'pending', 'c', 'The status of the service has been reverted to pending from being completed (action is automatically logged when a service is reverted back for further work)::::Lo stato del servizio riportato da completato a pendente (azione automaticamente registrata quando un servizio viene reinviato per ulteriori adempimenti)::::Статус услуги изменен к "исполняется" (событие будет автоматически записано в журнал событий)');

INSERT INTO application.service_action_type (code, display_value, status_to_set, status, description) 
VALUES ('start', 'Start::::Comincia::::Запустить', 'pending', 'c', 'Provisional RRR Changes Made to Database as a result of application (action is automatically logged when a change is made to a rrr object)::::Apportate Modifiche Provvisorie di tipo RRR al Database come risultato della pratica::::Определенные изменения должны быть сделаны, относящиеся к услуги (событие будет автоматически записано в журнал событий)');

INSERT INTO application.service_action_type (code, display_value, status_to_set, status, description) 
VALUES ('lodge', 'Lodge::::Registrata::::Подать заявление', 'lodged', 'c', 'Application for service(s) is officially received by land office (action is automatically logged when application is saved for the first time)::::La pratica per i servizi formalmente ricevuta da ufficio territoriale::::Заявление принято официально регистрационным офисом (событие будет автоматически записано в журнал событий)');

----------------------------------------------------------------------------------------------------

INSERT INTO application.service_status_type (code, display_value, status, description) 
VALUES ('completed', 'Completed::::Completata::::Завершен', 'c', '...::::::::...');

INSERT INTO application.service_status_type (code, display_value, status, description) 
VALUES ('lodged', 'Lodged::::Registrata::::Зарегистрирован', 'c', 'Application for a service has been lodged and officially received by land office::::La pratica per un servizio, registrata e formalmente ricevuta da ufficio territoriale::::Заявление было подано и зарегистрировано в регистрационном офисе');

INSERT INTO application.service_status_type (code, display_value, status, description) 
VALUES ('pending', 'Pending::::Pendente::::На исполнении', 'c', '...::::::::...');

INSERT INTO application.service_status_type (code, display_value, status, description) 
VALUES ('cancelled', 'Cancelled::::Cancellato::::Отменен', 'c', '...::::::::...');

----------------------------------------------------------------------------------------------------

INSERT INTO application.type_action (code, display_value, description, status) 
VALUES ('cancel', 'Cancel::::Cancellazione::::Отмена', '...::::::::...', 'c');

INSERT INTO application.type_action (code, display_value, description, status) 
VALUES ('new', 'New::::Nuovo::::Новый', '...::::::::...', 'c');

INSERT INTO application.type_action (code, display_value, description, status) 
VALUES ('vary', 'Vary::::Variazione::::Изменить', '...::::::::...', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('addDocument', 'Add document::::Documenti scannerizzati allegati alla pratica::::Добавлен документ', null, 'c', 'Scanned Documents linked to Application (action is automatically logged when a new document is saved)::::Documenti scannerizzati allegati alla pratica::::Добавление документа к заявлению');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('archive', 'Archive::::Archiviata::::Помещено в архив', 'completed', 'c', 'Paper application records are archived (action is manually logged)::::I fogli della pratica sono stati archiviati::::Отправление в архив бумажной копии заявления');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('validateFailed', 'Quality Check Fails::::Controllo Qualita Fallito::::Проверка качества вернула ошибки', null, 'c', 'Quality check fails (automatically logged when a critical business rule failure occurs)::::Controllo Qualita Fallito::::Ошибки при проверки качества будут автоматически записаны в лог системы');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('withdraw', 'Withdraw application::::Pratica Ritirata::::Забрано', 'annulled', 'c', 'Application withdrawn by Applicant (action is manually logged)::::Pratica Ritirata dal Richiedente::::Заявление было забрано заявителем');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('resubmit', 'Resubmit::::Reinvia::::Подано заново', 'lodged', 'c', '');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('validatePassed', 'Quality Check Passes::::Controllo Qualita Superato::::Успешная проверка качества', null, 'c', 'Quality check passes (automatically logged when business rules are run without any critical failures)::::Controllo Qualita Superato::::Успешная проверка качества');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('requisition', 'Requisition:::Ulteriori Informazioni domandate dal richiedente::::::::Запрошена доп. информацию', 'requisitioned', 'c', 'Further information requested from applicant (action is manually logged)::::Ulteriori Informazioni domandate dal richiedente::::Дальнейшая информация запрошена у заявителя');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('unAssign', 'Unassign::::Dealloca::::Освобождено', null, 'c', '');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('approve', 'Approve::::Approvata::::Одобрено', 'approved', 'c', 'Application is approved (automatically logged when application is approved successively)::::Pratica approvata::::Заявление одобрено');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('dispatch', 'Dispatch::::Inviata::::Отослано', null, 'c', 'Application documents and new land office products are sent or collected by applicant (action is manually logged)::::I documenti della pratica e i nuovi prodotti da Ufficio Territoriale sono stati spediti o ritirati dal richiedente::::Документы заявления отсылаются заявителю или он забирает их сам');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('cancel', 'Cancel application::::Pratica cancellata::::Отменено', 'annulled', 'c', 'Application cancelled by Land Office (action is automatically logged when application is cancelled)::::Pratica cancellata da Ufficio Territoriale::::Отмена исполнения заявления');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('validate', 'Validate::::Convalida::::Проверено', null, 'c', 'The action validate does not leave a mark, because validateFailed and validateSucceded will be used instead when the validate is completed.::::::::The action validate does not leave a mark, because validateFailed and validateSucceded will be used instead when the validate is completed.');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('assign', 'Assign::::Assegna::::Назначено', null, 'c', '');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('lodge', 'Lodgement Notice Prepared::::Ricevuta della Registrazione Preparata::::Подготовлено уведомление об оплате', 'lodged', 'c', 'Lodgement notice is prepared (action is automatically logged when application details are saved for the first time::::La ricevuta della registrazione pronta::::Подготовлено уведомление об оплате');

INSERT INTO application.application_action_type (code, display_value, status_to_set, status, description) 
VALUES ('lapse', 'Lapse::::Decadimento::::Помечено как устарешее', 'annulled', 'c', '');

----------------------------------------------------------------------------------------------------

INSERT INTO application.application_status_type (code, display_value, status, description) 
VALUES ('approved', 'Approved::::Approvato::::Одобрено', 'c', '');

INSERT INTO application.application_status_type (code, display_value, status, description) 
VALUES ('annulled', 'Annulled::::Anullato::::Аннулировано', 'c', '');

INSERT INTO application.application_status_type (code, display_value, status, description) 
VALUES ('completed', 'Completed::::Completato::::Завершено', 'c', '');

INSERT INTO application.application_status_type (code, display_value, status, description) 
VALUES ('requisitioned', 'Requisitioned::::Requisito::::Запрошена доп. информация', 'c', '');

INSERT INTO application.application_status_type (code, display_value, status, description) 
VALUES ('lodged', 'Lodged::::Registrata::::Подано', 'c', 'Application has been lodged and officially received by land office::::La pratica registrata e formalmente ricevuta da ufficio territoriale::::Заявление подано и официально принято регистрационным офисом');

----------------------------------------------------------------------------------------------------

INSERT INTO application.request_category_type (code, display_value, description, status) 
VALUES ('registrationServices', 'Registration Services::::Servizi di Registrazione::::Регистрационные услуги', '...::::::::...', 'c');

INSERT INTO application.request_category_type (code, display_value, description, status) 
VALUES ('informationServices', 'Information Services::::Servizi Informativi::::Информационные услуги', '...::::::::...', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('noteOccupation', 'registrationServices', 'Occupation Noted::::Nota occupazione::::Уведомление о самозахвате', '...::::::::...', 'x', 5, 5.00, 0.00, 0.01, 1, 'Occupation by <name> recorded', null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('titleSearch', 'informationServices', 'Title Search::::Ricerca Titolo::::Поиск недвижимости', '...::::::::...', 'c', 1, 5.00, 0.00, 0.00, 1, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('waterRights', 'registrationServices', 'Register Water Rights::::Registrazione diritti di acqua''::::Регистрация права пользования водными ресурсами', '...::::::::...', 'x', 5, 5.00, 0.01, 0.00, 1, 'Water Rights granted to <name>', 'waterrights', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('documentCopy', 'informationServices', 'Document Copy::::Copia Documento::::Копия документа', '...::::::::...', 'c', 1, 0.50, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('mortgage', 'registrationServices', 'Register Mortgage::::Registrazione ipoteca::::Регистрация ипотеки', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Mortgage to <lender>', 'mortgage', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('varyCaveat', 'registrationServices', 'Vary caveat::::::::Изменить арест', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '<Caveat> <reference>', 'caveat', 'vary');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('newFreehold', 'registrationServices', 'New Freehold Title::::Nuovo Titolo::::Новое право собственности (свободное)', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Fee Simple Estate', null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('removeRestriction', 'registrationServices', 'Remove Restriction (General)::::Rimozione restrizione (generica)::::Снять ограничение', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '<restriction> <reference> cancelled', null, 'cancel');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('varyRight', 'registrationServices', 'Vary Right (General)::::Modifica diritto (generico)::::Изменить право (общее)', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Variation of <right> <reference>', null, 'vary');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('removeCaveat', 'registrationServices', 'Remove Caveat::::Rimozione prelazione::::Снять арест', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Caveat <reference> removed', 'caveat', 'cancel');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('newOwnership', 'registrationServices', 'Change of Ownership::::Cambio proprieta::::Смена владельца', '...::::::::...', 'c', 5, 5.00, 0.00, 0.02, 1, 'Transfer to <name>', 'ownership', 'vary');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cnclStandardDocument', 'registrationServices', 'Withdraw Standard Document::::::::Удалить типовой документ', 'To withdraw from use any standard document (such as standard mortgage or standard lease)::::::::...', 'c', 1, 5.00, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('servitude', 'registrationServices', 'Register Servitude::::registrazione servitu::::Регистрация сервитута', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Servitude over <parcel1> in favour of <parcel2>', 'servitude', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cadastreExport', 'informationServices', 'Cadastre Export::::Export Catastale::::Экспорт кадастра еще текст', '', 'x', 1, 0.00, 0.10, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('caveat', 'registrationServices', 'Register Caveat::::Registrazione prelazione''::::Регистрация ареста', '...::::::::...', 'c', 5, 50.00, 0.00, 0.00, 1, 'Caveat in the name of <name>', 'caveat', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('regnPowerOfAttorney', 'registrationServices', 'Registration of Power of Attorney::::Registrazione di Procura::::Регистрация доверенности', '...::::::::...', 'c', 3, 5.00, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('surveyPlanCopy', 'informationServices', 'Survey Plan Copy::::Copia Piano Perizia::::Копия кадастрового плана', '...::::::::...', 'x', 1, 1.00, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cadastrePrint', 'informationServices', 'Cadastre Print::::Stampa Catastale::::Печать кадастровых данных', '...::::::::...', 'c', 1, 0.50, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('removeRight', 'registrationServices', 'Remove Right (General)::::Rimozione diritto (generico)::::Прекратить право', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '<right> <reference> cancelled', null, 'cancel');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('varyMortgage', 'registrationServices', 'Vary Mortgage::::Modifica ipoteca::::Изменить ипотеку', '...::::::::...', 'c', 1, 5.00, 0.00, 0.00, 1, 'Change on the mortgage', 'mortgage', 'vary');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('lodgeObjection', 'registrationServices', 'Lodge Objection::::Obiezioni::::Заявление оспаривания права', '...::::::::...', 'c', 90, 5.00, 0.00, 0.00, 1, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cnclPowerOfAttorney', 'registrationServices', 'Cancel Power of Attorney::::::::Нотариальная доверенность', '...::::::::...', 'c', 1, 5.00, 0.00, 0.00, 0, null, null, 'cancel');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cadastreChange', 'registrationServices', 'Change to Cadastre::::Cambio del Catasto::::Изменение кадастра', '...::::::::...', 'c', 30, 25.00, 0.10, 0.00, 1, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('newDigitalProperty', 'registrationServices', 'New Digital Property::::Nuova Proprieta Digitale::::Регистрация существующего права собственности', '...::::::::...', 'x', 5, 0.00, 0.00, 0.00, 1, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('newState', 'registrationServices', 'New State Title::::Nuovo Titolo::::Новое право собственности (государственное)', '...::::::::...', 'x', 5, 0.00, 0.00, 0.00, 1, 'State Estate', null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('newApartment', 'registrationServices', 'New Apartment Title::::Nuovo Titolo::::Новое право на квартиру', '...::::::::...', 'c', 5, 5.00, 0.00, 0.02, 1, 'Apartment Estate', 'apartment', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('regnDeeds', 'registrationServices', 'Deed Registration::::Registrazione Atto::::Регистрация сделки', '...::::::::...', 'x', 3, 1.00, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('registerLease', 'registrationServices', 'Register Lease::::Registrazione affitto::::Регистрация права пользования', '...::::::::...', 'c', 5, 5.00, 0.00, 0.01, 1, 'Lease of nn years to <name>', 'lease', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('varyLease', 'registrationServices', 'Vary Lease::::Modifica affitto::::Изменить право пользования', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Variation of Lease <reference>', 'lease', 'vary');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cancelProperty', 'registrationServices', 'Cancel title::::Cancella prioprieta::::Прекращение права собственности', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, '', null, 'cancel');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('buildingRestriction', 'registrationServices', 'Register Building Restriction::::Registrazione restrizioni edificabilita::::Регистрация ограничения на строение', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Building Restriction', 'noBuilding', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('newDigitalTitle', 'registrationServices', 'Convert to Digital Title::::Nuovo Titolo Digitale::::Новое право собственности (конвертация)', '...::::::::...', 'c', 5, 0.00, 0.00, 0.00, 1, 'Title converted to digital format', null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('cadastreBulk', 'informationServices', 'Cadastre Bulk Export::::Export Carico Catastale::::Массовая загрузка кадастровых данных', '...::::::::...', 'x', 5, 5.00, 0.10, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('lifeEstate', 'registrationServices', 'Establish Life Estate::::Imposizione patrimonio vitalizio::::Регистрация пожизненного права пользования', '...::::::::...', 'x', 5, 5.00, 0.00, 0.02, 1, 'Life Estate for <name1> with Remainder Estate in <name2, name3>', 'lifeEstate', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('historicOrder', 'registrationServices', 'Register Historic Preservation Order::::Registrazione ordine storico di precedenze::::Регистрация недвижимости исторического назначения', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Historic Preservation Order', 'noBuilding', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('limitedRoadAccess', 'registrationServices', 'Register Limited Road Access::::registrazione limitazione accesso stradale::::Регистрация ограниченного доступа к дороги', '...::::::::...', 'c', 5, 5.00, 0.00, 0.00, 1, 'Limited Road Access', 'limitedAccess', null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('mapExistingParcel', 'registrationServices', 'Map Existing Parcel::::::::Нанести на карту существующий участок', '', 'c', 30, 0.00, 0.00, 0.00, 0, 'Allows to make changes to the cadastre', null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('redefineCadastre', 'registrationServices', 'Redefine Cadastre::::Redefinizione catasto::::Изменение кадастрового объекта', '...::::::::...', 'c', 30, 25.00, 0.10, 0.00, 1, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('regnStandardDocument', 'registrationServices', 'Registration of Standard Document::::Documento di Documento Standard::::Регистрация типового документа', '...::::::::...', 'c', 3, 5.00, 0.00, 0.00, 0, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('usufruct', 'registrationServices', 'Register Usufruct::::Registrazione usufrutto::::Регистрация права пользования ресурсами', '...::::::::...', 'x', 5, 5.00, 0.00, 0.00, 1, '<usufruct> right granted to <name>', 'usufruct', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('systematicRegn', 'registrationServices', 'Systematic Registration Claim::::Registrazione Sistematica::::Запрос на системную регистрацию', '...::::::::...', 'c', 90, 50.00, 0.00, 0.00, 0, 'Title issued at completion of systematic registration', 'ownership', 'new');

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('regnOnTitle', 'registrationServices', 'Registration on Title::::Registrazione di Titolo::::Регистрация права собственности', '...::::::::...', 'c', 5, 5.00, 0.00, 0.01, 1, null, null, null);

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) 
VALUES ('serviceEnquiry', 'informationServices', 'Service Enquiry::::Richiesta Servizio::::Запрос информации о заявлении', '...::::::::...', 'c', 1, 0.00, 0.00, 0.00, 0, null, null, null);

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.area_type (code, display_value, description, status) 
VALUES ('calculatedArea', 'Calculated Area::::Area calcolata::::Вычисленная Площадь', '', 'c');

INSERT INTO cadastre.area_type (code, display_value, description, status) 
VALUES ('nonOfficialArea', 'Non-official Area::::Area Non ufficiale::::Неофициальная Площадь', '', 'c');

INSERT INTO cadastre.area_type (code, display_value, description, status) 
VALUES ('officialArea', 'Official Area::::Area Ufficiale::::Официальная Площадь', '', 'c');

INSERT INTO cadastre.area_type (code, display_value, description, status) 
VALUES ('surveyedArea', 'Surveyed Area::::Area Sorvegliata::::Площадь по Съемке', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.building_unit_type (code, display_value, description, status) 
VALUES ('individual', 'Individual::::Individuale::::Индивидуальное', '', 'c');

INSERT INTO cadastre.building_unit_type (code, display_value, description, status) 
VALUES ('shared', 'Shared::::Condiviso::::Общая', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.dimension_type (code, display_value, description, status) 
VALUES ('0D', '0D::::0D::::0D', '', 'c');

INSERT INTO cadastre.dimension_type (code, display_value, description, status) 
VALUES ('1D', '1D::::1D::::1D', '', 'c');

INSERT INTO cadastre.dimension_type (code, display_value, description, status) 
VALUES ('2D', '2D::::sD::::2D', '', 'c');

INSERT INTO cadastre.dimension_type (code, display_value, description, status) 
VALUES ('3D', '3D::::3D::::3D', '', 'c');

INSERT INTO cadastre.dimension_type (code, display_value, description, status) 
VALUES ('liminal', 'Liminal::::::::Liminal', '', 'x');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.hierarchy_level (code, display_value, description, status) 
VALUES ('0', 'Hierarchy 0::::::::Hierarchy 0', '', 'c');

INSERT INTO cadastre.hierarchy_level (code, display_value, description, status) 
VALUES ('1', 'Hierarchy 1::::::::Hierarchy 1', '', 'c');

INSERT INTO cadastre.hierarchy_level (code, display_value, description, status) 
VALUES ('2', 'Hierarchy 2::::::::Hierarchy 2', '', 'c');

INSERT INTO cadastre.hierarchy_level (code, display_value, description, status) 
VALUES ('3', 'Hierarchy 3::::::::Hierarchy 3', '', 'c');

INSERT INTO cadastre.hierarchy_level (code, display_value, description, status) 
VALUES ('4', 'Hierarchy 4::::::::Hierarchy 4', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.land_use_type (code, display_value, description, status) 
VALUES ('commercial', 'Commercial::::ITALIANO::::Коммерческая', '', 'c');

INSERT INTO cadastre.land_use_type (code, display_value, description, status) 
VALUES ('residential', 'Residential::::ITALIANO::::Жилая', '', 'c');

INSERT INTO cadastre.land_use_type (code, display_value, description, status) 
VALUES ('industrial', 'Industrial::::ITALIANO::::Производственная', '', 'c');

INSERT INTO cadastre.land_use_type (code, display_value, description, status) 
VALUES ('agricultural', 'Agricultural::::ITALIANO::::Сельскохозяйственная', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('building', 'Building::::Costruzione::::Здание', '', 'x');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('customary', 'Customary::::Consueto::::Традиционный', '', 'x');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('informal', 'Informal::::Informale::::Неформальный', '', 'x');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('mixed', 'Mixed::::Misto::::Смешанный', '', 'x');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('network', 'Network::::Rete::::Сеть', '', 'x');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('primaryRight', 'Primary Right::::Diritto Primario::::Первичное право', '', 'c');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('responsibility', 'Responsibility::::Responsabilita::::Ответственность', '', 'x');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('restriction', 'Restriction::::Restrizione::::Ограничение', '', 'c');

INSERT INTO cadastre.level_content_type (code, display_value, description, status) 
VALUES ('geographicLocator', 'Geographic Locators::::Locatori Geografici::::Географические Точки', 'Extension to LADM::::::::Расширение LADM', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.register_type (code, display_value, description, status) 
VALUES ('all', 'All::::Tutti::::Все', '', 'c');

INSERT INTO cadastre.register_type (code, display_value, description, status) 
VALUES ('forest', 'Forest::::Forestale::::Лес', '', 'c');

INSERT INTO cadastre.register_type (code, display_value, description, status) 
VALUES ('mining', 'Mining::::Minerario::::Добыча', '', 'c');

INSERT INTO cadastre.register_type (code, display_value, description, status) 
VALUES ('publicSpace', 'Public Space::::Spazio Pubblico::::Общественная территория', '', 'c');

INSERT INTO cadastre.register_type (code, display_value, description, status) 
VALUES ('rural', 'Rural::::Rurale::::Сельский', '', 'c');

INSERT INTO cadastre.register_type (code, display_value, description, status) 
VALUES ('urban', 'Urban::::Urbano::::Городской', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.structure_type (code, display_value, description, status) 
VALUES ('point', 'Point::::Punto::::Точка', '', 'c');

INSERT INTO cadastre.structure_type (code, display_value, description, status) 
VALUES ('polygon', 'Polygon::::Poligono::::Полигон', '', 'c');

INSERT INTO cadastre.structure_type (code, display_value, description, status) 
VALUES ('sketch', 'Sketch::::Schizzo::::Схема', '', 'c');

INSERT INTO cadastre.structure_type (code, display_value, description, status) 
VALUES ('text', 'Text::::Testo::::Текс', '', 'c');

INSERT INTO cadastre.structure_type (code, display_value, description, status) 
VALUES ('topological', 'Topological::::Topologico::::Топологический', '', 'c');

INSERT INTO cadastre.structure_type (code, display_value, description, status) 
VALUES ('unStructuredLine', 'UnstructuredLine::::LineanonDefinita::::Неструктурированная линия', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.surface_relation_type (code, display_value, description, status) 
VALUES ('above', 'Above::::Sopra::::Над', '', 'x');

INSERT INTO cadastre.surface_relation_type (code, display_value, description, status) 
VALUES ('below', 'Below::::Sotto::::Под', '', 'x');

INSERT INTO cadastre.surface_relation_type (code, display_value, description, status) 
VALUES ('mixed', 'Mixed::::Misto::::Смешанный', '', 'x');

INSERT INTO cadastre.surface_relation_type (code, display_value, description, status) 
VALUES ('onSurface', 'On Surface::::Sulla Superficie::::На Поверхности', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.utility_network_status_type (code, display_value, description, status) 
VALUES ('inUse', 'In Use::::In uso::::Используется', '', 'c');

INSERT INTO cadastre.utility_network_status_type (code, display_value, description, status) 
VALUES ('outOfUse', 'Out of Use::::Fuori uso::::Не используется', '', 'c');

INSERT INTO cadastre.utility_network_status_type (code, display_value, description, status) 
VALUES ('planned', 'Planned::::Pianificato::::Запланировано', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('chemical', 'Chemicals::::Cimica::::Химическая', '', 'c');

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('electricity', 'Electricity::::Elettricita::::Электричество', '', 'c');

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('gas', 'Gas::::Gas::::Газ', '', 'c');

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('heating', 'Heating::::Riscaldamento::::Отопление', '', 'c');

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('oil', 'Oil::::Carburante::::Нефть', '', 'c');

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('telecommunication', 'Telecommunication::::Telecomunicazione::::Телекоммуникации', '', 'c');

INSERT INTO cadastre.utility_network_type (code, display_value, description, status) 
VALUES ('water', 'Water::::Acqua::::Вода', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO cadastre.cadastre_object_type (code, display_value, description, status, in_topology) 
VALUES ('parcel', 'Parcel::::Particella::::Участок', '', 'c', 't');

INSERT INTO cadastre.cadastre_object_type (code, display_value, description, status, in_topology) 
VALUES ('buildingUnit', 'Building Unit::::Unita Edile::::Единица Здания', '', 'c', 'f');

INSERT INTO cadastre.cadastre_object_type (code, display_value, description, status, in_topology) 
VALUES ('utilityNetwork', 'Utility Network::::Rete Utilita::::Инфраструктурная Сеть', '', 'c', 'f');

----------------------------------------------------------------------------------------------------

INSERT INTO party.communication_type (code, display_value, status, description) 
VALUES ('eMail', 'e-Mail::::E-mail::::Эл. почта', 'c', '');

INSERT INTO party.communication_type (code, display_value, status, description) 
VALUES ('fax', 'Fax::::Fax::::Факс', 'c', '');

INSERT INTO party.communication_type (code, display_value, status, description) 
VALUES ('post', 'Post::::Posta::::Почта', 'c', '');

INSERT INTO party.communication_type (code, display_value, status, description) 
VALUES ('phone', 'Phone::::Telefono::::Телефон', 'c', '');

INSERT INTO party.communication_type (code, display_value, status, description) 
VALUES ('courier', 'Courier::::Corriere::::Курьер', 'c', '');

----------------------------------------------------------------------------------------------------

INSERT INTO party.gender_type (code, display_value, status, description) 
VALUES ('male', 'Male::::::::Мужской', 'c', '');

INSERT INTO party.gender_type (code, display_value, status, description) 
VALUES ('female', 'Female::::::::Женский', 'c', '');

----------------------------------------------------------------------------------------------------

INSERT INTO party.group_party_type (code, display_value, status, description) 
VALUES ('tribe', 'Tribe::::Tribu::::Племя', 'x', '');

INSERT INTO party.group_party_type (code, display_value, status, description) 
VALUES ('association', 'Association::::Associazione::::Ассоциация', 'c', '');

INSERT INTO party.group_party_type (code, display_value, status, description) 
VALUES ('family', 'Family::::Famiglia::::Семья', 'c', '');

INSERT INTO party.group_party_type (code, display_value, status, description) 
VALUES ('baunitGroup', 'Basic Administrative Unit Group::::Unita Gruppo Amministrativo di Base::::Базовая Административная Группа Единиц', 'x', '');

----------------------------------------------------------------------------------------------------

INSERT INTO party.id_type (code, display_value, status, description) 
VALUES ('nationalID', 'National ID::::Carta Identita Nazionale::::Внутренний ID', 'c', 'The main person ID that exists in the country::::Il principale documento identificativo nel paese::::Внутренняя ID карта гражданина внутри страны');

INSERT INTO party.id_type (code, display_value, status, description) 
VALUES ('nationalPassport', 'National Passport::::Passaporto Nazionale::::Паспорт', 'c', 'A passport issued by the country::::Passaporto fornito dal paese::::Паспорт, выданный в стране');

INSERT INTO party.id_type (code, display_value, status, description) 
VALUES ('otherPassport', 'Other Passport::::Altro Passaporto::::Другой паспорт', 'c', 'A passport issued by another country::::Passaporto Fornito da un altro paese::::Паспорт выданный другой страной');

----------------------------------------------------------------------------------------------------

INSERT INTO party.party_type (code, display_value, status, description) 
VALUES ('naturalPerson', 'Natural Person::::Persona Naturale::::Физическое лицо', 'c', '');

INSERT INTO party.party_type (code, display_value, status, description) 
VALUES ('nonNaturalPerson', 'Non-natural Person::::Persona Giuridica::::Организация', 'c', '');

INSERT INTO party.party_type (code, display_value, status, description) 
VALUES ('baunit', 'Basic Administrative Unit::::Unita Amministrativa di Base::::Базовая Административная Единица', 'c', '');

INSERT INTO party.party_type (code, display_value, status, description) 
VALUES ('group', 'Group::::Gruppo::::Группа', 't', '');

----------------------------------------------------------------------------------------------------

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('applicant', 'Applicant::::::::Заявитель', 'c', 'Extension to LADM::::::::Расширение LADM');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('conveyor', 'Conveyor::::Trasportatore::::Перевозчик', 'x', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('bank', 'Bank::::Banca::::Банк', 'c', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('moneyProvider', 'Money Provider::::Istituto Credito::::Заемщик денег', 'c', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('employee', 'Employee::::Impiegato::::Служащий', 'x', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('farmer', 'Farmer::::Contadino::::Фермер', 'x', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('citizen', 'Citizen::::Cittadino::::Гражданин', 'c', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('notary', 'Notary::::Notaio::::Нотариус', 'c', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('stateAdministrator', 'Registrar / Approving Surveyor::::Cancelleriere/ Perito Approvatore/::::Регистратор / Утверждающий Геодезист', 'c', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('landOfficer', 'Land Officer::::Ufficiale del Registro Territoriale::::Землеустроитель', 'c', 'Extension to LADM::::::::Расширение LADM');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('lodgingAgent', 'Lodging Agent::::Richiedente Registrazione::::Агент по подачи заявлений', 'c', 'Extension to LADM::::::::Расширение LADM');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('writer', 'Writer::::Autore::::Оформитель документов', 'x', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('powerOfAttorney', 'Power of Attorney::::Procuratore::::Адвокат (поверенный)', 'c', 'Extension to LADM::::::::Расширение LADM');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('surveyor', 'Surveyor::::Perito::::Геодезист', 'x', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('certifiedSurveyor', 'Licenced Surveyor::::Perito con Licenza::::Лицензированный Геодезист', 'c', '');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('transferee', 'Transferee (to)::::Avente Causa::::Получатель', 'c', 'Extension to LADM::::::::Расширение LADM');

INSERT INTO party.party_role_type (code, display_value, status, description) 
VALUES ('transferor', 'Transferor (from)::::Dante Causa::::Цедент', 'c', 'Extension to LADM::::::::Расширение LADM');

----------------------------------------------------------------------------------------------------

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('powerOfAttorney', 'Power of Attorney::::Procura::::Доверенность', 'c', 'Extension to LADM::::::::Расширение LADM', 't');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('deed', 'Deed::::::::Сделка', 'c', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('agriNotaryStatement', 'Agricultural Notary Statement::::Dichiarazione Agricola Notaio::::Нотариальное Сельскохозяйственное Заявление', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('mortgage', 'Mortgage::::Ipoteca::::Ипотека', 'c', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('pdf', 'Pdf Scanned Document::::::::Отсканированный Документ PDF', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('jpg', 'Jpg Scanned Document::::::::Отсканированный Документ JPEG', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('tif', 'Tif Scanned Document::::::::Отсканированный Документ TIF', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('title', 'Title::::Titolo::::Право Собственности', 'c', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('standardDocument', 'Standard Document::::Documento Standard::::Стандартный Документ', 'c', 'Extension to LADM::::::::Расширение LADM', 't');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('agriConsent', 'Agricultural Consent::::Permesso Agricolo::::Сельскохозяйственное Разрешение', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('cadastralMap', 'Cadastral Map::::Mappa Catastale::::Кадастровая Карта', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('idVerification', 'Form of Identification including Personal ID::::::::Форма удостоверения включая персональный ID', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('will', 'Will::::Testamento::::Завещание', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('systematicRegn', 'Systematic Registration Application::::Registrazione sistematica::::Заявление на Системную Регистрацию', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('proclamation', 'Proclamation::::Bando::::Прокламация', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('lease', 'Lease::::Affitto::::Договор Аренды', 'c', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('waiver', 'Waiver to Caveat or other requirement::::::::Ходатайство о приостановке судебного разбирательства', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('objection', 'Objection  document::::Obiezione::::Документ Обжалования', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('publicNotification', 'Public Notification for Systematic Registration::::Pubblica notifica per registrazione sistematica::::Публичное Уведомление о Системной Регистрации', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('cadastralSurvey', 'Cadastral Survey::::Rilevamento Catastale::::Кадастровая Съемка', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('agreement', 'Agreement::::Accordo::::Соглашение', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('courtOrder', 'Court Order::::Ordine Tribunale::::Судебное Решение', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('agriLease', 'Agricultural Lease::::Contratto Affitto Agricolo::::Сельскохозяйственная Аренда', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('tiff', 'Tiff Scanned Document::::::::Отсканированный Документ TIFF', 'x', '', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('contractForSale', 'Contract for Sale::::Contratto di vendita::::Договор о Продаже', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('caveat', 'Caveat::::::::Протест', 'c', 'Extension to LADM::::::::Расширение LADM', 'f');

----------------------------------------------------------------------------------------------------

INSERT INTO source.availability_status_type (code, display_value, status, description) 
VALUES ('archiveConverted', 'Converted::::Convertito::::Сконвертированный', 'c', '');

INSERT INTO source.availability_status_type (code, display_value, status, description) 
VALUES ('archiveDestroyed', 'Destroyed::::Distrutto::::Уничтоженный', 'x', '');

INSERT INTO source.availability_status_type (code, display_value, status, description) 
VALUES ('incomplete', 'Incomplete::::Incompleto::::Незаконченный', 'c', '');

INSERT INTO source.availability_status_type (code, display_value, status, description) 
VALUES ('archiveUnknown', 'Unknown::::Sconosciuto::::Неизвестный', 'c', '');

INSERT INTO source.availability_status_type (code, display_value, status, description) 
VALUES ('available', 'Available::::::::Доступный', 'c', 'Extension to LADM::::::::Extension to LADM');

----------------------------------------------------------------------------------------------------

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('videoHardcopy', 'Hardcopy Video::::Video in Hardcopy::::Видео на носителе', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('documentDigital', 'Digital Document::::Documento Digitale::::Цифровой Документ', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('documentHardcopy', 'Hardcopy Document::::Documento in Hardcopy::::Бумажный Документ', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('imageDigital', 'Digital Image::::Immagine Digitale::::Цифровое Изображение', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('imageHardcopy', 'Hardcopy Image::::Immagine in Hardcopy::::Бумажное Изображение', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('mapDigital', 'Digital Map::::Mappa Digitale::::Цифровая Карты', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('mapHardcopy', 'Hardcopy Map::::Mappa in Hardcopy::::Бумажная Карта', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('modelDigital', 'Digital Model::::Modello Digitale'',::::Цифровая Модель', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('modelHarcopy', 'Hardcopy Model::::Modello in Hardcopy::::Бумажная Модель', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('profileDigital', 'Digital Profile::::Profilo Digitale::::Цифровое Дело', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('profileHardcopy', 'Hardcopy Profile::::Profilo in Hardcopy::::Бумажное Дело', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('tableDigital', 'Digital Table::::Tabella Digitale::::Цифровая Таблица', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('tableHardcopy', 'Hardcopy Table::::Tabella in Hardcopy::::Бумажная Таблица', 'c', '');

INSERT INTO source.presentation_form_type (code, display_value, status, description) 
VALUES ('videoDigital', 'Digital Video::::Video Digitale'',::::Цифровое Видео', 'c', '');

----------------------------------------------------------------------------------------------------

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('fieldSketch', 'Field Sketch::::Schizzo Campo::::Полевая Схема', 'c', '');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('gnssSurvey', 'GNSS (GPS) Survey::::Rilevamento GNSS (GPS)::::Съемка GNSS (GPS)', 'c', '');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('orthoPhoto', 'Orthophoto::::Foto Ortopanoramica::::Аэрофотография', 'c', '');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('relativeMeasurement', 'Relative Measurements::::Misure relativa::::Относительные Измерения', 'c', '');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('topoMap', 'Topographical Map::::Mappa Topografica::::Топологическая Карта', 'c', '');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('video', 'Video::::Video::::Видео', 'c', '');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('cadastralSurvey', 'Cadastral Survey::::Perizia Catastale::::Кадастровая Съемка', 'c', 'Extension to LADM::::::::Расширение LADM');

INSERT INTO source.spatial_source_type (code, display_value, status, description) 
VALUES ('surveyData', 'Survey Data (Coordinates)::::Rilevamento Data::::Данные Съемки (Координаты)', 'c', 'Extension to LADM::::::::Расширение LADM');

----------------------------------------------------------------------------------------------------

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('TransactionCommit', 'Doc Registration - Save::::::::Doc Registration - Save', 'c', 'Allows documents for registration such as Power of Attorney and Standard Documents to be saved on the Document Registration screen. ::::::::Allows documents for registration such as Power of Attorney and Standard Documents to be saved on the Document Registration screen.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('BaunitSave', 'Property - Edit & Save::::::::Property - Edit & Save', 'c', 'Allows property details to be edited and saved.::::::::Allows property details to be edited and saved.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('cnclPowerOfAttorney', 'Service - Cancel Power of Attorney::::::::Service - Cancel Power of Attorney', 'c', 'Registration Service. Allows the Cancel Power of Attorney service to be started::::::::Registration Service. Allows the Cancel Power of Attorney service to be started');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('documentCopy', 'Service - Document Copy::::::::Service - Document Copy', 'c', 'Supporting Service. Allows the Document Copy service to be started.::::::::Supporting Service. Allows the Document Copy service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ManageSettings', 'Admin - System Settings::::::::Admin - System Settings', 'c', 'Allows system administrators to manage (edit and save) system setting details. Users with this role will be able to login to the SOLA Admin application. ::::::::Allows system administrators to manage (edit and save) system setting details. Users with this role will be able to login to the SOLA Admin application.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnView', 'Application - Search & View::::::::Application - Search & View', 'c', 'Allows users to search and view application details.::::::::Allows users to search and view application details.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnArchive', 'Appln Action - Archive::::::::Appln Action - Archive', 'c', 'Required to perform the Archive applicaiton action. The Archive action transitions the application into the Completed state.  ::::::::Required to perform the Archive applicaiton action. The Archive action transitions the application into the Completed state.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnRequisition', 'Appln Action - Requisition::::::::Appln Action - Requisition', 'c', 'Required to perform the Requisition applicaiton action. The Requisition action transitions the application into the Requisitioned state. ::::::::Required to perform the Requisition applicaiton action. The Requisition action transitions the application into the Requisitioned state.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('BulkApplication', 'Bulk Operations - Login ::::::::Bulk Operations - Login', 'c', 'Allows the user to login and use the Bulk Operations application. ::::::::Allows the user to login and use the Bulk Operations application.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('DashbrdViewUnassign', 'Dashboard - View Unassigned::::::::Dashboard - View Unassigned', 'c', 'Allows the user to view all unassigned applications in the Dashboard. To hide the Dashboard from the user, remove both this role and the Dashboard - View Assigned role. ::::::::Allows the user to view all unassigned applications in the Dashboard. To hide the Dashboard from the user, remove both this role and the Dashboard - View Assigned role.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('RHSave', 'Party - Save Rightholder::::::::Party - Save Rightholder', 'c', 'Allows parties that are rightholders to be edited and saved.::::::::Allows parties that are rightholders to be edited and saved.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('BaunitCertificate', 'Property - Print Certificate::::::::Property - Print Certificate', 'c', 'Allows the user to generate a property certificate. ::::::::Allows the user to generate a property certificate.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('cadastrePrint', 'Service - Cadastre Print::::::::Service - Cadastre Print', 'c', 'Supporting Service. Allows the Cadastre Print service to be started. ::::::::Supporting Service. Allows the Cadastre Print service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('newDigitalTitle', 'Service - Convert Title::::::::Service - Convert Title', 'c', 'Registration Service. Allows the Convert Title service to be started. ::::::::Registration Service. Allows the Convert Title service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ManageSecurity', 'Admin - Users and Security::::::::Admin - Users and Security', 'c', 'Allows system administrators to manage (edit and save) users, groups and roles. Users with this role will be able to login to the SOLA Admin application. ::::::::Allows system administrators to manage (edit and save) users, groups and roles. Users with this role will be able to login to the SOLA Admin application.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnUnassignOthers', 'Application - Unassign from Others::::::::Application - Unassign from Others', 'c', 'Allows the user to unassign an application from any user. ::::::::Allows the user to unassign an application from any user.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnDispatch', 'Appln Action - Dispatch::::::::Appln Action - Dispatch', 'c', 'Required to perform the Dispatch application action. Used to indicate that documents have been dispatched to applicant along with any certificates/reports/map prints requested by applicant::::::::Required to perform the Dispatch application action. Used to indicate that documents have been dispatched to applicant along with any certificates/reports/map prints requested by applicant');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('DashbrdViewAssign', 'Dashboard - View Assigned::::::::Dashboard - View Assigned', 'c', 'Allows the user to view applications assigned to them in the Dashboard. To hide the Dashboard from the user, remove both this role and the Dashboard - View Unassigned role. ::::::::Allows the user to view applications assigned to them in the Dashboard. To hide the Dashboard from the user, remove both this role and the Dashboard - View Unassigned role.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('varyLease', 'Service - Vary Lease::::::::Service - Vary Lease', 'c', 'Registration Service. Allows the Vary Lease service to be started. ::::::::Registration Service. Allows the Vary Lease service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('mapExistingParcel', 'Map Existing Parcel::::::::Map Existing Parcel', 'c', 'Allows to map existing parcel as described on existing title. ::::::::Allows to map existing parcel as described on existing title.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ManageRefdata', 'Admin - Reference Data::::::::Admin - Reference Data', 'c', 'Allows system administrators to manage (edit and save) reference data details.  Users with this role will be able to login to the SOLA Admin application. ::::::::Allows system administrators to manage (edit and save) reference data details.  Users with this role will be able to login to the SOLA Admin application.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnApprove', 'Appln Action - Approval::::::::Appln Action - Approval', 'c', 'Required to perform the Approve applicaiton action. The Approve action transitions the application into the Approved state. 
All services on the application must be completed before this action is available. ::::::::Required to perform the Approve applicaiton action. The Approve action transitions the application into the Approved state.
All services on the application must be completed before this action is available.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('cancelProperty', 'Service - Cancel Title::::::::Service - Cancel Title', 'c', 'Lease Service. Allows the Cancel Title to be started. ::::::::Lease Service. Allows the Cancel Title to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ViewMap', 'Map - View::::::::Map - View', 'c', 'Allows the user to view the map. ::::::::Allows the user to view the map.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ParcelSave', 'Parcel - Edit & Save::::::::Parcel - Edit & Save', 'c', 'Allows parcel details to be edited and saved.::::::::Allows parcel details to be edited and saved.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('PartySave', 'Party - Edit & Save::::::::Party - Edit & Save', 'c', 'Allows party details to be edited and saved unless the party is a rightholder. ::::::::Allows party details to be edited and saved unless the party is a rightholder.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('RightsExport', 'Reporting - Rights Export::::::::Reporting - Rights Export', 'c', 'Allows user to export rights informaiton into CSV format.  ::::::::Allows user to export rights informaiton into CSV format.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('newOwnership', 'Service - Chance of Ownership::::::::Service - Chance of Ownership', 'c', 'Registration Service. Allows the Change of Ownership service to be started. ::::::::Registration Service. Allows the Change of Ownership service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnAssignOthers', 'Application - Assign to Other Users::::::::Application - Assign to Other Users', 'c', 'Allows a user to assign an application to any other user in the same security groups they are in. ::::::::Allows a user to assign an application to any other user in the same security groups they are in.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnAssignSelf', 'Application - Assign to Self::::::::Application - Assign to Self', 'c', 'Allows a user to assign an application to themselves.::::::::Allows a user to assign an application to themselves.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnEdit', 'Application - Edit & Save::::::::Application - Edit & Save', 'c', 'Allows application details to be edited and saved. ::::::::Allows application details to be edited and saved.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnUnassignSelf', 'Application - Unassign from Self::::::::Application - Unassign from Self', 'c', 'Allows a user to unassign an application from themselves. ::::::::Allows a user to unassign an application from themselves.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnReject', 'Appln Action - Cancel::::::::Appln Action - Cancel', 'c', 'Required to perform the Cancel applicaiton action. The Cancel action transitions the application into the Annulled state.  ::::::::Required to perform the Cancel applicaiton action. The Cancel action transitions the application into the Annulled state.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnValidate', 'Appln Action - Validate::::::::Appln Action - Validate', 'c', 'Required to perform the Validate applicaiton action. Allows the user to manually run the validation rules against the application. ::::::::Required to perform the Validate applicaiton action. Allows the user to manually run the validation rules against the application.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('SourcePrint', 'Document - Print::::::::Document - Print', 'c', 'Allows users to print documents directly from SOLA. ::::::::Allows users to print documents directly from SOLA.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('SourceSave', 'Document - Save::::::::Document - Save', 'c', 'Allows document details to be edited and saved::::::::Allows document details to be edited and saved');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('SourceSearch', 'Document - Search & View::::::::Document - Search & View', 'c', 'Allows users to search for documents.::::::::Allows users to search for documents.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ExportMap', 'Map - KML Export::::::::Map - KML Export', 'c', 'Allows the user to export selected features from the map as KML.::::::::Allows the user to export selected features from the map as KML.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('PrintMap', 'Map - Print::::::::Map - Print', 'c', 'Allows the user to create printouts from the Map::::::::Allows the user to create printouts from the Map');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('PartySearch', 'Party - Search & View::::::::Party - Search & View', 'c', 'Allows user to search and view party details.::::::::Allows user to search and view party details.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('BaunitSearch', 'Property - Search::::::::Property - Search', 'c', 'Allows users to search for properties. ::::::::Allows users to search for properties.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('cadastreChange', 'Service - Change to Cadastre::::::::Service - Change to Cadastre', 'c', 'Survey Service. Allows the Change to Cadastre service to be started::::::::Survey Service. Allows the Change to Cadastre service to be started');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('newFreehold', 'Service - Freehold Title::::::::Service - Freehold Title', 'c', 'Registration Service. Allows the Freehold Title service to be started.::::::::Registration Service. Allows the Freehold Title service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnCreate', 'Application - Lodge::::::::Application - Lodge', 'c', 'Allows new application details to be created (lodged). ::::::::Allows new application details to be created (lodged).');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnStatus', 'Application - Status Report::::::::Application - Status Report', 'c', 'Allows the user to print a status report for the application.::::::::Allows the user to print a status report for the application.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnWithdraw', 'Appln Action - Withdraw::::::::Appln Action - Withdraw', 'c', 'Required to perform the Withdraw applicaiton action. The Withdraw action transitions the application into the Annulled state.  ::::::::Required to perform the Withdraw applicaiton action. The Withdraw action transitions the application into the Annulled state.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ChangePassword', 'Admin - Change Password::::::::Admin - Change Password', 'c', 'Allows a user to change their password and edit thier user name. This role should be included in every security group. ::::::::Allows a user to change their password and edit thier user name. This role should be included in every security group.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ManageBR', 'Admin - Business Rules::::::::Admin - Business Rules', 'c', 'Allows system administrators to manage (edit and save) business rules.::::::::Allows system administrators to manage (edit and save) business rules.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('lodgeObjection', 'Service - Lodge Objection::::::::Service - Lodge Objection', 'c', 'Systematic Registration Service. Allows the Lodge Objection service to be started.::::::::Systematic Registration Service. Allows the Lodge Objection service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('newApartment', 'Service - New Apartment Title::::::::Service - New Apartment Title', 'c', 'Registration Service. Allows the New Apartment Title service to be started. ::::::::Registration Service. Allows the New Apartment Title service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('buildingRestriction', 'Service - Register Building Restriction::::::::Service - Register Building Restriction', 'c', 'Registration Service. Allows the Register Building Restriction service to be started. ::::::::Registration Service. Allows the Register Building Restriction service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('historicOrder', 'Service - Register Historic Preservation Order::::::::Service - Register Historic Preservation Order', 'c', 'Registration Service. Allows the Register Historic Preservation Order service to be started. ::::::::Registration Service. Allows the Register Historic Preservation Order service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('systematicRegn', 'Service - Systematic Registration Claim::::::::Service - Systematic Registration Claim', 'c', 'Systematic Registration Service - Allows the Systematic Registration Claim service to be started. ::::::::Systematic Registration Service - Allows the Systematic Registration Claim service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('limtedRoadAccess', 'Service - Register Limited Road Access::::::::Service - Register Limited Road Access', 'c', 'Registration Service. Allows the Register Limited Road Access service to be started. ::::::::Registration Service. Allows the Register Limited Road Access service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('servitude', 'Service - Register Servitude::::::::Service - Register Servitude', 'c', 'Registration Service. Allows the Register Servitude service to be started. ::::::::Registration Service. Allows the Register Servitude service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('regnStandardDocument', 'Service - Registration of Standard Document::::::::Service - Registration of Standard Document', 'c', 'Registration Service. Allows the Register of Standard Document service to be started. ::::::::Registration Service. Allows the Register of Standard Document service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('removeRestriction', 'Service - Remove Restriction::::::::Service - Remove Restriction', 'c', 'Registration Service. Allows the Remove Restriction service to be started. ::::::::Registration Service. Allows the Remove Restriction service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('serviceEnquiry', 'Service - Service Enquiry::::::::Service - Service Enquiry', 'c', 'Supporting Service. Allow the Service Enquiry service to be started.::::::::Supporting Service. Allow the Service Enquiry service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('varyCaveat', 'Service - Vary Caveat::::::::Service - Vary Caveat', 'c', 'Registration Service. Allows the Vary Caveat service to be started. ::::::::Registration Service. Allows the Vary Caveat service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('varyMortgage', 'Service - Vary Mortgage::::::::Service - Vary Mortgage', 'c', 'Registration Service. Allows the Vary Mortgage service to be started.::::::::Registration Service. Allows the Vary Mortgage service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('cnclStandardDocument', 'Service - Withdraw Standard Document::::::::Service - Withdraw Standard Document', 'c', 'Registration Service. Allows the Withdraw Standard Document service to be started. ::::::::Registration Service. Allows the Withdraw Standard Document service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('RevertService', 'Service Action - Revert::::::::Service Action - Revert', 'c', 'Allows any completed service to be reverted to a Pending status for further action. ::::::::Allows any completed service to be reverted to a Pending status for further action.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('redefineCadastre', 'Service - Redefine Cadastre::::::::Service - Redefine Cadastre', 'c', 'Survey Service. Allows the Redefine Cadastre service to be started. ::::::::Survey Service. Allows the Redefine Cadastre service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('caveat', 'Service - Register Caveat::::::::Service - Register Caveat', 'c', 'Registration Service. Allows the Register Caveat service to be started. ::::::::Registration Service. Allows the Register Caveat service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('registerLease', 'Service - Register Lease::::::::Service - Register Lease', 'c', 'Registration Service. Allows the Register Lease service to be started. ::::::::Registration Service. Allows the Register Lease service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('mortgage', 'Service - Register Mortgage::::::::Service - Register Mortgage', 'c', 'Registration Service. Allows the Register Mortgage service to be started. ::::::::Registration Service. Allows the Register Mortgage service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('regnPowerOfAttorney', 'Service - Registration of Power of Attorney::::::::Service - Registration of Power of Attorney', 'c', 'Registration Service. Allows the Registration of Power of Attorney service to be started. ::::::::Registration Service. Allows the Registration of Power of Attorney service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('regnOnTitle', 'Service - Registration on Title::::::::Service - Registration on Title', 'c', 'Registration Service. Allows the Registration on Title service to be started. ::::::::Registration Service. Allows the Registration on Title service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('removeCaveat', 'Service - Remove Caveat::::::::Service - Remove Caveat', 'c', 'Registration Service. Allows the Remove Caveat service to be started. ::::::::Registration Service. Allows the Remove Caveat service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('removeRight', 'Service - Remove Right (General)::::::::Service - Remove Right (General)', 'c', 'Registration Service. Allows the Remove Right (General) service to be started. ::::::::Registration Service. Allows the Remove Right (General) service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('surveyPlanCopy', 'Service - Survey Plan Copy::::::::Service - Survey Plan Copy', 'c', 'Supporting Service. Allows the Survey Plan Copy service to be started. ::::::::Supporting Service. Allows the Survey Plan Copy service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('titleSearch', 'Service - Title Search::::::::Service - Title Search', 'c', 'Supporting Service. Allows the Title Search service to be started. ::::::::Supporting Service. Allows the Title Search service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('varyRight', 'Service - Vary Right (General)::::::::Service - Vary Right (General)', 'c', 'Registration Service. Allows the Vary Right (General) service to be started. ::::::::Registration Service. Allows the Vary Right (General) service to be started.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('CompleteService', 'Service Action - Complete::::::::Service Action - Complete', 'c', 'Allows any service to be completed::::::::Allows any service to be completed');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('StartService', 'Service Action - Start::::::::Service Action - Start', 'c', 'Allows any user to click the Start action. Note that the user must also have the appropraite Service role as well before they can successfully start the service. ::::::::Allows any user to click the Start action. Note that the user must also have the appropraite Service role as well before they can successfully start the service.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('CancelService', 'Service Action - Cancel::::::::Service Action - Cancel', 'c', 'Allows any service to be cancelled.::::::::Allows any service to be cancelled.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ReportGenerate', 'Reporting - Management Reports::::::::Reporting - Management Reports', 'c', 'Allows users to generate and view management reports (e.g. Lodgement Report)::::::::Allows users to generate and view management reports (e.g. Lodgement Report)');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('ApplnResubmit', 'Appln Action - Resubmit::::::::Appln Action - Resubmit', 'c', 'Required to perform the Resubmit applicaiton action. The Resubmit action transitions the application into the Lodged state if it is currently On Hold. ::::::::Required to perform the Resubmit applicaiton action. The Resubmit action transitions the application into the Lodged state if it is currently On Hold.');

INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('NoPasswordExpiry', 'Admin - No Password Expiry::::::::Admin - No Password Expiry', 'c', 'Users with this role will not be subject to a password expiry if one is in place. This role can be assigned to user accounts used by other systems to integrate with the SOLA web services. Note that password expiry can be configured using the pword-expiry-days system.setting::::::::Users with this role will not be subject to a password expiry if one is in place. This role can be assigned to user accounts used by other systems to integrate with the SOLA web services.');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br_severity_type (code, display_value, status, description) 
VALUES ('critical', 'Critical::::::::Критичное', 'c', '');

INSERT INTO system.br_severity_type (code, display_value, status, description) 
VALUES ('medium', 'Medium::::::::Среднее', 'c', '');

INSERT INTO system.br_severity_type (code, display_value, status, description) 
VALUES ('warning', 'Warning::::::::Предупреждение', 'c', '');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br_technical_type (code, display_value, status, description) 
VALUES ('sql', 'SQL::::SQL::::SQL', 'c', 'The rule definition is based in sql and it is executed by the database engine.::::::::The rule definition is based in sql and it is executed by the database engine.');

INSERT INTO system.br_technical_type (code, display_value, status, description) 
VALUES ('drools', 'Drools::::Drools::::Drools', 'c', 'The rule definition is based on Drools engine.::::::::The rule definition is based on Drools engine.');

----------------------------------------------------------------------------------------------------

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('cadastre_object', 'Cadastre Object::::Oggetto Catastale::::Кадастровый Объект', 'c', 'The target of the validation is the transaction related with the cadastre change. It accepts one parameter {id} which is the transaction id.::::::::Объектом проверки является кадастровый объект. Имеется один входной параметр - {id} который является id транзакции.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('rrr', 'Right or Restriction::::Diritto o Rstrizione::::Право или Ограничение', 'c', 'The target of the validation is the rrr. It accepts one parameter {id} which is the rrr id. ::::::::Объектом проверки является право. Имеется один входной параметр - {id} который является id права.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('spatial_unit_group', 'Spatial unit group::::::::Пространственная группа', 'c', 'The target of the validation are the spatial unit groups::::::::Объектом проверки является пространственные группы');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('ba_unit', 'Administrative Unit::::Unita Amministrativa::::Единица Недвижимости', 'c', 'The target of the validation is the ba_unit. It accepts one parameter {id} which is the ba_unit id.::::::::Объектом проверки является единица недвижимости. Имеется один входной параметр - {id} который является id недвижимости.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('bulkOperationSpatial', 'BUlk operation::::::::Массовая Операция', 'c', 'The target of the validation is the transaction related with the bulk operations.::::::::Объектом проверки является транзакция, отосящаяся к массовым операциям.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('public_display', 'Public display::::::::Публичный показ', 'c', 'The target of the validation is the set of cadastre objects/ba units that belong to a certain last part. It accepts one parameter {lastPart} which is the last part.::::::::Объектом проверки является комбинация кадастрового объекта и ед. недвижимости содержащих одинакокую последнюю часть идентификационного кода. Имеется один входной параметр - {lastPart} который является последней частью идентификационного кода.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('source', 'Source::::Sorgente::::Документ', 'c', 'The target of the validation is the source. It accepts one parameter {id} which is the source id.::::::::Объектом проверки является документ. Имеется один входной параметр - {id} который является id документа.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('service', 'Service::::Servizio::::Услуга', 'c', 'The target of the validation is the service. It accepts one parameter {id} which is the service id.::::::::Объектом проверки является услуга. Имеется один входной параметр - {id} который является id услуги.');

INSERT INTO system.br_validation_target_type (code, display_value, status, description) 
VALUES ('application', 'Application::::Pratica::::Заявление', 'c', 'The target of the validation is the application. It accepts one parameter {id} which is the application id.::::::::Объектом проверки является заявление. Имеется один входной параметр - {id} который является id заявления.');

----------------------------------------------------------------------------------------------------

INSERT INTO system.language (code, display_value, active, is_default, item_order) 
VALUES ('ru-RU', 'new_lanuage::::::::Русский', 't', 'f', 3);

INSERT INTO system.language (code, display_value, active, is_default, item_order) 
VALUES ('en-US', 'English::::Inglese::::Английский', 't', 't', 1);

INSERT INTO system.language (code, display_value, active, is_default, item_order) 
VALUES ('it-IT', 'Italian::::Italiano::::Итальянский', 't', 'f', 2);

----------------------------------------------------------------------------------------------------

INSERT INTO transaction.reg_status_type (code, display_value, description, status) 
VALUES ('current', 'Current::::::::Текущий', '', 'c');

INSERT INTO transaction.reg_status_type (code, display_value, description, status) 
VALUES ('pending', 'Pending::::::::На исполнении', '', 'c');

INSERT INTO transaction.reg_status_type (code, display_value, description, status) 
VALUES ('historic', 'Historic::::::::История', '', 'c');

INSERT INTO transaction.reg_status_type (code, display_value, description, status) 
VALUES ('previous', 'Previous::::::::Предыдущий', '', 'c');

----------------------------------------------------------------------------------------------------

INSERT INTO transaction.transaction_status_type (code, display_value, description, status) 
VALUES ('approved', 'Approved::::Approvata::::Одобрено', '', 'c');

INSERT INTO transaction.transaction_status_type (code, display_value, description, status) 
VALUES ('cancelled', 'Cancelled::::Cancellata::::Отменено', '', 'c');

INSERT INTO transaction.transaction_status_type (code, display_value, description, status) 
VALUES ('pending', 'Pending::::In Attesa::::Незавершено', '', 'c');

INSERT INTO transaction.transaction_status_type (code, display_value, description, status) 
VALUES ('completed', 'Completed::::Completato::::Завершено', '', 'c');

----------------------------------------------------------------------------------------------------

