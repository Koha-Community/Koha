#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage;
use Getopt::Long;

use C4::Members;
use Koha::DateUtils;

my ( $help, $verbose, $not_borrowered_since, $expired_before, $category_code,
    $dryrun );
GetOptions(
    'h|help'                 => \$help,
    'v|verbose'              => \$verbose,
    'not_borrowered_since:s' => \$not_borrowered_since,
    'expired_before:s'       => \$expired_before,
    'category_code:s'        => \$category_code,
    'dry-run'                => \$dryrun,
) || pod2usage(1);

if ($help) {
    pod2usage(1);
}

$not_borrowered_since = dt_from_string( $not_borrowered_since, 'iso' )
  if $not_borrowered_since;

$expired_before = dt_from_string( $expired_before, 'iso' )
  if $expired_before;

unless ( $not_borrowered_since or $expired_before or $category_code ) {
    pod2usage(q{At least one filter is mandatory});
    exit;
}

my $members = GetBorrowersToExpunge(
    {
        not_borrowered_since => $not_borrowered_since,
        expired_before       => $expired_before,
        category_code        => $category_code,
    }
);

say "I found " . scalar(@$members) . " patrons to delete";
for my $member (@$members) {
    print "Trying to delete patron " . $member->{borrowernumber} . "... ";
    eval {
        C4::Members::MoveMemberToDeleted( $member->{borrowernumber} )
          unless $dryrun;
    };
    if ($@) {
        say "Failed, I cannot move this patron ($@)";
        next;
    }
    eval { C4::Members::DelMember( $member->{borrowernumber} ) unless $dryrun; };
    if ($@) {
        say "Failed, I cannot delete this patron ($@)";
        next;
    }
    say "OK";
}

=head1 NAME

delete_patrons - This script deletes patrons

=head1 SYNOPSIS

delete_patrons.pl [-h -v] --not_borrowered_since=`date -d '-3 month' "+%Y-%m-%d"` --expired_before=`date -d '-3 month' "+%Y-%m-%d"` --category_code=CAT

Options are cumulatives.

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<--not_borrowered_since>

Delete patrons who have not borrowered since this date.

=item B<--expired_date>

Delete patrons with an account expired before this date.

=item B<--category_code>

Delete patrons who have this category code.

=item B<--dry-run>

Dry run mode. To use with the verbose mode.

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
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along
with Koha; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=cut
