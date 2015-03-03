package Koha::SearchEngine::QueryBuilder;

# This file is part of Koha.
#
# Copyright 2014 Catalyst IT
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

# This is a shim that gives you the appropriate query builder for your
# system preference.

=head1 NAME

Koha::SearchEngine::QueryBuilder - instantiates the query builder that
corresponds to the C<SearchEngine> system preference

=head1 DESCRIPTION

This allows you to be agnostic about what the search engine configuration is
and just get whatever querybuilder you need.

=head1 SYNOPSIS

    use Koha::SearchEngine::QueryBuilder;
    my $qb = Koha::SearchEngine::QueryBuilder->new();

=head1 METHODS

=head2 new

Creates a new C<QueryBuilder> of whatever the relevant type is.

=cut

use C4::Context;
use Modern::Perl;
use Carp;

sub new {
    my $engine = C4::Context->preference("SearchEngine");
    my $file = "Koha/SearchEngine/${engine}/QueryBuilder.pm";
    my $class = "Koha::SearchEngine::${engine}::QueryBuilder";
    croak "SearchEngine system preference not set" unless $engine;
    require $file;
    shift @_;
    return $class->new(@_);
}

1;
