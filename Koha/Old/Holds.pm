package Koha::Old::Holds;

# Copyright ByWater Solutions 2014
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

use Koha::Database;

use Koha::Old::Hold;

use base qw(Koha::Holds);

=head1 NAME

Koha::Old::Holds - Koha Old Hold object set class

This object represents a set of holds that have been filled or canceled

=head1 API

=head2 Class methods

=head3 filter_by_anonymizable

    my $holds = $patron->old_holds;
    my $anonymizable_holds = $holds->filter_by_anonymizable;

This method filters a I<Koha::Old::Holds> resultset, so it only contains holds that can be
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
            join     => ['patron'],
            order_by => ['me.reserve_id'],
        }
    );
}

=head3 anonymize

    $patron->old_holds->anonymize();

Anonymize the given I<Koha::Old::Holds> resultset.

=cut

sub anonymize {
    my ( $self, $params ) = @_;

    my $anonymous_id = C4::Context->preference('AnonymousPatron');

    Koha::Exceptions::SysPref::NotSet->throw( syspref => 'AnonymousPatron' )
        unless $anonymous_id;

    return $self->update( { borrowernumber => $anonymous_id }, { no_triggers => 1 } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'OldReserve';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Old::Hold';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
