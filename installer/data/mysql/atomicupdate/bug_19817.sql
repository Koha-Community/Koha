INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
VALUES ('KohaManualBaseURL','https://koha-community.org/manual/','','Where is the Koha manual/documentation located?','Free');

INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
VALUES ('KohaManualLanguage','en','en|ar|cs|es|de|fr|it|pt_BR|tr|zh_TW','What is the language of the online manual you want to use?','Choice');
