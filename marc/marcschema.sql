
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
		subfieldid bigint(20) unsigned NOT NULL auto_increment,
		tagid bigint(20) NOT NULL default '0',
		tag char(3) NOT NULL default '',
		bibid bigint(20) NOT NULL default '0',
		subfieldorder tinyint(4) NOT NULL default '0',
		subfieldmark char(1) NOT NULL default '',
		subfieldvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY (subfieldid),
		KEY (bibid,tagid,tag,subfieldmark),
		) TYPE=MyISAM;

# marc_blob_tag containts tag longer than 255 car.
# They are linked to a marc_NXX_tag_table record by bloblink
	CREATE TABLE marc_blob_tag (
		blobidlink bigint(20) NOT NULL auto_increment,
		tagvalue longtext NOT NULL,
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
	CREATE TABLE marc_tag_word (
		bibid bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		subfieldid char(1) NOT NULL default '',
		word varchar(255) NOT NULL default '',
		sndx_word varchar(255) NOT NULL default '', 	# the soundex version of the word (indexed)
		PRIMARY KEY  (bibid,tagnumber,subfieldid),
		KEY word (word),
		KEY sndx_word (sndx_word)
		) TYPE=MyISAM;

