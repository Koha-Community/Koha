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
use C4::Biblio;
use C4::OAI::Sets;
use MARC::File::XML;

use base ("HTTP::OAI::GetRecord");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::GetRecord->new(%args);

    my $prefix = $repository->{koha_identifier} . ':';
    my ($biblionumber) = $args{identifier} =~ /^$prefix(.*)/;
    my $items_included = $repository->items_included( $args{metadataPrefix} );
    my $dbh = C4::Context->dbh;
    my $sql = "
        SELECT timestamp
        FROM   biblioitems
        WHERE  biblionumber=?
    ";
    my @bind_params = ($biblionumber);
    if ( $items_included ) {
        # Take latest timestamp of biblio and any items
        $sql .= "
            UNION
            SELECT timestamp from deleteditems
            WHERE biblionumber=?
            UNION
            SELECT timestamp from items
            WHERE biblionumber=?
        ";
        push @bind_params, $biblionumber;
        push @bind_params, $biblionumber;
        $sql = "
            SELECT max(timestamp)
            FROM ($sql) bib
        ";
    }

    my $sth = $dbh->prepare( $sql ) || die( 'Could not prepare statement: ' . $dbh->errstr );
    $sth->execute( @bind_params ) || die( 'Could not execute statement: ' . $sth->errstr );
    my ($timestamp, $deleted);
    unless ( ($timestamp = $sth->fetchrow) ) {
        $sql = "
            SELECT timestamp
            FROM deletedbiblio
            WHERE biblionumber=?
        ";
        @bind_params = ($biblionumber);

        if ( $items_included ) {
            # Take latest timestamp among biblio and items
            $sql .= "
                UNION
                SELECT timestamp from deleteditems
                WHERE biblionumber=?
            ";
            push @bind_params, $biblionumber;
            $sql = "
                SELECT max(timestamp)
                FROM ($sql) bib
            ";
        }

        $sth = $dbh->prepare($sql) || die('Could not prepare statement: ' . $dbh->errstr);
        $sth->execute( @bind_params ) || die('Could not execute statement: ' . $sth->errstr);
        unless ( ($timestamp = $sth->fetchrow) )
        {
            return HTTP::OAI::Response->new(
             requestURL  => $repository->self_url(),
             errors      => [ new HTTP::OAI::Error(
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
        my $marcxml;
        $marcxml = $repository->get_biblio_marcxml($biblionumber, $args{metadataPrefix})
            unless $deleted;

        $self->record(
            Koha::OAI::Server::Record->new($repository, $marcxml, $timestamp, \@setSpecs, %args)
        );
    }
    return $self;
}

1;
