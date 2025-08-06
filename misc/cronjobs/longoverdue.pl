#!/usr/bin/perl
#-----------------------------------
# Copyright 2008 LibLime
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.
#-----------------------------------

=head1 NAME

longoverdue.pl  cron script to set lost statuses on overdue materials.
                Execute without options for help.

=cut

use strict;
use warnings;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use C4::Circulation qw( LostItem MarkIssueReturned );
use C4::Context;
use C4::Log qw( cronlogaction );
use Koha::ItemTypes;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::Script -cron;

my $lost;    #  key=lost value,  value=num days.
my ( $charge, $verbose, $confirm, $quiet );
my $endrange = 366;
my $mark_returned;
my $borrower_category      = [];
my $skip_borrower_category = [];
my @branches;
my @skip_branches;
my $itemtype        = [];
my $skip_itemtype   = [];
my $help            = 0;
my $man             = 0;
my $list_categories = 0;
my $list_itemtypes  = 0;
my @skip_lost_values;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'l|lost=s%'         => \$lost,
    'c|charge=s'        => \$charge,
    'confirm'           => \$confirm,
    'v|verbose'         => \$verbose,
    'quiet'             => \$quiet,
    'maxdays=s'         => \$endrange,
    'mark-returned'     => \$mark_returned,
    'h|help'            => \$help,
    'man|manual'        => \$man,
    'category=s'        => $borrower_category,
    'skip-category=s'   => $skip_borrower_category,
    'list-categories'   => \$list_categories,
    'library=s'         => \@branches,
    'skip-library=s'    => \@skip_branches,
    'itemtype=s'        => $itemtype,
    'skip-itemtype=s'   => $skip_itemtype,
    'list-itemtypes'    => \$list_itemtypes,
    'skip-lost-value=s' => \@skip_lost_values,
);

if ($man) {
    pod2usage( -verbose => 2 -exitval => 0 );
}

if ($help) {
    pod2usage(
        -verbose => 1,
        -exitval => 0
    );
}

if ( scalar @$borrower_category && scalar @$skip_borrower_category ) {
    pod2usage(
        -verbose => 1,
        -message => "The options --category and --skip-category are mutually exclusive.\n" . "Use one or the other.",
        -exitval => 1
    );
}

if ( scalar @branches && scalar @skip_branches ) {
    pod2usage(
        -verbose => 1,
        -message => "The options --library and --skip-library are mutually exclusive.\n" . "Use one or the other.",
        -exitval => 1
    );
}

if ( scalar @$itemtype && scalar @$skip_itemtype ) {
    pod2usage(
        -verbose => 1,
        -message => "The options --itemtype and --skip-itemtype are mutually exclusive.\n" . "Use one or the other.",
        -exitval => 1
    );
}

if ($list_categories) {

    my @categories = Koha::Patron::Categories->search()->get_column('categorycode');
    print "\nBorrower Categories: " . join( " ", @categories ) . "\n\n";
    exit 0;
}

if ($list_itemtypes) {
    my @itemtypes = Koha::ItemTypes->search()->get_column('itemtype');
    print "\nItemtypes: " . join( " ", @itemtypes ) . "\n\n";
    exit 0;
}

=head1 SYNOPSIS

   longoverdue.pl [ --help | -h | --man | --list-categories ]
   longoverdue.pl --lost | -l DAYS=LOST_CODE [ --charge | -c CHARGE_CODE ] [ --verbose | -v ] [ --quiet ]
                  [ --maxdays MAX_DAYS ] [ --mark-returned ] [ --category BORROWER_CATEGORY ] ...
                  [ --skip-category BORROWER_CATEGORY ] ...
                  [ --library LIBRARY_CODE ] [ --skip-library LIBRARY_CODE ] ...
                  [ --skip-lost-value LOST_VALUE [ --skip-lost-value LOST_VALUE ] ]
                  [ --commit ]


WARNING:  Flippant use of this script could set all or most of the items in your catalog to Lost and charge your
          patrons for them!

WARNING:  This script is known to be faulty.  It is NOT recommended to use multiple --lost options.
          See https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2883

=cut

=head1 OPTIONS

This script takes the following parameters :

=over 8

=item B<--lost | -l>

This option takes the form of n=lv, where n is num days overdue, and lv is the lost value.  See warning above.

=item B<--charge | -c>

This specifies what lost value triggers Koha to charge the account for the lost item.  Replacement costs are not charged if this is not specified.

=item B<--verbose | -v>

verbose.

=item B<--confirm>

confirm.  without this option, the script will report the number of affected items and return without modifying any records.

=item B<--quiet>

suppress summary output.

=item B<--maxdays>

