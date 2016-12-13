package Koha::Availability::Search;

# Copyright Koha-Suomi Oy 2016
#
# This file is part of Koha
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

use Koha::Biblio::Availability::Search;
use Koha::Item::Availability::Search;

use Koha::Exceptions;

sub new {
    my ($class, $params) = @_;

    my $self = {};

    bless $self, $class;
}

sub biblio {
    my ($self, $params) = @_;

    return Koha::Biblio::Availability::Search->new($params);
}

sub item {
    my ($self, $params) = @_;

    return Koha::Item::Availability::Search->new($params);
}

1;
