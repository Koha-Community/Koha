package Koha::Account::Line;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Account::Lines - Koha accountline Object class

=head1 API

=head2 Class Methods

=cut

=head3 TO_JSON

Overloads Koha::Object->TO_JSON

=cut

sub TO_JSON {
    my ($self) = @_;

    my $json = $self->SUPER::TO_JSON;

    my $itemnumber  = $self->itemnumber;
    my $description = $self->description;
    $description =~ s/^\s+|\s+$//g if defined $description;
    # If accountline description is an itemnumber, replace it with record title
    if (defined $description && defined $itemnumber &&
        $description == $itemnumber) {
        my $item = Koha::Items->find($itemnumber);
        if (defined $item) {
            my $biblio = $item->biblio;
            if (defined $biblio) {
                my $title = $biblio->title;
                $json->{description} = $title if defined $title;
            }
        }
    }

    return $json;
}

=head3 type

=cut

sub _type {
    return 'Accountline';
}

1;
