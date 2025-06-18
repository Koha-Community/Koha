package Koha::Review;

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

use base qw(Koha::Object);

=head1 NAME

Koha::Review - Koha Review Object class

=head1 API

=head2 Class Methods

=cut

=head3 approve

    $review->approve

Approve a review

=cut

sub approve {
    my ($self) = @_;
    $self->approved(1)->store;
}

=head3 unapprove

    $review->unapprove

Unapprove a review

=cut

sub unapprove {
    my ($self) = @_;
    $self->approved(0)->store;
}

=head3 type

=cut

sub _type {
    return 'Review';
}

1;
