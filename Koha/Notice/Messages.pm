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

use C4::Context;
use Koha::Database;
use Koha::Patrons;
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

Search for generated and queued notices according to the restrictions of the
logged in patron: where the patron can only see patrons from some libraries
(see L<Koha::Patron/libraries_where_can_see_patrons>), only the notices of
patrons from those libraries are returned.

The restriction is added to, not a replacement for, any condition on the patron's
library passed in C<$params>. Notices that are not linked to a patron are only
returned when there is no restriction. The passed C<$params> and C<$attributes>
are not modified. The names of the columns of the notices in C<$params> do not need
the name of their table, C<borrowernumber> is the same as C<me.borrowernumber>, as the table of
the patrons is joined and has columns with the same names.

When there is no logged in user (cronjobs, scripts) no restriction is applied, but when the
logged in patron cannot be found nothing is returned.

=cut

sub search_limited {
    my ( $self, $params, $attributes ) = @_;

    my $userenv = C4::Context->userenv;
    my $restriction;
    if ( $userenv and $userenv->{number} ) {
        my $logged_in_user = Koha::Patrons->find( $userenv->{number} );
        if ($logged_in_user) {
            my @restricted_branchcodes = $logged_in_user->libraries_where_can_see_patrons;

            # TODO This 'borrowernumber' relation name is confusing and needs to be renamed
            $restriction = { 'borrowernumber.branchcode' => { -in => \@restricted_branchcodes } }
                if @restricted_branchcodes;
        } else {

            # A logged in user we cannot find cannot be allowed to see anything
            $restriction = \['1 = 0'];
        }
    }

    # The patrons are joined, to restrict the notices to the libraries of the patrons: the columns
    # of the notices need the name of their table to not be ambiguous with those of the patrons
    $params = { map { ( /^-|\./ ? $_ : "me.$_" ) => $params->{$_} } keys %{$params} }
        if ref($params) eq 'HASH';

    my $where =
         !$restriction ? $params
        : $params      ? { -and => [ $params, $restriction ] }
        :                $restriction;

    my %attrs = %{ $attributes // {} };
    my @joins = ref( $attrs{join} ) eq 'ARRAY' ? @{ $attrs{join} } : defined $attrs{join} ? ( $attrs{join} ) : ();
    push @joins, 'borrowernumber' unless grep { defined && !ref && $_ eq 'borrowernumber' } @joins;
    $attrs{join} = \@joins;

    return $self->search( $where, \%attrs );
}

=head3 _type

Return the name of the DBIC result class this class wraps

=cut

sub _type {
    return 'MessageQueue';
}

=head3 object_class

Return the name of the class of the objects this class manages

=cut

sub object_class {
    return 'Koha::Notice::Message';
}

1;
