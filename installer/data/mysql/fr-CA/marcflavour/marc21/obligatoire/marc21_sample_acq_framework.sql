INSERT IGNORE INTO biblio_framework VALUES
		('ACQ', 'Grille d\'acquisitions');

INSERT IGNORE INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'ACQ'
FROM marc_tag_structure
WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'ACQ', seealso, link, defaultvalue
FROM marc_subfield_structure
WHERE frameworkcode = '';

INSERT INTO marc_tag_structure(tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'ACQ'
FROM marc_tag_structure
WHERE frameworkcode="" AND tagfield IN (
    SELECT tagfield
    FROM marc_subfield_structure
    WHERE (
            kohafield="biblio.title"
        OR  kohafield="biblio.author"
        OR  kohafield="biblioitems.publishercode"
        OR  kohafield="biblioitems.editionstatement"
        OR  kohafield="biblio.copyrightdate"
        OR  kohafield="biblioitems.isbn"
        OR  kohafield="biblio.seriestitle"
    ) AND frameworkcode=""
);
INSERT INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue, maxlength)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'ACQ', seealso, link, defaultvalue, maxlength
FROM marc_subfield_structure
WHERE frameworkcode=""
AND kohafield IN ("biblio.title", "biblio.author", "biblioitems.publishercode", "biblioitems.editionstatement", "biblio.copyrightdate", "biblioitems.isbn", "biblio.seriestitle" );

-- **************************************
-- IGNORE CERTAINES SOUS-ZONES EXEMPLAIRE
-- **************************************

UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = '0' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = '1' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = '2' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = '4' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = '5' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'f' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'g' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'j' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'l' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'm' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'n' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'q' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'r' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 's' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'u' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'v' AND frameworkcode = 'ACQ';
UPDATE marc_subfield_structure SET tab = -1 WHERE tagfield = '952' AND tagsubfield = 'w' AND frameworkcode = 'ACQ';
