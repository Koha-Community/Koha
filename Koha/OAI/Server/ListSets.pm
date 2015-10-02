# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
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

package Koha::OAI::Server::ListSets;

use Modern::Perl;
use HTTP::OAI;
use Koha::OAI::Server::ResumptionToken;
use Koha::OAI::Server::Description;
use C4::OAI::Sets;

use base ("HTTP::OAI::ListSets");


sub new {
    my ( $class, $repository, %args ) = @_;

    my $self = HTTP::OAI::ListSets->new(%args);
    my $token = Koha::OAI::Server::ResumptionToken->new(%args);
    my $sets = GetOAISets;
    my $pos = 0;
    foreach my $set (@$sets) {
        if ($pos < $token->{offset}) {
            $pos++;
            next;
        }
        my @descriptions = map {
            Koha::OAI::Server::Description->new( setDescription => $_ );
        } @{$set->{'descriptions'}};
        $self->set(
            HTTP::OAI::Set->new(
                setSpec => $set->{'spec'},
                setName => $set->{'name'},
                setDescription => \@descriptions,
            )
        );
        $pos++;
        last if ($pos + 1 - $token->{offset}) > $repository->{koha_max_count};
    }

    $self->resumptionToken(
        new Koha::OAI::Server::ResumptionToken(
            metadataPrefix => $token->{metadata_prefix},
            offset         => $pos
        )
    ) if ( $pos > $token->{offset} );

    return $self;
}

1;
