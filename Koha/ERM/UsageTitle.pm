package Koha::ERM::UsageTitle;

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

use base qw(Koha::Object);

use Koha::ERM::YearlyUsage;
use Koha::ERM::YearlyUsages;
use Koha::ERM::MonthlyUsage;
use Koha::ERM::MonthlyUsages;

=head1 NAME

Koha::ERM::UsageTitle - Koha ErmUsageTitle Object class

=head1 API

=head2 Class Methods
=head3 erm_usage_muses

Method to embed erm_usage_muses to titles for report formatting

=cut

sub erm_usage_muses {
    my ( $self ) = @_;
    my $usage_mus_rs = $self->_result->erm_usage_muses;
    return Koha::ERM::MonthlyUsages->_new_from_dbic($usage_mus_rs);
}

=head3 erm_usage_yuses

Method to embed erm_usage_yuses to titles for report formatting

=cut

sub erm_usage_yuses {
    my ( $self ) = @_;
    my $usage_yus_rs = $self->_result->erm_usage_yuses;
    return Koha::ERM::YearlyUsages->_new_from_dbic($usage_yus_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmUsageTitle';
}

1;
