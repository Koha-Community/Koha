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


exit;



# LAUNCH SCRIPT
print "Modifying Z39.50 daemon launch script...\n";
my $newfile='';
open (L, "$::intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh");
while (<L>) {
    if (/^RunAsUser=/) {
	$newfile.="RunAsUser=$::httpduser\n";
    } elsif (/^KohaZ3950Dir=/) {
	$newfile.="KohaZ3950Dir=$::intranetdir/scripts/z3950daemon\n";
    } else {
	$newfile.=$_;
    }
}
close L;
system("mv $::intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh $::intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh.orig");
open L, ">$::intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh";
print L $newfile;
close L;


# SHELL SCRIPT
print "Modifying Z39.50 daemon wrapper script...\n";
$newfile='';
open (S, "$::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh");
while (<S>) {
    if (/^KohaModuleDir=/) {
	$newfile.="KohaModuleDir=$::intranetdir/modules\n";
    } elsif (/^KohaZ3950Dir=/) {
	$newfile.="KohaZ3950Dir=$::intranetdir/scripts/z3950daemon\n";
    } elsif (/^LogDir=/) {
	$newfile.="LogDir=$::kohalogdir\n";
    } else {
	$newfile.=$_;
    }
}
close S;

system("mv $::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh $::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh.orig");
open S, ">$::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh";
print S $newfile;
close S;
chmod 0750, "$::intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh";
chmod 0750, "$::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh";
chmod 0750, "$::intranetdir/scripts/z3950daemon/processz3950queue";
chown(0, (getpwnam($::httpduser)) [3], "$::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh") or warn "can't chown $::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh: $!";
chown(0, (getpwnam($::httpduser)) [3], "$::intranetdir/scripts/z3950daemon/processz3950queue") or warn "can't chown $::intranetdir/scripts/z3950daemon/processz3950queue: $!";

print qq|

==================
= Authentication =
==================

This release of Koha has a new authentication module.  If you are not already
using basic authentication on your intranet, you will be required to log in to
access some of the features of the intranet.  You can log in using the userid
and password from the /etc/koha.conf configuration file at any time.  Use the
"Members" module to add passwords for other accounts and set their permissions.

[NOTE PERMISSIONS ARE NOT COMPLETED AS OF 1.2.3RC1.  Do not give passwords to
 any patrons unless you want them to have full access to your intranet.]
|;
print "Press the <ENTER> key to continue: ";
<STDIN>;


#RESTART APACHE
print "\n\n";
#print qq|
#
#COMPLETED
#=========
#Congratulations ... your Koha installation is almost complete!
#The final step is to restart your webserver.
#
#You will be able to connect to your Librarian interface at:
#
#   http://$servername\:$kohaport/
#
#and the OPAC interface at :
#
#   http://$servername\:$opacport/
#
#
#Be sure to read the INSTALL, and Hints files. 
#
#For more information visit http://www.koha.org
#
#Would you like to restart your webserver now? (Y/[N]):
#|;

my $restart = <STDIN>;
chomp $restart;

if ($restart=~/^y/i) {
	# Need to support other init structures here?
	if (-e "/etc/rc.d/init.d/httpd") {
	    system('/etc/rc.d/init.d/httpd restart');
	} elsif (-e "/etc/init.d/apache") {
	    system('/etc//init.d/apache restart');
	} elsif (-e "/etc/init.d/apache-ssl") {
	    system('/etc/init.d/apache-ssl restart');
	}
    } else {
	print qq|
Congratulations ... your Koha installation is complete!
You will need to restart your webserver before using Koha!
|;
    exit;
};
