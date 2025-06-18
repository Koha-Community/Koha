package Koha::Template::Plugin::To;

# This file is part of Koha.
#
# Copyright BibLibre 2014
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

use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

use JSON;
our $DYNAMIC = 1;

sub json {
    my ( $self, $value ) = @_;

    my $json = JSON->new->allow_nonref(1);
    $json = $json->encode($value);
    $json =~ s/^"|"$//g;       # Remove quotes around the strings
    $json =~ s/\\r/\\\\r/g;    # Convert newlines to escaped newline characters
    $json =~ s/\\n/\\\\n/g;
    return $json;
}

sub filter {
    my ( $self, $value ) = @_;
    return $self->json($value);
}

1;
