#  $Id$
#  
#  $Log$
#  Revision 1.14  2002/06/04 08:13:31  tipaul
#  ouuppsss... forget the 1.13 version, i made a mistake. This version works and should be the last
#
#  Revision 1.13/1.14  2002/06/04 07:56:56  tipaul
#  New and hopefully last version of the MARC-DB. Is the fastest in benchmark, everybody agree ;-) (Sergey, Steve and me, Paul)
#
#  Revision 1.13 2002/06/04 Paul
#  should be the last version... remains only 2 tables : the main table and the subfield one.
#  benchmark shows this structure is the fastest. I had to add indicator in the subfield table. should be in a tag_table, but as it s the
#  only real information that should be in this table, it has been thrown to subfield table (not a normal form, but an optimized one...)
#
#  Revision 1.12  2002/05/31 20:03:17  tonnesen
#  removed another _sergey
#
#  Revision 1.11  2002/05/31 19:41:29  tonnesen
#  removed fieldid in favour of tagid, removed _sergey from table names, added
#  tagorder field to tag table, renamed marc_field_table to marc_tag_table.
#
#
#
#  These first three tables store the data from a MARC record.
	
# marc_biblio contains 1 record for each biblio in the DB
CREATE TABLE marc_biblio (
		bibid bigint(20) unsigned NOT NULL auto_increment,
		datecreated date NOT NULL default '0000-00-00',
		datemodified date default NULL,
		origincode char(20) default NULL,
		PRIMARY KEY  (bibid),
		KEY origincode (origincode)
		) TYPE=MyISAM;

CREATE TABLE marc_subfield_table (
	subfieldid  bigint(20) unsigned NOT NULL auto_increment,# subfield identifier
	bibid bigint(20) unsigned NOT NULL, 			# link to marc_biblio table
	tag char(3) NOT NULL,					# tag number
	tagorder tinyint(4) NOT NULL default '1',		# display order for tags within a biblio when a tag is repeated
	tag_indicator char(2) NOT NULL,				# tag indicator
	subfieldcode char(1) NOT NULL default '',		# subfield code
	subfieldorder tinyint(4) NOT NULL default '1',		# display order for subfields within a tag when a subfield is repeated
	subfieldvalue varchar(255) default NULL,		# the subfields value if not longer than 255 char
	valuebloblink bigint(20) default NULL,			# the link to the blob, if value is longer than 255 char
	PRIMARY KEY (subfieldid),
	KEY bibid (bibid),
	KEY tag (tag),
	KEY tag_indicator (tag_indicator),
	KEY subfieldorder (subfieldorder),
	KEY subfieldcode (subfieldcode),
	KEY subfieldvalue (subfieldvalue)
);

# marc_blob_subfield containts subfields longer than 255 car.
# They are linked to a marc_subfield_table record by bloblink
	CREATE TABLE marc_blob_subfield (
		blobidlink bigint(20) NOT NULL auto_increment,
		subfieldvalue longtext NOT NULL,
		PRIMARY KEY  (blobidlink)
		) TYPE=MyISAM;

# The next two tables are used for labelling the tags and subfields for
# different implementions of marc USMARC, UNIMARC, CANMARC, UKMARC, etc.

# marc_tag_structure contains the definition of the marc tags.
# any MARC is supposed to be support-able
	CREATE TABLE marc_tag_structure (
		tagfield char(3) NOT NULL default '',
		liblibrarian char(255) NOT NULL default '',
		libopac char(255) NOT NULL default '',
		repeatable tinyint(4) NOT NULL default '0',
		mandatory tinyint(4) NOT NULL default '0',
		PRIMARY KEY  (tagfield)
		) TYPE=MyISAM;


# marc_subfield_structure contains the definition of the marc
# subfields. Any MARC is supposed to be support-able
	CREATE TABLE marc_subfield_structure (
		tagfield char(3) NOT NULL default '',
		tagsubfield char(1) NOT NULL default '',
		liblibrarian char(255) NOT NULL default '', 	# the text shown to a librarian
		libopac char(255) NOT NULL default '',		# the text shown to an opac user
		repeatable tinyint(4) NOT NULL default '0',	# is the field repeatable 0/1 ?
		mandatory tinyint(4) NOT NULL default '0',	# is the subfield mandatory in manual add 0/1 ?
		kohafield char(40) NOT NULL default '',		# the name of the normal-koha- DB field
		PRIMARY KEY  (tagfield,tagsubfield)
		) TYPE=MyISAM;


# This table is the table used for searching the marc records

# marc_tag_word contains 1 record for each word in each subfield in each tag in each biblio
	CREATE TABLE marc_word (
		bibid bigint(20) NOT NULL default '0',
		tag char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '1',
		subfieldid char(1) NOT NULL default '',
		subfieldorder tinyint(4) NOT NULL default '1',
		word varchar(255) NOT NULL default '',
		sndx_word varchar(255) NOT NULL default '', 	# the soundex version of the word (indexed)
		KEY bibid (bibid),
		KEY tag (tag),
		KEY tagorder (tagorder),
		KEY subfieldid (subfieldid),
		KEY subfieldorder (subfieldorder),
		KEY word (word),
		KEY sndx_word (sndx_word)
		) TYPE=MyISAM;

