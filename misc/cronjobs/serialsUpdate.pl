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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Koha::Script -cron;
use C4::Context;
use C4::Serials qw( GetSubscription GetNextDate ModSerialStatus );
use C4::Serials::Frequency;
use C4::Log         qw( cronlogaction );
use Koha::DateUtils qw( dt_from_string );

use Date::Calc   qw( check_date Date_to_Days );
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

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

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'help|h|?'  => \$help,
    'man'       => \$man,
    'v|verbose' => \$verbose,
    'c'         => \$confirm,
    'note:s'    => \$note,
    'no-note'   => \$nonote,
) or pod2usage(2);

pod2usage(1)               if $help;
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
     JOIN subscription
       ON (subscription.subscriptionid=serial.subscriptionid) 
     LEFT JOIN subscription_frequencies
       ON (subscription.periodicity = subscription_frequencies.id)
     WHERE serial.status = 1 
       AND subscription_frequencies.unit IS NOT NULL
       AND DATE_ADD(planneddate, INTERVAL CAST(graceperiod AS SIGNED) DAY) < NOW()
       AND subscription.closed = 0
       AND publisheddate IS NOT NULL
    }
);
$sth->execute();

while ( my $issue = $sth->fetchrow_hashref ) {
    if ($confirm) {
        ModSerialStatus(
            $issue->{serialid},    $issue->{serialseq},
            $issue->{planneddate}, $issue->{publisheddate}, $issue->{publisheddatetext},
            3,                     $note
        );
        $verbose and print "Serial issue with id=" . $issue->{serialid} . " marked late\n";
    } else {
        print "Serial issue with id=" . $issue->{serialid} . " would have been marked late\n";
    }
}

cronlogaction( { action => 'End', info => "COMPLETED" } );
