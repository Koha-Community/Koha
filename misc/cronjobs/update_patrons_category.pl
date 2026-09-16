#!/usr/bin/perl

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
use Koha::Logger;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::DateUtils qw( dt_from_string );
use Koha::Script -cron;

=head1 NAME

update_patrons_category.pl - Given a set of parameters update selected patrons from one catgeory to another. Options are cumulative.

=head1 SYNOPSIS

update_patrons_category.pl -f=categorycode -t=categorycode
                          [-b=branchcode] [--too_old] [--too_young] [-fo=X] [-fu=X]
                          [-rb=date] [-ra=date] [-v]
                          [--field column=value ...]

update_patrons_category.pl --help | --man

Options:

   --help                   brief help message
   --man                    full documentation
   -too_old                 update if over  maximum age for current category
   -too_young               update if under minimuum age current category
   -fo=X --finesover=X      update if fines over X amount
   -fu=X --finesunder=X     update if fines under X amount
   -rb=date --regbefore     update if registration date is before given date
   -ra=date --regafter      update if registration date is after a given date
   -d --field name=value    where <name> is a column in the borrowers table, patrons will be updated if the field is equal to given <value>
   --where <conditions>     where clause to add to the query
   -v -verbose              verbose mode
   -c --confirm             commit changes to db, no action will be taken unless this switch is included
   -b --branch <branchname> only deal with patrons from this library/branch
   -f --from <categorycode> change patron category from this category
   -t --to   <categorycode> change patron category to this category

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--verbose | -v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<--confirm | -c>

Commit changes. Unless this flag set is, the script will report changes but not actually execute them on the database.

=item B<--branch | -b>

Changes patrons for one specific branch. Use the value in the
branches.branchcode table.

=item B<--from | -f>

*Required* Defines the category to update. Expects the code from categories.categorycode.

=item B<--to | -t>

*Required* Defines the category patrons will be converted to. Expects the code from categories.categorycode.

=item B<--too_old>

Update patron only if they are above the maximum age range specified for the 'from' category.

=item B<--too_young>

Update patron only if they are below the minimum age range specified for the 'from' category.

=item B<--finesover=X | -fo=X>

Supply a number and only account with fines over this number will be updated.

=item B<--finesunder=X | -fu=X>

Supply a number and only account with fines under this number will be updated.

=item B<--regbefore=date | -rb=date>

Enter a date in ISO format YYYY-MM-DD and only patrons registered before this date will be updated.

=item B<--regafter=date | -ra=date>

Enter a date in ISO format YYYY-MM-DD and only patrons registered after this date will be updated.

=item B<--field column=value | -d column=value>

Use this flag to specify a column in the borrowers table and update only patrons whose value in that column equals the value supplied (repeatable)
A value of null will check for a field that is not set.

e.g.
--field dateexpiry=2016-01-01
will update all patrons who expired on that date, useful for schools etc.

=item B<--where $conditions>

Use this option to specify a condition built with columns from the borrowers table

e.g.
--where 'email IS NULL'
will update all patrons with no value for email

=back

=head1 DESCRIPTION

This script is designed to update patrons from one category to another.

=head1 USAGE EXAMPLES

C<update_patron_categories.pl> - Suggests that you read this help. :)

C<update_patron_categories.pl> -b=<branchcode> -f=<categorycode> -t=<categorycode> --confirm  - Processes a single branch, and updates the patron categories from fromcat to tocat.

C<update_patron_categories.pl> -b=<branchcode> -f=<categorycode> -t=<categorycode>  --too_old --confirm  - Processes a single branch, and updates the patron categories from fromcat to tocat for patrons over the age range of fromcat.

C<update_patron_categories.pl> -f=<categorycode> -t=<categorycode> -v  - Processes all branches, shows all messages, and reports the patrons who would be affected. Takes no action on the database.

=cut

