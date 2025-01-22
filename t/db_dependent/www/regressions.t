#!/usr/bin/env perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Context;
use C4::Biblio qw( ModBiblio );

use Koha::Database;
use Koha::Caches;

use MARC::Field;

my $intranet = $ENV{KOHA_INTRANET_URL} || C4::Context->preference("staffClientBaseURL");
my $opac     = $ENV{KOHA_OPAC_URL}     || C4::Context->preference("OPACBaseURL");

my $context   = C4::Context->new();
my $db_name   = $context->config("database");
my $db_host   = $context->config("hostname");
my $db_port   = $context->config("port") || '';
my $db_user   = $context->config("user");
my $db_passwd = $context->config("pass");
`mysqldump --add-drop-table -u $db_user --password="$db_passwd" -h $db_host -P $db_port $db_name > dumpfile.sql`;

my $t       = Test::Mojo->new();
my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'open redirection vulnerabilities in tracklinks' => sub {
    plan tests => 36;

    # No URI's
    my $biblio        = $builder->build_sample_biblio();
    my $biblionumber1 = $biblio->biblionumber;

    # Incorrect URI at Biblio level
    $biblio = $builder->build_sample_biblio();
    my $biblionumber2 = $biblio->biblionumber;
    my $record        = $biblio->metadata->record;
    my $new856        = MARC::Field->new( '856', '', '', u => "www.bing.com" );
    $record->insert_fields_ordered($new856);
    C4::Biblio::ModBiblio( $record, $biblionumber2 );

    # URI at Biblio level
    $biblio = $builder->build_sample_biblio();
    my $biblionumber3 = $biblio->biblionumber;
    $record = $biblio->metadata->record;
    $new856 = MARC::Field->new( '856', '', '', u => "http://www.google.com" );
    $record->insert_fields_ordered($new856);
    C4::Biblio::ModBiblio( $record, $biblionumber3 );

    # URI at Item level
    my $item        = $builder->build_sample_item( { uri => 'http://www.google.com' } );
    my $itemnumber1 = $item->itemnumber;

    # Incorrect URI at Item level
    $item = $builder->build_sample_item( { uri => 'www.bing.com ' } );
    my $itemnumber2 = $item->itemnumber;

    my $no_biblionumber   = '/cgi-bin/koha/tracklinks.pl?uri=http://www.google.com';
    my $bad_biblionumber1 = '/cgi-bin/koha/tracklinks.pl?uri=http://www.google.com&biblionumber=' . $biblionumber1;
    my $bad_biblionumber2 = '/cgi-bin/koha/tracklinks.pl?uri=http://www.google.com&biblionumber=' . $biblionumber2;
    my $good_biblionumber = '/cgi-bin/koha/tracklinks.pl?uri=http://www.google.com&biblionumber=' . $biblionumber3;
    my $bad_itemnumber    = '/cgi-bin/koha/tracklinks.pl?uri=http://www.google.com&itemnumber=' . $itemnumber2;
    my $good_itemnumber   = '/cgi-bin/koha/tracklinks.pl?uri=http://www.google.com&itemnumber=' . $itemnumber1;

    Koha::Caches->flush_L1_caches;

    # Don't Track
    C4::Context->set_preference( 'TrackClicks', '' );
    $t->get_ok( $opac . $no_biblionumber )->status_is( 404, "404 for no biblionumber" );
    $t->get_ok( $opac . $bad_biblionumber1 )->status_is( 404, "404 for biblionumber containing no URI - pref off" );
    $t->get_ok( $opac . $bad_biblionumber2 )
        ->status_is( 404, "404 for biblionumber containing different URI - pref off" );
    $t->get_ok( $opac . $good_biblionumber )->status_is( 404, "404 for biblionumber with matching URI - pref off" );
    $t->get_ok( $opac . $bad_itemnumber )->status_is( 404, "404 for itemnumber containing different URI- pref off" );
    $t->get_ok( $opac . $good_itemnumber )->status_is( 404, "404 for itemnumber with matching URI - pref off" );

    # Track
    C4::Context->set_preference( 'TrackClicks', 'track' );
    $t->get_ok( $opac . $no_biblionumber )->status_is( 404, "404 for no biblionumber" );
    $t->get_ok( $opac . $bad_biblionumber1 )->status_is( 404, "404 for biblionumber containing no URI" );
    $t->get_ok( $opac . $bad_biblionumber2 )->status_is( 404, "404 for biblionumber containing different URI" );
    $t->get_ok( $opac . $good_biblionumber )->status_is( 302, "302 for biblionumber with matching URI" );
    $t->get_ok( $opac . $bad_itemnumber )->status_is( 404, "404 for itemnumber containing different URI" );
    $t->get_ok( $opac . $good_itemnumber )->status_is( 302, "302 for itemnumber with matching URI" );

    # Track Anonymous
    C4::Context->set_preference( 'TrackClicks', 'anonymous' );
    $t->get_ok( $opac . $no_biblionumber )->status_is( 404, "404 for no biblionumber" );
    $t->get_ok( $opac . $bad_biblionumber1 )->status_is( 404, "404 for biblionumber containing no URI" );
    $t->get_ok( $opac . $bad_biblionumber2 )->status_is( 404, "404 for biblionumber containing different URI" );
    $t->get_ok( $opac . $good_biblionumber )->status_is( 302, "302 for biblionumber with matching URI" );
    $t->get_ok( $opac . $bad_itemnumber )->status_is( 404, "404 for itemnumber containing different URI" );
    $t->get_ok( $opac . $good_itemnumber )->status_is( 302, "302 for itemnumber with matching URI" );
};

`mysql -u $db_user --password="$db_passwd" -h $db_host -P $db_port --database="$db_name" < dumpfile.sql`;
`rm dumpfile.sql`;
