package Koha::Reports::BackgroundJobs;

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

use base 'Koha::BackgroundJobs';

=head1 NAME

Koha::Reports::BackgroundJobs - Koha::BackgroundJobs resultset that
opts out of per-user filtering.

=head1 DESCRIPTION

Koha::BackgroundJobs->search_limited hides jobs owned by other
librarians from anyone without the C<manage_background_jobs>
permission. The Report jobs dashboard deliberately shows every
run_report job to anyone who can run reports, so this subclass
overrides C<search_limited> to be a pass-through and is used in
place of Koha::BackgroundJobs by L<Koha::REST::V1::Reports::Jobs>.
Per-job ownership is still enforced on the cancel endpoint.

=head1 API

=head2 Class methods

=head3 search_limited

Pass-through wrapper that calls C<search>, ignoring the per-user filter
applied by L<Koha::BackgroundJobs/search_limited>.

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;
    return $self->search( $params, $attributes );
}

1;
