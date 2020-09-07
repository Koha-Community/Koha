#!/usr/bin/perl

use Modern::Perl;
use FindBin qw( $Bin );
use Test::More;
use Test::MockModule;
use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 5;
    }
    else {
        plan skip_all => 'Need Test::DBIx::Class';
    }

}

use Test::DBIx::Class;

fixtures_ok [
    VendorEdiAccount =>
      [ [ 'id', 'description', 'transport' ], [ 1, 'test vendor', 'FILE' ], ],
    EdifactMessage => [
        [ 'message_type', 'filename',  'raw_msg' ],
        [ 'TEST',         'duplicate', 'message_contents' ],
    ],
  ],
  'add_fixtures';

my $filename = 'QUOTES_413514.CEQ';

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

use_ok('Koha::Edifact::Transport');

my $trans = Koha::Edifact::Transport->new(1);

isa_ok( $trans, 'Koha::Edifact::Transport' );

$trans->working_directory("$Bin/edi_testfiles");

my $mhash = $trans->message_hash();
$mhash->{message_type} = 'TEST';    # set a bogus message type

$trans->ingest( $mhash, $filename );

my $cnt = ResultSet('EdifactMessage')->count();

is( $cnt, 2, 'unique message name ingested' );

$trans->ingest( $mhash, $filename );    # try a repeat ingest

my $cnt2 = ResultSet('EdifactMessage')->count();

is( $cnt2, 2, 'duplicate message name not ingested' );
