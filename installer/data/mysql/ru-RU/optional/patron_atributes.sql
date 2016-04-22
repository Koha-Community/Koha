TRUNCATE borrower_attribute_types;

INSERT INTO `borrower_attribute_types` (`code`, `description`, `repeatable`, `unique_id`, `opac_display`, `staff_searchable`, `authorised_value_category`) VALUES
('EDUCATION',  'Образование',                            1, 0, 1, 1, ''),
('EDU_INST',   'Учебное заведение',                      1, 0, 1, 1, ''),
('ETHNICITY',  'Этническая принадлежность',              0, 0, 1, 1, ''),
('ETHNICNOTE', 'Замечания по этнической принадлежности', 0, 0, 1, 1, ''),
('IDLDAP',     'Идентификатор LDAP',                     0, 0, 0, 1, ''),
('NATIONAL',   'Национальность',                         0, 0, 1, 0, ''),
('PASSP_NO',   'Серия и номер паспорта',                 0, 0, 0, 0, ''),
('PAS_IS_DAT', 'Когда выдан паспорт',                    0, 0, 0, 0, ''),
('PAS_IS_ORG', 'Где выдан паспорт',                      0, 0, 0, 0, ''),
('PATRONYMIC', 'Отчество',                               0, 0, 1, 1, ''),
('PROFESSION', 'Профессия',                              1, 0, 1, 1, '');
