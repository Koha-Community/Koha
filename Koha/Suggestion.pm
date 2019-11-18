package Koha::Suggestion;

# Copyright ByWater Solutions 2015
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

use Carp;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::Suggestion - Koha Suggestion object class

=head1 API

=head2 Class methods

=cut

=head3 store

Override the default store behavior so that new suggestions have
a suggesteddate of today

=cut

sub store {
    my ($self) = @_;

    unless ( $self->suggesteddate() ) {
        $self->suggesteddate( dt_from_string()->ymd );
    }

    return $self->SUPER::store();
}

=head3 suggester

    my $patron = $suggestion->suggester

Returns the I<Koha::Patron> for the suggestion generator. I<undef> is
returned if no suggester is linked.

=cut

sub suggester {
    my ($self) = @_;

    my $suggester_rs = $self->_result->suggester;
    return unless $suggester_rs;
    return Koha::Patron->_new_from_dbic($suggester_rs);
}

=head3 manager

my $manager = $suggestion->manager;

Returns the manager of the suggestion (Koha::Patron for managedby field)

=cut

sub manager {
    my ($self) = @_;
    my $manager_rs = $self->_result->managedby;
    return unless $manager_rs;
    return Koha::Patron->_new_from_dbic($manager_rs);
}

=head3 rejecter

my $rejecter = $suggestion->rejecter;

Returns the rejecter of the suggestion (Koha::Patron for rejectebby field)

=cut

sub rejecter {
    my ($self) = @_;
    my $rejecter_rs = $self->_result->managedby;
    return unless $rejecter_rs;
    return Koha::Patron->_new_from_dbic($rejecter_rs);
}

=head3 last_modifier

my $last_modifier = $suggestion->last_modifier;

Returns the librarian who last modified the suggestion (Koha::Patron for lastmodificationby field)

=cut

sub last_modifier {
    my ($self) = @_;
    my $last_modifier_rs = $self->_result->managedby;
    return unless $last_modifier_rs;
    return Koha::Patron->_new_from_dbic($last_modifier_rs);
}

=head3 fund

my $fund = $suggestion->fund;

Return the fund associated to the suggestion

=cut

sub fund {
    my ($self) = @_;
    my $fund_rs = $self->_result->budgetid;
    return unless $fund_rs;
    return Koha::Acquisition::Fund->_new_from_dbic($fund_rs);
}

=head3 type

=cut

sub _type {
    return 'Suggestion';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
