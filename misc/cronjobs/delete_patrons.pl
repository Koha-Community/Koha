#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage;
use Getopt::Long;

use C4::Members;
use C4::VirtualShelves;
use Koha::DateUtils;

my ( $help, $verbose, $not_borrowed_since, $expired_before, $category_code,
    $branchcode, $confirm );
GetOptions(
    'h|help'                 => \$help,
    'v|verbose'              => \$verbose,
    'not_borrowed_since:s'   => \$not_borrowed_since,
    'expired_before:s'       => \$expired_before,
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

unless ( $not_borrowed_since or $expired_before or $category_code or $branchcode ) {
    pod2usage(q{At least one filter is mandatory});
    exit;
}

my $members = GetBorrowersToExpunge(
    {
        not_borrowered_since => $not_borrowed_since,
        expired_before       => $expired_before,
        category_code        => $category_code,
        branchcode           => $branchcode,
    }
);

unless ($confirm) {
    say "Doing a dry run; no patron records will actually be deleted.";
    say "Run again with --confirm to delete the records.";
}

say scalar(@$members) . " patrons to delete";

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{PrintError} = 0;

$dbh->{AutoCommit} = 0; # use transactions to avoid partial deletes
for my $member (@$members) {
    print "Trying to delete patron $member->{borrowernumber}... "
      if $verbose;
    eval {
        C4::Members::MoveMemberToDeleted( $member->{borrowernumber} )
          if $confirm;
    };
    if ($@) {
        say "Failed to delete patron $member->{borrowernumber}, cannot move it: ($@)";
        $dbh->rollback;
        next;
    }
    eval {
        C4::VirtualShelves::HandleDelBorrower( $member->{borrowernumber} )
          if $confirm;
    };
    if ($@) {
        say "Failed to delete patron $member->{borrowernumber}, error handling its lists: ($@)";
        $dbh->rollback;
        next;
    }
    eval { C4::Members::DelMember( $member->{borrowernumber} ) if $confirm; };
    if ($@) {
        say "Failed to delete patron $member->{borrowernumber}: $@)";
        $dbh->rollback;
        next;
    }
    $dbh->commit;
    say "OK" if $verbose;
}

=head1 NAME

delete_patrons - This script deletes patrons

=head1 SYNOPSIS

delete_patrons.pl [-h -v -c] --not_borrowed_since=2013-07-21 --expired_before=2013-07-21 --category_code=CAT --library=CPL

dates can be generated with `date -d '-3 month' "+%Y-%m-%d"`

Options are cumulatives.

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<--not_borrowed_since>

Delete patrons who have not borrowed since this date.

=item B<--expired_date>

Delete patrons with an account expired before this date.

=item B<--category_code>

Delete patrons who have this category code.

=item B<--library>

Delete patrons in this library.

=item B<-c|--confirm>

Without this flag set, this script will do nothing.

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
