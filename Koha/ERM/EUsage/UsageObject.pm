package Koha::ERM::EUsage::UsageObject;

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

use Koha::ERM::EUsage::YearlyUsages;
use Koha::ERM::EUsage::MonthlyUsage;
use Koha::ERM::EUsage::MonthlyUsages;

=head1 NAME

Koha::ERM::EUsage::UsageObject - Base class for ERM usage report entities

=head1 SYNOPSIS

This is the base class for the usage report entities (titles, platforms,
items and databases). Each entity has monthly usage records stored in the
erm_usage_mus table. Yearly usage is read from the erm_usage_yus table, which
holds the monthly usage summed per year.

Subclasses must implement C<_type>.

=head1 API

=head2 Class Methods

=head3 erm_usage_muses

Method to embed erm_usage_muses to this usage object for report formatting

=cut

sub erm_usage_muses {
    my ($self) = @_;
    my $usage_mus_rs = $self->_result->erm_usage_muses;
    return Koha::ERM::EUsage::MonthlyUsages->_new_from_dbic($usage_mus_rs);
}

=head3 erm_usage_yuses

Method to embed erm_usage_yuses to this usage object for report formatting

=cut

sub erm_usage_yuses {
    my ($self) = @_;
    my $usage_yus_rs = $self->_result->erm_usage_yuses;
    return Koha::ERM::EUsage::YearlyUsages->_new_from_dbic($usage_yus_rs);
}

=head3 yearly_usages

Getter for yearly_usages for this usage object

Yearly usage is read-only. The erm_usage_yus table is rebuilt from the monthly
usage by Koha::ERM::EUsage::YearlyUsages->rebuild, so there is nothing to store here.

=cut

sub yearly_usages {
    my ($self) = @_;

    return $self->erm_usage_yuses;
}

=head3 monthly_usages

Getter/setter for monthly_usages for this usage object
Skips adding monthly_usage if it already exists

=cut

sub monthly_usages {
    my ( $self, $monthly_usages, $job_callbacks ) = @_;

    if ($monthly_usages) {
        for my $monthly_usage (@$monthly_usages) {
            if ( $self->monthly_usages()->search($monthly_usage)->last ) {
                $job_callbacks->{report_info_callback}->('skipped_mus')
                    if $job_callbacks;
                next;
            }
            $job_callbacks->{report_info_callback}->('added_mus')
                if $job_callbacks;
            Koha::ERM::EUsage::MonthlyUsage->new($monthly_usage)->store;
        }
    }
    my $monthly_usages_rs = $self->_result->erm_usage_muses;
    return Koha::ERM::EUsage::MonthlyUsages->_new_from_dbic($monthly_usages_rs);
}

1;
