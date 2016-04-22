TRUNCATE borrower_attribute_types;

INSERT INTO `borrower_attribute_types` (`code`, `description`, `repeatable`, `unique_id`, `opac_display`, `staff_searchable`, `authorised_value_category`) VALUES
('EDUCATION',  'Освіта',                               1, 0, 1, 1, ''),
('EDU_INST',   'Учбовий заклад',                       1, 0, 1, 1, ''),
('ETHNICITY',  'Етнічна приналежність',                0, 0, 1, 1, ''),
('ETHNICNOTE', 'Примітки щодо етнічної приналежності', 0, 0, 1, 1, ''),
('IDLDAP',     'Ідентифікатор LDAP',                   0, 0, 0, 1, ''),
('NATIONAL',   'Національність',                       0, 0, 1, 0, ''),
('PASSP_NO',   'Серія та номер паспорта',              0, 0, 0, 0, ''),
('PAS_IS_DAT', 'Коли видано паспорт',                  0, 0, 0, 0, ''),
('PAS_IS_ORG', 'Де видано паспорт',                    0, 0, 0, 0, ''),
('PATRONYMIC', 'По батькові',                          0, 0, 1, 1, ''),
('PROFESSION', 'Професія',                             1, 0, 1, 1, '');
