#!/usr/bin/perl
#
# Copyright 2008 Liblime
# Copyright 2014 Foundations Bible College, Inc.
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

use C4::Reports::Guided; # 0.12
use C4::Context;
use Koha::Email;

use Getopt::Long qw(:config auto_help auto_version);
use Pod::Usage;
use Mail::Sendmail;
use Text::CSV_XS;
use CGI;
use Carp;
use Encode;

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

   --format=s      selects format. Choice of text, html, csv, or tsv

   -e --email      whether to use e-mail (implied by --to or --from)
   --username      username to pass to the SMTP server for authentication
   --password      password to pass to the SMTP server for authentication
   --method        method is the type of authentication. Ie. LOGIN, DIGEST-MD5, etc.
   --to=s          e-mail address to send report to
   --from=s        e-mail address to send report from
   --subject=s     subject for the e-mail


 Arguments:
   reportID        report ID Number from saved_sql.id, multiple ID's may be specified

=head1 OPTIONS

=over

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<--format>

Current options are text, html, csv, and tsv. At the moment, text and tsv both produce tab-separated tab-separated output.

=item B<--email>

Whether to use e-mail (implied by --to or --from).

=item B<--username>

Username to pass to the SMTP server for authentication

=item B<--password>

Password to pass to the SMTP server for authentication

=item B<--method>

Method is the type of authentication. Ie. LOGIN, DIGEST-MD5, etc.

=item B<--to>

E-mail address to send report to. Defaults to KohaAdminEmailAddress.

=item B<--from>

E-mail address to send report from. Defaults to KohaAdminEmailAddress.

=item B<--subject>

Subject for the e-mail message. Defaults to "Koha Saved Report"

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

=over


=item *

Allow Saved Results option.


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
my $format  = "text";
my $to      = "";
my $from    = "";
my $subject = 'Koha Saved Report';
my $separator = ',';
my $quote = '"';

my $username = undef;
my $password = undef;
my $method = 'LOGIN';

GetOptions(
    'help|?'            => \$help,
    'man'               => \$man,
    'verbose'           => \$verbose,
    'format=s'          => \$format,
    'to=s'              => \$to,
    'from=s'            => \$from,
    'subject=s'         => \$subject,
    'email'             => \$email,
    'username:s'        => \$username,
    'password:s'        => \$password,
    'method:s'          => \$method,

) or pod2usage(2);
pod2usage( -verbose => 2 ) if ($man);
pod2usage( -verbose => 2 ) if ($help and $verbose);
pod2usage(1) if $help;

unless ($format) {
    $verbose and print STDERR "No format specified, assuming 'text'\n";
    $format = 'text';
}

if ($format eq 'tsv' || $format eq 'text') {
    $format = 'csv';
    $separator = "\t";
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


foreach my $report_id (@ARGV) {
    my $report = get_saved_report($report_id);
    unless ($report) {
        warn "ERROR: No saved report $report_id found";
        next;
    }
    my $sql         = $report->{savedsql};
    my $report_name = $report->{report_name};
    my $type        = $report->{type};

    $verbose and print "SQL: $sql\n\n";
    if (defined($report_name) and $report_name ne "")
    {
        $subject = $report_name ;
    }
    else
    {
        $subject = 'Koha Saved Report';
    }
    # my $results = execute_query($sql, undef, 0, 99999, $format, $report_id);
    my ($sth) = execute_query($sql);
    # execute_query(sql, , 0, 20, , )
    my $count = scalar($sth->rows);
    unless ($count) {
        print "NO OUTPUT: 0 results from execute_query\n";
        next;
    }
    $verbose and print "$count results from execute_query\n";

    my $message;
    if ($format eq 'html') {
        my $cgi = CGI->new();
        my @rows = ();
        while (my $line = $sth->fetchrow_arrayref) {
            foreach (@$line) { defined($_) or $_ = ''; }    # catch undef values, replace w/ ''
            push @rows, $cgi->TR( join('', $cgi->td($line)) ) . "\n";
        }
        $message = $cgi->table(join "", @rows);
    } elsif ($format eq 'csv') {
        my $csv = Text::CSV_XS->new({
            quote_char  => $quote,
            sep_char    => $separator,
            });
        while (my $line = $sth->fetchrow_arrayref) {
            $csv->combine(@$line);
#            foreach (@$line) {
#                defined($_) or $_ = '';
#                $_ =~ s/$quote/\\$quote/g;
#                $_ = "$quote$_$quote";
#            }    # catch undef values, replace w/ ''
#            $message .= join ($separator, @$line) . "\n";
            $message .= $csv->string() . "\n";
        }
    }
    if ($email){
        my $email = Koha::Email->new();
        my %mail;
        if ($format eq 'html') {
                $message = "<html><head><style>tr:nth-child(2n+1) { background-color: #ccc;}</style></head><body>$message</body></html>";
           %mail = $email->create_message_headers({
              to      => $to,
              from    => $from,
              contenttype => 'text/html',
              subject => encode('utf8', $subject ),
              message => encode('utf8', $message )
           }
          );
        } else {
          %mail = $email->create_message_headers ({
              to      => $to,
              from    => $from,
              subject => encode('utf8', $subject ),
              message => encode('utf8', $message )
          }
          );
        }
        $mail{'Auth'} = {user => $username, pass => $password, method => $method} if $username;
        sendmail(%mail) or carp 'mail not sent:' . $Mail::Sendmail::error;
    } else {
        print $message;
    }
    # my @xmlarray = ... ;
    # my $url = "/cgi-bin/koha/reports/guided_reports.pl?phase=retrieve%20results&id=$id";
    # my $xml = XML::Dumper->new()->pl2xml( \@xmlarray );
    # store_results($id,$xml);
}
