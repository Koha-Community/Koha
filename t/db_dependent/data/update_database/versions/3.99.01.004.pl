#!/usr/bin/perl

# You write good Perl, so you start with Modern::Perl, of course
use Modern::Perl;

# then you load Packages that could be usefull
use C4::Context;
# Loading this package is usefull if you need to check if a table exist (TableExists)
use C4::Update::Database;

# you *must* have the sub _get_queries
# it returns an array of all SQL that have to be executed
# this array will be stored "forever" in your Koha database
# thus, you will be able to know which SQL has been executed
# at the time of upgrade. Very handy, because since then
# your database configuration may have changed and you'll wonder
# what has really be executed, not what would be executed today !

# put in an array the SQL to execute
# put in an array the comments
sub _get_queries {
    my @queries;
    my @comments;
    push @comments, "Add sample feature";
    unless ( C4::Update::Database::TableExists('testtable') ) {
        push @queries, qq{
                CREATE TABLE `UpdateDatabase_testtable` (
                  `id` int(11) NOT NULL AUTO_INCREMENT,
                  `source` text DEFAULT NULL,
                  `text` mediumtext NOT NULL,
                  `timestamp` datetime NOT NULL,
                  PRIMARY KEY (`id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8
            };
        push @comments, qq { * Added the table UpdateDatabase_testtable that did not exist};
    }
    push @queries, qq{INSERT IGNORE INTO `systempreferences` (variable,value,explanation,options,type) VALUES('UpdateDatabase::testsyspref1',0,'Enable or disable display of Quote of the Day on the OPAC home page',NULL,'YesNo')};
    push @queries, qq{INSERT IGNORE INTO `systempreferences` (variable,value,explanation,options,type) VALUES('UpdateDatabase::testsyspref2',0,'Enable or disable display of Quote of the Day on the OPAC home page',NULL,'YesNo')};
    push @comments , qq{ * Added 2 sysprefs};

# return queries and comments
    return { queries => \@queries, comments => \@comments };
}
1;
