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

package Koha::OAI::Server::Identify;

use Modern::Perl;
use HTTP::OAI;
use C4::Context;

use base ("HTTP::OAI::Identify");

sub new {
    my ($class, $repository) = @_;

    my ($baseURL) = $repository->self_url() =~ /(.*)\?.*/;
    my $self = $class->SUPER::new(
        baseURL             => $baseURL,
        repositoryName      => C4::Context->preference("LibraryName"),
        adminEmail          => C4::Context->preference("KohaAdminEmailAddress"),
        MaxCount            => C4::Context->preference("OAI-PMH:MaxCount"),
        granularity         => 'YYYY-MM-DD',
        earliestDatestamp   => '0001-01-01',
        deletedRecord       => C4::Context->preference("OAI-PMH:DeletedRecord") || 'no',
    );

    # FIXME - alas, the description element is not so simple; to validate
    # against the OAI-PMH schema, it cannot contain just a string,
    # but one or more elements that validate against another XML schema.
    # For now, simply omitting it.
    # $self->description( "Koha OAI Repository" );

    $self->compression( 'gzip' );

    return $self;
}

1;
