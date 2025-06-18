#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage   qw( pod2usage );
use Getopt::Long qw( GetOptions );

use Koha::Script -cron;
use C4::Members     qw( GetBorrowersToExpunge );
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use C4::Log qw( cronlogaction );

my (
    $help,          $verbose,    $not_borrowed_since, $expired_before,            $last_seen,
    @category_code, $branchcode, $file,               @without_restriction_types, $confirm
);

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'h|help'                     => \$help,
    'v|verbose'                  => \$verbose,
    'not_borrowed_since:s'       => \$not_borrowed_since,
    'expired_before:s'           => \$expired_before,
    'last_seen:s'                => \$last_seen,
    'category_code:s'            => \@category_code,
    'library:s'                  => \$branchcode,
    'file:s'                     => \$file,
    'without_restriction_type:s' => \@without_restriction_types,
    'c|confirm'                  => \$confirm,
) || pod2usage(1);

if ($help) {
    pod2usage(1);
}

$not_borrowed_since = dt_from_string( $not_borrowed_since, 'iso' )
    if $not_borrowed_since;

$expired_before = dt_from_string( $expired_before, 'iso' )
    if $expired_before;

if ( $last_seen and not C4::Context->preference('TrackLastPatronActivityTriggers') ) {
    pod2usage(q{The option --last_seen will be ineffective if preference TrackLastPatronActivityTriggers is empty});
}

unless ( $not_borrowed_since or $expired_before or $last_seen or @category_code or $branchcode or $file ) {
    pod2usage(q{At least one filter is mandatory});
}

if ( @without_restriction_types > 0 ) {
    my %restriction_types;
    @restriction_types{ map { $_->code() } Koha::Patron::Restriction::Types->search()->as_list } = ();

    my @invalid_restriction_types;
    foreach my $restriction_type (@without_restriction_types) {
        if ( !exists $restriction_types{$restriction_type} ) {
            push @invalid_restriction_types, $restriction_type;
        }
    }
    if ( @invalid_restriction_types > 0 ) {
        die 'Invalid restriction type(s): ' . join ', ', @invalid_restriction_types;
    }
}

my @file_members;
if ($file) {
    open( my $fh, '<:encoding(UTF-8)', $file ) or die "Could not open file $file' $!";
    while ( my $line = <$fh> ) {
        chomp($line);
        my %fm     = ( 'borrowernumber' => $line );
        my $fm_ref = \%fm;
        push @file_members, $fm_ref;
    }
    close $fh;
}

my $members;
if ( $not_borrowed_since or $expired_before or $last_seen or @category_code or $branchcode ) {
    $members = GetBorrowersToExpunge(
        {
            not_borrowed_since        => $not_borrowed_since,
            expired_before            => $expired_before,
            last_seen                 => $last_seen,
            category_code             => \@category_code,
            branchcode                => $branchcode,
            without_restriction_types => \@without_restriction_types
        }
    );
}

if ( $members and @file_members ) {
    my @filtered_members;
    for my $member (@$members) {
        for my $fm (@file_members) {
            if ( $member->{borrowernumber} eq $fm->{borrowernumber} ) {
                push @filtered_members, $fm;
            }
        }
    }
    $members = \@filtered_members;
}

if ( !defined $members and @file_members ) {
    $members = \@file_members;
}

unless ($confirm) {
    say "Doing a dry run; no patron records will actually be deleted.";
    say "Run again with --confirm to delete the records.";
    $verbose ||= 1;
}

say scalar(@$members) . " patrons match conditions" if $verbose;

my $anonymous_patron = C4::Context->preference("AnonymousPatron");
my $deleted          = 0;
for my $member (@$members) {
    print "Testing that we can delete patron $member->{borrowernumber}... "
        if $verbose;

    my $borrowernumber = $member->{borrowernumber};
    my $patron         = Koha::Patrons->find($borrowernumber);
    unless ($patron) {
        say "Cannot delete: Patron with borrowernumber $borrowernumber does not exist";
        next;
    }
    if ( my $charges = $patron->account->non_issues_charges ) {    # And what if we owe to this patron?
        say "Cannot delete patron $borrowernumber: patron has $charges in fines" if $verbose;
        next;
    }

    if ($anonymous_patron) {
        if ( $patron->id eq $anonymous_patron ) {
            say "Cannot delete patron $borrowernumber: patron is AnonymousPatron";
            next;
        }
    }

    if ($confirm) {
        my $deleted = eval { $patron->move_to_deleted; };
        if ( $@ or not $deleted ) {
            say "Cannot delete patron $borrowernumber, cannot move it" . ( $@ ? ": ($@)" : "" ) if $verbose;
            next;
        }

        eval { $patron->delete };
        if ($@) {
            say "Cannot delete patron $borrowernumber: $@)";
            next;
        }
    }
    $deleted++;
    say "OK" if $verbose;
}

say $confirm ? "$deleted patrons deleted" : "$deleted patrons would have been deleted" if $verbose;

cronlogaction( { action => 'End', info => "COMPLETED" } );

=head1 NAME

delete_patrons - This script deletes patrons

=head1 SYNOPSIS

delete_patrons.pl [-h|--help] [-v|--verbose] [-c|--confirm] [--not_borrowed_since=DATE] [--expired_before=DATE] [--last-seen=DATE] [--category_code=CAT] [--category_code=CAT ...] [--library=LIBRARY] [--file=FILE] [--without_restriction_type=TYPE] [--without_restriction_type=TYPE ...]

Dates should be in ISO format, e.g., 2013-07-19, and can be generated
with `date -d '-3 month' --iso-8601`.

The options to select the patron records to delete are cumulative.  For
example, supplying both --expired_before and --library specifies that
that patron records must meet both conditions to be selected for deletion.

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<--not_borrowed_since>

Delete patrons who have not borrowed since this date.

NOTE: Patrons who have all their old checkouts anonymized will
have an empty circulation history and be deleted if this option is
used. Anonymization can happen because the patron has
borrowers.privacy = 2, through cronjobs doing anonymization
or by the patron choosing to anonymize their history in the
OPAC.

=item B<--expired_before>

Delete patrons with an account expired before this date.

=item B<--last_seen>

Delete patrons who have not been active since this date.

The system preference TrackLastPatronActivityTriggers must contain at least one trigger to use this option.

=item B<--category_code>

Delete patrons who have this category code.

Can be used multiple times for additional category codes.

=item B<--library>

Delete patrons in this library.

=item B<--file>

Delete patrons whose borrower numbers are in this file.  If other criteria are defined
it will only delete those in the file that match those criteria.

=item B<--without_restriction_type>

Delete patrons who DO NOT have a restriction with this restriction type.

Can be used multiple times for additional restriction types.

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

=cut
