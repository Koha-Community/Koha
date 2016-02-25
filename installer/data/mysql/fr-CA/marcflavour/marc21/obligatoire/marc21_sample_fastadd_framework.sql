INSERT IGNORE INTO biblio_framework VALUES
		('FA', 'Grille d\'ajout rapide');

INSERT IGNORE INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'FA'
FROM marc_tag_structure
WHERE frameworkcode = '' AND
tagfield IN ('000', '008', '010', '020', '022', '050', '082', '090', '099', '100', '245', '250', '260', '300', '500', '942', '952', '999');

INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'FA', seealso, link, defaultvalue
FROM marc_subfield_structure
WHERE frameworkcode = '' AND
tagfield IN ('000', '008', '010', '020', '022', '050', '082', '090', '099', '100', '245', '250', '260', '300', '500', '942', '952', '999');

-- ****************************************
-- AFFICHE LES SOUS-ZONES DANS LA GRILLE FA
-- ****************************************

UPDATE marc_subfield_structure SET tab = 0 WHERE tagfield IN ('100','245','250','260','300','500','942') AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '010' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '010' AND tagsubfield = 'b' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '010' AND tagsubfield = 'z' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '020' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '020' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '020' AND tagsubfield = 'z' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '082' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '082' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='5' WHERE tagfield = '090' AND tagsubfield = 'a' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='5' WHERE tagfield = '090' AND tagsubfield = 'b' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = '9' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'b' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'c' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'f' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'g' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'j' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'k' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'l' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'n' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'p' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 't' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '100' AND tagsubfield = 'u' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'd' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'e' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'f' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'g' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'k' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'n' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 'p' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '245' AND tagsubfield = 's' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '250' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '250' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = 'd' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = 'e' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = 'f' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = 'g' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = 'k' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '260' AND tagsubfield = 'l' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = '3' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = '5' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = '8' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = 'l' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = 'n' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = 'x' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '500' AND tagsubfield = 'z' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='5' WHERE tagfield = '942' AND tagsubfield = '0' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='5' WHERE tagfield = '942' AND tagsubfield = 'c' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='5' WHERE tagfield = '942' AND tagsubfield = 'n' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='5' WHERE tagfield = '942' AND tagsubfield = 's' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = '1' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = '3' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = '6' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = '9' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'j' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'l' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'm' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'n' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'q' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'r' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 's' AND frameworkcode = 'FA';
UPDATE marc_subfield_structure SET hidden ='0' WHERE tagfield = '952' AND tagsubfield = 'x' AND frameworkcode = 'FA';
