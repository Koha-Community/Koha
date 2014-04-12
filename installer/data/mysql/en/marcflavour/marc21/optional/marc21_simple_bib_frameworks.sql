-- *************************************************************
--       SIMPLE KOHA MARC 21 BIBLIOGRAPHIC FRAMEWORKS
-- *************************************************************


-- *******************************************************************
-- SIMPLE BOOKS KOHA RECORD AND HOLDINGS MANAGEMENT FIELDS/SUBFIELDS.
-- *******************************************************************
INSERT IGNORE INTO biblio_framework VALUES ( 'BKS', 'Books, Booklets, Workbooks' );

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
INSERT IGNORE INTO biblio_framework VALUES ( 'CF', 'CD-ROMs, DVD-ROMs, General Online Resources' );
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
INSERT IGNORE INTO biblio_framework VALUES ( 'SR', 'Audio Cassettes, CDs' );

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
INSERT IGNORE INTO biblio_framework VALUES ( 'VR', 'DVDs, VHS' );

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
INSERT IGNORE INTO biblio_framework VALUES ( 'AR', 'Models' );

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
INSERT IGNORE INTO biblio_framework VALUES ( 'KT', 'Kits' );

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
INSERT IGNORE INTO biblio_framework VALUES ( 'IR', 'Binders' );

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
INSERT IGNORE INTO biblio_framework VALUES ( 'SER', 'Serials' );

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
