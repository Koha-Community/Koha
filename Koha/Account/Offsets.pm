package Koha::Account::Offsets;

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

use Koha::Account::Offset;

use base qw(Koha::Objects);

=head1 NAME

Koha::Account::Offsets - Koha Account Offset Object set class

Account offsets track the changes made to the balance of account lines

=head1 API

=head2 Class methods

=head3 total

    my $offsets = Koha::Account::Offsets->search({ ...  });
    my $total   = $offsets->total;

Returns the sum of the amounts of the account offsets resultset. If the resultset is
empty it returns 0.

=cut

sub total {
    my ($self) = @_;

    my $offsets = $self->search(
        {},
        {
            select => [ { sum => 'me.amount' } ],
            as     => ['total_amount'],
        }
    );

    return $offsets->count
        ? $offsets->next->get_column('total_amount') + 0
        : 0;
}

=head3 filter_by_non_reversible

    my $non_reversible_offsets = Koha::Account::Offsets->search(..)->filter_by_non_reversible;

Filter offsets so only non-reversible ones are left in the resultset.

=cut

sub filter_by_non_reversible {
    my ($self) = @_;

    my $me = $self->_resultset()->current_source_alias;

    my $where = {
        debit_id                  => { '!=' => undef },
        credit_id                 => { '!=' => undef },
        type                      => 'APPLY',
        'credit.credit_type_code' => [ 'WRITEOFF', 'DISCOUNT', 'CANCELLATION' ],
        'credit.status'           => [ { '!=' => 'VOID' }, undef ],
        $me . '.amount'           => { '<' => 0 }
    };
    my $attr = { join => 'credit' };

    return $self->search( $where, $attr );
}

=head3 filter_by_reversible

    my $reversible_offsets = Koha::Account::Offsets->search(..)->filter_by_reversible;

Filter offsets so only reversible ones are left in the resultset.

=cut

sub filter_by_reversible {
    my ($self) = @_;

    my $me = $self->_resultset()->current_source_alias;

    my $where = {
        debit_id                  => { '!=' => undef },
        credit_id                 => { '!=' => undef },
        type                      => 'APPLY',
        'credit.credit_type_code' => { -not_in => [ 'WRITEOFF', 'DISCOUNT', 'CANCELLATION' ] },
        'credit.status'           => [ { '!=' => 'VOID' }, undef ],
        $me . '.amount'           => { '<' => 0 }
    };
    my $attr = { join => 'credit' };

    return $self->search( $where, $attr );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'AccountOffset';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Account::Offset';
}

1;
