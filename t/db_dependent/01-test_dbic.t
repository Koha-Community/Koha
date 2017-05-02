#!/usr/bin/perl

# This file is part of Koha.

use Modern::Perl;

use Test::More;
use Test::MockModule;

use Koha::Database;
use Koha::Libraries;

my $verbose = 0;

subtest "Scenario: Show how caching prevents Test::DBIx::Class from working properly and how to circumvent it", sub {
  my ($firstSchema, $cachedSchema, $cachedSchema2, $firstLibCount, $libCount);

  eval {

  ok($firstSchema = Koha::Database->schema,
  'Step: Given a normal DB connection.');

  $firstLibCount = Koha::Libraries->search->count; # first count normal conn

  print "\$firstLibCount '$firstLibCount'\n" if $verbose;

  ok($cachedSchema = Koha::Database::get_schema_cached(),
  '  And the DB connection is cached');

  unlike(getConnectionDBName($cachedSchema), qr/sqlite/i,
  '  And the cached DB connection type is not sqlite');
  print "getConnectionDBName() -> ".getConnectionDBName($cachedSchema)."\n" if $verbose;


  use_ok('Test::DBIx::Class');
  my $db = Test::MockModule->new('Koha::Database');
  $db->mock( _new_schema => sub { return Schema(); } );
  ok(1,
  'Step: Given Test::DBIx::Class (T:D:C) is loaded and DB accessor is mocked. Connection from cache is still used.');

  ok($libCount = Koha::Libraries->search->count,
  '  When the libraries are counted');

  is($libCount, $firstLibCount,
  '  Then we got the same count as without T:D:C');

  $cachedSchema = Koha::Database::get_schema_cached();
  is($cachedSchema, $firstSchema,
  '  And the cached DB connection is the same as without T:D:C');

  is(getConnectionDBName($cachedSchema), getConnectionDBName($firstSchema),
  '  And the cached DB connection type is unchanged');


  ok(Koha::Database::flush_schema_cache(),
  'Step: Given the DB connection cache is flushed');

  ok(! ($libCount = Koha::Libraries->search->count),
  '  When the libraries are counted');

  is($libCount, 0,
  '  Then we got 0 libraries because fixtures are not deployed');

  $cachedSchema = Koha::Database::get_schema_cached();
  isnt($cachedSchema, $firstSchema,
  '  And the cached DB connection has changed');

  like(getConnectionDBName($cachedSchema), qr/sqlite/i,
  '  And the cached DB connection type is sqlite');


  fixtures_ok( [ #Dynamically load fixtures, because we dynamically load T:D:C. Otherwise there be compile errors!
      Branch => [
          ['branchcode', 'branchname'],
          ['XXX_test', 'my branchname XXX'],
      ]
  ],
  'Step: Given we deploy T:D:C Fixtures');

  ok($libCount = Koha::Libraries->search->count,
  '  When the libraries are counted');

  is($libCount, 1,
  '  Then we got the count from fixtures');

  $cachedSchema2 = Koha::Database::get_schema_cached();
  is($cachedSchema2, $cachedSchema,
  '  And the cached DB connection is the same from T:D:C');

  like(getConnectionDBName($cachedSchema), qr/sqlite/i,
  '  And the cached DB connection type is sqlite');

  };
  ok(0, $@) if $@;
};

done_testing;


sub getConnectionDBName {
  #return shift->storage->_dbh_details->{info}->{dbms_version}; #This would return the name from server, but sqlite doesn't report a clear text name and version here.
  return shift->storage->connect_info->[0]->{dsn};
}
