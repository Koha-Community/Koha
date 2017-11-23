package Koha::MessageQueue::PrintProviderEnfo;

# Copyright 2015 Vaara-kirjastot
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Net::FTP;
use Net::SFTP::Foreign;

use Koha::MessageQueue::PrintProviderInterface;
use C4::Context;

use base "Koha::MessageQueue::PrintProviderInterface";

sub sendAll {
    my ($self, $messageQueues, $params) = @_;
    my ($ok, $error);
    return (undef, "PrintProviderEnfo->sendAll(): the given MessageQueues-array is empty!") unless $messageQueues && @$messageQueues;

    my $providerConfig = C4::Context->config('printProviders')->{enfo};
    my $letterStagingDirectory = $providerConfig->{letterStagingDirectory}.'/';
    $error = `mkdir -p $letterStagingDirectory`;
    return (undef, "PrintProviderEnfo->sendAll(): Couldn't create the letterStagingDirectory '$letterStagingDirectory': $error") if $error;
    my $clientId = $providerConfig->{clientId};

    print "\nPrintProviderEnfo():: Happily sending all '".scalar(@$messageQueues)."' print overdue notifications\n";

    my $validMessageQueues; ($validMessageQueues, $error) = _validateAllMessageQueues($messageQueues);
    ##STOP if we haven't got no valid messages.
    unless ($validMessageQueues && @$validMessageQueues) {
        print "\n-- no overdue notifications survived the validation\n";
        return (undef, $error);
    }
    print "\n-- '".scalar(@$validMessageQueues)."' overdue notifications survived the validation\n";

    my $letter = _buildEplLetter($validMessageQueues);

    ##Write the file.
    my $ymd = DateTime->now(time_zone => C4::Context->tz())->ymd('');
    my $file = $letterStagingDirectory.$clientId.'_'.$ymd.'.epl';
    open(my $eKirje, ">:encoding(UTF-8)", $file) or return (undef, "Couldn't write to the temp file $file for sending to Enfo Zender");
    print $eKirje $letter;
    close $eKirje;

    #Validate the complete finished file.
    unless(open($eKirje, "<:encoding(UTF-8)", $file)) {
        print "Couldn't read the temp file '$file' for validating to Enfo Zender";
        return (undef, "Couldn't read the temp file '$file' for validating to Enfo Zender");
    }
    my @writedLetter = <$eKirje>;

    close $eKirje;
    if (my $badRow = _validateEpl(join("",@writedLetter))) {
        print join('','PrintProviderEnfo->sendAll(): Validating built file "',$file,'" failed',"\n",
                      $badRow,"\n");
        return (undef, "FILE_IS_INVALID");
    }

    unless(exists($providerConfig->{dontReallySendAnything})) { #Have we disabled the sending part for testing purposes?
        ($ok, $error) = _sendTheLetterViaFtp($file, $providerConfig);
        unless ($ok) {
            return (undef, "PrintProviderEnfo->sendAll(): $error");
        }
    }
    _markAllMessageQueuesSent($validMessageQueues);
    print "\n-- '".scalar(@$validMessageQueues)."' overdue notifications marked as sent\n";

    #Call the parent interface to handle fines and debarments using the default way.
    $validMessageQueues = $self->SUPER::sendAll($validMessageQueues, $params);
    print "\n-- Fines and debarments checked\n";

    return $validMessageQueues;
}

