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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Script -cron;
use C4::Reports::Guided qw( store_results execute_query );
use Koha::Reports;
use C4::Context;
use Koha::Email;
use Koha::DateUtils qw( dt_from_string );
use Koha::File::Transports;
use Koha::SMTP::Servers;

use Text::CSV::Encoded;
use CGI       qw ( -utf8 );
use Carp      qw( carp );
use Encode    qw( decode );
use JSON      qw( to_json );
use Try::Tiny qw( catch try );

=head1 NAME

runreport.pl - Run pre-existing saved reports

=head1 SYNOPSIS

runreport.pl [ -h | -m ] [ -v ] reportID [ reportID ... ]

 Options:
   -h --help        brief help message
   -m --man         full documentation, same as --help --verbose
   -v --verbose     verbose output

   --format=s       selects format. Choice of text, html, csv or tsv

   -e --email       whether to use e-mail (implied by --to or --from)
   --send_empty     whether to send an email when there are no results from the
                    specified report
   -a --attachment  additionally attach the report as a file. cannot be used with html format
   -n --filename    (ftp/sftp only) optionally specify the name to use when uploading the file
   --username       username to pass to the SMTP server for authentication
   --password       password to pass to the SMTP server for authentication
   --method         method is the type of authentication. Ie. LOGIN, DIGEST-MD5, etc.
   --to=s           e-mail address to send report to
   --from=s         e-mail address to send report from
   --subject=s      subject for the e-mail
   --param=s        parameters for the report
   --store-results  store the result of the report
   --sftp-dest-id=i the ID of the target FTP/SFTP server, if you wish to upload the report
   --separator      separator character for csv
   --quote          quote character for csv
   --csv-header     add column names as first line of csv output


 Arguments:
   reportID         report ID Number from saved_sql.id, multiple ID's may be specified

=head1 OPTIONS

=over

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<--format>

Current options are text, html, csv, and tsv. At the moment, text and tsv both produce tab-separated output.

=item B<--separator>

Separator character, only for csv format. Default to comma.

=item B<--quote>

Quote character, only for csv format. Default to double quote.
Empty string is allowed.

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

=item B<--param>

Repeatable, should provide one param per param requested for the report.
Report params are not combined as on the staff side, so you may need to repeat
params.

=item B<--store-results>

Store the result of the report into the saved_reports DB table.

To access the results, go on Reports > Guided reports > Saved report.

=back

=head1 DESCRIPTION

This script is designed to run existing Saved Reports.

=head1 USAGE EXAMPLES

B<runreport.pl 16>

In the most basic form, runs the report specified by ID number from 
saved_sql.id, in this case #16, outputting the results to STDOUT.  

B<runreport.pl 16 17>

Same as above, but also runs report #17. 

=head1 SEE ALSO

Reports - Guided Reports

=cut

binmode STDOUT, ":encoding(UTF-8)";

my $opt = Koha::Script->describe_options(
    'Run one or more saved reports, optionally emailing or uploading the output.

%c %o reportID [ reportID ... ]',
    [ 'verbose|v',   'verbose output' ],
    [ 'format=s',    'output format: text, html, csv, or tsv', { default => 'text' } ],
    [ 'separator=s', 'separator character for csv output (default: comma)' ],
    [ 'quote=s',     'quote character for csv output; empty string allowed (default: double quote)' ],
    [ 'to=s',   'email address to send the report to (defaults to KohaAdminEmailAddress)',   { implies => 'email' } ],
    [ 'from=s', 'email address to send the report from (defaults to KohaAdminEmailAddress)', { implies => 'email' } ],
    [ 'subject=s',      'subject for the email (defaults to the report name, or "Koha Saved Report")' ],
    [ 'param=s@',       'parameter for the report; repeat for multiple parameters', { default => [] } ],
    [ 'email|e',        'send the report by email (implied by --to or --from)' ],
    [ 'send_empty',     'send an email even when the report has no results' ],
    [ 'sftp-dest-id=i', 'ID of the target FTP/SFTP server to upload the report to' ],
    [ 'attachment|a',   'additionally attach the report as a file; cannot be used with html format' ],
    [ 'filename|n:s',   '(ftp/sftp only) name to use when uploading the file' ],
    [ 'username:s',     'username to pass to the SMTP server for authentication' ],
    [ 'password:s',     'password to pass to the SMTP server for authentication' ],
    [ 'method:s', 'authentication method to pass to the SMTP server, e.g. LOGIN, DIGEST-MD5', { default => 'LOGIN' } ],
    [ 'store-results', 'store the result of the report in the saved_reports table' ],
    [ 'csv-header',    'add column names as the first line of csv output' ],
    {
        args   => { min => 1, name => 'reportID', variadic => 1 },
        epilog => "Arguments:\n"
            . "  reportID  report ID from saved_sql.id; multiple IDs may be given\n\n"
            . "Examples:\n"
            . "  %c 16\n    Run report #16, outputting the results to STDOUT.\n\n"
            . "  %c 16 17\n    Run reports #16 and #17.\n",
    },
);

my @report_ids = @ARGV;

my $verbose       = $opt->verbose;
my $format        = $opt->format;
my $to            = $opt->to      // '';
my $from          = $opt->from    // '';
my $subject       = $opt->subject // '';
my @params        = @{ $opt->param };
my $send_email    = $opt->email;
my $send_empty    = $opt->send_empty;
my $sftp_dest_id  = $opt->sftp_dest_id // 0;
my $attachment    = $opt->attachment;
my $filename      = $opt->filename;
my $username      = $opt->username;
my $password      = $opt->password;
my $method        = $opt->method;
my $store_results = $opt->store_results;
my $csv_header    = $opt->csv_header;

