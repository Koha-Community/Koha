# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

package Koha::OAI::Server::Identify;

use Modern::Perl;

use HTTP::OAI;
use C4::Context;
use Koha::DateUtils qw(dt_from_string);

use base ("HTTP::OAI::Identify");

sub new {
    my ( $class, $repository ) = @_;

    my $baseURL = $repository->self_url();
    $baseURL = $+{base_url}
        if $baseURL =~ m/(?<base_url>.*)\?.*/;

    my $self = $class->SUPER::new(
        baseURL           => $baseURL,
        repositoryName    => C4::Context->preference("LibraryName"),
        adminEmail        => C4::Context->preference("KohaAdminEmailAddress"),
        MaxCount          => C4::Context->preference("OAI-PMH:MaxCount"),
        granularity       => 'YYYY-MM-DDThh:mm:ssZ',
        earliestDatestamp => _get_earliest_datestamp()                        || '0001-01-01T00:00:00Z',
        deletedRecord     => C4::Context->preference("OAI-PMH:DeletedRecord") || 'no',
    );

    # FIXME - alas, the description element is not so simple; to validate
    # against the OAI-PMH schema, it cannot contain just a string,
    # but one or more elements that validate against another XML schema.
    # For now, simply omitting it.
    # $self->description( "Koha OAI Repository" );

    $self->compression('gzip');

    return $self;
}

# Find the earliest timestamp in the biblio table. If this table is empty, undef
# will be returned and we will report the fallback 0001-01-01.
sub _get_earliest_datestamp {
    my $dbh = C4::Context->dbh;

    # We do not need to perform timezone conversion here, because the time zone
    # is set to UTC for the entire SQL session in Koha/OAI/Server/Repository.pm
    my ($earliest) = $dbh->selectrow_array(
        q{
        SELECT MIN(timestamp) AS earliest
        FROM biblio
    }
    );

    return dt_from_string( $earliest, 'sql' )->strftime('%FT%TZ');
}

1;
