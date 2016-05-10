package Koha::SearchEngine::Zebra::QueryBuilder;

# This file is part of Koha.
#
# Copyright 2012 BibLibre
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

use base qw(Class::Accessor);

use C4::Search;
use C4::AuthoritiesMarc;

sub build_query {
    shift;
    C4::Search::buildQuery @_;
}

sub build_query_compat {
    # Because this passes directly on to C4::Search, we have no trouble being
    # compatible.
    build_query(@_);
}

sub build_authorities_query {
    shift;
    C4::AuthoritiesMarc::SearchAuthorities(@_);
    return {
        marclist     => $_[0],
        and_or       => $_[1],
        excluding    => $_[2],
        operator     => $_[3],
        value        => $_[4],
        authtypecode => $_[5],
        orderby      => $_[6],
    };
}

sub build_authorities_query_compat {
    # Pass straight through as well
    build_authorities_query(@_);
}

1;
