package Koha::ERM::EUsage::YearlyUsages;

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

use C4::Context;
use Koha::Database;

use Koha::ERM::EUsage::YearlyUsage;

use base qw(Koha::Objects);

=head1 NAME

Koha::ERM::EUsage::YearlyUsages- Koha ErmYearlyUsage Object set class

=head1 API

=head2 Class Methods

=cut

=head3 rebuild

    my $rows = Koha::ERM::EUsage::YearlyUsages->rebuild(
        { usage_data_provider_id => $id, report_type => 'TR_J1', year => 2023 }
    );

Rebuilds the erm_usage_yus rows from the monthly usage in erm_usage_mus and
returns the number of rows written. erm_usage_yus is a derived table: its rows
are only ever the sum of the monthly usage per year, so a re-harvest or a year
spread over several files always gives the right total.

C<usage_data_provider_id>, C<report_type> and C<year> are optional filters. A
key that is given limits the rebuild to the matching rows, undef included (a
report type of undef matches rows without a report type). Without any key the
whole table is rebuilt.

Call it after every write to erm_usage_mus, once for each provider, report type
and year that changed.

=cut

sub rebuild {
    my ( $class, $params ) = @_;
    $params //= {};

    my @keys   = grep { exists $params->{$_} } qw( usage_data_provider_id report_type year );
    my $where  = @keys ? 'WHERE ' . join( ' AND ', map { "`$_` <=> ?" } @keys ) : q{};
    my @values = @{$params}{@keys};

    my $schema = Koha::Database->new->schema;
    my $dbh    = C4::Context->dbh;

    return $schema->txn_do(
        sub {

            # Jobs for the months of one provider run in parallel, wait for the others to finish
            if ( defined $params->{usage_data_provider_id} ) {
                $dbh->do(
                    q{
                        SELECT erm_usage_data_provider_id
                        FROM erm_usage_data_providers
                        WHERE erm_usage_data_provider_id = ?
                        FOR UPDATE
                    },
                    undef, $params->{usage_data_provider_id}
                );
            }

            $dbh->do( qq{DELETE FROM `erm_usage_yus` $where}, undef, @values );

            my $rows = $dbh->do(
                qq{
                    INSERT INTO `erm_usage_yus` (
                        `title_id`, `platform_id`, `database_id`, `item_id`,
                        `usage_data_provider_id`, `year`, `totalcount`,
                        `metric_type`, `access_type`, `yop`, `report_type`
                    )
                    SELECT
                        `title_id`, `platform_id`, `database_id`, `item_id`,
                        `usage_data_provider_id`, `year`,
                        CAST(SUM(`usage_count`) AS SIGNED),
                        `metric_type`, `access_type`, `yop`, `report_type`
                    FROM `erm_usage_mus`
                    $where
                    GROUP BY
                        `title_id`, `platform_id`, `database_id`, `item_id`,
                        `usage_data_provider_id`, `year`,
                        `metric_type`, `access_type`, `yop`, `report_type`
                }, undef, @values
            );

            return $rows + 0;
        }
    );
}

=head3 type

=cut

sub _type {
    return 'ErmUsageYus';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::ERM::EUsage::YearlyUsage';
}

1;