Specifies the end of the range of overdue days to deal with (defaults to 366).  This value is universal to all lost num days overdue passed.

=item B<--mark-returned>

When an item is marked lost, remove it from the borrowers issued items.
If not provided, the value of the system preference 'MarkLostItemsAsReturned' will be used.

=item B<--category>

Act on the listed borrower category code (borrowers.categorycode).
Exclude all others. This may be specified multiple times to include multiple categories.
May not be used with B<--skip-category>
If not provided, the value of the system preference 'DefaultLongOverduePatronCategories' will be used.

=item B<--skip-category>

Act on all available borrower category codes, except those listed.
This may be specified multiple times, to exclude multiple categories.
May not be used with B<--category>
If not provided, the value of the system preference 'DefaultLongOverdueSkipPatronCategories' will be used.

=item B<--list-categories>

List borrower categories available for use by B<--category> or
B<--skip-category>, and exit.

=item B<--library>

Act on the listed library codes.  Exclude all others.  This may be specified multiple times to include multiple libraries.  Which libraries are selected follows the CircControl system preference.
May not be used with B<--skip-library>

=item B<--skip-library>

Act on all library codes except the ones listed.  This may be specified multiple times to exclude multiple libraries.  Which libraries are excluded follows the CircControl system preference.
May not be used with B<--library>

=item B<--itemtype>

Act on the listed itemtype code.
Exclude all others. This may be specified multiple times to include multiple itemtypes.
May not be used with B<--skip-itemtype>

=item B<--skip-itemtype>

Act on all available itemtype codes, except those listed.
This may be specified multiple times, to exclude multiple itemtypes.
May not be used with B<--itemtype>

=item B<--skip-lost-value>

Act on all available lost values, except those listed.
This may be specified multiple times, to exclude multiple lost values.

=item B<--list-itemtypes>

List itemtypes available for use by B<--itemtype> or
B<--skip-itemtype>, and exit.

=item B<--help | -h>

Display short help message an exit.

=item B<--man | --manual >

Display entire manual and exit.

=back

=cut

=head1 Description

This cron script set lost values on overdue items and optionally sets charges the patron's account
for the item's replacement price.  It is designed to be run as a nightly job.  The command line options that globally
define this behavior for this script  will likely be moved into Koha's core circulation / issuing rules code in a
near-term release, so this script is not intended to have a long lifetime.


=cut

=head1 Examples

  $PERL5LIB/misc/cronjobs/longoverdue.pl --lost 30=1
    Would set LOST=1 after 30 days (up to one year), but not charge the account.
    This would be suitable for the Koha default LOST authorized value of 1 -> 'Lost'.

  $PERL5LIB/misc/cronjobs/longoverdue.pl --lost 60=2 --charge 2
    Would set LOST=2 after 60 days (up to one year), and charge the account when setting LOST=2.
    This would be suitable for the Koha default LOST authorized value of 2 -> 'Long Overdue'

=cut

# FIXME: We need three pieces of data to operate:
#         ~ lower bound (number of days),
#         ~ upper bound (number of days),
#         ~ new lost value.
#        Right now we get only two, causing the endrange hack.  This is a design-level failure.
# FIXME: do checks on --lost ranges to make sure they are exclusive.
# FIXME: do checks on --lost ranges to make sure the authorized values exist.
# FIXME: do checks on --lost ranges to make sure don't go past endrange.
#

unless ( scalar @skip_lost_values ) {
    my $preference = C4::Context->preference('DefaultLongOverdueSkipLostStatuses');
    @skip_lost_values = split( ',', $preference );
}

if ( !defined($lost) ) {
    my $longoverdue_value = C4::Context->preference('DefaultLongOverdueLostValue');
    my $longoverdue_days  = C4::Context->preference('DefaultLongOverdueDays');
    if (    defined($longoverdue_value)
        and defined($longoverdue_days)
        and $longoverdue_value ne ''
        and $longoverdue_days ne ''
        and $longoverdue_days >= 0 )
    {
        $lost->{$longoverdue_days} = $longoverdue_value;
    } else {
        pod2usage(
            {
                -exitval => 1,
                -msg     =>
                    q|ERROR: No --lost (-l) option or system preferences DefaultLongOverdueLostValue/DefaultLongOverdueDays defined|,
            }
        );
    }
}
if ( !defined($charge) ) {
    my $charge_value = C4::Context->preference('DefaultLongOverdueChargeValue');
    if ( defined($charge_value) and $charge_value ne '' ) {
        $charge = $charge_value;
    }
}

if ( scalar @$borrower_category == 0 ) {
    if ( C4::Context->preference('DefaultLongOverduePatronCategories') ) {
        my $categories = C4::Context->preference('DefaultLongOverduePatronCategories');
        $borrower_category = [ split( ',', $categories ) ];
    }
}

