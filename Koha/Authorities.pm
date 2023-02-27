package Koha::Authorities;

# Copyright 2015 Koha Development Team
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

use Koha::Authority;

use base qw(Koha::Objects Koha::Objects::Record::Collections);

=head1 NAME

Koha::Authorities - Koha Authority object set class

=head1 API

=head2 Class Methods

=head3 get_usage_count

    $count = Koha::Authorities->get_usage_count({ authid => $i });

    Returns the number of linked biblio records.

    Note: Code originates from C4::AuthoritiesMarc::CountUsage.

    This is a class method, since the authid may refer to a deleted record.

=cut

sub get_usage_count {
    my ( $class, $params ) = @_;
    my $authid = $params->{authid} || return;

    my $searcher = Koha::SearchEngine::Search->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    my ( $err, $result, $count ) = $searcher->simple_search_compat( 'an:' . $authid, 0, 0 );
    if( $err ) {
        warn "Error: $err from search for " . $authid;
        return;
    }
    return $count;
}

=head3 linked_biblionumbers

    my @biblios = Koha::Authorities->linked_biblionumbers({
        authid => $id, [ max_results => $max ], [ offset => $offset ],
    });

    Returns array of biblionumbers, as extracted from the result records of
    the search engine.

    This is a class method, since the authid may refer to a deleted record.

=cut

sub linked_biblionumbers {
    my ( $self, $params ) = @_;
    my $authid = $params->{authid} || return;

    my $searcher = Koha::SearchEngine::Search->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    # if max_results is undefined, we will get all results
    my ( $err, $result, $count ) = $searcher->simple_search_compat( 'an:' . $authid, $params->{offset} // 0, $params->{max_results} );

    if( $err ) {
        warn "Error: $err from search for " . $authid;
        return;
    }

    my @biblionumbers;
    foreach my $res ( @$result ) {
        my $bibno = $searcher->extract_biblionumber( $res );
        push @biblionumbers, $bibno if $bibno;
    }
    return @biblionumbers;
}

=head3 type

=cut

sub _type {
    return 'AuthHeader';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Authority';
}

1;
