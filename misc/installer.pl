#!/usr/bin/perl -w # please develop with -w

#use diagnostics;

use Install;
use Getopt::Long;

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
   elsif (open(INPUT, "</etc/hostname")) {
      $domainname = <INPUT>;
   }
}
Install::setdomainname $domainname;

###############################################
# SET  THE  etcdir  ENVIRONMENT  VAR  INSTEAD #
###############################################
my $etcdir = $ENV{etcdir}||'/etc';
system("mkdir -p $etcdir");

my $auto_install_file;
GetOptions(
    'i:s'    => \$auto_install_file,
);
my $auto_install = read_autoinstall_file($auto_install_file);

Install::setetcdir $etcdir;

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
checkperlmodules($auto_install);

# Ask for installation directories
getapacheinfo($auto_install);

getinstallationdirectories($auto_install);

getdatabaseinfo($auto_install);

getapachevhostinfo($auto_install);

updateapacheconf();

# basicauthentication();

installfiles($auto_install);

backupmycnf();

databasesetup($auto_install);

updatedatabase($auto_install);

populatedatabase($auto_install);

restoremycnf();

finalizeconfigfile();

restartapache($auto_install);

showmessage(getmessage('AuthenticationWarning', [$etcdir]), 'PressEnter') unless ($auto_install->{NoPressEnter});

showmessage(getmessage('Completed', [ Install::getservername(), Install::getintranetport(), Install::getservername(), Install::getopacport()]), 'PressEnter');

if (-f "kohareporter") {
    my $reply=showmessage('Would you like to complete a survey about your library?', 'yn', 'y');
    if ($reply=~/y/i) {
	system("perl kohareporter");
    }
}
