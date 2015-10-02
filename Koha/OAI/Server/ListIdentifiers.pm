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

package Koha::OAI::Server::ListIdentifiers;

use Modern::Perl;
use HTTP::OAI;
use C4::OAI::Sets;

use base ("HTTP::OAI::ListIdentifiers");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::ListIdentifiers->new(%args);

    my $token = new Koha::OAI::Server::ResumptionToken( %args );
    my $dbh = C4::Context->dbh;
    my $set;
    if(defined $token->{'set'}) {
        $set = GetOAISetBySpec($token->{'set'});
    }
    my $max = $repository->{koha_max_count};
    my $sql = "
        (SELECT biblioitems.biblionumber, biblioitems.timestamp
        FROM biblioitems
    ";
    $sql .= " JOIN oai_sets_biblios ON biblioitems.biblionumber = oai_sets_biblios.biblionumber " if defined $set;
    $sql .= " WHERE timestamp >= ? AND timestamp <= ? ";
    $sql .= " AND oai_sets_biblios.set_id = ? " if defined $set;
    $sql .= ") UNION
        (SELECT deletedbiblio.biblionumber, timestamp FROM deletedbiblio";
    $sql .= " JOIN oai_sets_biblios ON deletedbiblio.biblionumber = oai_sets_biblios.biblionumber " if defined $set;
    $sql .= " WHERE DATE(timestamp) >= ? AND DATE(timestamp) <= ? ";
    $sql .= " AND oai_sets_biblios.set_id = ? " if defined $set;

    $sql .= ") ORDER BY biblionumber
        LIMIT " . ($max+1) . "
        OFFSET $token->{offset}
    ";
    my $sth = $dbh->prepare( $sql );
    my @bind_params = ($token->{'from_arg'}, $token->{'until_arg'});
    push @bind_params, $set->{'id'} if defined $set;
    push @bind_params, ($token->{'from'}, $token->{'until'});
    push @bind_params, $set->{'id'} if defined $set;
    $sth->execute( @bind_params );

    my $count = 0;
    while ( my ($biblionumber, $timestamp) = $sth->fetchrow ) {
        $count++;
        if ( $count > $max ) {
            $self->resumptionToken(
                new Koha::OAI::Server::ResumptionToken(
                    metadataPrefix  => $token->{metadata_prefix},
                    from            => $token->{from},
                    until           => $token->{until},
                    offset          => $token->{offset} + $max,
                    set             => $token->{set}
                )
            );
            last;
        }
        $timestamp =~ s/ /T/, $timestamp .= 'Z';
        $self->identifier( new HTTP::OAI::Header(
            identifier => $repository->{ koha_identifier} . ':' . $biblionumber,
            datestamp  => $timestamp,
        ) );
    }

    # Return error if no results
    unless ($count) {
        return HTTP::OAI::Response->new(
            requestURL => $repository->self_url(),
            errors     => [ new HTTP::OAI::Error( code => 'noRecordsMatch' ) ],
        );
    }

    return $self;
}

1;
