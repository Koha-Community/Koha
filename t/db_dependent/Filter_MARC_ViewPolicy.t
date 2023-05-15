#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2015 Mark Tompsett
#                - Initial commit, perlcritic clean-up, and
#                  debugging
# Copyright 2016 Tomas Cohen Arazi
#                - Expansion of test cases to be comprehensive
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
use C4::Biblio qw( GetMarcFromKohaField );
use Koha::Caches;
use Koha::Database;

BEGIN {
    use_ok('Koha::RecordProcessor');
}

my $dbh = C4::Context->dbh;

my $database = Koha::Database->new();
my $schema   = $database->schema();

sub run_hiding_tests {

    my $interface = shift;

    # TODO: -8 is Flagged, which doesn't seem used.
    # -9 and +9 are supposedly valid future values
    # according to older documentation in 3.10.x
    my @valid_hidden_values =
      ( -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8 );

    my $hidden = {
        'opac'     => [ -8, 1,  2,  3,  4,  5, 6, 7, 8 ],
        'intranet' => [ -8, -7, -4, -3, -2, 2, 3, 5, 8 ]
    };

    my ( $isbn_field, $isbn_subfield ) =
      GetMarcFromKohaField( 'biblioitems.isbn' );
    my $update_sql = q{UPDATE marc_subfield_structure SET hidden=? };
    my $sth        = $dbh->prepare($update_sql);
    foreach my $hidden_value (@valid_hidden_values) {

        $sth->execute($hidden_value);

        my $cache = Koha::Caches->get_instance();
        $cache->flush_all();    # easy way to ensure DB is queried again.

        my $processor = Koha::RecordProcessor->new(
            {
                schema  => 'MARC',
                filters => ('ViewPolicy'),
                options => { interface => $interface }
            }
        );

        is(
            ref( $processor->filters->[0] ),
            'Koha::Filter::MARC::ViewPolicy',
            "Created record processor with ViewPolicy filter ($hidden_value)"
        );

        # Create a fresh record
        my $sample_record     = create_marc_record();
        my $unfiltered_record = $sample_record->clone();

        # Apply filters
        my $filtered_record = $processor->process($sample_record);

        # Data fields
        if ( any { $_ == $hidden_value } @{ $hidden->{$interface} } ) {

            # Subfield and controlfield are set to be hidden
            is( $filtered_record->field($isbn_field),
                undef,
                "Data field has been deleted because of hidden=$hidden_value" );
            isnt( $unfiltered_record->field($isbn_field), undef,
"Data field has been deleted in the original record because of hidden=$hidden_value"
            );

            # Control fields have a different behaviour in code
            is( $filtered_record->field('008'), undef,
                "Control field has been deleted because of hidden=$hidden_value"
            );
            isnt( $unfiltered_record->field('008'), undef,
"Control field has been deleted in the original record because of hidden=$hidden_value"
            );

            ok( $filtered_record && $unfiltered_record, 'Records exist' );

        }
        else {
            isnt( $filtered_record->field($isbn_field), undef,
                "Data field hasn't been deleted because of hidden=$hidden_value"
            );
            isnt( $unfiltered_record->field($isbn_field), undef,
"Data field hasn't been deleted in the original record because of hidden=$hidden_value"
            );

            # Control fields have a different behaviour in code
            isnt( $filtered_record->field('008'), undef,
"Control field hasn't been deleted because of hidden=$hidden_value"
            );
            isnt( $unfiltered_record->field('008'), undef,
"Control field hasn't been deleted in the original record because of hidden=$hidden_value"
            );

            # force all the hidden values the same, so filtered and unfiltered
            # records should be identical.
            is_deeply( $filtered_record, $unfiltered_record,
                'Records are the same' );
        }

    }

    $sth->execute(-1); # -1 is visible in opac and intranet.

    my $cache = Koha::Caches->get_instance();
    $cache->flush_all();    # easy way to ensure DB is queried again.

    my $shouldhidemarc = Koha::Filter::MARC::ViewPolicy->should_hide_marc(
        {
            frameworkcode => q{},
            interface     => $interface
        }
    );
    my @hiddenfields = grep { $shouldhidemarc->{$_}==1 } keys %{$shouldhidemarc};

    $sth->execute(8); # 8 is invisible in opac and intranet.

    $cache->flush_all();    # easy way to ensure DB is queried again.

    $shouldhidemarc = Koha::Filter::MARC::ViewPolicy->should_hide_marc(
        {
            frameworkcode => q{},
            interface     => $interface
        }
    );
    my @keyvalues = keys %{$shouldhidemarc};
    my @visiblefields = grep { $shouldhidemarc->{$_}==1 } @keyvalues;

    is(scalar @hiddenfields,0,'Should Hide MARC - Full Visibility');
    is_deeply(\@visiblefields,\@keyvalues,'Should Hide MARC - No Visibility');
    return;
}

sub create_marc_record {

    my ( $title_field, $title_subfield ) =
      GetMarcFromKohaField( 'biblio.title' );
    my ( $isbn_field, $isbn_subfield ) =
      GetMarcFromKohaField( 'biblioitems.isbn' );
    my $isbn        = '0590353403';
    my $title       = 'Foundation';
    my $marc_record = MARC::Record->new;
    my @fields      = (
        MARC::Field->new( '003', 'AR-CdUBM' ),
        MARC::Field->new( '008', '######suuuu####ag_||||__||||_0||_|_uuu|d' ),
        MARC::Field->new( $isbn_field,  q{}, q{}, $isbn_subfield  => $isbn ),
        MARC::Field->new( $title_field, q{}, q{}, $title_subfield => $title ),
    );

    $marc_record->insert_fields_ordered(@fields);

    return $marc_record;
}

subtest 'Koha::Filter::MARC::ViewPolicy opac tests' => sub {

    plan tests => 104;

    $schema->storage->txn_begin();
    run_hiding_tests('opac');
    $schema->storage->txn_rollback();
};

subtest 'Koha::Filter::MARC::ViewPolicy intranet tests' => sub {

    plan tests => 104;

    $schema->storage->txn_begin();
    run_hiding_tests('intranet');
    $schema->storage->txn_rollback();
};

my $cache = Koha::Caches->get_instance();
$cache->flush_all(); # Clear cache for the other tests
