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


# Check for missing Perl Modules

checkperlmodules();


# Ask for installation directories

my ($opacdir, $intranetdir) = getinstallationdirectories();




$::etcdir = '/etc';



$::dbname = 'Koha';
$::hostname = 'localhost';
$::user = 'kohaadmin';
$::pass = '';


getdatabaseinfo();



getapacheinfo();


print "user: $::httpduser\n";
print "conf:  $::realhttpdconf\n";
exit;

getapachevhostinfo();

#
# Update Apache Conf File.
#
#

my $logfiledir=`grep ^ErrorLog $$::realhttpdconf`;
chomp $logfiledir;

if ($logfiledir) {
    $logfiledir=~m#ErrorLog (.*)/[^/]*$#;
    $logfiledir=$1;
}

unless ($logfiledir) {
    $logfiledir='logs';
}
print qq|

UPDATING APACHE.CONF
====================

|;


print "Checking for modules that need to be loaded...\n";
my $httpdconf='';
my $envmodule=0;
my $includesmodule=0;
open HC, $$::realhttpdconf;
while (<HC>) {
    if (/^\s*#\s*LoadModule env_module /) {
	s/^\s*#\s*//;
	print "  Loading env_module in httpd.conf\n";
	$envmodule=1;
    }
    if (/^\s*#\s*LoadModule includes_module /) {
	s/^\s*#\s*//;
	print "  Loading includes_module in httpd.conf\n";
    }
    if (/\s*LoadModule includes_module / ) {
	$includesmodule=1;
    }
    $httpdconf.=$_;
}

my $apachebackupmade=0;
if ($envmodule || $includesmodule) {
    system("mv -f $$::realhttpdconf $$::realhttpdconf\.prekoha");
    $apachebackupmade=1;
    open HC, ">$$::realhttpdconf";
    print HC $httpdconf;
    close HC;
}


if (0) {
#if (`grep 'VirtualHost $servername' $$::realhttpdconf`) {
#    print qq|
#$$::realhttpdconf appears to already have an entry for Koha
#Virtual Hosts.  You may need to edit $$::realhttpdconf
#if anything has changed since it was last set up.  This
#script will not attempt to modify an existing Koha apache
#configuration.
#
#|;
    print "Press <ENTER> to continue...";
    <STDIN>;
    print "\n";
} else {
    unless ($apachebackupmade) {
	system("cp -f $$::realhttpdconf $$::realhttpdconf\.prekoha");
    }
    my $includesdirectives='';
    if ($includesmodule) {
	$includesdirectives.="Options +Includes\n";
	$includesdirectives.="   AddHandler server-parsed .html\n";
    }
    open(SITE,">>$$::realhttpdconf") or warn "Insufficient priveleges to open $$::realhttpdconf for writing.\n";
#    print SITE <<EOP
#
#
## Ports to listen to for Koha
#Listen $opacport
#Listen $kohaport
#
## NameVirtualHost is used by one of the optional configurations detailed below
#
##NameVirtualHost 11.22.33.44
#
## KOHA's OPAC Configuration
#<VirtualHost $servername\:$opacport>
#   ServerAdmin $svr_admin
#   DocumentRoot $opacdir/htdocs
#   ServerName $servername
#   ScriptAlias /cgi-bin/koha/ $opacdir/cgi-bin/
#   ErrorLog $logfiledir/opac-error_log
#   TransferLog $logfiledir/opac-access_log
#   SetEnv PERL5LIB "$intranetdir/modules"
#   $includesdirectives
#</VirtualHost>
#
## KOHA's INTRANET Configuration
#<VirtualHost $servername\:$kohaport>
#   ServerAdmin $svr_admin
#   DocumentRoot $intranetdir/htdocs
#   ServerName $servername
#   ScriptAlias /cgi-bin/koha/ "$intranetdir/cgi-bin/"
#   ErrorLog $logfiledir/koha-error_log
#   TransferLog $logfiledir/koha-access_log
#   SetEnv PERL5LIB "$intranetdir/modules"
#   $includesdirectives
#</VirtualHost>
#
## If you want to use name based Virtual Hosting:
##   1. remove the two Listen lines
##   2. replace $servername\:$opacport wih your.opac.domain.name
##   3. replace ServerName $servername wih ServerName your.opac.domain.name
##   4. replace $servername\:$kohaport wih your intranet domain name
##   5. replace ServerName $servername wih ServerName your.intranet.domain.name
##
## If you want to use NameVirtualHost'ing (using two names on one ip address):
##   1.  Follow steps 1-5 above
##   2.  Uncomment the NameVirtualHost line and set the correct ip address
#
#EOP
#;


    print qq|

Intranet Authentication
=======================

I can set it up so that the Intranet/Librarian site is password protected.
|;
print "Would you like to do this? ([Y]/N): ";
chomp($input = <STDIN>);

my $apacheauthusername='librarian';
my $apacheauthpassword='';
unless ($input=~/^n/i) {
    print "\nEnter a userid to login with [$apacheauthusername]: ";
    chomp ($input = <STDIN>);
    if ($input) {
	$apacheauthusername=$input;
	$apacheauthusername=~s/[^a-zA-Z0-9]//g;
    }
    while (! $apacheauthpassword) {
	print "\nEnter a password for the $apacheauthusername user: ";
	chomp ($input = <STDIN>);
	if ($input) {
	    $apacheauthpassword=$input;
	}
	if (!$apacheauthpassword) {
	    print "\nPlease enter a password.\n";
	}
    }
    open AUTH, ">/etc/kohaintranet.pass";
    my $chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    my $salt=substr($chars, int(rand(length($chars))),1);
    $salt.=substr($chars, int(rand(length($chars))),1);
    print AUTH $apacheauthusername.":".crypt($apacheauthpassword, $salt)."\n";
    close AUTH;
    print SITE <<EOP

<Directory $intranetdir>
    AuthUserFile /etc/kohaintranet.pass
    AuthType Basic
    AuthName "Koha Intranet (for librarians only)"
    Require  valid-user
</Directory>
EOP
}

    close(SITE);

    print "Successfully updated Apache Configuration file.\n";
}