my $opt = Koha::Script->describe_options(
    'Update patrons from one category to another, based on optional filtering criteria. Options are cumulative.

%c %o',
    [ 'from|f=s',        'change patron category from this category (categories.categorycode)', { required => 1 } ],
    [ 'to|t=s',          'change patron category to this category (categories.categorycode)',   { required => 1 } ],
    [ 'branch|b=s',      'only deal with patrons from this library/branch' ],
    [ 'too_old',         'update patron only if above the maximum age range for the "from" category' ],
    [ 'too_young',       'update patron only if below the minimum age range for the "from" category' ],
    [ 'finesover|fo=s',  'only update patrons with fines over this amount' ],
    [ 'finesunder|fu=s', 'only update patrons with fines under this amount' ],
    [ 'regbefore|rb=s',  'only update patrons registered before this date (YYYY-MM-DD)' ],
    [ 'regafter|ra=s',   'only update patrons registered after this date (YYYY-MM-DD)' ],
    [
        'field|d=s%',
        'update patrons where this borrowers column equals this value (repeatable); "null" checks for an unset field'
    ],
    [ 'where=s@',  'a raw WHERE condition, built from borrowers columns, to add to the query (repeatable)' ],
    [ 'verbose|v', 'verbose output' ],
    [ 'confirm|c', 'commit changes to the database; without this, changes are reported but not made' ],
    {
              epilog => "Examples:\n"
            . "  %c --from CATCODE1 --to CATCODE2 --branch BRANCHCODE --confirm\n"
            . "    Update patrons at BRANCHCODE from CATCODE1 to CATCODE2.\n\n"
            . "  %c --from CATCODE1 --to CATCODE2 --too_old --confirm\n"
            . "    Update patrons over CATCODE1's maximum age from CATCODE1 to CATCODE2.\n\n"
            . "  %c --from CATCODE1 --to CATCODE2 --verbose\n"
            . "    Report (without updating) which patrons would move from CATCODE1 to CATCODE2.\n",
    },
);

my $verbose    = $opt->verbose;
my $doit       = $opt->confirm;
my $ageunder   = $opt->too_young;
my $ageover    = $opt->too_old;
my $fine_min   = $opt->finesover;
my $fine_max   = $opt->finesunder;
my $fromcat    = $opt->from;
my $tocat      = $opt->to;
my $reg_bef    = $opt->regbefore;
my $reg_aft    = $opt->regafter;
my $branch_lim = $opt->branch;
my %fields     = %{ $opt->field // {} };
my @where      = @{ $opt->where // [] };

( $verbose && !$doit ) and print "No actions will be taken (test mode)\n";

$verbose and print "Will update patrons from $fromcat to $tocat with conditions below (if any)\n";

my %params;

if ( $reg_bef || $reg_aft ) {
    my $date_bef;
    my $date_aft;
    if ( defined $reg_bef ) {
        eval { $date_bef = dt_from_string( $reg_bef, 'iso' ); };
    }
    die "$reg_bef is not a valid date before, aborting! Use a date in format YYYY-MM-DD.$@"
        if $@;
    if ( defined $reg_aft ) {
        eval { $date_aft = dt_from_string( $reg_aft, 'iso' ); };
    }
    die "$reg_bef is not a valid date after, aborting! Use a date in format YYYY-MM-DD.$@"
        if $@;
    $params{dateenrolled}{'<='} = $reg_bef if defined $date_bef;
    $params{dateenrolled}{'>='} = $reg_aft if defined $date_aft;
}

my $cat_from = Koha::Patron::Categories->find($fromcat);
my $cat_to   = Koha::Patron::Categories->find($tocat);
die "Categories not found" unless $cat_from && $cat_to;

$params{"me.categorycode"} = $fromcat;
$params{"me.branchcode"}   = $branch_lim if $branch_lim;

if ($verbose) {
    print "Conditions:\n";
    print "    Registered before $reg_bef\n"                           if $reg_bef;
    print "    Registered after  $reg_aft\n"                           if $reg_aft;
    print "    Total fines more than $fine_min\n"                      if $fine_min;
    print "    Total fines less than $fine_max\n"                      if $fine_max;
    print "    Age below minimum for " . $cat_from->description . "\n" if $ageunder;
    print "    Age above maximum for " . $cat_from->description . "\n" if $ageover;
    if ( defined $branch_lim ) {
        print "    Branchcode of patron is $branch_lim\n";
    }
}

while ( my ( $key, $value ) = each %fields ) {
    $verbose and print "    Borrower column $key is $value\n";
    $value = undef if lc($value) eq 'null';
    $params{ "me." . $key } = $value;
}

my $where_literal  = join ' AND ', @where;
my $target_patrons = Koha::Patrons->search( \%params );
$target_patrons = $target_patrons->search( \$where_literal ) if @where;
$target_patrons = $target_patrons->search_patrons_to_update_category(
    {
        from          => $fromcat,
        search_params => \%params,
        too_young     => $ageunder,
        too_old       => $ageover,
        fine_min      => $fine_min,
        fine_max      => $fine_max,
    }
);

my $patrons_found    = $target_patrons->count;
my $actually_updated = 0;
my $testdisplay      = $doit ? "" : "WOULD HAVE ";
if ($verbose) {
    while ( my $target_patron = $target_patrons->next() ) {
        $target_patron->discard_changes();
        $verbose
            and print $testdisplay
            . "Updated "
            . $target_patron->firstname() . " "
            . $target_patron->surname()
            . " from $fromcat to $tocat\n";
    }
    $target_patrons->reset;
}
if ($doit) {
    $actually_updated = $target_patrons->update_category_to( { category => $tocat } );
}

$verbose and print "$patrons_found found, $actually_updated updated\n";
