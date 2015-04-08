#!/usr/bin/perl
#
# Copyright (C) 2011 ByWater Solutions
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

use Getopt::Long;
use Pod::Usage;

use C4::Context;

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

die
  "TalkingTechItivaPhoneNotification system preference not activated... dying\n"
  unless ( C4::Context->preference("TalkingTechItivaPhoneNotification") );

# Database handle
my $dbh = C4::Context->dbh;

# Benchmarking
my $updated = 0;
my $total   = 0;

# Options
my $verbose;
my $help;
my $infile;

GetOptions(
    'i|input:s' => \$infile,
    'v'         => \$verbose,
    'help|h'    => \$help,
);

die pod2usage() if $help;

# initialize the input data, either file or query
if ( defined $infile ) {
    open( my $IN, '<', $infile ) || die("Cannot open input file");
    print "Opening $infile\n" if ( defined $verbose );

    while (<$IN>) {

        # data should take to form "<Transaction ID>","<SUCCESS or FAIL>"
        s/["\n]//g;    # strip quotes and newlines: they're unnecessary
        my @data   = split(/,/);
        my $result = update_notice(@data);
        $updated += $result;
        $total++;
    }
}
else {
    die pod2usage( -verbose => 1 );
}

print "$updated of $total results lines processed\n" if ( defined $verbose );

=head1 NAME

TalkingTech_itiva_inbound.pl

=head1 SYNOPSIS

  TalkingTech_itiva_inbound.pl
  TalkingTech_itiva_inbound.pl -v --input=/tmp/talkingtech/results.csv

Script to process received Results files for Talking Tech i-tiva
phone notification system.

=over 8

=item B<--help> B<-h>

Prints this help

=item B<-v>

Provide verbose log information.

=item B<--input> B<-i>

REQUIRED. Path to incoming results file.

=back

=cut

sub update_notice {
    my $message_id = shift;
    my $status     = shift;

    if ( $status =~ m/SUCCESS/i ) {
        $status = 'sent';
    }
    elsif ( $status =~ m/FAIL/i ) {
        $status = 'failed';
    }
    else {
        warn "unexpected status $status for message ID $message_id\n";
        return 0;
    }

    my $query =
"UPDATE message_queue SET status = ? WHERE message_id = ? and status = 'pending'";
    my $sth = $dbh->prepare($query);

    my $result = $sth->execute( $status, $message_id );
    return $result;
}