print qq|

SETTING UP Z39.50 DAEMON
========================
|;

my $kohalogdir='/var/log/koha';
print "Directory for logging by Z39.50 daemon [$kohalogdir]: ";
chomp($input = <STDIN>);
if ($input) {
    $kohalogdir=$input;
}

unless (-e "$kohalogdir") {
    my $result = mkdir 0770, "$kohalogdir"; 
    if ($result==0) {
        my @dirs = split(m#/#, $kohalogdir);
	my $checkdir='';
	foreach (@dirs) {
	    $checkdir.="$_/";
	    unless (-e "$checkdir") {
		mkdir($checkdir, 0775);
	    }
	}
    }
}

#
# Setup the modules directory
#
print qq|

CREATING REQUIRED DIRECTORIES
=============================

|;


unless ( -d $intranetdir ) {
   print "Creating $intranetdir...\n";
   my $result=mkdir ($intranetdir, oct(770));
   if ($result==0) {
       my @dirs = split(m#/#, $intranetdir);
	my $checkdir='';
	foreach (@dirs) {
	    $checkdir.="$_/";
	    unless (-e "$checkdir") {
		mkdir($checkdir, 0775);
	    }
	}
   }
   chown (oct(0), (getgrnam($::httpduser))[2], "$intranetdir");
   chmod (oct(770), "$intranetdir");
}
unless ( -d "$intranetdir/htdocs" ) {
   print "Creating $intranetdir/htdocs...\n";
   mkdir ("$intranetdir/htdocs", oct(750));
}
unless ( -d "$intranetdir/cgi-bin" ) {
   print "Creating $intranetdir/cgi-bin...\n";
   mkdir ("$intranetdir/cgi-bin", oct(750));
}
unless ( -d "$intranetdir/modules" ) {
   print "Creating $intranetdir/modules...\n";
   mkdir ("$intranetdir/modules", oct(750));
}
unless ( -d "$intranetdir/scripts" ) {
   print "Creating $intranetdir/scripts...\n";
   mkdir ("$intranetdir/scripts", oct(750));
}
unless ( -d $opacdir ) {
   print "Creating $opacdir...\n";
   my $result=mkdir ($opacdir, oct(770));
   if ($result==0) {
       my @dirs = split(m#/#, $opacdir);
	my $checkdir='';
	foreach (@dirs) {
	    $checkdir.="$_/";
	    unless (-e "$checkdir") {
		mkdir($checkdir, 0775);
	    }
	}
   }
   chown (oct(0), (getgrnam($::httpduser))[2], "$opacdir");
   chmod (oct(770), "$opacdir");
}
unless ( -d "$opacdir/htdocs" ) {
   print "Creating $opacdir/htdocs...\n";
   mkdir ("$opacdir/htdocs", oct(750));
}
unless ( -d "$opacdir/cgi-bin" ) {
   print "Creating $opacdir/cgi-bin...\n";
   mkdir ("$opacdir/cgi-bin", oct(750));
}



print "\n\nINSTALLING KOHA...\n";
print "\n\n==================\n";
print "Copying internet-html files to $intranetdir/htdocs...\n";
system("cp -R intranet-html/* $intranetdir/htdocs/");
print "Copying intranet-cgi files to $intranetdir/cgi-bin...\n";
system("cp -R intranet-cgi/* $intranetdir/cgi-bin/");
print "Copying script files to $intranetdir/scripts...\n";
system("cp -R scripts/* $intranetdir/scripts/");
print "Copying module files to $intranetdir/modules...\n";
system("cp -R modules/* $intranetdir/modules/");
print "Copying opac-html files to $opacdir/htdocs...\n";
system("cp -R opac-html/* $opacdir/htdocs/");
print "Copying opac-cgi files to $opacdir/cgi-bin...\n";
system("cp -R opac-cgi/* $opacdir/cgi-bin/");

system("chown -R root.$::httpduser $opacdir");
system("chown -R root.$::httpduser $intranetdir");


print qq|

KOHA.CONF
=========
Koha uses a small configuration file that is placed in your /etc/ files
directory. The configuration file, will be created in this directory.

|;

#Create the configuration file
open(SITES,">$::etcdir/koha.conf") or warn "Couldn't create file
at $::etcdir.  Must have write capability.\n";
print SITES <<EOP
database=$::dbname
hostname=$::hostname
user=$::user
pass=$::pass
includes=$intranetdir/htdocs/includes
intranetdir=$intranetdir
opacdir=$opacdir
kohalogdir=$kohalogdir
kohaversion=$::kohaversion
httpduser=$::httpduser
EOP
;
close(SITES);

#
# Set ownership of the koha.conf file for security
#
chown((getpwnam($::httpduser)) [2,3], "$::etcdir/koha.conf") or warn "can't chown koha.conf: $!";
chmod 0440, "$::etcdir/koha.conf";


print "Successfully created the Koha configuration file.\n";

print qq|

MYSQL CONFIGURATION
===================
|;
my $mysql;
my $mysqldir;
my $mysqluser = 'root';
my $mysqlpass = '';

foreach my $mysql (qw(/usr/local/mysql
                      /opt/mysql
		      )) {
   if ( -d $mysql ) {
            $mysqldir=$mysql;
   }
}
if (!$mysqldir){
    $mysqldir='/usr';
}
print qq|
To allow us to create the koha database please supply the 
mysql\'s root users password
|;

my $needpassword=1;
while ($needpassword) {
    print "Enter mysql\'s root users password: ";
    chomp($input = <STDIN>);
    $mysqlpass = $input;
    my $result=system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass proc > /dev/null 2>&1");
    if ($result) {
	print "\n\nInvalid password for the MySql root user.\n\n";
    } else {
	$needpassword=0;
    }
}


print qq|

CREATING DATABASE
=================
|;
my $result=system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass create $::dbname");
if ($result) {
    print "\nCouldn't connect to the MySQL server for the reason given above.\n";
    print "This is a serious problem, the database will not get installed.\n";
    print "Press <ENTER> to continue...";
    <STDIN>;
    print "\n";
} else {
    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $::dbname < koha.mysql");
    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass mysql -e \"insert into user (Host,User,Password) values ('$::hostname','$::user',password('$::pass'))\"\;");
    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass mysql -e \"insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv, index_priv, alter_priv) values ('%','$::dbname','$::user','Y','Y','Y','Y','Y','Y','Y','Y')\"");
    system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass reload");

    system ("perl -I $intranetdir/modules scripts/updater/updatedatabase");


    print qq|

SAMPLE DATA
===========
If you are installing Koha for evaluation purposes,  I have a batch of sample
data that you can install now.

If you are installing Koha with the intention of populating it with your own
data, you probably don't want this sample data installed.
|;
    print "\nWould you like to install the sample data? Y/[N]: ";
    chomp($input = <STDIN>);
    if ($input =~/^y/i) {
	system("gunzip sampledata-1.2.gz");
	system("cat sampledata-1.2 | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $::dbname");
	system("gzip -9 sampledata-1.2");
	system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $::dbname -e \"insert into branches (branchcode,branchname,issuing) values ('MAIN', 'Main Library', 1)\"");
	system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $::dbname -e \"insert into printers (printername,printqueue,printtype) values ('Circulation Desk Printer', 'lp', 'hp')\"");
	print qq|

Sample data has been installed.  For some suggestions on testing Koha, please
read the file doc/HOWTO-Testing.  If you find any bugs, please submit them at
http://bugs.koha.org/.  If you need help with testing Koha, you can post a
question through the koha-devel mailing list, or you can check for a developer
online at +irc.katipo.co.nz:6667 channel #koha.

You can find instructions for subscribing to the Koha mailing lists at:

    http://www.koha.org


Press <ENTER> to continue...
|;
	<STDIN>;
    } else {
	print "\n\nWould you like to add a branch and printer? [Y]/N: ";
	chomp($input = <STDIN>);


	unless ($input =~/^n/i) {
	    my $branch='Main Library';
	    print "Enter a name for the library branch [$branch]: ";
	    chomp($input = <STDIN>);
	    if ($input) {
		$branch=$input;
	    }
	    $branch=~s/[^A-Za-z0-9\s]//g;
	    my $branchcode=$branch;
	    $branchcode=~s/[^A-Za-z0-9]//g;
	    $branchcode=uc($branchcode);
	    $branchcode=substr($branchcode,0,4);
	    print "Enter a four letter code for your branch [$branchcode]: ";
	    chomp($input = <STDIN>);
	    if ($input) {
		$branchcode=$input;
	    }
	    $branchcode=~s/[^A-Z]//g;
	    $branchcode=uc($branchcode);
	    $branchcode=substr($branchcode,0,4);
	    print "Adding branch '$branch' with code '$branchcode'.\n";
	    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $::dbname -e \"insert into branches (branchcode,branchname,issuing) values ('$branchcode', '$branch', 1)\"");
	    my $printername='Library Printer';
	    print "Enter a name for the printer [$printername]: ";
	    chomp($input = <STDIN>);
	    if ($input) {
		$printername=$input;
	    }
	    $printername=~s/[^A-Za-z0-9\s]//g;
	    my $printerqueue='lp';
	    print "Enter the queue for the printer [$printerqueue]: ";
	    chomp($input = <STDIN>);
	    if ($input) {
		$printerqueue=$input;
	    }
	    $printerqueue=~s/[^A-Za-z0-9]//g;
	    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $::dbname -e \"insert into printers (printername,printqueue,printtype) values ('$printername', '$printerqueue', '')\"");
	}
    }


}


