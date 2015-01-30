#!/usr/bin/perl
#

use Modern::Perl;
use utf8;

use Test::More tests => 12;

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
is( ref($schema), 'Koha::Schema', 'Koha::Database->new->schema should return a Koha::Schema' );
my $another_schema = $database->schema();
is( $another_schema->storage->_conn_pid, $schema->storage->_conn_pid, 'Getting another schema should return the same one, it has correctly been cached' );
$another_schema = Koha::Database->new->schema();
is( $another_schema->storage->_conn_pid, $schema->storage->_conn_pid, 'Getting another schema should return the same one, it has correctly been cached' );

my $new_schema;
ok( $new_schema = $database->new_schema(), 'Try to get a new schema' );
ok( $database->set_schema($new_schema), 'Switch to new schema' );
ok( $database->restore_schema(),        'Switch back' );

# run in a transaction
$schema->storage->txn_begin();

# clear the way
$schema->resultset('Category')->search({ categorycode => 'GIFT-RUS' })->delete;
my $gift = 'подарок';
$schema->resultset('Category')->create({
    categorycode => 'GIFT-RUS',
    description  => $gift,
});
my $desc = $schema->resultset('Category')->search({
    categorycode => 'GIFT-RUS',
})->single->get_column('description');
is($desc, $gift, 'stored and retrieved UTF8 string');
$schema->storage->txn_rollback();
