#!/usr/bin/perl -w # please develop with -w

#use diagnostics;

use Install;
use strict; # please develop with the strict pragma


$::language='en';

if ($<) {
    print "\n\nYou must run koha.upgrade as root.\n\n";
    exit;
}
unless ($< == 0) {
    print "You must be root to run this script.\n";
    exit 1;
}

$::kohaversion=`cat koha.version`;
chomp $::kohaversion;


if ($::kohaversion =~ /RC/) {
    releasecandidatewarning();
}

if (-e "/etc/koha.conf") {
    $::installedversion=`grep kohaversion= /etc/koha.conf`;
    chomp $::installedversion;
    $::installedversion=~m/kohaversion=(.*)/;
    $::installedversion=$1;
    my $installedversionmsg;
    if ($::installedversion) {
	$installedversionmsg=getmessage('KohaVersionInstalled', [$::installedversion]);
    } else {
	$installedversionmsg=getmessage('KohaUnknownVersionInstalled');
    }

    my $message=getmessage('KohaAlreadyInstalled', [$::kohaversion, $installedversionmsg]);
    showmessage($message, 'none');
    exit;
}

my $continuingmsg=getmessage('continuing');

my $message=getmessage('WelcomeToKohaInstaller');
my $answer=showmessage($message, 'yn');

if ($answer eq "Y" || $answer eq "y") {
	print $continuingmsg;
    } else {
    print qq|
This installer currently does not support a completely automated 
setup.

Please be sure to read the documentation, or visit the Koha website 
at http://www.koha.org for more information.
|;
    exit;
};

my $input;
$::domainname = `hostname -d`;
chomp $::domainname;
$::etcdir = '/etc';


# Check for missing Perl Modules
checkperlmodules();

# Ask for installation directories
getinstallationdirectories();

getdatabaseinfo();

getapacheinfo();

getapachevhostinfo();

updateapacheconf();

basicauthentication();

installfiles();

databasesetup();

restartapache();

showmessage(getmessage('AuthenticationWarning'), 'PressEnter');


showmessage(getmessage('Completed', [ $::servername, $::intranetport, $::servername, $::opacport]), 'PressEnter');




my $reply=showmessage('Would you like to complete a survey about your library?', 'yn', 'y');
if ($reply=~/y/i) {
    system("perl kohareporter");
}

