#/usr/bin/perl
use warnings;
use strict;
use utf8;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

use Net::SFTP::Foreign;
use Net::FTP;

sub WriteiPostEPL {
    my %hash = @_;
    my $letters;

    # Replace unconverted characters  with ? to prevent \x{...} mess in letter.
    open ( LETTERS, ">encoding(latin1)", \$letters );
    print LETTERS $hash{'epl'};
    close LETTERS;

    $letters =~ s/\\x\{....\}/?/g;

    # Make target directory if needed
    my $stagingdir =
      C4::Context->config('ksmessaging')->{'letters'}->{'branches'}->{"$hash{'branchconfig'}"}->{'stagingdir'};

    unless ( -d "$stagingdir" ) {
        mkdir "$stagingdir" or die localtime . ": Can't create directory $stagingdir.";
    }

    # Then write to disk
    open ( LETTERS, ">encoding(latin1)", $stagingdir . '/' . $hash{'filename'} )
      or die localtime . ": Can't write to " . $stagingdir . '/' . $hash{'filename'} . ".";

    print LETTERS $letters;
    close LETTERS;
}

sub WriteiPostArchive {
    my %hash=@_;

    # Determine and make target directory if needed
    my $stagingdir = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'stagingdir'};
    unless ( -d "$stagingdir" ) {
        mkdir "$stagingdir" or die localtime . ": Can't create directory $stagingdir.";
    }

    my $zip = Archive::Zip->new();

    # If the archive already exists, we'll read it first for appending the new files to it
    if ( -e $stagingdir . '/' . $hash{'filename'} ) {
        $zip->read($stagingdir . '/' . $hash{'filename'}) == AZ_OK or die localtime . " Can't read existing archive " . $stagingdir . "/" . $hash{'filename'} . '.';
    }

    # Place data inside the archive as files
    $zip->addString ( $hash{'pdf'}, $hash{'pdfname'} );
    $zip->addString ( $hash{'xml'}, $hash{'xmlname'} );

    # Create archive or overwrite the old one with the new files appended
    if ( -e $stagingdir . '/' . $hash{'filename'} ) {
        $zip->overwrite() == AZ_OK or die localtime . ": Can't add files to " . $stagingdir . '/' . $hash{'filename'} . '.';
    } else {
        $zip->writeToFileNamed($stagingdir . '/' . $hash{'filename'}) == AZ_OK or die localtime . ": Can't create archive " . $stagingdir . '/' . $hash{'filename'} . '.';
    }
}

sub GetTransferConfig {
    my %hash = @_;
    my %config;

    $config{"$_"} = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'filetransfer'}->{"$_"}
    foreach ( qw ( host port remotedir user password protocol ) );

    return %config;
}

sub FileTransfer {
    my %hash = @_;

    # This defines where the files to be transferred were put
    my $stagingdir = C4::Context->config('ksmessaging')->{"$hash{'interface'}"}->{'branches'}->{"$hash{'branchconfig'}"}->{'stagingdir'};

    my %config = GetTransferConfig('interface' => "$hash{'interface'}", 'branchconfig' => "$hash{'branchconfig'}");
    $config{'remotedir'}  = '~' unless $config{'remotedir'}; # Default dir

    if ( $config{'host'} && $config{'user'} && $config{'password'} && $config{'protocol'} ) {
        # Tell the user what is happening
        print STDERR "\nSending $stagingdir/$hash{'filename'} to $config{'user'}\@$config{'host'}:$config{'remotedir'} port $config{'port'} with $config{'protocol'}\n";

        if ( $config{'protocol'} eq 'sftp' ) {
            $config{'port'} = 22  unless $config{'port'}; # Default port for sftp

            # Connect and send with SFTP
            my $sftp = Net::SFTP::Foreign->new ( 'host'     => $config{'host'},
                                                 'port'     => $config{'port'},
                                                 'user'     => $config{'user'},
                                                 'password' => $config{'password'} );

            if ( $sftp->error ) {
                print STDERR "Logging in to SFTP server failed.\n";
                return 0;
            }
            unless ( $sftp->put ( $stagingdir . '/' . $hash{'filename'}, $config{'remotedir'} . '/' . $hash{'filename'} . '.part' ) ) {
                print STDERR "Transferring file to SFTP server failed.\n";
                return 0;
            }
            unless ( $sftp->rename ( $config{'remotedir'} . '/' . $hash{'filename'} . '.part', $config{'remotedir'} . '/' . $hash{'filename'} ) ) {
                print STDERR "Renaming a file on SFTP server failed.\n";
                return 0;
            }
        }
        elsif ( $config{'protocol'} eq 'ftp' ) {
            $config{'port'} = 21  unless $config{'port'}; # Default port for ftp

            # Connect and send with FTP
            my $ftp = Net::FTP->new ( 'Host'     => $config{'host'},
                                      'Port'     => $config{'port'},
                                      'Passive'  => 1,
                                      'Debug'    => 1 );

            unless ( $ftp->login ( $config{'user'}, $config{'password'} ) ) {
                print STDERR "Logging in to FTP server failed.\n";
                return 0;
            }
            unless ( $ftp->put ( $stagingdir . '/' . $hash{'filename'}, $config{'remotedir'} . '/' . $hash{'filename'} . '.part' ) ) {
                print STDERR "Transfering file to FTP server failed.\n";
                return 0;
            }
            unless ( $ftp->rename ( $config{'remotedir'} . '/' . $hash{'filename'} . '.part', $config{'remotedir'}. '/' . $hash{'filename'} ) ) {
                print STDERR "Renaming a file on FTP server failed.\n";
                return 0;
            }
        }
        else {
            print STDERR "Unknown protocol " . $config{'protocol'} . ".\n";
            return 0;
        }
    }
    else {
        print STDERR "File transfer skipped (not configured).\n";
        return 1; # This is not an error as such, just let the user know what happened.
    }
}

1;
