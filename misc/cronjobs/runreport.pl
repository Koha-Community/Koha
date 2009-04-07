#!/usr/bin/perl -w
#
# Copyright 2008 Liblime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use C4::Reports::Guided; # 0.12
use C4::Context;

use Getopt::Long qw(:config auto_help auto_version);
use Pod::Usage;
use Mail::Sendmail;
use Text::CSV_XS;
use CGI;

use vars qw($VERSION);

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
    $VERSION = 0.22;
}

=head1 NAME

runreport.pl - Run pre-existing saved reports

=head1 SYNOPSIS

runreport.pl [ -h | -m ] [ -v ] reportID [ reportID ... ]

 Options:
   -h --help       brief help message
   -m --man        full documentation, same as --help --verbose
   -v --verbose    verbose output

 Arguments:
   reportID        report ID Number from saved_sql.id, multiple ID's may be specified

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=back

=head1 DESCRIPTION

This script is designed to run existing Saved Reports.

=head1 USAGE EXAMPLES

B<runreport.pl 16>

In the most basic form, runs the report specified by ID number from 
saved_sql.id, in this case #16, outputting the results to STDOUT.  

B<runreport.pl 16 17>

Same as above, but also runs report #17. 

=head1 TO DO

=over 8

 ~ Complete testing for Sendmail related options: --email, --to, and --from.
 ~ Allow Saved Results option.
 ~ Possible --format option for CSV or tab-delimited output.

=back

=head1 SEE ALSO

Reports - Guided Reports

=cut

# These variables can be set by command line options,
# initially set to default values.

my $help    = 0;
my $man     = 0;
my $verbose = 0;
my $email   = 0;
my $format  = "";
my $to      = "";
my $from    = "";
my $subject = 'Koha Saved Report';

GetOptions(
    'help|?'     => \$help,
    'man'        => \$man,
    'verbose'    => \$verbose,
    'format'     => \$format,
    'to'         => \$to,
    'from'       => \$from,
    'email'      => \$email,
) or pod2usage(2);
pod2usage( -verbose => 2 ) if ($man);
pod2usage( -verbose => 2 ) if ($help and $verbose);
pod2usage(1) if $help;

unless ($format) {
    $verbose and print STDERR "No format specified, assuming 'text'\n";
    $format = '';
    # $format = 'text';
}

if ($to or $from or $email) {
    $email = 1;
    $from or $from = C4::Context->preference('KohaAdminEmailAddress');
    $to   or $to   = C4::Context->preference('KohaAdminEmailAddress');
}

unless (scalar(@ARGV)) {
    print STDERR "ERROR: No reportID(s) specified\n";
    pod2usage(1);
}
($verbose) and print scalar(@ARGV), " argument(s) after options: " . join(" ", @ARGV) . "\n";


foreach my $report (@ARGV) {
    my ($sql, $type) = get_saved_report($report);
    unless ($sql) {
        warn "ERROR: No saved report $report found";
        next;
    }
    $verbose and print "SQL: $sql\n\n";
    # my $results = execute_query($sql, undef, 0, 99999, $format, $report); 
    my ($sth) = execute_query($sql);
    # execute_query(sql, , 0, 20, , )
    my $count = scalar($sth->rows);
    unless ($count) {
        print "NO OUTPUT: 0 results from execute_query\n";
        next;
    }
    $verbose and print "$count results from execute_query\n";

    my $cgi = CGI->new();
    my @rows = ();
    while (my $line = $sth->fetchrow_arrayref) {
        foreach (@$line) { defined($_) or $_ = ''; }    # catch undef values, replace w/ ''
        push @rows, $cgi->TR( join('', $cgi->td($line)) ) . "\n";
    }
    my $message = $cgi->table(join "", @rows);

    if ($email){
        my %mail = (
            To      => $to,
            From    => $from,
            Subject => $subject,
            Message => $message 
        );
        sendmail(%mail) or warn "mail not sent";
    } else {
        print $message;
    }
    # my @xmlarray = ... ;
    # my $url = "/cgi-bin/koha/reports/guided_reports.pl?phase=retrieve%20results&id=$id";
    # my $xml = XML::Dumper->new()->pl2xml( \@xmlarray );
    # store_results($id,$xml);
}
