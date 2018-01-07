#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage;
use Getopt::Long;

use C4::Members;
use Koha::DateUtils;
use Koha::Patrons;
use C4::Log;

my ( $help, $verbose, $not_borrowed_since, $expired_before, $last_seen,
    $category_code, $branchcode, $confirm );
GetOptions(
    'h|help'                 => \$help,
    'v|verbose'              => \$verbose,
    'not_borrowed_since:s'   => \$not_borrowed_since,
    'expired_before:s'       => \$expired_before,
    'last_seen:s'            => \$last_seen,
    'category_code:s'        => \$category_code,
    'library:s'              => \$branchcode,
    'c|confirm'              => \$confirm,
) || pod2usage(1);

if ($help) {
    pod2usage(1);
}

$not_borrowed_since = dt_from_string( $not_borrowed_since, 'iso' )
  if $not_borrowed_since;

$expired_before = dt_from_string( $expired_before, 'iso' )
  if $expired_before;

if ( $last_seen and not C4::Context->preference('TrackLastPatronActivity') ) {
    pod2usage(q{The --last_seen option cannot be used with TrackLastPatronActivity turned off});
}

unless ( $not_borrowed_since or $expired_before or $last_seen or $category_code or $branchcode ) {
    pod2usage(q{At least one filter is mandatory});
}

cronlogaction();

my $members = GetBorrowersToExpunge(
    {
        not_borrowed_since => $not_borrowed_since,
        expired_before       => $expired_before,
        last_seen            => $last_seen,
        category_code        => $category_code,
        branchcode           => $branchcode,
    }
);

unless ($confirm) {
    say "Doing a dry run; no patron records will actually be deleted.";
    say "Run again with --confirm to delete the records.";
}

say scalar(@$members) . " patrons to delete";

my $deleted = 0;
for my $member (@$members) {
    print "Trying to delete patron $member->{borrowernumber}... "
      if $verbose;

    my $borrowernumber = $member->{borrowernumber};
    my $patron = Koha::Patrons->find( $borrowernumber );
    unless ( $patron ) {
        say "Patron with borrowernumber $borrowernumber does not exist";
        next;
    }
    if ( my $charges = $patron->account->non_issues_charges ) { # And what if we owe to this patron?
        say "Failed to delete patron $borrowernumber: patron has $charges in fines";
        next;
    }

    if ( $confirm ) {
        my $deleted = eval { $patron->move_to_deleted; };
        if ($@ or not $deleted) {
            say "Failed to delete patron $borrowernumber, cannot move it" . ( $@ ? ": ($@)" : "" );
            next;
        }

        eval { $patron->delete };
        if ($@) {
            say "Failed to delete patron $borrowernumber: $@)";
            next;
        }
    }
    $deleted++;
    say "OK" if $verbose;
}

say "$deleted patrons deleted";

=head1 NAME

delete_patrons - This script deletes patrons

=head1 SYNOPSIS

delete_patrons.pl [-h|--help] [-v|--verbose] [-c|--confirm] [--not_borrowed_since=DATE] [--expired_before=DATE] [--last-seen=DATE] [--category_code=CAT] [--library=LIBRARY]

Dates should be in ISO format, e.g., 2013-07-19, and can be generated
with `date -d '-3 month' "+%Y-%m-%d"`.

The options to select the patron records to delete are cumulative.  For
example, supplying both --expired_before and --library specifies that
that patron records must meet both conditions to be selected for deletion.

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<--not_borrowed_since>

Delete patrons who have not borrowed since this date.

=item B<--expired_before>

Delete patrons with an account expired before this date.

=item B<--last_seen>

Delete patrons who have not been connected since this date.

The system preference TrackLastPatronActivity must be enabled to use this option.

=item B<--category_code>

Delete patrons who have this category code.

=item B<--library>

Delete patrons in this library.

=item B<-c|--confirm>

This flag must be provided in order for the script to actually
delete patron records.  If it is not supplied, the script will
only report on the patron records it would have deleted.

=item B<-v|--verbose>

Verbose mode.

=back

=head1 AUTHOR

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2013 BibLibre

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along
with Koha; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=cut