if ( $format ne 'csv' ) {
    print STDERR "Cannot specify separator if not using CSV format\n" if $opt->separator;
    print STDERR "Cannot specify quote if not using CSV format\n"     if $opt->quote;
}

my $separator = ( $format eq 'csv' && $opt->separator ) ? $opt->separator : ',';
my $quote     = ( $format eq 'csv' && $opt->quote )     ? $opt->quote     : '"';

if ( $format eq 'tsv' || $format eq 'text' ) {
    $format    = 'csv';
    $separator = "\t";
}

if ($send_email) {
    $from ||= C4::Context->preference('KohaAdminEmailAddress');
    $to   ||= C4::Context->preference('KohaAdminEmailAddress');
}

($verbose) and print scalar(@report_ids), " argument(s) after options: " . join( " ", @report_ids ) . "\n";

my $today = dt_from_string();
my $date  = $today->ymd();

foreach my $report_id (@report_ids) {
    my $report = Koha::Reports->find($report_id);
    unless ($report) {
        warn "ERROR: No saved report $report_id found";
        next;
    }
    my $sql         = $report->savedsql;
    my $report_name = $report->report_name;
    my $type        = $report->type;

    $verbose and print "SQL: $sql\n\n";
    if ( $subject eq "" ) {
        if ( defined($report_name) and $report_name ne "" ) {
            $subject = $report_name;
        } else {
            $subject = 'Koha Saved Report';
        }
    }

    # convert SQL parameters to placeholders
    my $params_needed = ( $sql =~ s/(<<[^>]+>>)/\?/g );
    die( "You supplied " . scalar @params . " parameter(s) and $params_needed are required by the report" )
        if scalar @params != $params_needed;

    my ($sth) = execute_query(
        {
            sql        => $sql,
            sql_params => \@params,
            report_id  => $report_id,
        }
    );
    my $count = scalar( $sth->rows );
    unless ( $count || $send_empty ) {
        print "NO OUTPUT: 0 results from execute_query\n";
        next;
    }
    $verbose and print "$count results from execute_query\n";

    my $message;
    my @rows_to_store;
    if ( !$count ) {
        $message = "No results were returned for the report\n";
    } elsif ( $format eq 'html' ) {
        my $cgi = CGI->new();
        my @rows;
        while ( my $line = $sth->fetchrow_arrayref ) {
            foreach (@$line) { defined($_) or $_ = ''; }    # catch undef values, replace w/ ''
            push @rows,          $cgi->TR( join( '', $cgi->td($line) ) ) . "\n";
            push @rows_to_store, [@$line] if $store_results;
        }
        $message = $cgi->table( join "", @rows );
    } elsif ( $format eq 'csv' ) {
        my $csv = Text::CSV::Encoded->new(
            {
                encoding_out => 'utf8',
                binary       => 1,
                quote_char   => $quote,
                sep_char     => $separator,
                formula      => 'empty',
            }
        );

        if ($csv_header) {
            my @fields = map { decode( 'utf8', $_ ) } @{ $sth->{NAME} };
            $csv->combine(@fields);
            $message .= $csv->string() . "\n";
            push @rows_to_store, [@fields] if $store_results;
        }

        while ( my $line = $sth->fetchrow_arrayref ) {
            $csv->combine(@$line);
            $message .= $csv->string() . "\n";
            push @rows_to_store, [@$line] if $store_results;
        }
        $message = Encode::decode_utf8($message);
    }
    if ( $store_results && $count ) {
        my $json = to_json( \@rows_to_store );
        C4::Reports::Guided::store_results( $report_id, $json );
    }
    if ($send_email) {

        my $email = Koha::Email->new(
            {
                to      => $to,
                from    => $from,
                subject => $subject,
            }
        );

        if ( $format eq 'html' ) {
            $message =
                "<html><head><style>tr:nth-child(2n+1) { background-color: #ccc;}</style></head><body>$message</body></html>";
            $email->html_body($message);
        } else {
            $email->text_body($message);
        }

        $email->attach(
            Encode::encode_utf8($message),
            content_type => "text/$format",
            name         => "report$report_id-$date.$format",
            disposition  => 'attachment',
        ) if $attachment;

        my $smtp_server = Koha::SMTP::Servers->get_default;
        $smtp_server->set(
            {
                user_name => $username,
                password  => $password,
            }
        ) if $username;

        $email->transport( $smtp_server->transport );
        try {
            $email->send_or_die;
        } catch {
            carp "Mail not sent: $_";
        };
    }

    if ($sftp_dest_id) {
        my $sftp_server = Koha::File::Transports->find($sftp_dest_id);

        die("ERROR:\tSupplied FTP/SFTP Server doesn't exist")
            unless ($sftp_server);

        my $upload_directory = $sftp_server->upload_directory;
        my $filename_to_use  = $filename || "report$report_id-$date.$format";

        open my $fh, "<", \$message;
        die("ERROR:\tMessage supplied is empty, or not suitable for upload")
            unless ($fh);

        die("ERROR:\tNo upload directory specified in config")
            unless ($upload_directory);

        # Use simplified API - automatic connection and directory management
        my $result = $sftp_server->upload_file( $fh, $filename_to_use, { path => $upload_directory } );

        die("ERROR:\tUnable to upload report to server")
            unless ($result);
    }

    if ( !$send_email && !$sftp_dest_id ) {
        print $message;
    }
}

