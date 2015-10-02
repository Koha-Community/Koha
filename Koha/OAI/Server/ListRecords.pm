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

package Koha::OAI::Server::ListRecords;

use Modern::Perl;
use C4::Biblio;
use HTTP::OAI;
use Koha::OAI::Server::ResumptionToken;
use Koha::OAI::Server::Record;
use Koha::OAI::Server::DeletedRecord;
use C4::OAI::Sets;
use MARC::File::XML;

use base ("HTTP::OAI::ListRecords");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::ListRecords->new(%args);

    my $token = new Koha::OAI::Server::ResumptionToken( %args );
    my $dbh = C4::Context->dbh;
    my $set;
    if(defined $token->{'set'}) {
        $set = GetOAISetBySpec($token->{'set'});
    }
    my $max = $repository->{koha_max_count};
    my $sql = "
        (SELECT biblioitems.biblionumber, biblioitems.timestamp, marcxml
        FROM biblioitems
    ";
    $sql .= " JOIN oai_sets_biblios ON biblioitems.biblionumber = oai_sets_biblios.biblionumber " if defined $set;
    $sql .= " WHERE timestamp >= ? AND timestamp <= ? ";
    $sql .= " AND oai_sets_biblios.set_id = ? " if defined $set;
    $sql .= ") UNION
        (SELECT deletedbiblio.biblionumber, null as marcxml, timestamp FROM deletedbiblio";
    $sql .= " JOIN oai_sets_biblios ON deletedbiblio.biblionumber = oai_sets_biblios.biblionumber " if defined $set;
    $sql .= " WHERE DATE(timestamp) >= ? AND DATE(timestamp) <= ? ";
    $sql .= " AND oai_sets_biblios.set_id = ? " if defined $set;

    $sql .= ") ORDER BY biblionumber
        LIMIT " . ($max + 1) . "
        OFFSET $token->{offset}
    ";
    my $sth = $dbh->prepare( $sql );
    my @bind_params = ($token->{'from_arg'}, $token->{'until_arg'});
    push @bind_params, $set->{'id'} if defined $set;
    push @bind_params, ($token->{'from'}, $token->{'until'});
    push @bind_params, $set->{'id'} if defined $set;
    $sth->execute( @bind_params );

    my $count = 0;
    my $format = $args{metadataPrefix} || $token->{metadata_prefix};
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
        my $marcxml = $repository->get_biblio_marcxml($biblionumber, $format);
        my $oai_sets = GetOAISetsBiblio($biblionumber);
        my @setSpecs;
        foreach (@$oai_sets) {
            push @setSpecs, $_->{spec};
        }
        if ($marcxml) {
          $self->record( Koha::OAI::Server::Record->new(
              $repository, $marcxml, $timestamp, \@setSpecs,
              identifier      => $repository->{ koha_identifier } . ':' . $biblionumber,
              metadataPrefix  => $token->{metadata_prefix}
          ) );
        } else {
          $self->record( Koha::OAI::Server::DeletedRecord->new(
          $timestamp, \@setSpecs, identifier => $repository->{ koha_identifier } . ':' . $biblionumber ) );
        }
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
