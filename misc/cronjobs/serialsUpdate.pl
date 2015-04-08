#!/usr/bin/perl

# Copyright 2008 SARL Biblibre
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use C4::Serials;

use Date::Calc qw/Date_to_Days check_date/;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

serialsUpdate.pl - change status of serial issues that are late

=head1 SYNOPSIS

serialsUpdate.pl [ -h | -m ][ -v ] -c ][ --note "you are late" ][ --no-note ]

 Options:
   --h --help -?   Brief help message
   --man           Full documentation
   --verbose -v    Verbose mode
   -c              Confirm: without this option, the script will report on affected serial
                   issues without modifying database
   --note          Note set on affected serial issues, by default "Automatically set to late"
   --no-note       Do not set a note on affected serial issues

=cut

my $dbh = C4::Context->dbh;

my $man     = 0;
my $help    = 0;
my $confirm = 0;
my $verbose = 0;
my $note    = '';
my $nonote  = 0;

GetOptions(
    'help|h|?'  => \$help,
    'man'       => \$man,
    'v|verbose' => \$verbose,
    'c'         => \$confirm,
    'note:s'    => \$note,
    'no-note'   => \$nonote,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

$verbose and !$confirm and print "### Database will not be modified ###\n";

if ( $note && $nonote ) {
    $note = '';
}
if ( !$note && !$nonote ) {
    $note = 'Automatically set to late';
}
$verbose and print $note ? "Note : $note\n" : "No note\n";

# select all serials with not "irregular" periodicity that are late
my $sth = $dbh->prepare(
    q{
     SELECT
       serial.serialid,
       serial.serialseq,
       serial.planneddate,
       serial.publisheddate,
       subscription.subscriptionid
     FROM serial 
     LEFT JOIN subscription 
       ON (subscription.subscriptionid=serial.subscriptionid) 
     LEFT JOIN subscription_frequencies
       ON (subscription.periodicity = subscription_frequencies.id)
     WHERE serial.status = 1 
       AND subscription_frequencies.unit IS NOT NULL
       AND DATE_ADD(planneddate, INTERVAL CAST(graceperiod AS SIGNED) DAY) < NOW()
       AND subscription.closed = 0
    }
);
$sth->execute();

while ( my $issue = $sth->fetchrow_hashref ) {

    my $subscription = &GetSubscription( $issue->{subscriptionid} );
    my $publisheddate  = $issue->{publisheddate};

    if ( $subscription && $publisheddate && $publisheddate ne "0000-00-00" ) {
        my $nextpublisheddate = GetNextDate( $subscription, $publisheddate );
        my $today = format_date_in_iso( C4::Dates->new()->output() );

        if ( $nextpublisheddate && $today ) {
            my ( $year,  $month,  $day )  = split( /-/, $nextpublisheddate );
            my ( $tyear, $tmonth, $tday ) = split( /-/, $today );
            if (   check_date( $year, $month, $day )
                && check_date( $tyear, $tmonth, $tday )
                && Date_to_Days( $year, $month, $day ) <
                Date_to_Days( $tyear, $tmonth, $tday ) )
            {
                $confirm
                  and ModSerialStatus( $issue->{serialid}, $issue->{serialseq},
                    $issue->{planneddate}, $issue->{publisheddate},
                    3, $note );
                $verbose
                  and print "Serial issue with id=" . $issue->{serialid} . " updated\n";
            }
        }
        else {
            $verbose
              and print "Error with serial("
              . $issue->{serialid}
              . ") has no existent subscription("
              . $issue->{subscriptionid}
              . ") attached or planneddate is wrong\n";
        }
    }
}
