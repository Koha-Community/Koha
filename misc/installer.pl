#!/usr/bin/perl -w # please develop with -w

#use diagnostics;

use Install;
use strict; # please develop with the strict pragma

use vars qw( $input );

Install::setlanguage 'en';

my $domainname = `hostname`; # Note: must not have any arguments (portability)
if ($domainname =~ /^[^\s\.]+\.([-a-z0-9\.]+)$/) {
   $domainname = $1;
} else {
   undef $domainname;
   if (open(INPUT, "</etc/resolv.conf")) {
      while (<INPUT>) {
	 $domainname = $1 if /^domain\s+([-a-z0-9\.]+)\s*$/i;
      last if defined $domainname;
      }
      close INPUT;
   }
}
Install::setdomainname $domainname;

my $etcdir = '/etc';
Install::setetcdir $etcdir;

unless ($< == 0) {
    print "You must be root to run this script.\n";
    exit 1;
}


unless (-d 'intranet-html') {
   print <<EOP;
You seem to be installing from CVS. Please run the "buildrelease" script
and install from the resulting release tarball.
EOP
   exit 1;
}

my $kohaversion=`cat koha.version`;
chomp $kohaversion;
Install::setkohaversion $kohaversion;


if ($kohaversion =~ /RC/) {
    releasecandidatewarning();
}

checkabortedinstall();

if (-e "$etcdir/koha.conf") {
    my $installedversion=`grep kohaversion= "$etcdir/koha.conf"`;
    chomp $installedversion;
    $installedversion=~m/kohaversion=(.*)/;
    $installedversion=$1;
    my $installedversionmsg;
    if ($installedversion) {
	$installedversionmsg=getmessage('KohaVersionInstalled', [$installedversion]);
    } else {
	$installedversionmsg=getmessage('KohaUnknownVersionInstalled');
    }

    my $message=getmessage('KohaAlreadyInstalled', [$etcdir, $kohaversion, $installedversionmsg]);
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

# Check for missing Perl Modules
checkperlmodules();

# Ask for installation directories
getapacheinfo();

getinstallationdirectories();

getdatabaseinfo();

getapachevhostinfo();

updateapacheconf();

basicauthentication();

installfiles();

databasesetup();

updatedatabase();

populatedatabase();

finalizeconfigfile();

restartapache();




showmessage(getmessage('AuthenticationWarning', [$etcdir]), 'PressEnter');


showmessage(getmessage('Completed', [ Install::getservername(), Install::getintranetport(), Install::getservername(), Install::getopacport()]), 'PressEnter');




if (-f "kohareporter") {
    my $reply=showmessage('Would you like to complete a survey about your library?', 'yn', 'y');
    if ($reply=~/y/i) {
	system("perl kohareporter");
    }
}
