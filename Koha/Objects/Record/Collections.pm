package Koha::Objects::Record::Collections;

# Copyright 2023 Theke Solutions
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

use MARC::File::MiJ;
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Record;

=head1 NAME

Koha::Objects::Record::Collections - Generic records collection handling class

=head1 SYNOPSIS

    use base qw(Koha::Objects Koha::Objects::Record::Collections);
    my $collections = Koha::Objects->print_collection($format);

=head1 DESCRIPTION

This class is provided as a generic way of handling a collection of records for Koha::Objects-based classes
in Koha.

This class must always be subclassed.

=head1 API

=head2 Class methods

=cut

=head3 print_collection
    my $collection_text = $result_set->print_collection($format)

Return a text representation of a collection (group of records) in the specified format.
Allowed formats are marcxml, mij, marc and txt. Defaults to marcxml.

=cut

sub print_collection {
    my ( $self, $format ) = @_;

    my ( $start, $glue, $end, @parts );

    my %serializers = (
        'mij'     => \&MARC::File::MiJ::encode,
        'marc'    => \&MARC::File::USMARC::encode,
        'txt'     => \&MARC::Record::as_formatted,
        'marcxml' => \&MARC::File::XML::record
    );
    if ( $format eq 'mij' ) {
        $start = '[';
        $glue  = ',';
        $end   = ']';
    }
    elsif ( $format eq 'marc' ) {
        $glue = "\n";
    }
    elsif ( $format eq 'txt' ) {
        $glue = "\n\n";
    }
    else {
        $glue   = '';
        $format = 'marcxml';
        $start  = MARC::File::XML::header();
        $end    = MARC::File::XML::footer();
    }
    while ( my $element = $self->next ) {
        push @parts, $serializers{$format}->( $element->record );
    }
    return
        ( defined $start ? $start : '' )
      . join( $glue, @parts )
      . ( defined $end ? $end : '' );
}

1;
