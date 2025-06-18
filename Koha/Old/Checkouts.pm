package Koha::Old::Checkouts;

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
use Koha::DateUtils qw( dt_from_string );
use Koha::Old::Checkout;

use base qw(Koha::Objects);

=head1 NAME

Koha::Old::Checkouts - Koha Old Checkouts object set class

This object represents a set of completed checkouts

=head1 API

=head2 Class methods

=head3 filter_by_anonymizable

    my $checkouts = $patron->old_checkouts;
    my $anonymizable_checkouts = $checkouts->filter_by_anonymizable;

This method filters the resultset, so it only contains checkouts that can be
anonymized given the patron privacy settings.

=cut

sub filter_by_anonymizable {
    my ( $self, $params ) = @_;

    my $anonymous_patron = C4::Context->preference('AnonymousPatron') || undef;

    return $self->search(
        {
            'me.borrowernumber' => { 'not' => undef },
            'patron.privacy'    => { '<>'  => 0 },
            (
                $anonymous_patron
                ? ( 'me.borrowernumber' => { '!=' => $anonymous_patron } )
                : ()
            ),
        },
        {
            join => ['patron'],
        }
    );
}

=head3 filter_by_todays_checkins

=cut

sub filter_by_todays_checkins {
    my ($self) = @_;

    my $dtf         = Koha::Database->new->schema->storage->datetime_parser;
    my $today       = dt_from_string;
    my $today_start = $today->clone->set( hour => 0,  minute => 0,  second => 0 );
    my $today_end   = $today->clone->set( hour => 23, minute => 59, second => 59 );
    $today_start = $dtf->format_datetime($today_start);
    $today_end   = $dtf->format_datetime($today_end);
    return $self->search(
        {
            returndate => {
                '>=' => $today_start,
                '<=' => $today_end,
            },
        }
    );
}

=head3 anonymize

    $patron->old_checkouts->anonymize();

Anonymize the given I<Koha::Old::Checkouts> resultset.

=cut

sub anonymize {
    my ( $self, $params ) = @_;

    my $anonymous_id = C4::Context->preference('AnonymousPatron');

    Koha::Exceptions::SysPref::NotSet->throw( syspref => 'AnonymousPatron' )
        unless $anonymous_id;

    while ( my $checkout = $self->next ) {
        my $self_renewals = $checkout->renewals->search( { renewer_id => $checkout->borrowernumber } );
        $self_renewals->update( { renewer_id => $anonymous_id } );
    }

    return $self->update( { borrowernumber => $anonymous_id }, { no_triggers => 1 } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'OldIssue';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Old::Checkout';
}

1;
