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

use vars qw($VERSION);

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
    $VERSION = 0.21;
}

=head1 NAME

runreport.pl - Run a pre-existing saved report.

=head1 SYNOPSIS

runreport.pl [ -v ] 

 Options:
   -h --help             brief help message
   -m --man              full documentation, same as --help --verbose
   -v --verbose          verbose output

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

This script is designed to run an existing Saved Report.

=head1 USAGE EXAMPLES

B<runreport.pl> 16

In the most basic form, runs the report specified by ID number from 
saved_sql.id, in this case #16, outputting the results to STDOUT.  

=head1 SEE ALSO

Reports - Guided Reports

=cut

# These variables can be set by command line options,
# initially set to default values.

my $help    = 0;
my $man     = 0;
my $verbose = 0;
my $format  = "";
my $to      = C4::Context->preference('KohaAdminEmailAddress');
my $from    = C4::Context->preference('KohaAdminEmailAddress');
my $subject = 'Koha Saved Report';

GetOptions(
    'help|?'     => \$help,
    'man'        => \$man,
    'verbose'    => \$verbose,
    'format'     => \$format,
    'to'         => \$to,
    'from'       => \$from,
) or pod2usage(2);
pod2usage( -verbose => 2 ) if ($man);
pod2usage( -verbose => 2 ) if ($help and $verbose);
pod2usage(1) if $help;

unless ($format) {
    $verbose and print STDERR "No format specified, assuming 'text'\n";
    $format = '';
    # $format = 'text';
}

unless (scalar(@ARGV)) {
    print STDERR "ERROR: No reports specified\n";
    pod2usage(1);
}
print scalar(@ARGV), " argument(s) after options: " . join(" ", @ARGV) . "\n";

my $email;

foreach my $report (@ARGV) {
    my ($sql, $type) = get_saved_report($report);
    unless ($sql) {
        warn "ERROR: No saved report $report found";
        next;
    }
    $verbose and print "SQL: $sql\n\n";
    # my $results = execute_query($sql, undef, 0, 99999, $format, $report); 
    my ($results) = execute_query($sql, undef, 0, 20, , ); 
    # execute_query(sql, , 0, 20, , )
    my $count = scalar(@$results);
    unless ($count) {
        print "NO OUTPUT: 0 results from execute_query\n";
        next;
    }
    $verbose and print "$count results from execute_query\n";
    my $message = "<table>\n" . join("\n", map {$_->{row}} @$results) . "\n</table>\n";

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
}
