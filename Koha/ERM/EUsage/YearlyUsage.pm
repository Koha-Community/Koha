package Koha::ERM::EUsage::YearlyUsage;

# Copyright 2023 PTFS Europe

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

use base qw(Koha::Object);

use Koha::Exception;

=head1 NAME

Koha::ERM::EUsage::YearlyUsage - Koha ErmYearlyUsage Object class

=head1 SYNOPSIS

This object is backed by the erm_usage_yus table, which holds the sum of the
monthly usage in erm_usage_mus per year. Koha::ERM::EUsage::YearlyUsages->rebuild
writes the rows, so the object is read-only.

=head1 API

=head2 Class Methods

=head3 store

Yearly usage cannot be stored. Add monthly usage, then call Koha::ERM::EUsage::YearlyUsages->rebuild.

=cut

sub store {
    Koha::Exception->throw('Koha::ERM::EUsage::YearlyUsage is read-only: erm_usage_yus is rebuilt from erm_usage_mus');
}

=head3 delete

Yearly usage cannot be deleted. Delete the monthly usage, then call Koha::ERM::EUsage::YearlyUsages->rebuild.

=cut

sub delete {
    Koha::Exception->throw('Koha::ERM::EUsage::YearlyUsage is read-only: erm_usage_yus is rebuilt from erm_usage_mus');
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmUsageYus';
}

1;
