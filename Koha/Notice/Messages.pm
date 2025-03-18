package Koha::Notice::Messages;

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

use Koha::Database;
use Koha::Notice::Message;

use base qw(Koha::Objects);

=head1 NAME

Koha::Notice::Message - Koha notice message Object class, related to the message_queue table

=head1 API

=head2 Class Methods

=cut

=head3 get_failed_notices

    my $failed_notices = Koha::Notice::Messages->get_failed_notices({ days => 7 });

Returns a hashref of all notices that have failed to send in the last X days, as specified in the 'days' parameter.
If not specified, will default to the last 7 days.

=cut

sub get_failed_notices {
    my ( $self, $params ) = @_;
    my $days = $params->{days} ? $params->{days} : 7;

    return $self->search(
        {
            time_queued => { -between => \"DATE_SUB(NOW(), INTERVAL $days DAY) AND NOW()" },
            status      => "failed",
        }
    );
}

=head3 type

=cut

sub _type {
    return 'MessageQueue';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Notice::Message';
}

1;
