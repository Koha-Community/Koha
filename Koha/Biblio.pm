package Koha::Biblio;

# Copyright ByWater Solutions 2014
#
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

use Carp;

use C4::Biblio qw( GetRecordValue GetMarcBiblio GetFrameworkCode );

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Biblio - Koha Biblio Object class

=head1 API

=head2 Class Methods

=cut

=head3 subtitles

my @subtitles = $biblio->subtitles();

Returns list of subtitles for a record.

Keyword to MARC mapping for subtitle must be set for this method to return any possible values.

=cut

sub subtitles {
    my ( $self ) = @_;

    return map { $_->{subfield} } @{ GetRecordValue( 'subtitle', GetMarcBiblio( $self->id ), $self->frameworkcode ) };
}

=head3 items

Returns the related Koha::Items object for this biblio in scalar context,
or list of Koha::Item objects in list context.

=cut

sub items {
    my ($self) = @_;

    $self->{_items} ||= Koha::Items->search( { biblionumber => $self->biblionumber() } );

    return wantarray ? $self->{_items}->as_list : $self->{_items};
}

=head3 type

=cut

sub _type {
    return 'Biblio';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
