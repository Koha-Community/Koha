-- На основі MARC21-структури англійською „DEFAULT“
-- Переклад/адаптація: Сергій Дубик, Ольга Баркова (2011)

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '090', '', 1, 'LOCAL CALL NUMBER (SERIES) [OBSOLETE]; LOCALLY ASSIGNED LC-TYPE CALL NUMBER (OCLC); LOCAL CALL NUMBER (RLIN)', 'LOCAL CALL NUMBER (SERIES) [OBSOLETE]; LOCALLY ASSIGNED LC-TYPE CALL NUMBER (OCLC); LOCAL CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '090', '2', 0, 0, 'Number source', 'Number source',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', '5', 0, 1, 'Institution to which field applies', 'Institution to which field applies', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', '6', 0, 0, 'Linkage', 'Linkage',                       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'a', 0, 1, 'Call number ; Classification number (OCLC) (R) ; Classification number, CALL (RLIN) (NR)', 'Call number ; Classification number (OCLC) (R) ; Classification number, CALL (RLIN) (NR)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'b', 0, 0, 'Item number ; Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 'Item number ; Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'd', 0, 0, 'Volumes/dates to which call number applies', 'Volumes/dates to which call number applies', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'e', 0, 0, 'Feature heading (OCLC)', 'Feature heading (OCLC)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'f', 0, 0, 'Filing suffix (OCLC) ; Footnote, FNT (RLIN)', 'Filing suffix (OCLC) ; Footnote, FNT (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'h', 0, 0, 'Output transaction history, HST (RLIN)', 'Output transaction history, HST (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'i', 0, 0, 'Output transaction instruction, INS (RLIN)', 'Output transaction instruction, INS (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'l', 0, 0, 'Extra card control statement, EXT (RLIN)', 'Extra card control statement, EXT (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'n', 0, 0, 'Additional local notes, ANT (RLIN)', 'Additional local notes, ANT (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'p', 0, 0, 'Pathfinder code, PTH (RLIN)', 'Pathfinder code, PTH (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 't', 0, 0, 'Field suppresion, FSP (RLIN)', 'Field suppresion, FSP (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'v', 0, 0, 'Volumes, VOL (RLIN)', 'Volumes, VOL (RLIN)', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'y', 0, 0, 'Date, VOL (RLIN)', 'Date, VOL (RLIN)',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '090', 'z', 0, 1, 'Cancelled/invalid call number', 'Cancelled/invalid call number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '099', '', 1, 'LOCAL FREE-TEXT CALL NUMBER (OCLC)', 'LOCAL FREE-TEXT CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '099', '2', 0, 0, 'Edition number', 'Edition number',         0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', '5', 0, 1, 'Institution to which field applies', 'Institution to which field applies', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', '6', 0, 0, 'Linkage', 'Linkage',                       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', 'a', 0, 0, 'Classification number', 'Classification number', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', 'b', 0, 0, 'Item number', 'Item number',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', 'd', 0, 0, 'Volumes/dates to which call number applies', 'Volumes/dates to which call number applies', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '099', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, 0, '', NULL, NULL, 0, NULL, 0);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '880', '9', 0, 1, 9, 9,                                       8, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '942', 1, '', 'KOHA INTERNAL USE', 'KOHA INTERNAL USE', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '942', 'a', 1, 0, 'Koha auth type', 'Koha auth type',         9, 8, 'auth_header.authtypecode', NULL, NULL, 0, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
