package Koha::OAI::Server::ListBase;

# Copyright The National Library of Finland, University of Helsinki 2016-2017
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

=head1 NAME

Koha::OAI::Server::ListBase - OAI ListIdentifiers/ListRecords shared functionality

=head1 DESCRIPTION

Koha::OAI::Server::ListBase contains OAI-PMH functions shared by ListIdentifiers and ListRecords.

=cut

use Modern::Perl;
use HTTP::OAI;
use Koha::OAI::Server::ResumptionToken;
use Koha::OAI::Server::Record;
use Koha::OAI::Server::DeletedRecord;
use C4::OAI::Sets qw( GetOAISetBySpec GetOAISetsBiblio );
use MARC::File::XML;

sub GetRecords {
    my ($class, $self, $repository, $metadata, %args) = @_;

    my $token = Koha::OAI::Server::ResumptionToken->new( %args );
    my $dbh = C4::Context->dbh;
    my $set;
    if ( defined $token->{'set'} ) {
        $set = GetOAISetBySpec($token->{'set'});
    }
    my $deleted = defined $token->{deleted} ? $token->{deleted} : 0;
    my $max = $repository->{koha_max_count};
    my $count = 0;
    my $format = $args{metadataPrefix} || $token->{metadata_prefix};
    my $include_items = $repository->items_included( $format );
    my $from = $token->{from_arg};
    my $until = $token->{until_arg};
    my $next_id = $token->{next_id};

    # Since creating a union of normal and deleted record tables would be a heavy
    # operation in a large database, build results in two stages:
    # first deleted records ($deleted == 1), then normal records ($deleted == 0)
    STAGELOOP:
    for ( ; $deleted >= 0; $deleted-- ) {
        my $table = $deleted ? 'deletedbiblio_metadata' : 'biblio_metadata';

        my @part_bind_params = ($next_id);

        # Note: "main" is alias of the main table in the SELECT statement to avoid ambiquity with joined tables
        my $where = "main.biblionumber >= ?";
        if ( $from ) {
            $where .= " AND main.timestamp >= ?";
            push @part_bind_params, $from;
        }
        if ( $until ) {
            $where .= " AND main.timestamp <= ?";
            push @part_bind_params, $until;
        }
        if ( defined $set ) {
            $where .= " AND main.biblionumber in (SELECT osb.biblionumber FROM oai_sets_biblios osb WHERE osb.set_id = ?)";
            push @part_bind_params, $set->{'id'};
        }

        my @bind_params = @part_bind_params;

        my $order_limit = 'ORDER BY main.biblionumber LIMIT ' . ($max + 1);

        my $sql;
        my $ts_sql;

        # If items are included, fetch a set of potential biblionumbers from items tables as well.
        # Then merge them, sort them and take the required number of them from the resulting list.
        # This may seem counter-intuitive as in worst case we fetch 3 times the biblionumbers needed,
        # but avoiding joins or subqueries makes this so much faster that it does not matter.
        if ( $include_items && !$deleted )  {
            $sql = "
                (SELECT biblionumber
                FROM $table main
                WHERE $where $order_limit)
                  UNION
                (SELECT DISTINCT(biblionumber) FROM deleteditems main JOIN biblio USING (biblionumber) WHERE $where
                $order_limit)
                  UNION
                (SELECT DISTINCT(biblionumber) FROM items main WHERE $where $order_limit)";
            push @bind_params, @part_bind_params;
            push @bind_params, @part_bind_params;
            $sql = "SELECT biblionumber FROM ($sql) main $order_limit";

            $ts_sql = "
                SELECT MAX(timestamp)
                FROM (
                    SELECT timestamp FROM biblio_metadata WHERE biblionumber = ?
                    UNION
                    SELECT timestamp FROM deleteditems WHERE biblionumber = ?
                    UNION
                    SELECT timestamp FROM items WHERE biblionumber = ?
                ) bi
            ";
        } else {
            $sql = "
                SELECT biblionumber
                FROM $table main
                WHERE $where $order_limit
            ";

            $ts_sql = "SELECT max(timestamp) FROM $table WHERE biblionumber = ?";
        }

        my $sth = $dbh->prepare( $sql ) || die( 'Could not prepare statement: ' . $dbh->errstr );
        my $ts_sth = $dbh->prepare( $ts_sql ) || die( 'Could not prepare statement: ' . $dbh->errstr );

        $sth->execute( @bind_params ) || die( 'Could not execute statement: ' . $sth->errstr );
        foreach my $row (@{ $sth->fetchall_arrayref() }) {
            my $biblionumber = $row->[0];
            $count++;
            if ( $count > $max ) {
                $self->resumptionToken(
                    Koha::OAI::Server::ResumptionToken->new(
                        metadataPrefix  => $token->{metadata_prefix},
                        from            => $token->{from},
                        until           => $token->{until},
                        cursor          => $token->{cursor} + $max,
                        set             => $token->{set},
                        deleted         => $deleted,
                        next_id         => $biblionumber
                    )
                );
                last STAGELOOP;
            }
            my @params = ($biblionumber);
            if ( $include_items && !$deleted ) {
                push @params, $deleted ? ( $biblionumber ) : ( $biblionumber, $biblionumber );
            }
            $ts_sth->execute( @params ) || die( 'Could not execute statement: ' . $ts_sth->errstr );

            my ($timestamp) = $ts_sth->fetchrow;

            my $oai_sets = GetOAISetsBiblio($biblionumber);
            my @setSpecs;
            foreach ( @$oai_sets ) {
                push @setSpecs, $_->{spec};
            }
            if ( $metadata ) {
                my ( $marcxml, $marcxml_error );
                ( $marcxml, $marcxml_error ) = $repository->get_biblio_marcxml( $biblionumber, $format ) if !$deleted;
                my %params;
                $params{identifier}     = $repository->{koha_identifier} . ':' . $biblionumber;
                $params{metadataPrefix} = $token->{metadata_prefix};
                $params{about}          = [$marcxml_error] if $marcxml_error;
                if ($marcxml) {
                    $self->record(
                        Koha::OAI::Server::Record->new(
                            $repository, $marcxml, $timestamp, \@setSpecs,
                            %params
                        )
                    );
                } else {
                    $self->record(
                        Koha::OAI::Server::DeletedRecord->new(
                            $timestamp, \@setSpecs, identifier => $repository->{koha_identifier} . ':' . $biblionumber
                        )
                    );
                }
            } else {
                $timestamp =~ s/ /T/;
                $timestamp .= 'Z';
                $self->identifier( HTTP::OAI::Header->new(
                    identifier => $repository->{ koha_identifier} . ':' . $biblionumber,
                    datestamp  => $timestamp,
                    status     => $deleted ? 'deleted' : undef,
                ) );
            }
        }
        # Reset $next_id for the next stage
        $next_id = 0;
    }
    return $count;
}

1;
