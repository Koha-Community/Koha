#  $Id$
#  
#  $Log$
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

CREATE TABLE marc_tag_table (
       tagid    bigint(20) unsigned NOT NULL auto_increment,	# tag identifier
       bibid    bigint(20) NOT NULL default '0',                # biblio identifier
       tag      char(3) NOT NULL default '',			# tag number (eg 110)
       tagorder tinyint(4) NOT NULL default '0',		# display order of tag within a record
       PRIMARY KEY (tagid),
       KEY (bibid),
       KEY (tag)
);

CREATE TABLE marc_subfield_table_sergey (
       subfieldid  bigint(20) unsigned NOT NULL auto_increment,	# subfield identifier
       tagid bigint(20),					# tag identifier
       subfieldorder tinyint(4) NOT NULL default '0',		# display order for subfields within a tag
       subfieldcode char(1) NOT NULL default '',		# subfield code
       subfieldvalue varchar(255) default NULL,			# the subfields value if not longer than 255 char
       valuebloblink bigint(20) default NULL,			# the link to the blob, if value is longer than 255 char
       PRIMARY KEY (subfieldid),
       KEY (tagid)
);


# marc_blob_subfield containts subfields longer than 255 car.
# They are linked to a marc_subfield_table record by bloblink
	CREATE TABLE marc_blob_tag (
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

