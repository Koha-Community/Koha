package Koha::Item::Availability::Checkin::Result;

# Copyright 2026 Koha Development Team
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

use Modern::Perl;
use base 'Koha::Result::Availability';

=head1 NAME

Koha::Item::Availability::Checkin::Result - Typed availability result for checkin operations

=head1 DESCRIPTION

Subclass of L<Koha::Result::Availability> that defines the token contract
for checkin operations. The confirmation token is generated from the item
and user context objects.

=head1 API

=head2 Methods

=head3 token_params

    my $params = $result->token_params;

Returns C<[qw(item user)]>. These context keys must be set before
calling C<as_token> or C<check_token>.

=cut

sub token_params { [qw(item user)] }

1;
