package Koha::Account::CreditType;

# Copyright PTFS Europe 2019
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

use Koha::Database;
use Koha::Exceptions;

use base qw(Koha::Object::Mixin::AdditionalFields Koha::Object Koha::Object::Limit::Library);

=head1 NAME

Koha::Account::CreditType - Koha Account credit type Object class

=head1 API

=head2 Class Methods

=cut

=head3 delete

Overridden delete method to prevent system default deletions

=cut

sub delete {
    my ($self) = @_;

    Koha::Exceptions::CannotDeleteDefault->throw if $self->is_system;

    return $self->SUPER::delete;
}

=head3 _library_limits

Configurable library limits

=cut

sub _library_limits {
    return {
        class   => "AccountCreditTypesBranch",
        id      => "credit_type_code",
        library => "branchcode",
    };
}

=head3 type

=cut

sub _type {
    return 'AccountCreditType';
}

1;
