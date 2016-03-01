#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2015 Mark Tompsett
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

use Test::More tests => 3;

use List::MoreUtils qw/any/;
use MARC::Record;
use MARC::Field;
use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::RecordProcessor');
}

my $dbh = C4::Context->dbh;

my $database = Koha::Database->new();
my $schema   = $database->schema();
$dbh->{RaiseError} = 1;

my @valid_hidden_values = (
    '-7', '-6', '-5', '-4', '-3', '-2', '-1', '0',
     '1',  '2',  '3',  '4',  '5',  '6',  '7', '8'
);

my $hidden = {
    opac     => [  '1',  '2',  '3',  '4', '5', '6', '7', '8' ],
    intranet => [ '-7', '-4', '-3', '-2', '2', '3', '5', '8' ]
};

sub run_hiding_tests {

    my $interface = shift;

    # foreach my $hidden_value ( @{ $hidden->{ $interface } } ) {
    foreach my $hidden_value ( @valid_hidden_values ) {

        $schema->storage->txn_begin();

        my $sth = $dbh->prepare("
            UPDATE marc_subfield_structure SET hidden=?
            WHERE tagfield='020' OR
                  tagfield='008';
        ");
        $sth->execute( $hidden_value );

        my $processor = Koha::RecordProcessor->new({
            schema  => 'MARC',
            filters => ( 'ViewPolicy' ),
            options => { interface => $interface }
        });

        is(
            ref( $processor->filters->[0] ),
            'Koha::Filter::MARC::ViewPolicy',
            "Created record processor with ViewPolicy filter ($hidden_value)"
        );

        # Create a fresh record
        my $record = create_marc_record();
        # Apply filters
        my $filtered_record = $processor->process( $record );
        # Data fields

        if ( any { $_ eq $hidden_value } @{ $hidden->{ $interface } }) {
            # Subfield and controlfield are set to be hidden

            is( $filtered_record->field('020'), undef,
                "Data field has been deleted because of hidden=$hidden_value" );
            is( $record->field('020'), undef,
                "Data field has been deleted in the original record because of hidden=$hidden_value" );
            # Control fields have a different behaviour in code
            is( $filtered_record->field('008'), undef,
                "Control field has been deleted because of hidden=$hidden_value" );
            is( $record->field('008'), undef,
                "Control field has been deleted in the original record because of hidden=$hidden_value" );

        } else {

            isnt( $filtered_record->field('020'), undef,
                "Data field hasn't been deleted because of hidden=$hidden_value" );
            isnt( $record->field('020'), undef,
                "Data field hasn't been deleted in the original record because of hidden=$hidden_value" );
            # Control fields have a different behaviour in code
            isnt( $filtered_record->field('008'), undef,
                "Control field hasn't been deleted because of hidden=$hidden_value" );
            isnt( $record->field('008'), undef,
                "Control field hasn't been deleted in the original record because of hidden=$hidden_value" );
        }

        is_deeply( $filtered_record, $record,
            "Records are the same" );

        $schema->storage->txn_rollback();
    }
}

sub create_marc_record {

    my $isbn   = '0590353403';
    my $title  = 'Foundation';
    my $record = MARC::Record->new;
    my @fields = (
        MARC::Field->new( '003', 'AR-CdUBM'),
        MARC::Field->new( '008', '######suuuu####ag_||||__||||_0||_|_uuu|d'),
        MARC::Field->new( '020', q{}, q{}, 'a' => $isbn  ),
        MARC::Field->new( '245', q{}, q{}, 'a' => $title )
    );

    $record->insert_fields_ordered( @fields );

    return $record;
}

subtest 'Koha::Filter::MARC::ViewPolicy opac tests' => sub {

    plan tests => 96;

    run_hiding_tests('opac');
};

subtest 'Koha::Filter::MARC::ViewPolicy intranet tests' => sub {

    plan tests => 96;

    run_hiding_tests('intranet');
};


1;
