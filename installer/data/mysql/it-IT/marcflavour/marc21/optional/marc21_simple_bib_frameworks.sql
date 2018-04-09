-- *************************************************************
--       SIMPLE KOHA MARC 21 BIBLIOGRAPHIC FRAMEWORKS
-- *************************************************************


-- *******************************************************************
-- SIMPLE BOOKS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- *******************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'BKS', 'Libri' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'BKS'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'BKS', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************

-- ****************************************************************************
-- SIMPLE COMPUTER FILES KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- ****************************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'CF', 'Risorse elettroniche' );
INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'CF'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'CF', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************


-- *****************************************************************************
-- SIMPLE SOUND RECORDINGS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- *****************************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'SR', 'CD e cassette audio' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'SR'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'SR', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************


-- ****************************************************************************
-- SIMPLE VIDEORECORDINGS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- ****************************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'VR', 'DVD, VHS' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'VR'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'VR', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************


-- **************************************************************************
-- SIMPLE 3D ARTIFACTS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- **************************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'AR', 'Modelli' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'AR'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'AR', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************


-- ******************************************************************
-- SIMPLE KITS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- ******************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'KT', 'Kits' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'KT'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'KT', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- ******************************************************


-- **********************************************************************************
-- SIMPLE INTEGRATING RESOURCES KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- **********************************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'IR', 'Raccolte' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'IR'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'IR', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************


-- *********************************************************************
-- SIMPLE SERIALS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- *********************************************************************
INSERT IGNORE INTO biblio_framework VALUES
		( 'SER', 'Seriali' );

