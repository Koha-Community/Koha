#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use utf8;
use Test::More;    #See plan tests => \d+ below
use Test::NoWarnings;
use Test::WWW::Mechanize;
use Data::Dumper;
use File::Basename qw(dirname );
use POSIX;
use Encode;
use URI::Escape;

use C4::Context;

use t::lib::Mocks::Zebra;

my $testdir = File::Spec->rel2abs( dirname(__FILE__) );

# global variables that will be used when forking

my $marcflavour = C4::Context->preference('marcflavour') || 'MARC21';

my $file1 =
    $marcflavour eq 'UNIMARC'
    ? "$testdir/data/unimarcutf8record.mrc"
    : "$testdir/data/marc21utf8record.mrc";

my $file2 =
    $marcflavour eq 'UNIMARC'
    ? "$testdir/data/unimarclatin1utf8rec.mrc"
    : "$testdir/data/marc21latin1utf8rec.mrc";

my $file3 =
    $marcflavour eq 'UNIMARC'
    ? "$testdir/data/unimarcutf8supprec.mrc"
    : "$testdir/data/marc21utf8supprec.mrc";

our $intranet = $ENV{KOHA_INTRANET_URL};
our $opac     = $ENV{KOHA_OPAC_URL};

# test KOHA_INTRANET_URL is set
if ( not $intranet ) {
    plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}

# test KOHA_OPAC_URL is set
elsif ( not $opac ) {
    plan skip_all => "Tests skip. You must set env. variable KOHA_OPAC_URL to do tests\n";
} else {
    plan tests => 81;
}

$intranet =~ s#/$##;
$opac     =~ s#/$##;

my $mock_zebra = t::lib::Mocks::Zebra->new(
    {
        intranet  => $intranet,
        opac      => $opac,
        koha_conf => $ENV{KOHA_CONF},
    }
);

#-------------------------------- Test with greek and corean chars;
# launch the zebra saerch process
$mock_zebra->launch_zebra;
if ( not defined $mock_zebra->{zebra_pid} ) {
    plan skip_all => "Tests skip. Error starting Zebra Server to do those tests\n";
}

# launch the zebra index process
$mock_zebra->launch_indexer;
if ( not defined $mock_zebra->{indexer_pid} ) {
    plan skip_all => "Tests skip. Error starting the indexer daemon to do those tests\n";
}

our $agent = Test::WWW::Mechanize->new( autocheck => 1 );
$agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'connect to intranet' );
$agent->form_name('loginform');
$agent->field( 'login_userid',   $ENV{KOHA_PASS} || 'koha' );
$agent->field( 'login_password', $ENV{KOHA_USER} || 'koha' );
$agent->field( 'branch',         '' );
$agent->click_ok( '', 'login to staff interface' );

my $batch_id  = $mock_zebra->load_records_ui($file1);
my $utf8_reg1 = qr/学協会. μμ/;
test_search( 'Αθήνα', 'deuteros', $utf8_reg1 );
$mock_zebra->clean_records($batch_id);
$mock_zebra->cleanup;

#--------------------------------- Test with only utf-8 chars in the latin-1 range;
$mock_zebra->launch_zebra;
if ( not defined $mock_zebra->{zebra_pid} ) {
    plan skip_all => "Tests skip. Error starting Zebra Server to do those tests\n";
}
$mock_zebra->launch_indexer;
if ( not defined $mock_zebra->{indexer_pid} ) {
    plan skip_all => "Tests skip. Error starting the indexer daemon to do those tests\n";
}
$batch_id = $mock_zebra->load_records_ui($file2);
my $utf8_reg2 = qr/Tòmas/;
test_search( 'Ramòn', 'Tòmas', $utf8_reg2 );
$mock_zebra->clean_records($batch_id);
$mock_zebra->cleanup;

#--------------------------------- Test with supplementary utf-8 chars;
$mock_zebra->launch_zebra;
if ( not defined $mock_zebra->{zebra_pid} ) {
    plan skip_all => "Tests skip. Error starting Zebra Server to do those tests\n";
}
$mock_zebra->launch_indexer;
if ( not defined $mock_zebra->{indexer_pid} ) {
    plan skip_all => "Tests skip. Error starting the indexer daemon to do those tests\n";
}
$batch_id = $mock_zebra->load_records_ui($file3);
my $utf8_reg3 = qr/😀/;
test_search( "𠻺tomasito𠻺", 'A tiny record', $utf8_reg3 );
$mock_zebra->clean_records($batch_id);
$mock_zebra->cleanup;

sub test_search {
    my ( $publisher, $search_key, $utf8_reg ) = @_;

    # --------------------------------- TEST INTRANET SEARCH

    $agent->get_ok( "$intranet/cgi-bin/koha/catalogue/search.pl", "got search on intranet" );
    $agent->form_number(5);
    $agent->field( 'idx', 'kw' );
    $agent->field( 'q',   $search_key );
    $agent->click();
    my $intra_text = $agent->text();

    $agent->get_ok( "$intranet/cgi-bin/koha/catalogue/search.pl", "got search on intranet" );
    $agent->form_number(5);
    $agent->field( 'idx', 'kw' );
    $agent->field( 'q',   $publisher );
    $agent->click();
    $intra_text = $agent->text();

    my $expected_base = q|search.pl\?advsearch=1&idx=kw&q=| . uri_escape_utf8($publisher);
    $agent->base_like( qr|$expected_base|, );

    ok( ( length( Encode::encode( 'UTF-8', $intra_text ) ) != length($intra_text) ), 'UTF-8 are multi-byte. Good' );
    ok( $intra_text =~ $utf8_reg, 'UTF-8 chars are correctly present. Good' );

    # -------------------------------------------------- TEST ON OPAC

    $agent->get_ok( "$opac", "got opac" );
    $agent->form_name('searchform');
    $agent->field( 'q',   $search_key );
    $agent->field( 'idx', '' );
    $agent->click();
    my $opac_text = $agent->text();

    $agent->get_ok( "$opac", "got opac" );
    $agent->form_name('searchform');
    $agent->field( 'q',   $publisher );
    $agent->field( 'idx', '' );
    $agent->click();
    $opac_text = $agent->text();

    $expected_base = q|opac-search.pl\?(idx=&)?q=| . uri_escape_utf8($publisher);
    $agent->base_like( qr|$expected_base|, );

    # Test added on BZ 14909 in addition to making the empty idx= optional
    # in the previous regex
    $agent->base_unlike( qr|idx=\w+|, 'Base does not contain an idx' );

    ok( ( length( Encode::encode( 'UTF-8', $opac_text ) ) != length($opac_text) ), 'UTF-8 are multi-byte. Good' );
    ok( $opac_text =~ $utf8_reg, 'UTF-8 chars are correctly present. Good' );

}

END {
    $mock_zebra->cleanup;
}

