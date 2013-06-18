#!/usr/bin/perl
#

use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
    use_ok('Koha::Database');
}

my $database;
ok( $database = Koha::Database->new(), 'Created Koha::Database Object' );

my $schema;
ok( $schema = $database->schema(), 'Get a schema' );
my $dbh;
ok( $dbh = $schema->storage->dbh(), 'Get an old fashioned DBI dbh handle' );
ok( $schema->storage->connected(), 'Check our db connection is active' );
ok( $schema = $database->schema(), 'Try and get the same schema' );

my $new_schema;
ok( $new_schema = $database->new_schema(), 'Try to get a new schema' );
ok( $database->set_schema($new_schema), 'Switch to new schema' );
ok( $database->restore_schema(),        'Switch back' );

