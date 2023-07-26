#!/usr/bin/perl

use Modern::Perl;
use FindBin qw( $Bin );
use Test::More tests => 6;
use Test::Warn;

use t::lib::TestBuilder;

use Koha::Database;

use_ok('Koha::Edifact::Transport');

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $account = $builder->build(
    {
        source => 'VendorEdiAccount',
        value  => {
            description => 'test vendor', transport => 'FILE',
        }
    }
);
$builder->build(
    {
        source => 'EdifactMessage',
        value  => { message_type => 'TEST', filename => 'duplicate', raw_msg => 'message_contents' }
    }
);

my $dirname  = ( $Bin =~ /^(.*\/t\/)/ ? $1 . 'edi_testfiles/' : q{} );
my $filename = 'QUOTES_413514.CEQ';
ok( -e $dirname . $filename, 'File QUOTES_413514.CEQ found' );

my $trans = Koha::Edifact::Transport->new( $account->{id} );

isa_ok( $trans, 'Koha::Edifact::Transport' );

$trans->working_directory($dirname);

my $mhash = $trans->message_hash();
$mhash->{message_type} = 'TEST';    # set a bogus message type

$trans->ingest( $mhash, $filename );

my $cnt = $schema->resultset('EdifactMessage')->count();

is( $cnt, 2, 'unique message name ingested' );

# try a repeat ingest
warning_like { $trans->ingest( $mhash, $filename ) } qr/skipping ingest of QUOTES_413514.CEQ/,
    'Warning on repeated ingest';

my $cnt2 = $schema->resultset('EdifactMessage')->count();

is( $cnt2, 2, 'duplicate message name not ingested' );

$schema->storage->txn_rollback;
