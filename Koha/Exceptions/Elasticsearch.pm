package Koha::Exceptions::Elasticsearch;

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

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Elasticsearch' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Elasticsearch::BadResponse' => {
        isa         => 'Koha::Exceptions::Elasticsearch',
        description => 'Bad response received when submitting request to Elasticsearch',
        fields      => [ 'type', 'details' ]
    },
    'Koha::Exceptions::Elasticsearch::MARCFieldExprParseError' => {
        isa         => 'Koha::Exceptions::Elasticsearch',
        description => 'Error parsing MARC Field Expression'
    }
);

=head1 NAME

Koha::Exceptions::Elasticsearch - Base class for elasticsearch exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Elasticsearch

Generic Elasticsearch exception

=head2 Koha::Exceptions::Elasticsearch::BadResponse

Exception to be used when more a request to ES fails

=head2 Koha::Exceptions::Elasticsearch::MARCFieldExprParseError

Exception to be used when encountering an error parsing MARC Field Expression

=head1 Class methods

=cut

1;
