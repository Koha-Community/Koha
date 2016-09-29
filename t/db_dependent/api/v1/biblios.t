#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use t::lib::TestBuilder;

use Test::More tests => 3;
use Test::Mojo;
use Data::Dumper;
use C4::Auth;
use C4::Context;
use Koha::Database;
use MARC::File::XML ( BinaryEncoding => 'utf8', RecordFormat => 'UNIMARC' );

BEGIN {
    use_ok('Koha::Biblios');
}

my $schema  = Koha::Database->schema;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $file = MARC::File::XML->in( 't/db_dependent/Record/testrecords/marcxml_utf8.xml' );
my $record = $file->next();
my ( $biblionumber, $itemnumber );

my $librarian = $builder->build({
    source => "Borrower",
    value => {
        categorycode => 'S',
        branchcode => 'NPL',
        flags => 1, # editcatalogue
    },
});

my $session = C4::Auth::get_session('');
$session->param('number', $librarian->{ borrowernumber });
$session->param('id', $librarian->{ userid });
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

subtest 'Create biblio' => sub {
	plan tests => 5;

	my $tx = $t->ua->build_tx(POST => '/api/v1/biblios' => $record->as_xml());
	$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
	$tx->req->cookies({name => 'CGISESSID', value => $session->id});
	$t->request_ok($tx)
	  ->status_is(201);
	$biblionumber = $tx->res->json->{biblionumber};
	$itemnumber   = $tx->res->json->{items};

	$t->json_is('/biblionumber' => $biblionumber)
	  ->json_is('/items'      => $itemnumber)
	  ->header_like(Location => qr/$biblionumber/, 'Location header contains biblionumber');
};

subtest 'Delete biblio' => sub {
	plan tests => 2;

	my $tx = $t->ua->build_tx(DELETE => "/api/v1/biblios/$biblionumber");
	$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
	$tx->req->cookies({name => 'CGISESSID', value => $session->id});
	$t->request_ok($tx)
	  ->status_is(200);
};


$schema->storage->txn_rollback;
