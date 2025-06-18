#!/usr/bin/perl

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
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use C4::Log             qw( cronlogaction );
use C4::Reports::Guided qw( EmailReport );

=head1 NAME

patron_emailer.pl

=head1 SYNOPSIS

patron_emailer.pl
    [--report ][--notice][--module] --library  --from

 Options:
    --help                       brief help
    --report                     report ID to use as data for email template
    --notice                     specific notice code to use
    --module                     which module to find the above notice in
    --library                    specified branch for selecting notice, will use all libraries by default
    --from                       specified email for 'from' address, report column 'from' used if not specified
    --email                      specified column to use as 'to' email address, report column 'email' used if not specified
    --verbose                    increased verbosity, will print notices and errors
    --commit                     send emails, without this script will only report

=head1 OPTIONS

=over 8

=item B<-help>

Print brief help and exit.

=item B<-man>

Print full documentation and exit.

=item B<-report>

Specify a saved SQL report id in the Koha system to user for the emails. All, and only,
    columns in the report will be available for notice template variables

=item B<-notice>

Specific notice (CODE) to select

=item B<-module>

Which module to find the specified notice in

=item B<-library>

Option to specify which branches notice should be used, 'All libraries' is used if not specified

=item B<-from>

Specify the sender address of the email, if not specified a 'from' column in the report will be used.

=item B<-email>

Specify the column to find recipient address of the email, if not specified an 'email' column in the report will be used.

=item B<-verbose>

Increased verbosity, reports successes and errors.

=item B<-commit>

Send emails, if omitted script will report as verbose.

=back

=cut

binmode( STDOUT, ":encoding(UTF-8)" );

my $help = 0;
my $report_id;
my $notice;
my $module;     #this is only for selecting correct notice - report itself defines available columns, not module
my $library;    #as above, determines which notice to use, will use 'all libraries' if not specified
my $email;      #to specify which column should be used as email in report will use 'email' from borrwers table
my $from;       #to specify from address, will expect 'from' column in report if not specified
my $verbose = 0;
my $commit  = 0;

my $error_msgs = {
    MISSING_PARAMS => "You must supply a report ID, letter module and code at minimum\n",
    NO_LETTER      => "The specified letter was not found, please check your input\n",
    NO_REPORT      => "The specified report was not found, please check your input\n",
    REPORT_FAIL    => "There was an error running the report, please check your SQL\n",
    NO_BOR_COL     => "There was no borrowernumber found for row ",
    NO_EMAIL_COL   => "There was no email found for row ",
    NO_FROM_COL    => "No from email was specified for row ",
    NO_BOR         => "There is no borrower with borrowernumber "
};

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'help|?'    => \$help,
    'report=i'  => \$report_id,
    'notice=s'  => \$notice,
    'module=s'  => \$module,
    'library=s' => \$library,
    'email=s'   => \$email,
    'from=s'    => \$from,
    'verbose'   => \$verbose,
    'commit'    => \$commit
) or pod2usage(1);
pod2usage(1) if $help;
pod2usage(1) unless $report_id && $notice && $module;

my ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
    {
        email     => $email,
        from      => $from,
        report_id => $report_id,
        module    => $module,
        code      => $notice,
        branch    => $library,
        verbose   => $verbose,
        commit    => $commit,
    }
);

foreach my $email (@$emails) {
    print "No emails will be sent!\n" unless $commit;
    if ( $verbose || !$commit ) {
        print "Email generated to $email->{to_address} from $email->{from_address}\n";
        print "Content:\n";
        print $email->{letter}->{content} . "\n";
    }
    C4::Letters::EnqueueLetter(
        {
            letter                 => $email->{letter},
            borrowernumber         => $email->{borrowernumber},
            message_transport_type => 'email',
            from_address           => $email->{from_address},
            to_address             => $email->{to_address},
        }
    ) if $commit;
}

if ( $verbose || !$commit ) {
    foreach my $error (@$errors) {
        foreach ( keys %{$error} ) {
            print "$_\n";
            if   ( $_ eq 'FATAL' ) { print $error_msgs->{ ${$error}{$_} } }
            else                   { print $error_msgs->{$_} . ${$error}{$_} . "\n" }
        }
    }
}

cronlogaction( { action => 'End', info => "COMPLETED" } );
