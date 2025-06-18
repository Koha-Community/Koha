package Koha::Account::Lines;

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
use Koha::Account::Line;

use base qw(Koha::Objects);

=head1 NAME

Koha::Account::Lines - Koha Account Line Object set class

=head1 API

=head2 Class Methods

=head3 total_outstanding

    my $lines = Koha::Account::Lines->search({ ...  });
    my $total = $lines->total_outstanding;

Returns the sum of the outstanding amounts of the resultset. If the resultset is
empty it returns 0.

=cut

sub total_outstanding {
    my ($self) = @_;

    my $me    = $self->_resultset()->current_source_alias . ".";
    my $lines = $self->search(
        {},
        {
            select => [ { sum => $me . 'amountoutstanding' } ],
            as     => ['total_amountoutstanding'],
        }
    );

    return $lines->count
        ? $lines->next->get_column('total_amountoutstanding') + 0
        : 0;
}

=head3 total

    my $lines = Koha::Account::Lines->search({ ...  });
    my $total = $lines->total;

Returns the sum of the amounts of the resultset. If the resultset is
empty it returns 0.

=cut

sub total {
    my ( $self, $conditions ) = @_;

    $conditions //= {};
    my $me    = $self->_resultset()->current_source_alias . ".";
    my $lines = $self->search(
        $conditions,
        {
            select => [ { sum => $me . 'amount' } ],
            as     => ['total']
        }
    );
    return $lines->count ? $lines->next->get_column('total') + 0 : 0;
}

=head3 credits_total

    my $lines = Koha::Account::Lines->search({ ...  });
    my $credits_total = $lines->credits_total;

Returns the sum of the amounts of the resultset. If the resultset is
empty it returns 0.

=cut

sub credits_total {
    my ( $self, $conditions ) = @_;

    my $me               = $self->_resultset()->current_source_alias . ".";
    my $local_conditions = { $me . 'amount' => { '<' => 0 } };
    $conditions //= {};
    my $merged_conditions = { %{$conditions}, %{$local_conditions} };

    my $lines = $self->search(
        $merged_conditions,
        {
            select => [ { sum => $me . 'amount' } ],
            as     => ['total']
        }
    );
    return $lines->count ? $lines->next->get_column('total') + 0 : 0;
}

=head3 debits_total

    my $lines = Koha::Account::Lines->search({ ...  });
    my $debits_total = $lines->debits_total;

Returns the sum of the amounts of the resultset. If the resultset is
empty it returns 0.

=cut

sub debits_total {
    my ( $self, $conditions ) = @_;

    my $me               = $self->_resultset()->current_source_alias . ".";
    my $local_conditions = { $me . 'amount' => { '>' => 0 } };
    $conditions //= {};
    my $merged_conditions = { %{$conditions}, %{$local_conditions} };

    my $lines = $self->search(
        $merged_conditions,
        {
            select => [ { sum => $me . 'amount' } ],
            as     => ['total']
        }
    );
    return $lines->count ? $lines->next->get_column('total') + 0 : 0;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Accountline';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Account::Line';
}

1;
