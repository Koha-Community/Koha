#!/usr/bin/perl

# Copyright 2012 C & P Bibliography Services
# Copyright 2017 Koha Development Team
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

use utf8;
use Test::More;    #See plan tests => \d+ below
use Test::WWW::Mechanize;
use XML::Simple;
use JSON;
use File::Basename;
use File::Spec;
use POSIX;
use t::lib::Mocks::Zebra;
use Koha::BackgroundJobs;

my $testdir = File::Spec->rel2abs( dirname(__FILE__) );

my $koha_conf = $ENV{KOHA_CONF};
my $xml       = XMLin($koha_conf);

use C4::Context;
my $marcflavour = C4::Context->preference('marcflavour') || 'MARC21';

my $file =
    $marcflavour eq 'UNIMARC'
    ? "$testdir/data/unimarcrecord.mrc"
    : "$testdir/data/marc21record.mrc";

my $user     = $ENV{KOHA_USER} || $xml->{config}->{user};
my $password = $ENV{KOHA_PASS} || $xml->{config}->{pass};
my $intranet = $ENV{KOHA_INTRANET_URL};

if ( not defined $intranet ) {
    plan skip_all => "You must set the environment variable KOHA_INTRANET_URL to "
        . "point this test to your staff interface. If you do not have "
        . "KOHA_CONF set, you must also set KOHA_USER and KOHA_PASS for "
        . "your username and password";
} else {
    plan tests => 24;
}

$intranet =~ s#/$##;

my $mock_zebra = t::lib::Mocks::Zebra->new(
    {
        intranet  => $intranet,
        koha_conf => $ENV{KOHA_CONF},
    }
);

my $import_batch_id = $mock_zebra->load_records_ui($file);

my $bookdescription;
if ( $marcflavour eq 'UNIMARC' ) {
    $bookdescription = 'Jeffrey Esakov et Tom Weiss';
} else {
    $bookdescription = 'Data structures';
}

my $agent = Test::WWW::Mechanize->new( autocheck => 1 );
$agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'connect to intranet' );
$agent->form_name('loginform');
$agent->field( 'login_password', $password );
$agent->field( 'login_userid',   $user );
$agent->field( 'branch',         '' );
$agent->click_ok( '', 'login to staff interface' );

# Get datatable for the batch id
$agent->get("$intranet/cgi-bin/koha/tools/batch_records_ajax.pl?import_batch_id=$import_batch_id");
my $jsonresponse = decode_json $agent->content;
like( $jsonresponse->{data}[0]->{citation}, qr/$bookdescription/, 'found book' );
is( $jsonresponse->{data}[0]->{status},         'imported', 'record marked as staged' );
is( $jsonresponse->{data}[0]->{overlay_status}, 'no_match', 'record has no matches' );

my $biblionumber = $jsonresponse->{data}[0]->{matched};

$agent->get_ok(
    "$intranet/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber",
    'getting imported bib'
);
$agent->content_contains(
    'Details for ' . $bookdescription,
    'bib is imported'
);

$agent->get("$intranet/cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=$import_batch_id");
$agent->form_number(5);
$agent->click_ok( 'mainformsubmit', "revert import" );

sleep(1);

# FIXME - This if fragile and can fail if there is a race condition
my $job = Koha::BackgroundJobs->search( { type => 'marc_import_revert_batch' } )->last;
my $i;
while ( $job->discard_changes->status ne 'finished' ) {
    sleep(1);
    last if ++$i > 10;
}
is( $job->status, 'finished', 'job is finished' );

$agent->get_ok(
    "$intranet/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber",
    'getting reverted bib'
);
$agent->content_contains(
    'The record you requested does not exist',
    'bib is gone'
);

$agent->get("$intranet/cgi-bin/koha/tools/batch_records_ajax.pl?import_batch_id=$import_batch_id");
$jsonresponse = decode_json $agent->content;
is( $jsonresponse->{data}[0]->{status}, 'reverted', 'record marked as reverted' );

