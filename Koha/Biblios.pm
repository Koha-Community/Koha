package Koha::Biblios;

# Copyright ByWater Solutions 2015
#
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


use Koha::Database;

use Koha::Biblio;
use Koha::Libraries;
use MARC::File::MiJ;
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Record;

use base qw(Koha::Objects Koha::Objects::Record::Collections);

=head1 NAME

Koha::Biblios - Koha Biblio object set class

=head1 API

=head2 Class methods

=head3 print_collection
    my $collection_text = $result_set->print_collection($format)

Return a text representation of a collection (group of records) in the specified format.
Allowed formats are marcxml, mij, marc and txt. Defaults to marcxml.

=cut

sub print_collection {
    my ( $self, $format ) = @_;

    my ($start, $glue, $end, @parts);

    my %serializers = (
        'mij' => \&MARC::File::MiJ::encode,
        'marc' => \&MARC::File::USMARC::encode,
        'txt' => \&MARC::Record::as_formatted,
        'marcxml' => \&MARC::File::XML::record
    );
    if ($format eq 'mij') {
        $start = '[';
        $glue = ',';
        $end = ']';
    } elsif ($format eq 'marc') {
        $glue = "\n";
    } elsif ($format eq 'txt') {
        $glue = "\n\n";
    } else {
        $glue = '';
        $format = 'marcxml';
        $start = MARC::File::XML::header();
        $end = MARC::File::XML::footer();
    }
    while (my $biblio = $self->next) {
        push @parts, $serializers{$format}->($biblio->metadata->record);
    }
    return (defined $start ? $start : '').join($glue, @parts).(defined $end ? $end : '');
}

=head3 pickup_locations

    my $biblios = Koha::Biblios->search(...);
    my $pickup_locations = $biblios->pickup_locations({ patron => $patron });

For a given resultset, it returns all the pickup locations

=cut

sub pickup_locations {
    my ( $self, $params ) = @_;

    my $patron = $params->{patron};

    my @pickup_locations;
    foreach my $biblio ( $self->as_list ) {
        push @pickup_locations,
          $biblio->pickup_locations( { patron => $patron } )
          ->_resultset->get_column('branchcode')->all;
    }

    return Koha::Libraries->search(
        {
            branchcode => \@pickup_locations
        },
        { order_by => ['branchname'] }
    );
}

=head2 Internal methods

=head3 type

=cut

sub _type {
    return 'Biblio';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Biblio';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
