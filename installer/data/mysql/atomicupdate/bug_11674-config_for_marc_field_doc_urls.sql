
INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
VALUES ('MarcFieldDocURL', NULL, NULL, 'URL used for MARC field documentation. Following substitutions are available: {MARC} = marc flavour, eg. \"MARC21\" or \"UNIMARC\". {FIELD} = field number, eg. \"000\" or \"048\". {LANG} = user language, eg. \"en\" or \"fi-FI\"', 'free');