sub _sendTheLetterViaFtp {
    my ($file, $providerConfig) = @_;

    #Get the ftp-connection.
    my ($ftpcon, $error);
    my $error_fn = 'error';
    if ($providerConfig->{sftp}) {
        ($ftpcon, $error) = _getSftpToEnfo( $providerConfig );
    } else {
        ($ftpcon, $error) = _getFtpToEnfo( $providerConfig );
        $error_fn = 'message';
    }
    if ($error) {
        return(undef, $error);
    }
    else {
        #If the remoteDirectory-configuration is defined, try changing to that directory, if it is not present try creating it.
        if ($providerConfig->{remoteDirectory} && length $providerConfig->{remoteDirectory} > 0) {
            unless($ftpcon->cwd( $providerConfig->{remoteDirectory} )) {
                my $firstError = "FTP: Cannot change working directory :".$ftpcon->$error_fn;
                unless($ftpcon->mkdir( $providerConfig->{remoteDirectory} )) {
                    my $secondError = "FTP: Cannot create directory :".$ftpcon->$error_fn;
                    return (undef, "FTP: Failed to change to given directory '".$providerConfig->{remoteDirectory}."'. Trying to create it fails as well. Errors follow:    ".$firstError."  <>  ".$secondError);
                }
            }
        }

        unless($ftpcon->put( $file )) {
            return (undef, "FTP->put():ing the eLetter '$file' to Enfo Zender failed: ". $ftpcon->$error_fn);
        }

        $ftpcon->close();

        return (1, undef); #Sending succeeded!
    }
    return (undef, "Something happened and the sending failed");
}

sub _getFtpToEnfo {
    my ($providerConfig) = @_;

    my $ftpcon = Net::FTP->new( Host => $providerConfig->{host},
                                Timeout => 10);
    unless ($ftpcon) {
        return (undef, "Cannot connect to ENFO's ftp server: $@");
    }

    if ($ftpcon->login($providerConfig->{user},$providerConfig->{passwd})){
        return ($ftpcon, undef);
    }
    else {
        return (undef, "Cannot login to ENFO's ftp server: $@");
    }
}

sub _getSftpToEnfo {
    my ($providerConfig) = @_;

    $Net::SFTP::Foreign::debug = 1;
    my $sftpcon = Net::SFTP::Foreign->new(
        host => $providerConfig->{host},
        timeout => 10,
        user => $providerConfig->{user},
        password => $providerConfig->{passwd},
        more => '-v'
    );
    unless ($sftpcon) {
        return (undef, "Cannot connect to ENFO's sftp server: $@");
    }
    return ($sftpcon, undef);
}

sub _validateAllMessageQueues {
    my $messageQueues = shift;

    #Validate all messageQueue-objects to contain only valid .epl -messages.
    my $validMessageQueues = [];
    foreach my $messageQueue (@$messageQueues) {
        if (my $badRow = _validateEpl($messageQueue->content)) {
            $messageQueue->setStatus('failed');
            print join('','PrintProviderEnfo->sendAll(): Validating messageQueue id "',$messageQueue->id,'" failed for borrowernumber "',$messageQueue->borrowernumber,'".',"\n",
                          $badRow,"\n");
        }
        else {
            push @$validMessageQueues, $messageQueue;
        }
    }
    return (undef, "PrintProviderEnfo->sendAll(): No valid messageQueues for sending\n") unless @$validMessageQueues;
    return ($validMessageQueues, undef);
}

=head _validateEpl
@PARAM1 String, the .epl-message to validate
@RETURNS Integer, the rownumber which failed the validation
=cut

sub _validateEpl {
    my $content = shift;

    #If any row in the messageQueue content doesn't start with [E 0-9][P0-9]
    #We fail this messageQueue!
    my @rows = split('\n', $content);
    my $i = 1; #Count the rows so we can report on which row it failed.
    foreach my $row (@rows) {
        unless ($row =~ /^[E 0-9][P0-9]/) {
            return "$i:$row";
        }
        $i++;
    }
    return 0;
}

sub _buildEplLetter {
    my $messageQueues = shift;
    my $kohaAdminEmail = C4::Context->preference('KohaAdminEmailAddress');

    ##Write the eLetter
    my @sb; #Initiate a StringBuilder
    #Write the eLetter header
    push @sb, "EPL1180055438800T002S  0                $kohaAdminEmail\n";
    #Iterate the messageQueue-objects, which contain validated messages.
    foreach my $messageQueue (@$messageQueues) {
        push @sb, $messageQueue->content . "\n";
    }
    return join('', @sb);
}

sub _markAllMessageQueuesSent {
    my $validatedMessageQueues = shift;

    foreach my $messageQueue (@$validatedMessageQueues) {
        $messageQueue->setStatus( 'sent' );
    }
}

1; #Satisfy the compiler
