#!/usr/bin/perl

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

use Modern::Perl;
use C4::Context;
use Net::SFTP::Foreign;
use C4::Log qw( cronlogaction );
use Koha::Email;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use Carp qw( carp );

=head1 NAME

sftp_file.pl - SFTP a file to a remote server

=head1 SYNOPSIS

sftp_file.pl [ -h | -m ] [ -v ] host user pass upload_dir port file email

 Options:
   -h --help       brief help message
   -m --man        full documentation, same as --help --verbose
   -v --verbose    verbose output
   --host          SFTP host to upload to
   --user          SFTP user
   --pass          SFTP password
   --upload_dir    Directory on SFTP host to upload to
   --port          SFTP upload port to use - falls back to port 22
   --file          File to SFTP to host
   --email         Email address to receive confirmation of SFTP upload success or failure

=head1 OPTIONS

=over

=item B<--help>

Print brief help and exit.

=item B<--man>

Print full documentation and exit.

=item B<--verbose>

Increased verbosity, reports successes and errors.

=item B<--host>

Remote server host to SFTP file to.

=item B<--user>

Username credential to authenticate to remote host.

=item B<--pass>

Password credential to authenticate to remote host.

=item B<--upload_dir>

Directory on remote host to SFTP file to.

=item B<--port>

Remote host port to use for SFTP upload. Koha will fallback to port 22 if this parameter is not defined.

=item B<--file>

File to SFTP to remote host.

=item B<--email>

Email address to receive the confirmation if the SFTP upload was a success or failure.

=back

=head1 DESCRIPTION

This script is designed to SFTP files.

=head1 DESCRIPTION

This script is designed to SFTP files to a remote server.

=head1 USAGE EXAMPLES

B<sftp_file.pl --host test.com --user test --pass 123cne --upload_dir uploads --file /tmp/test.mrc>

In this example the script will upload /tmp/test.mrc on the Koha server to the test.com remote host using the username:password of test:123cne. The file will be SFTP to the uploads directory.

=head1 TO DO

=back

=cut

# These variables can be set by command line options,
# initially set to default values.

my $help                 = 0;
my $man                  = 0;
my $verbose              = 0;
my $host                 = undef;
my $user                 = undef;
my $pass                 = undef;
my $upload_dir           = undef;
my $port                 = 22;
my $file                 = 0;
my $email                = 0;
my $admin_address        = undef;
my $status_email         = undef;
my $status_email_message = undef;
my $sftp_status          = undef;

my $command_line_options = join(" ",@ARGV);

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'verbose'        => \$verbose,
    'host=s'         => \$host,
    'user=s'         => \$user,
    'pass=s'         => \$pass,
    'upload_dir=s'   => \$upload_dir,
    'port=s'         => \$port,
    'file=s'         => \$file,
    'email=s'        => \$email,
) or pod2usage(2);
pod2usage( -verbose => 2 ) if ($man);
pod2usage( -verbose => 2 ) if ($help and $verbose);
pod2usage(1) if $help;

cronlogaction({ info => $command_line_options });

# Check we have all the SFTP details we need
if ( !$user || !$pass || !$host || !$upload_dir ) {
    pod2usage(q|Please provide details for sftp username, password, upload directory, and host|);
}

# Prepare the SFTP connection
my $sftp = Net::SFTP::Foreign->new(
    host           => $host,
    user           => $user,
    password       => $pass,
    port           => $port,
    timeout        => 10,
    stderr_discard => 1,
);
$sftp->die_on_error( "Cannot ssh to $host" . $sftp->error );

# Change to remote directory
$sftp->setcwd( $upload_dir )
    or return warn "Cannot change remote dir : $sftp->error\n";

# If the --email parameter is defined then prepare sending an email confirming the success
# or failure of the SFTP
if ( $email ) {
    if ( C4::Context->preference('KohaAdminEmailAddress') ) {
        $admin_address = C4::Context->preference('KohaAdminEmailAddress');
    }

    if ( !Koha::Email->is_valid($email) ) {
        return warn "The email address you defined in the --email parameter is invalid\n";
    }

    $status_email = Koha::Email->new(
        {
            to        => $email,
            from      => $admin_address,
            subject   => '[OCLC] ' . C4::Context->config('database') . ' ' . $sftp_status,
        }
    );
}

# Do the SFTP upload
open my $fh, '<', $file;
if (
    $sftp->put(
        $fh, $file,
            callback => sub { my ( $sftp, $data, $offset, $size ) = @_; warn "$offset of $size bytes transferred\n"; }
        )
) {
    $sftp_status = 'successful';
    # Send success email
    if ( $email ) {
        $status_email_message = "OCLC upload was successful";
    }
    close $fh;
} else {
    $sftp_status = 'failed';
    # Send failure email
    if ( $email ) {
        $status_email_message = "OCLC upload failed\nOCLC error: " . $sftp->error;
    }
}

# Send email confirming the success or failure of the SFTP
if ( $email ) {
    $status_email->text_body($status_email_message);
    my $smtp_server = Koha::SMTP::Servers->get_default;
    $email->transport( $smtp_server->transport );
    try {
        $email->send_or_die;
    }
    catch {
        carp "Mail not sent: $_";
    };
}

cronlogaction({ action => 'End', info => "COMPLETED" });
