package Koha::Exceptions::ArticleRequest;

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

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::ArticleRequest' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::ArticleRequest::LimitReached' => {
        isa         => 'Koha::Exceptions::ArticleRequest',
        description => 'Article request limit was reached'
    },
    'Koha::Exceptions::ArticleRequest::WrongFormat' => {
        isa         => 'Koha::Exceptions::ArticleRequest',
        description => 'Passed format is not locally supported',
        fields      => ['format'],
    },
);

=head1 NAME

Koha::Exceptions::ArticleRequest - Base class for ArticleRequest exceptions

=head1 Exceptions

=head2 Koha::Exceptions::ArticleRequest

Generic ArticleRequest exception

=head2 Koha::Exceptions::ArticleRequest::LimitReached

Exception to be used when the article request limit has been reached.

=cut

1;
