package Koha::Old::Hold;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::Hold);

use C4::Context;
use Koha::Exceptions::SysPref;

=head1 NAME

Koha::Old::Hold - Koha Old Hold object class

This object represents a hold that has been filled or canceled

=head1 API

=head2 Class methods

=head3 biblio

Returns the related Koha::Biblio object for this old hold

=cut

sub biblio {
    my ($self) = @_;
    my $rs = $self->_result->biblionumber;
    return unless $rs;
    return Koha::Biblio->_new_from_dbic($rs);
}

=head3 anonymize

    $old_hold->anonymize();

Anonymize the given I<Koha::Old::Hold> object.

=cut

sub anonymize {
    my ($self) = @_;

    my $anonymous_id = C4::Context->preference('AnonymousPatron');

    Koha::Exceptions::SysPref::NotSet->throw( syspref => 'AnonymousPatron' )
        unless $anonymous_id;

    return $self->update( { borrowernumber => $anonymous_id } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'OldReserve';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
