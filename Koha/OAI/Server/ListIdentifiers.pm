# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
# Copyright The National Library of Finland, University of Helsinki 2016
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

package Koha::OAI::Server::ListIdentifiers;

use Modern::Perl;
use HTTP::OAI;

use base qw(HTTP::OAI::ListIdentifiers Koha::OAI::Server::ListBase);

sub new {
    my ( $class, $repository, %args ) = @_;

    my $self = HTTP::OAI::ListIdentifiers->new(%args);

    my $count = $class->GetRecords( $self, $repository, 0, %args );

    # Return error if no results
    unless ($count) {
        return HTTP::OAI::Response->new(
            requestURL => $repository->self_url(),
            errors     => [ HTTP::OAI::Error->new( code => 'noRecordsMatch' ) ],
        );
    }

    return $self;
}

1;