if ( scalar @$skip_borrower_category == 0 ) {
    if ( C4::Context->preference('DefaultLongOverdueSkipPatronCategories') ) {
        my $categories = C4::Context->preference('DefaultLongOverdueSkipPatronCategories');
        $skip_borrower_category = [ split( ',', $categories ) ];
    }
}

unless ($confirm) {
    $verbose = 1;    # If you're not running it for real, then the whole point is the print output.
    print "### TEST MODE -- NO ACTIONS TAKEN ###\n";
}

# In my opinion, this line is safe SQL to have outside the API. --atz
our $bounds_sth = C4::Context->dbh->prepare("SELECT DATE_SUB(CURDATE(), INTERVAL ? DAY)");

sub bounds {
    $bounds_sth->execute(shift);
    return $bounds_sth->fetchrow;
}

# FIXME - This sql should be inside the API.
sub longoverdue_sth {
    my ($params) = @_;
    my $skip_lost_values = $params->{skip_lost_values};

    my $skip_lost_values_sql = q{};
    if (@$skip_lost_values) {
        my $values = join( ',', map { qq{'$_'} } @$skip_lost_values );
        $skip_lost_values_sql = "AND itemlost NOT IN ( $values )";
    }

    my $query = "
    SELECT items.itemnumber, borrowernumber, date_due, itemlost
      FROM issues, items
     WHERE items.itemnumber = issues.itemnumber
      AND  DATE_SUB(CURDATE(), INTERVAL ? DAY)  > date_due
      AND  DATE_SUB(CURDATE(), INTERVAL ? DAY) <= date_due
      AND  itemlost <> ?
      $skip_lost_values_sql
     ORDER BY date_due
    ";
    return C4::Context->dbh->prepare($query);
}

my $dbh               = C4::Context->dbh;
my $lost_control_pref = C4::Context->preference('LostChargesControl');
my $home_holding_pref = C4::Context->preference('HomeOrHoldingBranch');

my @available_categories = Koha::Patron::Categories->search()->get_column('categorycode');
$borrower_category      = [ map { uc $_ } @$borrower_category ];
$skip_borrower_category = [ map { uc $_ } @$skip_borrower_category ];
my %category_to_process;
for my $cat (@$borrower_category) {
    unless ( grep { $_ eq $cat } @available_categories ) {
        pod2usage(
            '-exitval' => 1,
            '-message' => "The category $cat does not exist in the database",
        );
    }
    $category_to_process{$cat} = 1;
}
if (@$skip_borrower_category) {
    for my $cat (@$skip_borrower_category) {
        unless ( grep { $_ eq $cat } @available_categories ) {
            pod2usage(
                '-exitval' => 1,
                '-message' => "The category $cat does not exist in the database",
            );
        }
    }
    %category_to_process = map { $_ => 1 } @available_categories;
    %category_to_process = ( %category_to_process, map { $_ => 0 } @$skip_borrower_category );
}

my $filter_borrower_categories = ( scalar @$borrower_category || scalar @$skip_borrower_category );

my @available_branches = Koha::Libraries->search()->get_column('branchcode');
my %branches_to_process;

# If --library was used, validate any branchcode passed in and mark them as branches to use
for my $lib (@branches) {
    unless ( grep { $_ eq $lib } @available_branches ) {
        pod2usage(
            '-exitval' => 1,
            '-message' => "The library $lib does not exist in the database",
        );
    }
    $branches_to_process{$lib} = 1;
}

# If --skip-library was used, validate any branchcode passed in and mark them as branches to *not* use
if (@skip_branches) {
    for my $lib (@skip_branches) {
        unless ( grep { $_ eq $lib } @available_branches ) {
            pod2usage(
                '-exitval' => 1,
                '-message' => "The library $lib does not exist in the database",
            );
        }
    }
    %branches_to_process = map { $_ => 1 } @available_branches;

    # The mapped 0 values here will overwrite the corrosponding mapped 1 values
    # where the 0 values exist
    %branches_to_process = ( %branches_to_process, map { $_ => 0 } @skip_branches );
}

my $filter_branches = ( scalar @branches || scalar @skip_branches );

