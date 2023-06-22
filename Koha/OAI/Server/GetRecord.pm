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

package Koha::OAI::Server::GetRecord;

use Modern::Perl;
use HTTP::OAI;
use C4::OAI::Sets qw( GetOAISetsBiblio );
use MARC::File::XML;

use base ("HTTP::OAI::GetRecord");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::GetRecord->new(%args);

    my $prefix = $repository->{koha_identifier} . ':';
    my ($biblionumber) = $args{identifier} =~ /^$prefix(.*)/;
    my $items_included = $repository->items_included( $args{metadataPrefix} );
    my $dbh = C4::Context->dbh;
    my $sql;
    my @bind_params = ($biblionumber);
    if ( $items_included ) {
        # Take latest timestamp of biblio and any items
        # Or timestamp of deleted items where bib not deleted
        $sql .= "
            SELECT timestamp
            FROM   biblio_metadata
            WHERE  biblionumber=?
              UNION
            SELECT deleteditems.timestamp FROM deleteditems JOIN biblio USING (biblionumber)
            WHERE  deleteditems.biblionumber=?
              UNION
            SELECT timestamp from items
            WHERE  biblionumber=?
        ";
        push @bind_params, $biblionumber;
        push @bind_params, $biblionumber;
        $sql = "
            SELECT max(timestamp) as timestamp
            FROM ($sql) bib
        ";
    } else {
        $sql = "
            SELECT max(timestamp) as timestamp
            FROM   biblio_metadata
            WHERE  biblionumber=?
        ";
    }

    my $sth = $dbh->prepare( $sql ) || die( 'Could not prepare statement: ' . $dbh->errstr );
    $sth->execute( @bind_params ) || die( 'Could not execute statement: ' . $sth->errstr );
    my ($timestamp, $deleted);
    # If there are no rows in biblio_metadata, try deletedbiblio_metadata
    unless ( ($timestamp = $sth->fetchrow) ) {
        $sql = "
            SELECT max(timestamp)
            FROM   deletedbiblio_metadata
            WHERE  biblionumber=?
        ";
        @bind_params = ($biblionumber);

        $sth = $dbh->prepare($sql) || die('Could not prepare statement: ' . $dbh->errstr);
        $sth->execute( @bind_params ) || die('Could not execute statement: ' . $sth->errstr);
        unless ( ($timestamp = $sth->fetchrow) )
        {
            return HTTP::OAI::Response->new(
             requestURL  => $repository->self_url(),
             errors      => [ HTTP::OAI::Error->new(
                code    => 'idDoesNotExist',
                message => "There is no biblio record with this identifier",
                ) ],
            );
        }
        $deleted = 1;
    }

    my $oai_sets = GetOAISetsBiblio($biblionumber);
    my @setSpecs;
    foreach (@$oai_sets) {
        push @setSpecs, $_->{spec};
    }

    if ($deleted) {
        $self->record(
            Koha::OAI::Server::DeletedRecord->new($timestamp, \@setSpecs, %args)
        );
    } else {
        # We fetch it using this method, rather than the database directly,
        # so it'll include the item data
        my ( $marcxml, $marcxml_error ) = $repository->get_biblio_marcxml( $biblionumber, $args{metadataPrefix} );
        $args{about} = [$marcxml_error] if $marcxml_error;
        $self->record(
            Koha::OAI::Server::Record->new($repository, $marcxml, $timestamp, \@setSpecs, %args)
        );
    }
    return $self;
}

1;
