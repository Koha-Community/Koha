package Koha::SearchEngine::Zebra::Search;

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

use Moose::Role;
with 'Koha::SearchEngine::SearchRole';

use Data::SearchEngine::Zebra;
use Data::SearchEngine::Query;
use Koha::SearchEngine::Zebra;
use Data::Dump qw(dump);

has searchengine => (
    is => 'rw',
    isa => 'Koha::SearchEngine::Zebra',
    default => sub { Koha::SearchEngine::Zebra->new },
    lazy => 1
);

sub search {
    my ($self,$query_string) = @_;

     my $query = Data::SearchEngine::Query->new(
       count => 10,
       page => 1,
       query => $query_string,
     );

    warn "search for $query_string";

    my $results = $self->searchengine->search($query);

    foreach my $item (@{ $results->items }) {
        my $title = $item->get_value('ste_title');
        #utf8::encode($title);
        print "$title\n";
                warn dump $title;
    }
}

sub dosmth {'bou' }

1;