INSERT IGNORE INTO marc_tag_structure (
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
	SELECT
		tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'SER'
	FROM marc_tag_structure
	WHERE frameworkcode = '';

INSERT IGNORE INTO marc_subfield_structure (
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue)
	SELECT
		tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value,
		authtypecode, value_builder, isurl, hidden, 'SER', seealso, link, defaultvalue
	FROM marc_subfield_structure
	WHERE frameworkcode = '';
-- *******************************************************

-- **************************************
-- REVERT HIDDEN FIELD TO ORIGINAL VALUES
-- **************************************
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '001' AND tagsubfield = '@' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '003' AND tagsubfield = '@' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '005' AND tagsubfield = '@' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '010' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '010' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '010' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '015' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '015' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '016' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '016' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '016' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '020' AND tagsubfield = 'a' AND frameworkcode IN ('AR','CF','IR','KT','SR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '020' AND tagsubfield = 'a' AND frameworkcode IN ('SER','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '020' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '020' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '022' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '022' AND tagsubfield = 'a' AND frameworkcode IN ('CF','IR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '022' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '022' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '022' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '024' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '024' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '024' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '024' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '024' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '027' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '027' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '028' AND tagsubfield = 'a' AND frameworkcode IN ('BKS','IR','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '028' AND tagsubfield = 'b' AND frameworkcode IN ('BKS','IR','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '035' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '035' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '040' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '040' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '040' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '040' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '041' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','IR','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '041' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '045' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '045' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '047' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '047' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '048' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '048' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '048' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '074' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '086' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '100' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = 0 WHERE tagfield = '100' AND tagsubfield = '9' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '100' AND tagsubfield = 'a' AND frameworkcode IN ('CF','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '100' AND tagsubfield = 'd' AND frameworkcode IN ('CF','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '100' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '100' AND tagsubfield = 'q' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '110' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '110' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '110' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '110' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '111' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '111' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '111' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '111' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '111' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '111' AND tagsubfield = 'j' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '130' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '130' AND tagsubfield = 'l' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '130' AND tagsubfield = 'r' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '210' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '210' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '210' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '222' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '222' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '240' AND tagsubfield = 'r' AND frameworkcode IN ('AR','BKS','IR','KT','SER','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '243' AND tagsubfield = 'r' AND frameworkcode IN ('CF','SR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '245' AND tagsubfield = 'h' AND frameworkcode IN ('BKS','IR','SER');
UPDATE marc_subfield_structure SET hidden = 0 WHERE tagfield = '246' AND tagsubfield = 'h' AND frameworkcode = 'SR';
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '247' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '247' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '247' AND tagsubfield = 'f' AND frameworkcode IN ('CF','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '247' AND tagsubfield = 'h' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '247' AND tagsubfield = 'x' AND frameworkcode IN ('CF','SER');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '250' AND tagsubfield = 'a' AND frameworkcode IN ('AR','CF','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '250' AND tagsubfield = 'b' AND frameworkcode IN ('AR','CF','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '260' AND tagsubfield = 'a' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '260' AND tagsubfield = 'b' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '260' AND tagsubfield = 'c' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '270' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '300' AND tagsubfield = 'f' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '300' AND tagsubfield = 'g' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '306' AND tagsubfield = 'a' AND frameworkcode = 'KT';
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '306' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '310' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '310' AND tagsubfield = 'b' AND frameworkcode IN ('CF','SER');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '362' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','IR','KT','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '490' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '490' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '490' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '500' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '501' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '504' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '505' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '505' AND tagsubfield = 'g' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '505' AND tagsubfield = 'r' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '505' AND tagsubfield = 't' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '505' AND tagsubfield = 'u' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '506' AND tagsubfield = 'a' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '506' AND tagsubfield = 'b' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '506' AND tagsubfield = 'c' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '506' AND tagsubfield = 'd' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '506' AND tagsubfield = 'e' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '506' AND tagsubfield = 'u' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '507' AND tagsubfield = 'a' AND frameworkcode = 'AR';
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '507' AND tagsubfield = 'b' AND frameworkcode = 'AR';
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '508' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '511' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '516' AND tagsubfield = 'a' AND frameworkcode = 'VR';
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '518' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '520' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '520' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '520' AND tagsubfield = 'u' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '521' AND tagsubfield = 'a' AND frameworkcode IN ('SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '521' AND tagsubfield = 'b' AND frameworkcode IN ('SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '524' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '526' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '526' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '526' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '526' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '530' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '530' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '530' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '530' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '530' AND tagsubfield = 'u' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'f' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'm' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '533' AND tagsubfield = 'n' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '546' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '546' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '555' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '555' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '555' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '555' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '555' AND tagsubfield = 'u' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '556' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '556' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '562' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '562' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '562' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '562' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '562' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '563' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '563' AND tagsubfield = 'u' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '585' AND tagsubfield = '3' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '585' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'q' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 't' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '600' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 't' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '610' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 'l' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 't' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '630' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '648' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '648' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '648' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '648' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '648' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '648' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '651' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '651' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '651' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '651' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '651' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '651' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '653' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '654' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '655' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = 'k' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '656' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '657' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '657' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '657' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '657' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '657' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '657' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '658' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '658' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'f' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'g' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '662' AND tagsubfield = 'h' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '690' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '690' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '690' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '690' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '690' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '690' AND tagsubfield = 'v' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '690' AND tagsubfield = 'x' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '690' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '690' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '700' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '700' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '700' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '700' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '700' AND tagsubfield = 'q' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '710' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '710' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '710' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '710' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '711' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '711' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '711' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '711' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '711' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '711' AND tagsubfield = 'j' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '720' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '720' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '720' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '730' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '730' AND tagsubfield = 'l' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '730' AND tagsubfield = 'm' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '730' AND tagsubfield = 'r' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '740' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '800' AND tagsubfield = 'q' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '810' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '810' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '810' AND tagsubfield = 'b' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '810' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '810' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '810' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '811' AND tagsubfield = '4' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '811' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '811' AND tagsubfield = 'c' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '811' AND tagsubfield = 'd' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '811' AND tagsubfield = 'e' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '811' AND tagsubfield = 'j' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '830' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '830' AND tagsubfield = 'l' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '830' AND tagsubfield = 'r' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '830' AND tagsubfield = 's' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '856' AND tagsubfield = '3' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '856' AND tagsubfield = 'u' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '856' AND tagsubfield = 'y' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -1 WHERE tagfield = '856' AND tagsubfield = 'z' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '887' AND tagsubfield = '2' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = -6 WHERE tagfield = '887' AND tagsubfield = 'a' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = 9 WHERE tagfield = '942' AND tagsubfield = 'i' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');
UPDATE marc_subfield_structure SET hidden = 0 WHERE tagfield = '952' AND tagsubfield = '1' AND frameworkcode IN ('AR','BKS','CF','IR','KT','SER','SR','VR');

-- Create the ACQ framework based on the default framework, fields 952 only
INSERT IGNORE INTO biblio_framework VALUES( 'ACQ', 'Acquisition framework' );
INSERT INTO marc_tag_structure(tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'ACQ' FROM marc_tag_structure WHERE tagfield='952' AND frameworkcode='';

INSERT INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue, maxlength)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'ACQ', seealso, link, defaultvalue, maxlength FROM marc_subfield_structure WHERE tagfield='952' AND frameworkcode='';

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
