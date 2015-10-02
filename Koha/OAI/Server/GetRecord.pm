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

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
        SELECT timestamp
        FROM   biblioitems
        WHERE  biblionumber=? " );
    my $prefix = $repository->{koha_identifier} . ':';
    my ($biblionumber) = $args{identifier} =~ /^$prefix(.*)/;
    $sth->execute( $biblionumber );
    my ($timestamp, $deleted);
    unless ( ($timestamp) = $sth->fetchrow ) {
        unless ( ($timestamp) = $dbh->selectrow_array(q/
            SELECT timestamp
            FROM deletedbiblio
            WHERE biblionumber=? /, undef, $biblionumber ))
        {
            return HTTP::OAI::Response->new(
             requestURL  => $repository->self_url(),
             errors      => [ new HTTP::OAI::Error(
                code    => 'idDoesNotExist',
                message => "There is no biblio record with this identifier",
                ) ],
            );
        }
        else {
            $deleted = 1;
        }
    }

    # We fetch it using this method, rather than the database directly,
    # so it'll include the item data
    my $marcxml;
    $marcxml = $repository->get_biblio_marcxml($biblionumber, $args{metadataPrefix})
        unless $deleted;
    my $oai_sets = GetOAISetsBiblio($biblionumber);
    my @setSpecs;
    foreach (@$oai_sets) {
        push @setSpecs, $_->{spec};
    }

    #$self->header( HTTP::OAI::Header->new( identifier  => $args{identifier} ) );
    $self->record(
        $deleted
        ? Koha::OAI::Server::DeletedRecord->new($timestamp, \@setSpecs, %args)
        : Koha::OAI::Server::Record->new($repository, $marcxml, $timestamp, \@setSpecs, %args)
    );
    return $self;
}

1;
