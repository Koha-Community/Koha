INSERT IGNORE INTO biblio_framework VALUES
		('SIMP', 'Grille simplifiée');

INSERT IGNORE INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'SIMP'
FROM marc_tag_structure
WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'SIMP', seealso, link, defaultvalue
FROM marc_subfield_structure
WHERE frameworkcode = '';

-- ********************************************
-- AFFICHAGE DES SOUS-ZONES DANS LA GRILLE SIMP
-- ********************************************
;
UPDATE marc_subfield_structure SET tab='-1', hidden = 8 WHERE frameworkcode = 'SIMP';
;
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='000' AND tagsubfield = '@';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='001' AND tagsubfield = '@';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='008' AND tagsubfield = '@';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='020' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='022' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='050' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='080' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='082' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='100' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='110' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='245' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='245' AND tagsubfield = 'b';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='245' AND tagsubfield = 'c';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='260' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='260' AND tagsubfield = 'b';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='260' AND tagsubfield = 'c';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='264' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='264' AND tagsubfield = 'b';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='264' AND tagsubfield = 'c';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='300' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='300' AND tagsubfield = 'b';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='300' AND tagsubfield = 'c';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='490' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='490' AND tagsubfield = 'v';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='500' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='520' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='650' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='650' AND tagsubfield = 'x';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='650' AND tagsubfield = 'y';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='650' AND tagsubfield = 'z';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='700' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='710' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='942' AND tagsubfield = '2';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='942' AND tagsubfield = 'c';
UPDATE marc_subfield_structure SET tab='0',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='942' AND tagsubfield = 'n';

UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = '2';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = '3';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = '7';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = '8';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'a';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'b';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'c';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'h';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'o';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'p';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'x';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'y';
UPDATE marc_subfield_structure SET tab='10',hidden='0' WHERE frameworkcode = 'SIMP' AND tagfield='952' AND tagsubfield = 'z';
