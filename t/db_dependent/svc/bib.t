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

use Test::More tests => 6;
use Test::NoWarnings;
use Test::MockModule;
use FindBin;

use t::lib::TestBuilder;

use C4::Biblio qw( AddBiblio );
use Koha::Biblios;
use MARC::Record;
use MARC::Field;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $script = "$FindBin::Bin/../../../svc/bib";

# Runs svc/bib in-process as a GET request for $biblionumber, with API auth
# mocked to succeed, and returns the raw output and any exception that escaped.
sub run_fetch_bib {
    my ($biblionumber) = @_;

    my $auth = Test::MockModule->new('C4::Auth');
    $auth->mock( check_api_auth => sub { return ( 'ok', undef, undef ) } );

    local $ENV{REQUEST_METHOD} = 'GET';
    local $ENV{PATH_INFO}      = "/$biblionumber";
    local $ENV{QUERY_STRING}   = '';

    my $output = '';
    my $error;
    {
        # Warnings (e.g. from the repair of a record) are expected and not asserted here
        local $SIG{__WARN__} = sub { };
        no warnings 'once';
        local *CORE::GLOBAL::exit = sub { die "svc-bib-exit\n" };
        local *STDOUT;
        open STDOUT, '>', \$output or die "Cannot capture STDOUT: $!";
        do $script;
        $error = $@;
    }
    $auth->unmock_all;

    $error = '' if $error eq "svc-bib-exit\n";
    return ( $output, $error );
}

sub split_response {
    my ($output) = @_;
    my ( $headers, $body ) = split /\r?\n\r?\n/, $output, 2;
    return ( $headers // '', $body // '' );
}

$schema->storage->txn_begin;

my $title = 'Oranges and Peaches';

my $record = MARC::Record->new();
$record->append_fields( MARC::Field->new( '245', '', '', 'a' => $title ) );
my ($biblionumber) = AddBiblio( $record, '' );

subtest 'Valid record' => sub {
    plan tests => 4;

    my ( $output,  $error ) = run_fetch_bib($biblionumber);
    my ( $headers, $body )  = split_response($output);

    is( $error, '', 'svc/bib runs without dying' );
    unlike( $headers, qr/^Status:/m, 'Response is a 200' );
    like( $headers, qr/^Invalid-Metadata: 0/mi, 'invalid_metadata header is 0 for a valid record' );
    like( $body,    qr/\Q$title\E/,             'Response body carries the record' );
};

# Store corrupt MARCXML directly, bypassing store()
{
    my $metadata = Koha::Biblios->find($biblionumber)->metadata;
    ( my $xml = $metadata->metadata ) =~ s/\Q$title\E/Oranges and\x{1F} Peaches/;
    $metadata->_result->update( { metadata => $xml } );
}

subtest 'Recoverable record' => sub {
    plan tests => 5;

    my ( $output,  $error ) = run_fetch_bib($biblionumber);
    my ( $headers, $body )  = split_response($output);

    is( $error, '', 'svc/bib runs without dying' );
    unlike( $headers, qr/^Status:/m, 'Response is a 200' );
    like( $headers, qr/^Invalid-Metadata: 1/mi, 'invalid_metadata header is set for a repaired record' );
    like( $body,    qr/\Q$title\E/,             'Response body carries the repaired record' );
    unlike( $body, qr/\x{1F}/, 'Response body does not contain the control character' );
};

subtest 'Recoverable record is repaired only once' => sub {
    plan tests => 2;

    my ( $output,  $error ) = run_fetch_bib($biblionumber);
    my ( $headers, $body )  = split_response($output);

    is( $error, '', 'svc/bib runs without dying' );
    like(
        $headers, qr/^Invalid-Metadata: 0/mi,
        'The repaired metadata is stored, so the header is 0 on later requests'
    );
};

subtest 'Unrecoverable record' => sub {
    plan tests => 5;

    my $bad_record = MARC::Record->new();
    $bad_record->append_fields( MARC::Field->new( '245', '', '', 'a' => 'Unrecoverable' ) );
    my ($bad_biblionumber) = AddBiblio( $bad_record, '' );
    Koha::Biblios->find($bad_biblionumber)->metadata->_result->update( { metadata => 'this_is_not_marcxml' } );

    my ( $output,  $error ) = run_fetch_bib($bad_biblionumber);
    my ( $headers, $body )  = split_response($output);

    is( $error, '', 'svc/bib does not die on an unrecoverable record' );
    like( $headers, qr/^Status: 500/m, 'Response is a 500 for an unrecoverable record' );
    unlike( $headers, qr/^Invalid-Metadata:/mi, 'No invalid_metadata header when the record cannot be repaired' );
    like( $body, qr/<error>/, 'Response body carries an error message' );
    unlike( $body, qr/Can't locate object method/, 'No missing-method error leaks into the response' );
};

subtest 'Unknown biblionumber' => sub {
    plan tests => 2;

    my ( $output,  $error ) = run_fetch_bib(999999999);
    my ( $headers, $body )  = split_response($output);

    is( $error, '', 'svc/bib does not die for an unknown biblionumber' );
    like( $headers, qr/^Status: 404/m, 'Response is a 404' );
};

$schema->storage->txn_rollback;
