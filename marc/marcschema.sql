# marc_biblio contains 1 record for each biblio in the DB
	CREATE TABLE marc_biblio (
		bibcode bigint(20) unsigned NOT NULL auto_increment,
		datecreated date NOT NULL default '0000-00-00',
		datemodified date default NULL,
		origincode char(20) default NULL,
		PRIMARY KEY  (bibcode),
		KEY origincode (origincode)
		) TYPE=MyISAM;


# marc NXX_table contains 1 record for each tag of every biblio
# if the tag is more than 255 length, the value is in the marc_blob_tag table,
# the valuebloblink contains the number of the blob
	CREATE TABLE marc_0XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_1XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_2XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_3XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_4XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_5XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_6XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_7XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_8XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;
	CREATE TABLE marc_9XX_tag_table (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		tagorder tinyint(4) NOT NULL default '0',
		indicator char(2) NOT NULL default '',
		tagvalue varchar(255) default NULL,
		valuebloblink bigint(20) default NULL,
		PRIMARY KEY  (bibcode,tagnumber,tagorder)
		) TYPE=MyISAM;

# marc_blob_tag containts tag longer than 255 car.
# They are linked to a marc_NXX_tag_table record by bloblink
	CREATE TABLE marc_blob_tag (
		blobidlink bigint(20) NOT NULL auto_increment,
		tagvalue longtext NOT NULL,
		PRIMARY KEY  (blobidlink)
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

# marc_tag_word contains 1 record for each word in each subfield in each tag in each biblio
	CREATE TABLE marc_tag_word (
		bibcode bigint(20) NOT NULL default '0',
		tagnumber char(3) NOT NULL default '',
		subfieldid char(1) NOT NULL default '',
		word varchar(255) NOT NULL default '',
		sndx_word varchar(255) NOT NULL default '', 	# the soundex version of the word (indexed)
		PRIMARY KEY  (bibcode,tagnumber,subfieldid),
		KEY word (word),
		KEY sndx_word (sndx_word)
		) TYPE=MyISAM;













