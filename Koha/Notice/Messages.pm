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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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

=head3 search_limited

    my $messages = Koha::Notice::Messages->search_limited( $params, $attributes );

Search for generated and queued notices according to logged in patron restrictions

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $userenv = C4::Context->userenv;
    my @restricted_branchcodes;
    if ( $userenv and $userenv->{number} ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        @restricted_branchcodes = $logged_in_user->libraries_where_can_see_patrons;
    }

    # TODO This 'borrowernumber' relation name is confusing and needs to be renamed
    $params->{'borrowernumber.branchcode'} = { -in => \@restricted_branchcodes } if @restricted_branchcodes;
    $attributes->{join}                    = 'borrowernumber';
    return $self->search( $params, $attributes );
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
