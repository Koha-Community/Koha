#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More;
use Test::NoWarnings;
use File::Slurp qw(read_file);

use C4::Utils::DataTables::TablesSettings;

use Koha::Devel::Files;

my $yaml = C4::Utils::DataTables::TablesSettings->get_yaml;

my $dev_files = Koha::Devel::Files->new;
my @tt_files  = $dev_files->ls_tt_files;

my @tables;
for my $module ( sort keys %{ $yaml->{modules} } ) {
    my $tables = $yaml->{modules}->{$module};
    for my $page ( sort keys %$tables ) {
        my $table_config = $tables->{$page};
        for my $table_id ( sort keys %$table_config ) {
            push @tables, { module => $module, page => $page, table_id => $table_id, };
        }
    }
}

plan tests => scalar(@tables) + 1;

my @exceptions = (

    # server-side
    "catalogue/detail/bundle_tables",
    "catalogue/detail/holdings_table",
    "catalogue/detail/otherholdings_table",
    "catalogue/itemsearch/results",
    "circ/bookings/bookings-to-collect",

    # patron searches
    "circ/circulation/table_borrowers",

    # in holds_table.inc, does not have a fixed id
    "circ/holds/patron_holds_table",

    # in waiting_holds.inc, could be improved to be handled by this test
    "circ/holds_awaiting_pickup/holdscr",
    "circ/holds_awaiting_pickup/holdso",

    # in ill-list-table.inc, could be improved
    "illrequests/ill-requests/ill-requests",

    # in patron-search.inc
    "members/member/memberresultst",

    # server-side
    "members/moremember/bookings-table",

    # FIXME additional field columns
    "serials/claims/claimst",

    # OPAC
    "opac/biblio-detail/holdingst",
    "opac/biblio-detail/subscriptionst",
);
my @vue_tables = (
    [qw(sip2 institutions institutions)],
    [qw(acqui vendors vendors)],
    [qw(erm agreements agreements)],
    [qw(erm counter_logs counter_logs)],
    [qw(erm eholdings packages)],
    [qw(erm eholdings titles)],
    [qw(erm licenses licenses)],
    [qw(erm monthly_usages monthly_usages)],
    [qw(erm titles titles)],
    [qw(erm usage_data_providers usage_data_providers)],
    [qw(erm yearly_usages yearly_usages)],
    [qw(sip2 system_preference_overrides system_preference_overrides)],
    [qw(illrequests ill-supply ill-supply)],
);

my $table_id_mapping = {
    'catalogue/detail/acquisitiondetails-table'     => [qw( catalogue detail orders)],
    'catalogue/detail/checkoutshistory-table'       => [qw(catalogue issuehistory table_issues)],
    'catalogue/detail/comments-table'               => [qw(catalogue detail comments_table)],
    'circ/holds/holds-to-pull'                      => [qw(circ pendingreserves holdst)],
    'circ/overdues/circ-overdues'                   => [qw(circ overdues overduest)],
    'members/checkouthistory/checkouthistory-table' => [qw(members readingrec table_readingrec)],
    'members/fines/account-fines'                   => [qw(members boraccount table_account_fines)],
    'members/holdshistory/holdshistory-table'       => [qw(members holdshistory table_holdshistory)],
    'members/pay/pay-fines-table'                   => [qw(members pay finest)],
    'reports/orders_by_fund/funds-table'            => [qw(reports orders_by_budget funds)],

};

foreach my $table (@tables) {
    my $module   = $table->{module};
    my $page     = $table->{page};
    my $table_id = $table->{table_id};

    my $id = "$module/$page/$table_id";
    if ( grep { $_ eq $id } @exceptions ) {
        pass("Table '$id' is an exception");
        next;
    }
    if ( grep { $_->[0] eq $module && $_->[1] eq $page && $_->[2] eq $table_id } @vue_tables ) {
        pass("Table '$id' is in .vue files");
        next;
    }

    if ( exists $table_id_mapping->{$id} ) {
        $module   = $table_id_mapping->{$id}->[0];
        $page     = $table_id_mapping->{$id}->[1];
        $table_id = $table_id_mapping->{$id}->[2];
    }
    my ($matching_file) = grep { m{/$module/$page.tt} } @tt_files;
    my $content;
    if ($matching_file) {
        $content = read_file($matching_file);
        undef $matching_file unless $content =~ m{table id="$table_id"};
    }
    unless ($matching_file) {
        foreach my $file (@tt_files) {
            $content = read_file($file);
            if ( $content =~ m{table id="$table_id"} ) {
                $matching_file = $file;
                last;
            }
        }
    }
    unless ($matching_file) {
        fail(qq{No file found for table '$id'});
        next;
    }

    # Check if this specific table has conditional TT tags in its thead
    # We need to find the thead that belongs to this table
    # Only catch IF, UNLESS, FOR, WHILE, etc. that could change column count
    my $error;
    if ( $content =~ m{table id="$table_id"[^>]*>.*?<thead\b[^>]*>(.*?<\/thead>)}s ) {
        my $thead_content = $1;
        if ( $thead_content =~ m{\[%\s*(IF|UNLESS|FOR|WHILE|SWITCH|CASE)\b}s ) {
            $error = 1;
        }
    }
    ok( !$error, "Table '$id' in $matching_file has conditional TT tags in thead" );
}
