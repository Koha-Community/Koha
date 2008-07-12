#!/usr/bin/perl


# Database Updater
# This script checks for required updates to the database.

# Part of the Koha Library Software www.koha.org
# Licensed under the GPL.

# Bugs/ToDo:
# - Would also be a good idea to offer to do a backup at this time...

# NOTE:  If you do something more than once in here, make it table driven.
use strict;

# CPAN modules
use DBI;
use Getopt::Long;
# Koha modules
use C4::Context;

use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8' );
 
# FIXME - The user might be installing a new database, so can't rely
# on /etc/koha.conf anyway.

my $debug = 0;

my (
    $sth, $sti,
    $query,
    %existingtables,    # tables already in database
    %types,
    $table,
    $column,
    $type, $null, $key, $default, $extra,
    $prefitem,          # preference item in systempreferences table
);

my $silent;
GetOptions(
    's' =>\$silent
    );
my $dbh = C4::Context->dbh;
$|=1; # flushes output

my $DBversion = "3.00.00.000";
# if we are upgrading from Koha 2.2, then we need to run the complete & long updatedatabase
    # Tables to add if they don't exist
    my %requiretables = (
        action_logs     => "(
                        `timestamp` TIMESTAMP NOT NULL ,
                        `user` INT( 11 ) NOT NULL default '0' ,
                        `module` TEXT default '',
                        `action` TEXT default '' ,
                        `object` INT(11) NULL ,
                        `info` TEXT default '' ,
                        PRIMARY KEY ( `timestamp` , `user` )
                    )",
        letter        => "(
                        module varchar(20) NOT NULL default '',
                        code varchar(20) NOT NULL default '',
                        name varchar(100) NOT NULL default '',
                        title varchar(200) NOT NULL default '',
                        content text,
                        PRIMARY KEY  (module,code)
                    )",
        alert        =>"(
                        alertid int(11) NOT NULL auto_increment,
                        borrowernumber int(11) NOT NULL default '0',
                        type varchar(10) NOT NULL default '',
                        externalid varchar(20) NOT NULL default '',
                        PRIMARY KEY  (alertid),
                        KEY borrowernumber (borrowernumber),
                        KEY type (type,externalid)
                    )",
        opac_news => "(
                    `idnew` int(10) unsigned NOT NULL auto_increment,
                    `title` varchar(250) NOT NULL default '',
                    `new` text NOT NULL,
                    `lang` varchar(4) NOT NULL default '',
                    `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP,
                    PRIMARY KEY  (`idnew`)
                    )",
        repeatable_holidays => "(
                    `id` int(11) NOT NULL auto_increment,
                    `branchcode` varchar(10) NOT NULL default '',
                    `weekday` smallint(6) default NULL,
                    `day` smallint(6) default NULL,
                    `month` smallint(6) default NULL,
                    `title` varchar(50) NOT NULL default '',
                    `description` text NOT NULL,
                    PRIMARY KEY  (`id`)
                    )",
        special_holidays => "(
                    `id` int(11) NOT NULL auto_increment,
                    `branchcode` varchar(10) NOT NULL default '',
                    `day` smallint(6) NOT NULL default '0',
                    `month` smallint(6) NOT NULL default '0',
                    `year` smallint(6) NOT NULL default '0',
                    `isexception` smallint(1) NOT NULL default '1',
                    `title` varchar(50) NOT NULL default '',
                    `description` text NOT NULL,
                    PRIMARY KEY  (`id`)
                    )",
        overduerules    =>"(`branchcode` varchar(10) NOT NULL default '',
                        `categorycode` varchar(2) NOT NULL default '',
                        `delay1` int(4) default '0',
                        `letter1` varchar(20) default NULL,
                        `debarred1` varchar(1) default '0',
                        `delay2` int(4) default '0',
                        `debarred2` varchar(1) default '0',
                        `letter2` varchar(20) default NULL,
                        `delay3` int(4) default '0',
                        `letter3` varchar(20) default NULL,
                        `debarred3` int(1) default '0',
                        PRIMARY KEY  (`branchcode`,`categorycode`)
                        )",
        cities            => "(`cityid` int auto_increment,
                            `city_name` varchar(100) NOT NULL default '',
                            `city_zipcode` varchar(20),
                            PRIMARY KEY (`cityid`)
                        )",
        roadtype            => "(`roadtypeid` int auto_increment,
                            `road_type` varchar(100) NOT NULL default '',
                            PRIMARY KEY (`roadtypeid`)
                        )",
    
        labels                     => "(
                    labelid int(11) NOT NULL auto_increment,
                                batch_id varchar(10) NOT NULL default '1',
                                itemnumber varchar(100) NOT NULL default '',
                                timestamp timestamp(14) NOT NULL,
                                PRIMARY KEY  (labelid)
                                )",
    
        labels_conf                => "(
                    id int(4) NOT NULL auto_increment,
                                barcodetype char(100) default '',
                                title int(1) default '0',
                                subtitle int(1) default '0',
                                itemtype int(1) default '0',
                                barcode int(1) default '0',
                                dewey int(1) default '0',
                                class int(1) default '0',
                                subclass int(1) default '0',
                                itemcallnumber int(1) default '0',
                                author int(1) default '0',
                                issn int(1) default '0',
                                isbn int(1) default '0',
                                startlabel int(2) NOT NULL default '1',
                                printingtype char(32) default 'BAR',
                                layoutname char(20) NOT NULL default 'TEST',
                                guidebox int(1) default '0',
                                active tinyint(1) default '1',
                                fonttype char(10) collate utf8_unicode_ci default NULL,
                                ccode char(4) collate utf8_unicode_ci default NULL,
                                callnum_split int(1) default NULL,
                                text_justify char(1) collate utf8_unicode_ci default NULL,
                                PRIMARY KEY  (id)
                                )",
        reviews                  => "(
                                reviewid integer NOT NULL auto_increment,
                                borrowernumber integer,
                                biblionumber integer,
                                review text,
                                approved tinyint,
                                datereviewed datetime,
                                PRIMARY KEY (reviewid)
                                )",
        subscriptionroutinglist=>"(
                                routingid integer NOT NULL auto_increment,
                                borrowernumber integer,
                                ranking integer,
                                subscriptionid integer,
                                PRIMARY KEY (routingid)
                                )",
    
        notifys    => "(
                notify_id int(11) NOT NULL default '0',
                    `borrowernumber` int(11) NOT NULL default '0',
                `itemnumber` int(11) NOT NULL default '0',
                `notify_date` date default NULL,
                        `notify_send_date` date default NULL,
                        `notify_level` int(1) NOT NULL default '0',
                        `method` varchar(20) NOT NULL default ''
                )",
    
    charges    => "(
                `charge_id` varchar(5) NOT NULL default '',
                    `description` text NOT NULL,
                    `amount` decimal(28,6) NOT NULL default '0.000000',
                            `min` int(4) NOT NULL default '0',
                    `max` int(4) NOT NULL default '0',
                            `level` int(1) NOT NULL default '0',
                            PRIMARY KEY  (`charge_id`)
                )",
        tags => "(
            `entry` varchar(255) NOT NULL default '',
            `weight` bigint(20) NOT NULL default '0',
            PRIMARY KEY  (`entry`)
        )
        ",
    zebraqueue    => "(
                    `id` int NOT NULL auto_increment,
                    `biblio_auth_number` int(11) NOT NULL default '0',
                    `operation` char(20) NOT NULL default '',
                    `server` char(20) NOT NULL default '',
                    PRIMARY KEY  (`id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci AUTO_INCREMENT=1",
    
    );
    
    my %requirefields = (
        subscription => { 'letter' => 'varchar(20) NULL', 'distributedto' => 'text NULL', 'firstacquidate'=>'date default NULL','irregularity'=>'TEXT NULL default \'\'','numberpattern'=>'TINYINT(3) NULL default 0', 'callnumber'=>'text NULL', 'hemisphere' =>'TINYINT(3) NULL default 0', 'issuesatonce'=>'TINYINT(3) NOT NULL default 1',  'branchcode' =>'varchar(10) NOT NULL default \'\'', 'manualhistory'=>'TINYINT(1) NOT NULL default 0','internalnotes'=>'LONGTEXT NULL default \'\''},
        itemtypes => { 'imageurl' => 'varchar(200) NULL'},
        aqbookfund => { 'branchcode' => 'varchar(4) NULL'},
        aqbudget => { 'branchcode' => 'varchar(4) NULL'},
        auth_header => { 'marc' => 'BLOB NOT NULL', 'linkid' => 'BIGINT(20) NULL'},
        auth_subfield_structure =>{ 'hidden' => 'TINYINT(3) NOT NULL default 0', 'kohafield' => "VARCHAR(45) NULL default ''", 'linkid' =>  'TINYINT(1) NOT NULL default 0', 'isurl' => 'TINYINT(1)', 'frameworkcode'=>'VARCHAR(8) NOT  NULL'},
        marc_breeding => { 'isbn' => 'varchar(13) NOT NULL'},
        serial =>{ 'publisheddate' => 'date AFTER planneddate', 'claimdate' => 'date', 'itemnumber'=>'text NULL','routingnotes'=>'text NULL',},
        statistics => { 'associatedborrower' => 'integer'},
        z3950servers =>{  "name" =>"text",  "description" => "text NOT NULL",
                        "position" =>"enum('primary','secondary','') NOT NULL default 'primary'",  "icon" =>"text",
                        "type" =>"enum('zed','opensearch') NOT NULL default 'zed'",
                        },
        issues =>{ 'issuedate'=>"date NULL default NULL", },
    
    #    tablename        => { 'field' => 'fieldtype' },
    );
    
    # Enter here the table to delete.
    my @TableToDelete = qw(
        additionalauthors
        bibliosubject
        bibliosubtitle
        bibliothesaurus
    );
    
    my %uselessfields = (
    # tablename => "field1,field2",
        borrowers => "suburb,altstreetaddress,altsuburb,altcity,studentnumber,school,area,preferredcont,altcp",
        deletedborrowers=> "suburb,altstreetaddress,altsuburb,altcity,studentnumber,school,area,preferredcont,altcp",
        items => "multivolumepart,multivolume,binding",
        deleteditems => "multivolumepart,multivolume,binding",
        );
    # the other hash contains other actions that can't be done elsewhere. they are done
    # either BEFORE of AFTER everything else, depending on "when" entry (default => AFTER)
    
    # The tabledata hash contains data that should be in the tables.
    # The uniquefieldrequired hash entry is used to determine which (if any) fields
    # must not exist in the table for this row to be inserted.  If the
    # uniquefieldrequired entry is already in the table, the existing data is not
    # modified, unless the forceupdate hash entry is also set.  Fields in the
    # anonymous "forceupdate" hash will be forced to be updated to the default
    # values given in the %tabledata hash.
    
    my %tabledata = (
    # tablename => [
    #    {    uniquefielrequired => 'fieldname', # the primary key in the table
    #        fieldname => fieldvalue,
    #        fieldname2 => fieldvalue2,
    #    },
    # ],
        systempreferences => [
            {
                uniquefieldrequired => 'variable',
                variable            => 'useDaysMode',
                value               => 'Calendar',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation            => 'Choose the method for calculating due date: select Calendar to use the holidays module, and Days to ignore the holidays module',
                type        => 'Choice',
                options        => 'Calendar|Days|Datedue'
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'DebugLevel',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation            => 'Set the level of error info sent to the browser. 0=none, 1=some, 2=most',
                type                => 'Choice',
                options             => '0|1|2'
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'BorrowersTitles',
                value               => 'Mr|Mrs|Miss|Ms',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'List all Titles for borrowers',
                type                => 'free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'BorrowerMandatoryField',
                value               => 'cardnumber|surname|address',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'List all mandatory fields for borrowers',
                type                => 'free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'borrowerRelationship',
                value               => 'father|mother,grand-mother',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'The relationships between a guarantor & a guarantee (separated by | or ,)',
                type                => 'free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'ReservesMaxPickUpDelay',
                value               => '10',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Maximum delay to pick up a reserved document',
                type                => 'free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'TransfersMaxDaysWarning',
                value               => '3',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Max delay before considering the transfer has potentialy a problem',
                type                => 'free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'memberofinstitution',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Are your patrons members of institutions',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'ReadingHistory',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Allow reading record info retrievable from issues and oldissues tables',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'IssuingInProcess',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Allow no debt alert if the patron is issuing item that accumulate debt',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'AutomaticItemReturn',
                value               => '1',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'This Variable allow or not to return automaticly to his homebranch',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'reviewson',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Allows patrons to submit reviews from the opac',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'intranet_includes',
                value               => 'includes',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'The includes directory you want for specific look of Koha (includes or includes_npl for example)',
                type                => 'Free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'AutoLocation',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'switch to activate or not Autolocation, if Yes, the Librarian can\'t change his location, it\'s defined by branchip',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'serialsadditems',
                value               => '0',
                forceupdate         => {
                    'explanation' => 1,
                    'type' => 1
                },
                explanation => 'If set, a new item will be automatically added when receiving an issue',
                type => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'expandedSearchOption',
                value               => '0',
                forceupdate         => {
                    'explanation' => 1,
                    'type' => 1
                },
                explanation => 'search among marc field',
                type => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'RequestOnOpac',
                value               => '1',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'option to allow reserves on opac',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'OpacCloud',
                value               => '1',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Enable / Disable cloud link on OPAC (Require to run misc/cronjobs/build_browser_and_cloud.pl on the server)',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'OpacBrowser',
                value               => '1',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Enable/Disable browser link on OPAC (Require to run misc/cronjobs/build_browser_and_cloud.pl on the server)',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'OpacTopissue',
                value               => '0',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'If ON, enables the \'most popular items\' link on OPAC. Warning, this is an EXPERIMENTAL feature, turning ON may overload your server',
                type                => 'YesNo',
            },
        {
                uniquefieldrequired => 'variable',
                variable            => 'OpacAuthorities',
                value               => '1',
                forceupdate         => { 'explanation' => 1,
                                        'type' => 1},
                explanation         => 'Enable / Disable the search authority link on OPAC',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'CataloguingLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log cataloguing action.',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'BorrowersLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log borrowers edition/creation/deletion...',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'SubscriptionLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log Subscription action',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'IssueLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log issue.',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'ReturnLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log the circulation return',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'Version',
                value               => '3.0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Koha Version',
                type                => 'Free',
            },
            {   
                uniquefieldrequired => 'variable',
                variable            => 'LetterLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log all the letter sent',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'FinesLog',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want to log fines',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'NoZebra',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => 'Active this if you want NOT to use zebra (large libraries should avoid this parameters)',
                type                => 'YesNo',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'NoZebraIndexes',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => "Enter a specific hash for NoZebra indexes. Enter : 'indexname' => '100a,245a,500*','index2' => '...'",
                type                => 'Free',
            },
            {
                uniquefieldrequired => 'variable',
                variable            => 'uppercasesurnames',
                value               => '0',
                forceupdate         => {'explanation' => 1, 'type' => 1},
                explanation         => "Force Surnames to be uppercase",
                type                => 'YesNo',
            },
        ],
        userflags => [
            {
                uniquefieldrequired => 'bit',
                bit                 => '14',
                flag                => 'editauthorities',
                flagdesc            => 'allow to edit authorities',
                defaulton           => '0',
            },
            {
                uniquefieldrequired => 'bit',
                bit                 => '15',
                flag                 => 'serials',
                flagdesc            => 'allow to manage serials subscriptions',
                defaulton           => '0',
            },
            {
                uniquefieldrequired => 'bit',
                bit                 => '16',
                flag                 => 'reports',
                flagdesc            => 'allow to access to the reports module',
                defaulton           => '0',
            },
        ],
        authorised_values => [
            {
                uniquefieldrequired => 'id',
                category            => 'SUGGEST',
                authorised_value    => 'Not enough budget',
                lib                 => 'This book it too much expensive',
            }
        ],
    );
    
    my %fielddefinitions = (
    # fieldname => [
    #    {          field => 'fieldname',
    #             type    => 'fieldtype',
    #             null    => '',
    #             key     => '',
    #             default => ''
    #         },
    #     ],
        aqbasket =>  [
            {
                field    => 'booksellerid',
                type    => 'int(11)',
                null    => 'NOT NULL',
                key        => '',
                default    => '1',
                extra    => '',
            },
            {
                field   => 'booksellerinvoicenumber',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
        ],
		aqbookfund => [
			{
				field  => 'bookfundid',
				type   => 'varchar(10)',
				null   => 'NOT NULL',
				key    => '',
				default => "''",
				extra  => '',
			},
            {
                field   => 'branchcode',
                type    => 'varchar(10)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'bookfundname',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
                after   => 'bookfundid',
            },
		],
  
        aqbooksellers =>  [
            {
                field    => 'id',
                type    => 'int(11)',
                null    => 'NOT NULL',
                key        => 'PRI',
                default    => '',
                extra    => 'auto_increment',
            },
            {
                field    => 'currency',
                type    => 'varchar(3)',
                null    => 'NOT NULL',
                key        => '',
                default    => "''",
                extra    => '',
            },
            {
                field    => 'listprice',
                type    => 'varchar(10)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'invoiceprice',
                type    => 'varchar(10)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
			{
				field   => 'invoicedisc',
				type    => 'float(6,4)',
				null    => 'NULL',
				key     => '',
				default => 'NULL',
				extra   => '',
			},
			{
				field   => 'address1',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'address2',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'address3',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'address4',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'accountnumber',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'othersupplier',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'specialty',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'booksellerfax',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'notes',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'bookselleremail',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'booksellerurl',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'contnotes',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
			{
				field   => 'postal',
				type    => 'mediumtext',
				null    => 'NULL',
				key     => '',
				default => '',
				extra   => '',
			},
        ],
        
		aqbudget     =>  [
			{
				field    => 'bookfundid',
				type     => 'varchar(10)',
				null     => 'NOT NULL',
				key      => '',
				default  => "''",
				exra     => '',
			 },
			{
				field    => 'branchcode',
				type     => 'varchar(10)',
				null     => 'NULL',
				key      => '',
				default  => '',
				exra     => '',
			 },
		],
		
		aqorderbreakdown     =>  [
			{
				field    => 'bookfundid',
				type     => 'varchar(10)',
				null     => 'NOT NULL',
				key      => '',
				default  => "''",
				exra     => '',
			 },
			{
				field    => 'branchcode',
				type     => 'varchar(10)',
				null     => 'NULL',
				key      => '',
				default  => '',
				exra     => '',
			 },
		],

		aqorderdelivery => [
			{
				field    => 'ordernumber',
				type     => 'date',
				null     => 'NULL',
				key      => '',
				default  => 'NULL',
				exra     => '',
			 },
			{
				field    => 'deliverycomments',
				type     => 'mediumtext',
				null     => 'NULL',
				key      => '',
				default  => '',
				exra     => '',
			 },
        ],

        aqorders => [
			{
				field    => 'title',
				type     => 'mediumtext',
				null     => 'NULL',
				key      => '',
				default  => '',
				exra     => '',
			 },
			{
				field    => 'currency',
				type     => 'varchar(3)',
				null     => 'NULL',
				key      => '',
				default  => 'NULL',
				exra     => '',
			 },
            {
                field   => 'booksellerinvoicenumber',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
            {
                field   => 'notes',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
            {
                field   => 'supplierreference',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
            {
                field   => 'purchaseordernumber',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
        ],

        accountlines =>  [
            {
                field    => 'notify_id',
                type    => 'int(11)',
                null    => 'NOT NULL',
                key        => '',
                default    => '0',
                extra    => '',
            },
            {
                field    => 'notify_level',
                type    => 'int(2)',
                null    => 'NOT NULL',
                key        => '',
                default    => '0',
                extra    => '',
            },
			{
				field   => 'accountno',
				type    => 'smallint(6)',
				null    => 'NOT NULL',
				key     => '',
				default => '0',
				extra   => '',
			},
			{
				field   => 'description',
				type    => 'mediumtext',
				null    => 'NULL',
			},
			{
				field   => 'dispute',
				type    => 'mediumtext',
				null    => 'NULL',
		    },
        
        ],
       
        auth_header => [
            {
                field   => 'authtypecode',
                type    => 'varchar(10)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'datecreated',
                type    => 'date',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'origincode',
                type    => 'varchar(20)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'authtrees',
                type    => 'mediumtext',
				null    => 'NULL',
                key     => '',
                default => "",
                extra   => '',
                after   => 'origincode',
            },
        ],
 
        auth_subfield_structure => [
            {
                field   => 'authtypecode',
                type    => 'varchar(10)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'tagfield',
                type    => 'varchar(3)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'tagsubfield',
                type    => 'varchar(1)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'liblibrarian',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'libopac',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'authorised_value',
                type    => 'varchar(10)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'value_builder',
                type    => 'varchar(80)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'seealso',
                type    => 'varchar(255)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'kohafield',
                type    => 'varchar(45)',
				null    => 'NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'frameworkcode',
                type    => 'varchar(8)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
        ],
            
        auth_tag_structure => [
            {
                field   => 'authtypecode',
                type    => 'varchar(10)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'tagfield',
                type    => 'varchar(3)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'liblibrarian',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'libopac',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'authorised_value',
                type    => 'varchar(10)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
        ],

        auth_types => [
            {
                field   => 'auth_tag_to_report',
                type    => 'varchar(3)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'summary',
                type    => 'mediumtext',
				null    => 'NOT NULL',
                key     => '',
                default => '',
                extra   => '',
            },
        ],

        authorised_values => [
            {
                field   => 'category',
                type    => 'varchar(10)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'authorised_value',
                type    => 'varchar(80)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'lib',
                type    => 'varchar(80)',
				null    => 'NULL',
                key     => '',
                default => 'NULL',
                extra   => '',
            },
        ],

        biblio_framework => [
            {
                field   => 'frameworkcode',
                type    => 'varchar(4)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'frameworktext',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
        ],

        borrowers => [
            {
                field   => 'cardnumber',
                type    => 'varchar(16)',
				null    => 'NULL',
                key     => '',
                default => 'NULL',
                extra   => '',
            },
            {    field => 'surname',
                type => 'mediumtext',
                null => 'NOT NULL',
            },
            {    field => 'firstname',
                type => 'text',
                null => 'NULL',
            },
            {    field => 'title',
                type => 'mediumtext',
                null => 'NULL',
            },
            {    field => 'othernames',
                type => 'mediumtext',
                null => 'NULL',
            },
            {    field => 'initials',
                type => 'text',
                null => 'NULL',
            },
            {    field => 'B_email',
                type => 'text',
                null => 'NULL',
                after => 'B_zipcode',
            },
            {
                field => 'streetnumber', # street number (hidden if streettable table is empty)
                type => 'varchar(10)',
                null => 'NULL',
                after => 'initials',
            },
            {
                field => 'streettype', # street table, list builded from a system table
                type => 'varchar(50)',
                null => 'NULL',
                after => 'streetnumber',
            },
            {    field => 'phone',
                type => 'text',
                null => 'NULL',
            },
            {
                field => 'B_streetnumber', # street number (hidden if streettable table is empty)
                type => 'varchar(10)',
                null => 'NULL',
                after => 'fax',
            },
            {
                field => 'B_streettype', # street table, list builded from a system table
                type => 'varchar(50)',
                null => 'NULL',
                after => 'B_streetnumber',
            },
            {
                field => 'phonepro',
                type => 'text',
                null => 'NULL',
                after => 'fax',
            },
            {
                field => 'address2', # complement address
                type => 'text',
                null => 'NULL',
                after => 'address',
            },
            {
                field => 'emailpro',
                type => 'text',
                null => 'NULL',
                after => 'fax',
            },
            {
                field => 'contactfirstname', # contact's firstname
                type => 'text',
                null => 'NULL',
                after => 'contactname',
            },
            {
                field => 'contacttitle', # contact's title
                type => 'text',
                null => 'NULL',
                after => 'contactfirstname',
            },
            {
                field => 'branchcode',
                type  => 'varchar(10)',
                null  => 'NOT NULL',
                default    => "''",
                extra => '',
            },
            {
                field => 'categorycode',
                type  => 'varchar(10)',
                null  => 'NOT NULL',
                default    => "''",
                extra => '',
            },
            {
                field => 'address',
                type  => 'mediumtext',
                null  => 'NOT NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'email',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'B_city',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'city',
                type  => 'mediumtext',
                null  => 'NOT NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'fax',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'B_phone',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'contactname',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'opacnote',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'borrowernotes',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'sex',
                type  => 'varchar(1)',
                null  => 'NULL',
                default    => 'NULL',
                extra => '',
            },
        ],
        
        biblioitems =>  [
            {
                field    => 'itemtype',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'lcsort',
                type    => 'varchar(25)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'ccode',
                type    => 'varchar(4)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field   => 'dewey',
                type    => 'varchar(30)',
                null    => 'null',
                default => '',
                extra   => '',
            },
            {
                field   => 'publicationyear',
                type    => 'text',
                null    => 'null',
                default => '',
                extra   => '',
            },
            {
                field   => 'collectiontitle',
                type    => 'mediumtext',
                null    => 'null',
                default => '',
                extra   => '',
                after   => 'volumeddesc',
            },
            {
                field   => 'collectionissn',
                type    => 'text',
                null    => 'null',
                default => '',
                extra   => '',
                after   => 'collectiontitle',
            },
            {
                field   => 'collectionvolume',
                type    => 'mediumtext',
                null    => 'null',
                default => '',
                extra   => '',
                after   => 'collectionissn',
            },
            {
                field   => 'editionstatement',
                type    => 'text',
                null    => 'null',
                default => '',
                extra   => '',
                after   => 'collectionvolume',
            },
            {
                field   => 'editionresponsibility',
                type    => 'text',
                null    => 'null',
                default => '',
                extra   => '',
                after   => 'editionstatement',
            },
            {
                field   => 'volume',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'number',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'notes',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
        ],
                
        biblio => [
            {
                field   => 'author',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'title',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'unititle',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'seriestitle',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'abstract',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'notes',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'frameworkcode',
                type    => 'varchar(4)',
                null    => 'NOT NULL',
                default => "''",
                extra   => '',
                after   => 'biblionumber',
            },
	    ],

        deletedbiblio => [
            {
                field   => 'author',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'title',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'unititle',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'seriestitle',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'abstract',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'notes',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'frameworkcode',
                type    => 'varchar(4)',
                null    => 'NOT NULL',
                default => "''",
                extra   => '',
                after   => 'biblionumber',
            },
	    ],
        deletedbiblioitems => [
            {
                field   => 'itemtype',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'dewey',
                type    => 'varchar(30)',
                null    => 'null',
                default => '',
                extra   => '',
            },
            {
                field   => 'itemtype',
                type    => 'varchar(10)',
                null    => 'NULL',
                default => 'NULL',
                extra   => '',
            },
            {
                field   => 'volume',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'notes',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'number',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
        ],

        bookshelf => [
            {
                field   => 'shelfname',
                type    => 'varchar(255)',
                null    => 'NULL',
                default => 'NULL',
                extra   => '',
            },
            {
                field   => 'owner',
                type    => 'varchar(80)',
                null    => 'NULL',
                default => 'NULL',
                extra   => '',
            },
            {
                field   => 'category',
                type    => 'varchar(1)',
                null    => 'NULL',
                default => 'NULL',
                extra   => '',
            },
        ],

        branchcategories => [
            {
                field   => 'codedescription',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
        ],

        branches =>  [
            {
                field    => 'branchip',
                type    => 'varchar(15)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'branchprinter',
                type    => 'varchar(100)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field   => 'branchcode',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                default => "''",
                extra   => '',
            },
            {
                field   => 'branchname',
                type    => 'mediumtext',
                null    => 'NOT NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'branchaddress1',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'branchaddress2',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'branchaddress3',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'branchphone',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'branchfax',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
            {
                field   => 'branchemail',
                type    => 'mediumtext',
                null    => 'NULL',
                default => '',
                extra   => '',
            },
        ],
    
        branchrelations => [
            {
                field   => 'branchcode',
                type    => 'VARCHAR(10)',
                null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'categorycode',
                type    => 'VARCHAR(10)',
                null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            }
        ],

        branchtransfers =>[
            {
                field   => 'frombranch',
                type    => 'VARCHAR(10)',
                null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'tobranch',
                type    => 'VARCHAR(10)',
                null    => 'NOT NULL',
                key     => '',
                default => "''",
            },
            {
                field   => 'comments',
                type    => 'mediumtext',
                null    => 'NULL',
                key     => '',
                default => '',
            },
        ],
        
        categories =>  [
            {
                field    => 'category_type',
                type    => 'varchar(1)',
                null    => 'NOT NULL',
                key        => '',
                default    => 'A',
                extra    => '',
            },
            {
                field   => 'categorycode',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                key     => 'PRI',
                default => "''",
                extra   => '',
            },
            {
                field   => 'description',
                type    => 'mediumtext',
                null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
        ],
        
        deletedborrowers => [
            {
                field => 'branchcode',
                type  => 'varchar(10)',
                null  => 'NOT NULL',
                default    => "''",
                extra => '',
            },
            {
                field => 'categorycode',
                type  => 'varchar(2)',
                null  => 'NULL',
                default    => 'NULL',
                extra => '',
            },
            {
                field => 'B_phone',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'borrowernotes',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'contactname',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'B_city',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'B_zipcode',
                type  => 'varchar(25)',
                null  => 'NULL',
                default    => 'NULL',
                extra => '',
            },
            {
                field => 'zipcode',
                type  => 'varchar(25)',
                null  => 'NULL',
                default    => 'NULL',
                extra => '',
                after => 'city',
            },
            {
                field => 'email',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'address',
                type  => 'mediumtext',
                null  => 'NOT NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'fax',
                type  => 'mediumtext',
                null  => 'NULL',
                default    => '',
                extra => '',
            },
            {
                field => 'city',
                type  => 'mediumtext',
                null  => 'NOT NULL',
                default    => '',
                extra => '',
            },
            {    field => 'surname',
                type => 'mediumtext',
                null => 'NOT NULL',
            },
            {    field => 'firstname',
                type => 'text',
                null => 'NULL',
            },
            {    field => 'initials',
                type => 'text',
                null => 'NULL',
            },
            {    field => 'title',
                type => 'mediumtext',
                null => 'NULL',
            },
            {    field => 'othernames',
                type => 'mediumtext',
                null => 'NULL',
            },
            {    field => 'B_email',
                type => 'text',
                null => 'NULL',
                after => 'B_zipcode',
            },
            {
                field => 'streetnumber', # street number (hidden if streettable table is empty)
                type => 'varchar(10)',
                null => 'NULL',
                default => 'NULL',
                after => 'initials',
            },
            {
                field => 'streettype', # street table, list builded from a system table
                type => 'varchar(50)',
                null => 'NULL',
                default => 'NULL',
                after => 'streetnumber',
            },
            {    field => 'phone',
                type => 'text',
                null => 'NULL',
            },
            {
                field => 'B_streetnumber', # street number (hidden if streettable table is empty)
                type => 'varchar(10)',
                null => 'NULL',
                after => 'fax',
            },
            {
                field => 'B_streettype', # street table, list builded from a system table
                type => 'varchar(50)',
                null => 'NULL',
                after => 'B_streetnumber',
            },
            {
                field => 'phonepro',
                type => 'text',
                null => 'NULL',
                after => 'fax',
            },
            {
                field => 'address2', # complement address
                type => 'text',
                null => 'NULL',
                after => 'address',
            },
            {
                field => 'emailpro',
                type => 'text',
                null => 'NULL',
                after => 'fax',
            },
            {
                field => 'contactfirstname', # contact's firstname
                type => 'text',
                null => 'NULL',
                after => 'contactname',
            },
            {
                field => 'contacttitle', # contact's title
                type => 'text',
                null => 'NULL',
                after => 'contactfirstname',
            },
            {
                field => 'sex',
                type  => 'varchar(1)',
                null  => 'NULL',
                default    => 'NULL',
                extra => '',
            },
        ],
        
        issues =>  [
            {
                field    => 'borrowernumber',
                type    => 'int(11)',
                null    => 'NULL', # can be null when a borrower is deleted and the foreign key rule executed
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'itemnumber',
                type    => 'int(11)',
                null    => 'NULL', # can be null when a borrower is deleted and the foreign key rule executed
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field   => 'branchcode',
                type    => 'varchar(10)',
                null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
            {
                field   => 'issuedate',
                type    => 'date',
                null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
            {
                field   => 'return',
                type    => 'varchar(4)',
                null    => 'NULL',
                key     => '',
                default => 'NULL',
                extra   => '',
            },
            {
                field   => 'issuingbranch',
                type    => 'varchar(18)',
                null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
        ],
        issuingrules => [
            {
                field   => 'categorycode',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                default => "''",
                extra   => '',
            },
            {
                field   => 'branchcode',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                default => "''",
                extra   => '',
            },
            {
                field   => 'itemtype',
                type    => 'varchar(10)',
                null    => 'NOT NULL',
                default => "''",
                extra   => '',
            },
        ],

        items => [
            {
                field    => 'onloan',
                type    => 'date',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'cutterextra',
                type    => 'varchar(45)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'homebranch',
                type    => 'varchar(10)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'holdingbranch',
                type    => 'varchar(10)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'itype',
                type    => 'varchar(10)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'paidfor',
                type    => 'mediumtext',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'itemnotes',
                type    => 'mediumtext',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
        ],

        deleteditems => [
            {
                field    => 'paidfor',
                type    => 'mediumtext',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'itemnotes',
                type    => 'mediumtext',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
        ],

        itemtypes => [
            {
                field  => 'itemtype',
                type   => 'varchar(10)',
                default    => "''",
                null   => 'NOT NULL',
                key    => 'PRI',
                extra  => 'UNIQUE',
            },
            {
                field  => 'description',
                type   => 'MEDIUMTEXT',
                null   => 'NULL',
                key    => '',
                extra  => '',
            },
            {
                field  => 'summary',
                type   => 'TEXT',
                null   => 'NULL',
                key    => '',
                extra  => '',
            },
        ],
        marc_breeding => [
            {
                field => 'marc',
                type  => 'LONGBLOB',
                null  => 'NULL',
                key    => '',
                extra  => '',
            }
        ],
        marc_subfield_structure => [
            {
                field => 'defaultvalue',
                type  => 'TEXT',
                null  => 'NULL',
                key    => '',
                extra  => '',
            },
            {
                field   => 'authtypecode',
                type    => 'varchar(20)',
				null    => 'NULL',
                key     => '',
                default => 'NULL',
                extra   => '',
            },
            {
                field   => 'tagfield',
                type    => 'varchar(3)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'tagsubfield',
                type    => 'varchar(1)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'authorised_value',
                type    => 'varchar(20)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'seealso',
                type    => 'varchar(1100)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
        ],
            
        marc_tag_structure => [
            {
                field   => 'tagfield',
                type    => 'varchar(3)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'liblibrarian',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'libopac',
                type    => 'varchar(255)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'authorised_value',
                type    => 'varchar(10)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'frameworkcode',
                type    => 'varchar(4)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
        ],

        opac_news => [
            {
                field  => 'expirationdate',
                type   => 'date',
                null   => 'null',
                key    => '',
                extra  => '',
            },
            {
                field   => 'number',
                type    => 'int(11)',
                null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
            },
        ],

        printers => [
            {
                field   => 'printername',
                type    => 'varchar(40)',
				null    => 'NOT NULL',
                key     => '',
                default => "''",
                extra   => '',
            },
            {
                field   => 'printqueue',
                type    => 'varchar(20)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
            {
                field   => 'printtype',
                type    => 'varchar(20)',
				null    => 'NULL',
                key     => '',
                default => "NULL",
                extra   => '',
            },
        ],

        reserveconstraints => [
            {
                field    => 'reservedate',
                type    => 'date',
                null    => 'NULL',
                key        => '',
                default    => 'NULL',
                extra    => '',
            },
        ],

        reserves =>  [
            {
                field    => 'waitingdate',
                type    => 'date',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'reservedate',
                type    => 'date',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'constrainttype',
                type    => 'varchar(1)',
                null    => 'NULL',
                key        => '',
                default    => 'NULL',
                extra    => '',
                after   => 'biblionumber',
            },
            {
                field    => 'branchcode',
                type    => 'varchar(10)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'reservenotes',
                type    => 'mediumtext',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'found',
                type    => 'varchar(1)',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
        ],

        serial => [
            {
                field   => 'planneddate',
                type    => 'DATE',
                null    => 'NULL',
                key     => '',
                default => 'NULL',
                extra   => '',
            },
            {
                field   => 'notes',
                type    => 'TEXT',
                null    => 'NULL',
                key     => '',
                default => '',
                extra   => '',
                after   => 'planneddate',
            },
        ],

        shelfcontents => [
            {
                field => 'dateadded',
                type => 'timestamp',
                null    => 'NULL',
            },
        ],

        statistics => [
            {
                field => 'branch',
                type => 'varchar(10)',
                null    => 'NOT NULL',
            },
            {
                field => 'datetime',
                type => 'datetime',
                null    => 'NULL',
                default => 'NULL',
            },
            {
                field => 'itemtype',
                type => 'varchar(10)',
                null    => 'NULL',
            },
            {
                field => 'other',
                type => 'mediumtext',
                null    => 'NULL',
            },
        ],

        subscription => [
            {
                field   => 'startdate',
                type    => 'date',
                null    => 'NULL',
                key     => ''  ,
                default => 'NULL',
                extra   =>    '',
            },
            {
                field   => 'notes',
                type    => 'mediumtext',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
            {
                field   => 'monthlength',
                type    => 'int(11)',
                null    => 'NULL',
                key     => ''  ,
                default => '0',
                extra   =>    '',
            },
        ],

        subscriptionhistory => [
            {
                field   => 'histstartdate',
                type    => 'date',
                null    => 'NULL',
                key     => ''  ,
                default => 'NULL',
                extra   =>    '',
            },
            {
                field   => 'enddate',
                type    => 'date',
                null    => 'NULL',
                key     => ''  ,
                default => 'NULL',
                extra   =>    '',
            },
        ],

        systempreferences =>  [
            {
                field   => 'options',
                type    => 'mediumtext',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
            {
                field    => 'value',
                type    => 'text',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
            {
                field    => 'explanation',
                type    => 'text',
                null    => 'NULL',
                key        => '',
                default    => '',
                extra    => '',
            },
        ],
        suggestions => [
            {
                field   => 'reason',
                type    => 'text',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
            {
                field   => 'note',
                type    => 'mediumtext',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
        ],
        userflags => [
            {
                field   => 'flag',
                type    => 'varchar(30)',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
            {
                field   => 'flagdesc',
                type    => 'varchar(255)',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
        ],
        z3950servers => [
            {
                field   => 'name',
                type    => 'mediumtext',
                null    => 'NULL',
                key     => ''  ,
                default => '',
                extra   =>    '',
            },
        ],
    );
    
    my %indexes = (
    #    table => [
    #         {    indexname => 'index detail'
    #         }
    #    ],
        accountoffsets => [
            {    indexname => 'accountoffsets_ibfk_1',
                content => 'borrowernumber',
            },
        ],
        aqbooksellers => [
            {    indexname => 'PRIMARY',
                content => 'id',
                type => 'PRI',
            }
        ],
        aqbasket => [
            {    indexname => 'booksellerid',
                content => 'booksellerid',
            },
        ],
        aqorders => [
            {    indexname => 'basketno',
                content => 'basketno',
            },
        ],
        aqorderbreakdown => [
            {    indexname => 'ordernumber',
                content => 'ordernumber',
            },
            {    indexname => 'bookfundid',
                content => 'bookfundid',
            },
        ],
        biblioitems => [
            {    indexname => 'isbn',
                content => 'isbn',
            },
            {    indexname => 'publishercode',
                content => 'publishercode',
            },
        ],
        borrowers => [
            {
                indexname => 'borrowernumber',
                content   => 'borrowernumber',
                type => 'PRI',
                force => 1,
            }
        ],
        branches => [
            {
                indexname => 'branchcode',
                content   => 'branchcode',
                type => 'PRI',
            }
        ],
        branchrelations => [
            {
                indexname => 'PRIMARY',
                content => 'categorycode',
                type => 'PRI',
            }
        ],
        branchrelations => [
            {    indexname => 'PRIMARY',
                content => 'branchcode,categorycode',
                type => 'PRI',
            },
            {    indexname => 'branchcode',
                content => 'branchcode',
            },
            {    indexname => 'categorycode',
                content => 'categorycode',
            }
        ],
        currency => [
            {    indexname => 'PRIMARY',
                content => 'currency',
                type => 'PRI',
            }
        ],
        categories => [
            {
                indexname => 'categorycode',
                content   => 'categorycode',
            }
        ],
        issuingrules => [
            {
                indexname => 'categorycode',
                content   => 'categorycode',
            },
            {
                indexname => 'itemtype',
                content   => 'itemtype',
            },
        ],
        items => [
            {    indexname => 'homebranch',
                content => 'homebranch',
            },
            {    indexname => 'holdingbranch',
                content => 'holdingbranch',
            }
        ],
        itemtypes => [
            {
                indexname => 'itemtype',
                content   => 'itemtype',
            }
        ],
        shelfcontents => [
            {    indexname => 'shelfnumber',
                content => 'shelfnumber',
            },
            {    indexname => 'itemnumber',
                content => 'itemnumber',
            }
        ],
            userflags => [
                    { 	indexname => 'PRIMARY',
                            content => 'bit',
                            type => 'PRI',
                    }
            ]
    );
    
    my %foreign_keys = (
    #    table => [
    #         {    key => 'the key in table' (must be indexed)
    #            foreigntable => 'the foreigntable name', # (the parent)
    #            foreignkey => 'the foreign key column(s)' # (in the parent)
    #            onUpdate => 'CASCADE|SET NULL|NO ACTION| RESTRICT',
    #            onDelete => 'CASCADE|SET NULL|NO ACTION| RESTRICT',
    #         }
    #    ],
        branchrelations => [
            {    key => 'branchcode',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'categorycode',
                foreigntable => 'branchcategories',
                foreignkey => 'categorycode',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        shelfcontents => [
            {    key => 'shelfnumber',
                foreigntable => 'bookshelf',
                foreignkey => 'shelfnumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'itemnumber',
                foreigntable => 'items',
                foreignkey => 'itemnumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        # onDelete is RESTRICT on reference tables (branches, itemtype) as we don't want items to be
        # easily deleted, but branches/itemtype not too easy to empty...
        biblioitems => [
            {    key => 'biblionumber',
                foreigntable => 'biblio',
                foreignkey => 'biblionumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        items => [
            {    key => 'biblioitemnumber',
                foreigntable => 'biblioitems',
                foreignkey => 'biblioitemnumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'homebranch',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'CASCADE',
                onDelete => 'RESTRICT',
            },
            {    key => 'holdingbranch',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'CASCADE',
                onDelete => 'RESTRICT',
            },
        ],
        aqbasket => [
            {    key => 'booksellerid',
                foreigntable => 'aqbooksellers',
                foreignkey => 'id',
                onUpdate => 'CASCADE',
                onDelete => 'RESTRICT',
            },
        ],
        aqorders => [
            {    key => 'basketno',
                foreigntable => 'aqbasket',
                foreignkey => 'basketno',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'biblionumber',
                foreigntable => 'biblio',
                foreignkey => 'biblionumber',
                onUpdate => 'SET NULL',
                onDelete => 'SET NULL',
            },
        ],
        aqbooksellers => [
            {    key => 'listprice',
                foreigntable => 'currency',
                foreignkey => 'currency',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'invoiceprice',
                foreigntable => 'currency',
                foreignkey => 'currency',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        aqorderbreakdown => [
            {    key => 'ordernumber',
                foreigntable => 'aqorders',
                foreignkey => 'ordernumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'bookfundid',
                foreigntable => 'aqbookfund',
                foreignkey => 'bookfundid',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        branchtransfers => [
            {    key => 'frombranch',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'tobranch',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'itemnumber',
                foreigntable => 'items',
                foreignkey => 'itemnumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        issues => [    # constraint is SET NULL : when a borrower or an item is deleted, we keep the issuing record
        # for stat purposes
            {    key => 'borrowernumber',
                foreigntable => 'borrowers',
                foreignkey => 'borrowernumber',
                onUpdate => 'SET NULL',
                onDelete => 'SET NULL',
            },
            {    key => 'itemnumber',
                foreigntable => 'items',
                foreignkey => 'itemnumber',
                onUpdate => 'SET NULL',
                onDelete => 'SET NULL',
            },
        ],
        reserves => [
            {    key => 'borrowernumber',
                foreigntable => 'borrowers',
                foreignkey => 'borrowernumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'biblionumber',
                foreigntable => 'biblio',
                foreignkey => 'biblionumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'itemnumber',
                foreigntable => 'items',
                foreignkey => 'itemnumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'branchcode',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        borrowers => [ # foreign keys are RESTRICT as we don't want to delete borrowers when a branch is deleted
        # but prevent deleting a branch as soon as it has 1 borrower !
            {    key => 'categorycode',
                foreigntable => 'categories',
                foreignkey => 'categorycode',
                onUpdate => 'RESTRICT',
                onDelete => 'RESTRICT',
            },
            {    key => 'branchcode',
                foreigntable => 'branches',
                foreignkey => 'branchcode',
                onUpdate => 'RESTRICT',
                onDelete => 'RESTRICT',
            },
        ],
        accountlines => [
            {    key => 'borrowernumber',
                foreigntable => 'borrowers',
                foreignkey => 'borrowernumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
            {    key => 'itemnumber',
                foreigntable => 'items',
                foreignkey => 'itemnumber',
                onUpdate => 'SET NULL',
                onDelete => 'SET NULL',
            },
        ],
        accountoffsets => [
            {    key => 'borrowernumber',
                foreigntable => 'borrowers',
                foreignkey => 'borrowernumber',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        auth_tag_structure => [
            {    key => 'authtypecode',
                foreigntable => 'auth_types',
                foreignkey => 'authtypecode',
                onUpdate => 'CASCADE',
                onDelete => 'CASCADE',
            },
        ],
        # FIXME : don't constraint auth_*_table and auth_word, as they may be replaced by zebra
    );
    
    
    # column changes
    my %column_change = (
        # table
        borrowers => [
                    {
                        from => 'emailaddress',
                        to => 'email',
                        after => 'city',
                    },
                    {
                        from => 'streetaddress',
                        to => 'address',
                        after => 'initials',
                    },
                    {
                        from => 'faxnumber',
                        to => 'fax',
                        after => 'phone',
                    },
                    {
                        from => 'textmessaging',
                        to => 'opacnote',
                        after => 'userid',
                    },
                    {
                        from => 'altnotes',
                        to => 'contactnote',
                        after => 'opacnote',
                    },
                    {
                        from => 'physstreet',
                        to => 'B_address',
                        after => 'fax',
                    },
                    {
                        from => 'streetcity',
                        to => 'B_city',
                        after => 'B_address',
                    },
                    {
                        from => 'phoneday',
                        to => 'mobile',
                        after => 'phone',
                    },
                    {
                        from => 'zipcode',
                        to => 'zipcode',
                        after => 'city',
                    },
                    {
                        from => 'homezipcode',
                        to => 'B_zipcode',
                        after => 'B_city',
                    },
                    {
                        from => 'altphone',
                        to => 'B_phone',
                        after => 'B_zipcode',
                    },
                    {
                        from => 'expiry',
                        to => 'dateexpiry',
                        after => 'dateenrolled',
                    },
                    {
                        from => 'guarantor',
                        to => 'guarantorid',
                        after => 'contactname',
                    },
                    {
                        from => 'altrelationship',
                        to => 'relationship',
                        after => 'borrowernotes',
                    },
                ],
    
        deletedborrowers => [
                    {
                        from => 'emailaddress',
                        to => 'email',
                        after => 'city',
                    },
                    {
                        from => 'streetaddress',
                        to => 'address',
                        after => 'initials',
                    },
                    {
                        from => 'faxnumber',
                        to => 'fax',
                        after => 'phone',
                    },
                    {
                        from => 'textmessaging',
                        to => 'opacnote',
                        after => 'userid',
                    },
                    {
                        from => 'altnotes',
                        to => 'contactnote',
                        after => 'opacnote',
                    },
                    {
                        from => 'physstreet',
                        to => 'B_address',
                        after => 'fax',
                    },
                    {
                        from => 'streetcity',
                        to => 'B_city',
                        after => 'B_address',
                    },
                    {
                        from => 'phoneday',
                        to => 'mobile',
                        after => 'phone',
                    },
                    {
                        from => 'zipcode',
                        to => 'zipcode',
                        after => 'city',
                    },
                    {
                        from => 'homezipcode',
                        to => 'B_zipcode',
                        after => 'B_city',
                    },
                    {
                        from => 'altphone',
                        to => 'B_phone',
                        after => 'B_zipcode',
                    },
                    {
                        from => 'expiry',
                        to => 'dateexpiry',
                        after => 'dateenrolled',
                    },
                    {
                        from => 'guarantor',
                        to => 'guarantorid',
                        after => 'contactname',
                    },
                    {
                        from => 'altrelationship',
                        to => 'relationship',
                        after => 'borrowernotes',
                    },
                ],
            );
        
    
    # MOVE all tables TO UTF-8 and innoDB
    $sth = $dbh->prepare("show table status");
    $sth->execute;
    while ( my $table = $sth->fetchrow_hashref ) {
        next if $table->{Name} eq 'marc_word';
        next if $table->{Name} eq 'marc_subfield_table';
        next if $table->{Name} eq 'auth_word';
        next if $table->{Name} eq 'auth_subfield_table';
        if ($table->{Engine} ne 'InnoDB') {
            print "moving $table->{Name} to InnoDB\n";
            $dbh->do("ALTER TABLE $table->{Name} TYPE = innodb");
        }
        unless ($table->{Collation} =~ /^utf8/) {
            print "moving $table->{Name} to utf8\n";
            $dbh->do("ALTER TABLE $table->{Name} CONVERT TO CHARACTER SET utf8");
            $dbh->do("ALTER TABLE $table->{Name} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci");
            # FIXME : maybe a ALTER TABLE tbl_name CONVERT TO CHARACTER SET utf8 would be better, def char set seems to work fine. If any problem encountered, let's try with convert !
        } else {
        }
    }
   
    # list of columns that must exist for %column_change to be
    # processed without error, but which do not necessarily exist
    # in all 2.2 databases
    my %required_prereq_fields = (
        deletedborrowers => [ 
                                [ 'textmessaging', 'mediumtext AFTER faxnumber' ],
                                [ 'password',      'varchar(30) default NULL'   ],
                                [ 'flags',         'int(11) default NULL'       ],
                                [ 'userid',        'varchar(30) default NULL'   ],
                                [ 'homezipcode',   'varchar(25) default NULL'   ],
                                [ 'zipcode',       'varchar(25) default NULL'   ],
                                [ 'sort1',         'varchar(80) default NULL'   ],
                                [ 'sort2',         'varchar(80) default NULL'   ],
                             ],
    );

    foreach $table ( keys %required_prereq_fields ) {
        print "Check table $table\n" if $debug and not $silent;
        $sth = $dbh->prepare("show columns from $table");
        $sth->execute();
        undef %types;
        while ( ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow )
        {
            $types{$column} = $type;
        }    # while
        foreach my $entry ( @{ $required_prereq_fields{$table} } ) {
            ($column, $type) = @{ $entry };
            print "  Check column $column  [$type]\n" if $debug and not $silent;
            if ( !$types{$column} ) {
    
                # column doesn't exist
                print "Adding $column field to $table table...\n" unless $silent;
                $query = "alter table $table
                add column $column " . $type;
                print "Execute: $query\n" if $debug;
                my $sti = $dbh->prepare($query);
                $sti->execute;
                if ( $sti->err ) {
                    print "**Error : $sti->errstr \n";
                    $sti->finish;
                }    # if error
            }    # if column
        }    # foreach column
    }    # foreach table
    
    foreach my $table (keys %column_change) {
        $sth = $dbh->prepare("show columns from $table");
        $sth->execute();
        undef %types;
        while ( ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow )
        {
            $types{$column}->{type} ="$type";
            $types{$column}->{null} = "$null";
            $types{$column}->{key} = "$key";
            $types{$column}->{default} = "$default";
            $types{$column}->{extra} = "$extra";
        }    # while
        my $tablerows = $column_change{$table};
        foreach my $row ( @$tablerows ) {
            if ($types{$row->{from}}->{type}) {
                print "altering $table $row->{from} to $row->{to}\n";
                # ALTER TABLE `borrowers` CHANGE `faxnumber` `fax` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL
    #             alter table `borrowers` change `faxnumber` `fax` type text  null after phone
                my $sql =
                    "alter table `$table` change `$row->{from}` `$row->{to}` $types{$row->{from}}->{type} ".
                    ($types{$row->{from}}->{null} eq 'YES'?" NULL":" NOT NULL").
                    ($types{$row->{from}}->{default}?" default ".$types{$row->{from}}->{default}:"").
                    "$types{$row->{from}}->{extra} after $row->{after} ";
    #             print "$sql";
                $dbh->do($sql);
            }
        }
    }
    
    # Enter here the field you want to delete from DB.
    # FIXME :: there is a %uselessfield before which seems doing the same things.
    my %fieldtodelete = (
        # tablename => [fieldname1,fieldname2,...]
    
    ); # %fielddelete
    
    print "removing some unused fields...\n";
    foreach my $table ( keys %fieldtodelete ) {
        foreach my $field ( @{$fieldtodelete{$table}} ){
            print "removing ".$field." from ".$table;
            my $sth = $dbh->prepare("ALTER TABLE $table DROP $field");
            $sth->execute;
            if ( $sth->err ) {
                print "Error : $sth->errstr \n";
            }
        }
    }
    
    # Enter here the line you want to remove from DB.
    my %linetodelete = (
        # table name => where clause.
        userflags => [ "bit = 8" ], # delete the 'reserveforself' flags
        
    ); # %linetodelete
    
    #-------------------
    # Initialize
    
    # Start checking
    
    # Get version of MySQL database engine.
    my $mysqlversion = `mysqld --version`;
    $mysqlversion =~ /Ver (\S*) /;
    $mysqlversion = $1;
    if ( $mysqlversion ge '3.23' ) {
        print "Could convert to MyISAM database tables...\n" unless $silent;
    }
    
    #---------------------------------
    # Tables
    
    # Collect all tables into a list
    $sth = $dbh->prepare("show tables");
    $sth->execute;
    while ( my ($table) = $sth->fetchrow ) {
        $existingtables{$table} = 1;
    }
    
    
    # Now add any missing tables
    foreach $table ( keys %requiretables ) {
        unless ( $existingtables{$table} ) {
        print "Adding $table table...\n" unless $silent;
            my $sth = $dbh->prepare("create table $table $requiretables{$table} ENGINE=InnoDB DEFAULT CHARSET=utf8");
            $sth->execute;
            if ( $sth->err ) {
                print "Error : $sth->errstr \n";
                $sth->finish;
            }    # if error
        }    # unless exists
    }    # foreach
    
    #---------------------------------
    # Columns
    
    foreach $table ( keys %requirefields ) {
        print "Check table $table\n" if $debug and not $silent;
        $sth = $dbh->prepare("show columns from $table");
        $sth->execute();
        undef %types;
        while ( ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow )
        {
            $types{$column} = $type;
        }    # while
        foreach $column ( keys %{ $requirefields{$table} } ) {
            print "  Check column $column  [$types{$column}]\n" if $debug and not $silent;
            if ( !$types{$column} ) {
    
                # column doesn't exist
                print "Adding $column field to $table table...\n" unless $silent;
                $query = "alter table $table
                add column $column " . $requirefields{$table}->{$column};
                print "Execute: $query\n" if $debug;
                my $sti = $dbh->prepare($query);
                $sti->execute;
                if ( $sti->err ) {
                    print "**Error : $sti->errstr \n";
                    $sti->finish;
                }    # if error
            }    # if column
        }    # foreach column
    }    # foreach table
    
    foreach $table ( sort keys %fielddefinitions ) {
        print "Check table $table\n" if $debug;
        $sth = $dbh->prepare("show columns from $table");
        $sth->execute();
        my $definitions;
        while ( ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow )
        {
            $definitions->{$column}->{type}    = $type;
            $definitions->{$column}->{null}    = $null;
            $definitions->{$column}->{null}    = 'NULL' if $null eq 'YES';
            $definitions->{$column}->{key}     = $key;
            $definitions->{$column}->{default} = $default;
            $definitions->{$column}->{extra}   = $extra;
        }    # while
        my $fieldrow = $fielddefinitions{$table};
        foreach my $row (@$fieldrow) {
            my $field   = $row->{field};
            my $type    = $row->{type};
            my $null    = $row->{null};
    #         $null    = 'YES' if $row->{null} eq 'NULL';
            my $key     = $row->{key};
            my $default = $row->{default};
    #         $default="''" unless $default;
            my $extra   = $row->{extra};
            my $def     = $definitions->{$field};
            my $after    = ($row->{after}?" after ".$row->{after}:"");
    
            unless ( $type eq $def->{type}
                && $null eq $def->{null}
                && $key eq $def->{key}
                && $default eq $def->{default}
                && $extra eq $def->{extra} )
            {
                if ( $null eq '' ) {
                    $null = 'NOT NULL';
                }
                if ( $key eq 'PRI' ) {
                    $key = 'PRIMARY KEY';
                }
                unless ( $extra eq 'auto_increment' ) {
                    $extra = '';
                }
        
                # if it's a new column use "add", if it's an old one, use "change".
                my $action;
                if ($definitions->{$field}->{type}) {
                    $action="change `$field`"
                } else {
                    $action="add";
                }
    # if it's a primary key, drop the previous pk, before altering the table
                print "  alter or create $field in $table\n" unless $silent;
                my $query;
                if ($key ne 'PRIMARY KEY') {
    #                 warn "alter table $table $action $field $type $null $key $extra default $default $after";
                    $query = "alter table $table $action `$field` $type $null $key $extra ".
                             GetDefaultClause($default)." $after";
                } else {
    #             warn "alter table $table drop primary key, $action $field $type $null $key $extra default $default $after";
                    # something strange : for indexes UNIQUE, they are reported as primary key here.
                    # but if you try to run with drop primary key, it fails.
                    # thus, we run the query twice, one will fail, one will succeed.
                    # strange...
                    $query="alter table $table drop primary key, $action `$field` $type $null $key $extra ".
                           GetDefaultClause($default)." $after";
                    $query="alter table $table $action `$field` $type $null $key $extra ".
                           GetDefaultClause($default)." $after";
                }
                $dbh->do($query) or warn "Error while executing: $query";
            }
        }
    }
    
    print "removing some unused data...\n";
    foreach my $table ( keys %linetodelete ) {
        foreach my $where ( @{$linetodelete{$table}} ){
            print "DELETE FROM ".$table." where ".$where;
            print "\n";
            my $sth = $dbh->prepare("DELETE FROM $table where $where");
            $sth->execute;
            if ( $sth->err ) {
                print "Error : $sth->errstr \n";
            }
        }
    }
    
    # Populate tables with required data
    
    # synch table and deletedtable.
    foreach my $table (('borrowers','items','biblio','biblioitems')) {
        my %deletedborrowers;
        print "synch'ing $table and deleted$table\n";
        $sth = $dbh->prepare("show columns from deleted$table");
        $sth->execute;
        while ( my ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow ) {
            $deletedborrowers{$column}=1;
        }
        $sth = $dbh->prepare("show columns from $table");
        $sth->execute;
        my $previous;
        while ( my ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow ) {
            unless ($deletedborrowers{$column}) {
                my $newcol="alter table deleted$table add $column $type";
                if ($null eq 'YES') {
                    $newcol .= " NULL ";
                } else {
                    $newcol .= " NOT NULL ";
                }
                $newcol .= "default ".$dbh->quote($default) if $default;
                $newcol .= " after $previous" if $previous;
                $previous=$column;
                print "creating column $column\n";
                $dbh->do($newcol);
            }
        }
    }
    #
    # update publisheddate 
    #
    $sth = $dbh->prepare("select count(*) from serial where publisheddate is NULL");
    $sth->execute;
    my ($emptypublished) = $sth->fetchrow;
    if ($emptypublished) {
        print "Updating publisheddate\n";
        $dbh->do("update serial set publisheddate=planneddate where publisheddate is NULL");
    }
    # Why are we setting publisheddate = planneddate ?? if we don't have the data, we don't know it.
    # now, let's get rid of 000-00-00's.

        $dbh->do("update serial set publisheddate=NULL where publisheddate = 0");
        $dbh->do("update subscription set firstacquidate=startdate where firstacquidate = 0");
    
    foreach my $table ( keys %tabledata ) {
        print "Checking for data required in table $table...\n" unless $silent;
        my $tablerows = $tabledata{$table};
        foreach my $row (@$tablerows) {
            my $uniquefieldrequired = $row->{uniquefieldrequired};
            my $uniquevalue         = $row->{$uniquefieldrequired};
            my $forceupdate         = $row->{forceupdate};
            my $sth                 =
            $dbh->prepare(
    "select $uniquefieldrequired from $table where $uniquefieldrequired=?"
            );
            $sth->execute($uniquevalue);
            if ($sth->rows) {
                foreach my $field (keys %$forceupdate) {
                    if ($forceupdate->{$field}) {
                        my $sth=$dbh->prepare("update systempreferences set $field=? where $uniquefieldrequired=?");
                        $sth->execute($row->{$field}, $uniquevalue);
                    }
                }
            } else {
                print "Adding row to $table: " unless $silent;
                my @values;
                my $fieldlist;
                my $placeholders;
                foreach my $field ( keys %$row ) {
                    next if $field eq 'uniquefieldrequired';
                    next if $field eq 'forceupdate';
                    my $value = $row->{$field};
                    push @values, $value;
                    print "  $field => $value" unless $silent;
                    $fieldlist .= "$field,";
                    $placeholders .= "?,";
                }
                print "\n" unless $silent;
                $fieldlist    =~ s/,$//;
                $placeholders =~ s/,$//;
                print "insert into $table ($fieldlist) values ($placeholders)";
                my $sth =
                $dbh->prepare(
                    "insert into $table ($fieldlist) values ($placeholders)");
                $sth->execute(@values);
            }
        }
    }
    
    #
    # check indexes and create them when needed
    #
    print "Checking for index required...\n" unless $silent;
    foreach my $table ( keys %indexes ) {
        #
        # read all indexes from $table
        #
        $sth = $dbh->prepare("show index from $table");
        $sth->execute;
        my %existingindexes;
        while ( my ( $table, $non_unique, $key_name, $Seq_in_index, $Column_name, $Collation, $cardinality, $sub_part, $Packed, $comment ) = $sth->fetchrow ) {
            $existingindexes{$key_name} = 1;
        }
        # read indexes to check
        my $tablerows = $indexes{$table};
        foreach my $row (@$tablerows) {
            my $key_name=$row->{indexname};
            if ($existingindexes{$key_name} eq 1 and not $row->{force}) {
    #             print "$key_name existing";
            } else {
                print "\tCreating index $key_name in $table\n";
                my $sql;
                if ($row->{indexname} eq 'PRIMARY' or $row->{type} eq 'PRI') {
                    $sql = "alter table $table ADD PRIMARY KEY ($row->{content})";
                } else {
                    $sql = "alter table $table ADD INDEX $key_name ($row->{content}) $row->{type}";
                }
                $dbh->do($sql);
                print "Error $sql : $dbh->err \n" if $dbh->err;
            }
        }
    }
    
    #
    # check foreign keys and create them when needed
    #
    print "Checking for foreign keys required...\n" unless $silent;
    foreach my $table ( sort keys %foreign_keys ) {
        #
        # read all indexes from $table
        #
        $sth = $dbh->prepare("show table status like '$table'");
        $sth->execute;
        my $stat = $sth->fetchrow_hashref;
        # read indexes to check
        my $tablerows = $foreign_keys{$table};
        foreach my $row (@$tablerows) {
            my $foreign_table=$row->{foreigntable};
            if ($stat->{'Comment'} =~/$foreign_table/) {
    #             print "$foreign_table existing\n";
            } else {
                print "\tCreating foreign key $foreign_table in $table\n";
                # first, drop any orphan value in child table
                if ($row->{onDelete} ne "RESTRICT") {
                    my $sql = "delete from $table where $row->{key} not in (select $row->{foreignkey} from $row->{foreigntable})";
                    $dbh->do($sql);
                    print "SQL ERROR: $sql : $dbh->err \n" if $dbh->err;
                }
                my $sql="alter table $table ADD FOREIGN KEY $row->{key} ($row->{key}) REFERENCES $row->{foreigntable} ($row->{foreignkey})";
                $sql .= " on update ".$row->{onUpdate} if $row->{onUpdate};
                $sql .= " on delete ".$row->{onDelete} if $row->{onDelete};
                $dbh->do($sql);
                if ($dbh->err) {
                    print "====================
    An error occured during :
    \t$sql
    It probably means there is something wrong in your DB : a row ($table.$row->{key}) refers to a value in $row->{foreigntable}.$row->{foreignkey} that does not exist. solve the problem and run updater again (or just the previous SQL statement).
    You can find those values with select
    \t$table.* from $table where $row->{key} not in (select $row->{foreignkey} from $row->{foreigntable})
    ====================\n
    ";
                }
            }
        }
    }
    # now drop useless tables
    foreach $table ( @TableToDelete ) {
        if ( $existingtables{$table} ) {
            print "Dropping unused table $table\n" if $debug and not $silent;
            $dbh->do("drop table $table");
            if ( $dbh->err ) {
                print "Error : $dbh->errstr \n";
            }
        }
    }
    
    #
    # SPECIFIC STUFF
    #
    #
    # create frameworkcode row in biblio table & fill it with marc_biblio.frameworkcode.
    #
    
    # 1st, get how many biblio we will have to do...
    $sth = $dbh->prepare('select count(*) from marc_biblio');
    $sth->execute;
    my ($totaltodo) = $sth->fetchrow;
    
    $sth = $dbh->prepare("show columns from biblio");
    $sth->execute();
    my $definitions;
    my $bibliofwexist=0;
    while ( ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow ){
        $bibliofwexist=1 if $column eq 'frameworkcode';
    }
    unless ($bibliofwexist) {
        print "moving biblioframework to biblio table\n";
        $dbh->do('ALTER TABLE `biblio` ADD `frameworkcode` VARCHAR( 4 ) NOT NULL AFTER `biblionumber`');
        $sth = $dbh->prepare('select biblionumber,frameworkcode from marc_biblio');
        $sth->execute;
        my $sth_update = $dbh->prepare('update biblio set frameworkcode=? where biblionumber=?');
        my $totaldone=0;
        while (my ($biblionumber,$frameworkcode) = $sth->fetchrow) {
            $sth_update->execute($frameworkcode,$biblionumber);
            $totaldone++;
            print "\r$totaldone / $totaltodo" unless ($totaldone % 100);
        }
        print "\rdone\n";
    }
    
    # at last, remove useless fields
    foreach $table ( keys %uselessfields ) {
        my @fields = split /,/,$uselessfields{$table};
        my $fields;
        my $exists;
        foreach my $fieldtodrop (@fields) {
            $fieldtodrop =~ s/\t//g;
            $fieldtodrop =~ s/\n//g;
            $exists =0;
            $sth = $dbh->prepare("show columns from $table");
            $sth->execute;
            while ( my ( $column, $type, $null, $key, $default, $extra ) = $sth->fetchrow )
            {
                $exists =1 if ($column eq $fieldtodrop);
            }
            if ($exists) {
                print "deleting $fieldtodrop field in $table...\n" unless $silent;
                my $sth = $dbh->prepare("alter table $table drop $fieldtodrop");
                $sth->execute;
            }
        }
    }    # foreach
    
    #
    # Changing aqbookfund's primary key 
    #
    $sth=$dbh->prepare("ALTER TABLE `aqbookfund` DROP PRIMARY KEY , ADD PRIMARY KEY ( `bookfundid` , `branchcode` ) ;");
    $sth->execute;
   
    # drop extra key on borrowers.borrowernumber
    $dbh->do("ALTER TABLE borrowers DROP KEY borrowernumber"); 

    $sth->finish;
    print "upgrade to Koha 3.0 done\n";
    SetVersion ($DBversion);


=item GetDefaultClause

Generate a default clause (for an ALTER TABLE command)

=cut
sub GetDefaultClause {
    my $default = shift;

    return "" unless defined $default;
    return "" if $default eq '';    
    return "default ''" if $default eq "''";
    return "default NULL" if $default eq "NULL";
    return "default " . $dbh->quote($default);
}

=item TransformToNum

  Transform the Koha version from a 4 parts string
  to a number, with just 1 .
  
=cut

sub TransformToNum {
    my $version = shift;
    # remove the 3 last . to have a Perl number
    $version =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    return $version;
}

=item SetVersion
    set the DBversion in the systempreferences
=cut

sub SetVersion {
    my $kohaversion = TransformToNum(shift);
    if (C4::Context->preference('Version')) {
      my $finish=$dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
      $finish->execute($kohaversion);
    } else {
      my $finish=$dbh->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller')");
      $finish->execute($kohaversion);
    }
}
exit;

# Revision 1.172  2007/07/19 10:21:22  hdl