chmod 0770, $kohalogdir;
chown((getpwnam($::httpduser)) [2,3], $kohalogdir) or warn "can't chown $kohalogdir: $!";

# LAUNCH SCRIPT
print "Modifying Z39.50 daemon launch script...\n";
my $newfile='';
open (L, "$intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh");
while (<L>) {
    if (/^RunAsUser=/) {
	$newfile.="RunAsUser=$::httpduser\n";
    } elsif (/^KohaZ3950Dir=/) {
	$newfile.="KohaZ3950Dir=$intranetdir/scripts/z3950daemon\n";
    } else {
	$newfile.=$_;
    }
}
close L;
system("mv $intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh $intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh.orig");
open L, ">$intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh";
print L $newfile;
close L;


# SHELL SCRIPT
print "Modifying Z39.50 daemon wrapper script...\n";
$newfile='';
open (S, "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh");
while (<S>) {
    if (/^KohaModuleDir=/) {
	$newfile.="KohaModuleDir=$intranetdir/modules\n";
    } elsif (/^KohaZ3950Dir=/) {
	$newfile.="KohaZ3950Dir=$intranetdir/scripts/z3950daemon\n";
    } elsif (/^LogDir=/) {
	$newfile.="LogDir=$kohalogdir\n";
    } else {
	$newfile.=$_;
    }
}
close S;

system("mv $intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh $intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh.orig");
open S, ">$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh";
print S $newfile;
close S;
chmod 0750, "$intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh";
chmod 0750, "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh";
chmod 0750, "$intranetdir/scripts/z3950daemon/processz3950queue";
chown(0, (getpwnam($::httpduser)) [3], "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh") or warn "can't chown $intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh: $!";
chown(0, (getpwnam($::httpduser)) [3], "$intranetdir/scripts/z3950daemon/processz3950queue") or warn "can't chown $intranetdir/scripts/z3950daemon/processz3950queue: $!";

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
