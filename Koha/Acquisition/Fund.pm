package Koha::Acquisition::Fund;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Acquisition::Fund object class

=head1 API

=head2 Class methods

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Acquisition::Fund object
on the API.

=cut

sub to_api_mapping {
    return {
        budget_id         => 'fund_id',
        budget_code       => 'code',
        budget_name       => 'name',
        budget_branchcode => 'library_id',
        budget_amount     => 'total_amount',
        budget_encumb     => 'warn_at_percentage',
        budget_expend     => 'warn_at_amount',
        budget_notes      => 'notes',
        budget_period_id  => 'budget_id',
        timestamp         => 'timestamp',
        budget_owner_id   => 'fund_owner_id',
        budget_permission => 'fund_access',
        sort1_authcat     => 'statistic1_auth_value_category',
        sort2_authcat     => 'statistic2_auth_value_category',
        budget_parent_id  => 'parent_fund_id',
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqbudget';
}

1;