my @available_itemtypes = Koha::ItemTypes->search()->get_column('itemtype');
$itemtype      = [ map { uc $_ } @$itemtype ];
$skip_itemtype = [ map { uc $_ } @$skip_itemtype ];
my %itemtype_to_process;
for my $it (@$itemtype) {
    unless ( grep { $_ eq $it } @available_itemtypes ) {
        pod2usage(
            '-exitval' => 1,
            '-message' => "The itemtype $it does not exist in the database",
        );
    }
    $itemtype_to_process{$it} = 1;
}
if (@$skip_itemtype) {
    for my $it (@$skip_itemtype) {
        unless ( grep { $_ eq $it } @available_itemtypes ) {
            pod2usage(
                '-exitval' => 1,
                '-message' => "The itemtype $it does not exist in the database",
            );
        }
    }
    %itemtype_to_process = map { $_ => 1 } @available_itemtypes;
    %itemtype_to_process = ( %itemtype_to_process, map { $_ => 0 } @$skip_itemtype );
}

my $filter_itemtypes = ( scalar @$itemtype || scalar @$skip_itemtype );

my $count;
my @report;
my $total = 0;
my $i     = 0;

# FIXME - The item is only marked returned if you supply --charge .
#         We need a better way to handle this.
#
my $sth_items = longoverdue_sth( { skip_lost_values => \@skip_lost_values } );

foreach my $startrange ( sort keys %$lost ) {
    if ( my $lostvalue = $lost->{$startrange} ) {
        my ($date1) = bounds($startrange);
        my ($date2) = bounds($endrange);

        # print "\nRange ", ++$i, "\nDue $startrange - $endrange days ago ($date2 to $date1), lost => $lostvalue\n" if($verbose);
        $verbose
            and printf "\nRange %s\nDue %3s - %3s days ago (%s to %s), lost => %s\n", ++$i,
            $startrange, $endrange, $date2, $date1, $lostvalue;
        $sth_items->execute( $startrange, $endrange, $lostvalue );
        $count = 0;
    ITEM: while ( my $row = $sth_items->fetchrow_hashref ) {
            my $patron;
            if ($filter_borrower_categories) {
                $patron ||= Koha::Patrons->find( $row->{borrowernumber} );
                my $category = uc $patron->categorycode();
                next ITEM unless ( $category_to_process{$category} );
            }
            if ($filter_branches) {
                my $lib;
                for ($lost_control_pref) {
                    if ( $_ eq 'PatronLibrary' ) {
                        $patron ||= Koha::Patrons->find( $row->{borrowernumber} );
                        $lib = $patron->branchcode();
                    } elsif ( $_ eq 'PickupLibrary' ) {
                        $lib = C4::Context->userenv->{'branch'};
                    } else {    # ( $_ eq 'ItemHomeLibrary' )
                        if ( $home_holding_pref eq 'homebranch' ) {
                            $lib = Koha::Items->find( $row->{itemnumber} )->homebranch();
                        } else {    # ( $home_holding_pref eq 'holdingbranch' )
                            $lib = Koha::Items->find( $row->{itemnumber} )->holdingbranch();
                        }
                    }
                }
                next ITEM unless ( $branches_to_process{$lib} );
            }
            if ($filter_itemtypes) {
                my $it = uc Koha::Items->find( $row->{itemnumber} )->effective_itemtype();
                next ITEM unless ( $itemtype_to_process{$it} );
            }
            printf(
                "Due %s: item %5s from borrower %5s to lost: %s\n", $row->{date_due}, $row->{itemnumber},
                $row->{borrowernumber}, $lostvalue
            ) if ($verbose);
            if ($confirm) {
                Koha::Items->find( $row->{itemnumber} )->itemlost($lostvalue)->store;
                if ( $charge && $charge eq $lostvalue ) {
                    LostItem( $row->{'itemnumber'}, 'cronjob', $mark_returned );
                } elsif ($mark_returned) {
                    $patron ||= Koha::Patrons->find( $row->{borrowernumber} );
                    MarkIssueReturned( $row->{borrowernumber}, $row->{itemnumber}, undef, $patron->privacy );
                }
            }
            $count++;
        }
        push @report, {
            startrange => $startrange,
            endrange   => $endrange,
            range      => "$startrange - $endrange",
            date1      => $date1,
            date2      => $date2,
            lostvalue  => $lostvalue,
            count      => $count,
        };
        $total += $count;
    }
    $endrange = $startrange;
}

sub summarize {
    my $arg       = shift;             # ref to array
    my $got_items = shift || 0;        # print "count" line for items
    my @report    = @$arg or return;
    my $i         = 0;
    for my $range (@report) {
        printf "\nRange %s\nDue %3s - %3s days ago (%s to %s), lost => %s\n", ++$i,
            map { $range->{$_} } qw(startrange endrange date2 date1 lostvalue);
        $got_items and printf "  %4s items\n", $range->{count};
    }
}

if ( !$quiet ) {
    print "\n### LONGOVERDUE SUMMARY ###";
    summarize( \@report, 1 );
    print "\nTOTAL: $total items\n";
}

cronlogaction( { action => 'End', info => "COMPLETED" } );
