#!/usr/bin/perl -w # please develop with -w

# $Id$

#use diagnostics;

# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict; # please develop with the strict pragma

if ($<) {
    print "\n\nYou must run $0 as root.\n\n";
    exit;
}
unless ($< == 0) {
    print "You must be root to run this script.\n";
    exit 1;
}

my $kohaversion=`cat koha.version`;
chomp $kohaversion;


if ($kohaversion =~ /RC/) {
    print qq|
=====================
= RELEASE CANDIDATE =
=====================

WARNING WARNING WARNING WARNING WARNING

You are about to install Koha version $kohaversion.  This version of Koha is a
release candidate.  It is not intended to be installed on production systems.
It is being released so that users can test it before we release a final
version.

|;
    print "Are you sure you want to install Koha $kohaversion? (Y/[N]): ";

    my $answer = <STDIN>;
    chomp $answer;

    if ($answer eq "Y" || $answer eq "y") {
	print "Great! continuing setup... \n";
    } else {
	print qq|

Watch for announcements of Koha releases on the Koha mailing list or the Koha
web site (http://www.koha.org/).

|;
	exit;
    };
}

if (-e "/etc/koha.conf") {
    my $installedversion=`grep kohaversion= /etc/koha.conf`;
    chomp $installedversion;
    $installedversion=~m/kohaversion=(.*)/;
    $installedversion=$1;
    if ($installedversion) {
	$installedversion="You currently have Koha $installedversion on your system.\n";
    } else {
	$installedversion="I am not able to determine what version of Koha is installed now.\n";
    }

    print qq|
			==========================
			= Koha already installed =
			==========================

It looks like Koha is already installed on your system (/etc/koha.conf exists
already).  If you would like to upgrade your system to $kohaversion, please use
the koha.upgrade script in this directory.

$installedversion

|;
    exit;
}

system('clear');
print qq|
**********************************
* Welcome to the Koha Installer  *
**********************************
Welcome to the Koha install script!  This script will prompt you for some
basic information about your desired setup, then install Koha according to
your specifications.  To accept the default value for any question, simply hit
Enter at the prompt.

Please be sure to read the documentation, or visit the Koha website at
http://www.koha.org for more information.

Are you ready to begin the installation? (Y/[N]):
|;

my $answer = <STDIN>;
chomp $answer;

if ($answer eq "Y" || $answer eq "y") {
	print "Great! continuing setup... \n";
    } else {
    print qq|
This installer currently does not support a completely automated
setup.

Please be sure to read the documentation, or visit the Koha website
at http://www.koha.org for more information.
|;
    exit;
};

print "\n";

#
# Test for Perl and Modules
#
print qq|

PERL & MODULES
==============

|;

print "\nChecking perl modules ...\n";
    unless (eval "require 5.004") {
    die "Sorry, you need at least Perl 5.004\n";
}

my @missing = ();
unless (eval {require DBI})               { push @missing,"DBI" };
unless (eval {require Date::Manip})       { push @missing,"Date::Manip" };
unless (eval {require DBD::mysql})        { push @missing,"DBD::mysql" };
unless (eval {require MARC::Record}) { push @missing, "MARC::Record"};

unless (eval {require Net::Z3950})        {
    print qq|

The Net::Z3950 module is missing.  This module is necessary if you want to use
Koha's Z39.50 client to download bibliographic records from other libraries.
To install this module, you will need the yaz client installed from
http://www.indexdata.dk/yaz/ and then you can install the perl module with the
command:

perl -MCPAN -e 'install Net::Z3950'

Press the <ENTER> key to continue:
|;
    <STDIN>;
}

#
# Print out a list of any missing modules
#
if (@missing > 0) {
    print "\n\n";
    print "You are missing some Perl modules which are required by Koha.\n";
    print "Once these modules have been installed, rerun this installer.\n";
    print "They can be installed by running (as root) the following:\n";
    foreach my $module (@missing) {
	print "   perl -MCPAN -e 'install \"$module\"'\n";
	exit(1);
    }} else{
    print "All modules appear to be installed, continuing...\n";
};


print "\n";
my $input;
my $domainname = `hostname -d`;
chomp $domainname;
my $opacdir = '/usr/local/koha/opac';
my $kohadir = '/usr/local/koha/intranet';
my $getdirinfo=1;
while ($getdirinfo) {
    # Loop until opac directory and koha directory are different
    print qq|

OPAC DIRECTORY
==============
Please supply the directory you want Koha to store its OPAC files in.  Leave off
the trailing slash.  This directory will be auto-created for you if it doesn't
exist.

Usually $opacdir
|;

    print "Enter directory [$opacdir]: ";
    chomp($input = <STDIN>);

    if ($input) {
      $opacdir = $input;
    }


    print qq|

INTRANET/LIBRARIANS DIRECTORY
=============================
Please supply the directory you want Koha to store its Intranet/Librarians files
in.  Leave off the trailing slash.  This directory will be auto-created for you if
it doesn't exist.

|;

    print "Enter directory [$kohadir]: ";
    chomp($input = <STDIN>);

    if ($input) {
      $kohadir = $input;
    }
    if ($kohadir eq $opacdir) {
	print qq|

You must specify different directories for the OPAC and INTRANET files!

|;
    } else {
	$getdirinfo=0;
    }
}

#
#KOHA conf
#
my $etcdir = '/etc';
my $dbname = 'Koha';
my $hostname = 'localhost';
my $user = 'kohaadmin';
my $pass = '';

print qq|

KOHA.CONF
=========
Koha uses a small configuration file that is placed in your /etc/ files
directory. The configuration file, will be created in this directory.

|;

#Get the path to the koha.conf directory
#print "Enter the path to your configuration directory [$etcdir]: ";
#chomp($input = <STDIN>);
#
#if ($input) {
#  $etcdir = $input;
#}


#Get the database name
print qq|

Please provide the name of the mysql database for your koha installation.
This is normally "$dbname".

|;

print "Enter database name [$dbname]: ";
chomp($input = <STDIN>);

if ($input) {
  $dbname = $input;
}


#Get the hostname for the database
print qq|

Please provide the hostname for mysql.  Unless the database is located on another
machine this will be "localhost".
|;

print "Enter hostname [$hostname]: ";
chomp($input = <STDIN>);

if ($input) {
  $hostname = $input;
}

#Get the username for the database
print qq|

Please provide the name of the user, who will have full administrative rights
to the $dbname database, when authenticating from $hostname.

If no user is entered it will default to $user.
|;

print "Enter username [$user]:";
chomp($input = <STDIN>);

if ($input) {
  $user = $input;
}

#Get the password for the database user
print qq|

Please provide a good password for the user $user.
|;

print "Enter password:";
chomp($input = <STDIN>);

if ($input) {
  $pass = $input;
}

print "\n";



print "Successfully created the Koha configuration file.\n";

my $httpduser;
my $realhttpdconf;

foreach my $httpdconf (qw(/usr/local/apache/conf/httpd.conf
                      /usr/local/etc/apache/httpd.conf
                      /usr/local/etc/apache/apache.conf
                      /var/www/conf/httpd.conf
                      /etc/apache/conf/httpd.conf
                      /etc/apache/conf/apache.conf
                      /etc/apache-ssl/conf/apache.conf
                      /etc/httpd/conf/httpd.conf
                      /etc/httpd/httpd.conf)) {
   if ( -f $httpdconf ) {
            $realhttpdconf=$httpdconf;
            open (HTTPDCONF, $httpdconf) or warn "Insufficient privileges to open $httpdconf for reading.\n";
      while (<HTTPDCONF>) {
         if (/^\s*User\s+"?([-\w]+)"?\s*$/) {
            $httpduser = $1;
         }
      }
      close(HTTPDCONF);
   }
}
unless ($realhttpdconf) {
    print qq|

I was not able to find your apache configuration file.  It is usually
called httpd.conf or apache.conf.
|;
    print "Where is your Apache configuratin file? ";
    chomp($input = <STDIN>);

    if ($input) {
	$realhttpdconf = $input;
    } else {
	$realhttpdconf='';
    }
    if ( -f $realhttpdconf ) {
	open (HTTPDCONF, $realhttpdconf) or warn "Insufficient privileges to open $realhttpdconf for reading.\n";
	while (<HTTPDCONF>) {
	    if (/^\s*User\s+"?([-\w]+)"?\s*$/) {
		$httpduser = $1;
	    }
	}
	close(HTTPDCONF);
    }
}

unless ($httpduser) {
    print qq|

I was not able to determine the user that Apache is running as.  This
information is necessary in order to set the access privileges correctly on
/etc/koha.conf.  This user should be set in one of the Apache configuration
files using the "User" directive.
|;
    print "What is your Apache user? ";
    chomp($input = <STDIN>);

    if ($input) {
	$httpduser = $input;
    } else {
	$httpduser='Undetermined';
    }
}


#
#SETUP opac
#
my $svr_admin = "webmaster\@$domainname";
my $servername=`hostname -f`;
chomp $servername;
my $opacport=80;
my $kohaport=8080;

print qq|

OPAC and KOHA/LIBRARIAN CONFIGURATION
=====================================
Koha needs to setup your Apache configuration file for the
OPAC and LIBRARIAN virtual hosts.  By default this installer
will do this by using one ip address and two different ports
for the virtual hosts.  There are other ways to set this up,
and the installer will leave comments in httpd.conf detailing
what these other options are.

Please enter the e-mail address for your webserver admin.
Usually $svr_admin
|;

print "Enter e-mail address [$svr_admin]:";
chomp($input = <STDIN>);

if ($input) {
  $svr_admin = $input;
}


print qq|


Please enter the domain name or ip address of your computer.
|;
print "Enter server name/ip address [$servername]:";
chomp($input = <STDIN>);

if ($input) {
  $servername = $input;
}

print qq|

Please enter the port for your OPAC interface.
|;
print "Enter OPAC port [$opacport]:";
chomp($input = <STDIN>);

if ($input) {
  $opacport = $input;
}

print qq|

Please enter the port for your Intranet/Librarian interface.
|;
print "Enter intranet port [$kohaport]:";
chomp($input = <STDIN>);

if ($input) {
  $kohaport = $input;
}


#
# Update Apache Conf File.
#
#

my $logfiledir=`grep ^ErrorLog $realhttpdconf`;
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
open HC, $realhttpdconf;
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
    system("mv -f $realhttpdconf $realhttpdconf\.prekoha");
    $apachebackupmade=1;
    open HC, ">$realhttpdconf";
    print HC $httpdconf;
    close HC;
}


if (`grep 'VirtualHost $servername' $realhttpdconf`) {
    print qq|
$realhttpdconf appears to already have an entry for Koha
Virtual Hosts.  You may need to edit $realhttpdconf
if anything has changed since it was last set up.  This
script will not attempt to modify an existing Koha apache
configuration.

|;
    print "Press <ENTER> to continue...";
    <STDIN>;
    print "\n";
} else {
    unless ($apachebackupmade) {
	system("cp -f $realhttpdconf $realhttpdconf\.prekoha");
    }
    my $includesdirectives='';
    if ($includesmodule) {
	$includesdirectives.="Options +Includes\n";
	$includesdirectives.="   AddHandler server-parsed .html\n";
    }
    open(SITE,">>$realhttpdconf") or warn "Insufficient priveleges to open $realhttpdconf for writing.\n";
    print SITE <<EOP


# Ports to listen to for Koha
Listen $opacport
Listen $kohaport

# NameVirtualHost is used by one of the optional configurations detailed below

#NameVirtualHost 11.22.33.44

# KOHA's OPAC Configuration
<VirtualHost $servername\:$opacport>
   ServerAdmin $svr_admin
   DocumentRoot $opacdir/htdocs
   ServerName $servername
   ScriptAlias /cgi-bin/koha/ $opacdir/cgi-bin/
   ErrorLog $logfiledir/opac-error_log
   TransferLog $logfiledir/opac-access_log
   SetEnv PERL5LIB "$kohadir/modules"
   $includesdirectives
</VirtualHost>

# KOHA's INTRANET Configuration
<VirtualHost $servername\:$kohaport>
   ServerAdmin $svr_admin
   DocumentRoot $kohadir/htdocs
   ServerName $servername
   ScriptAlias /cgi-bin/koha/ "$kohadir/cgi-bin/"
   ErrorLog $logfiledir/koha-error_log
   TransferLog $logfiledir/koha-access_log
   SetEnv PERL5LIB "$kohadir/modules"
   $includesdirectives
</VirtualHost>

# If you want to use name based Virtual Hosting:
#   1. remove the two Listen lines
#   2. replace $servername\:$opacport wih your.opac.domain.name
#   3. replace ServerName $servername wih ServerName your.opac.domain.name
#   4. replace $servername\:$kohaport wih your intranet domain name
#   5. replace ServerName $servername wih ServerName your.intranet.domain.name
#
# If you want to use NameVirtualHost'ing (using two names on one ip address):
#   1.  Follow steps 1-5 above
#   2.  Uncomment the NameVirtualHost line and set the correct ip address

EOP
;


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

<Directory $kohadir>
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
    my $result = mkdir "$kohalogdir",  0770;
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


unless ( -d $kohadir ) {
   print "Creating $kohadir...\n";
   my $result=mkdir ($kohadir, 0770);
   if ($result==0) {
       my @dirs = split(m#/#, $kohadir);
	my $checkdir='';
	foreach (@dirs) {
	    $checkdir.="$_/";
	    unless (-e "$checkdir") {
		mkdir($checkdir, 0775);
	    }
	}
   }
   chown (0, (getgrnam($httpduser))[2], "$kohadir");
   chmod (0770, "$kohadir");
}
unless ( -d "$kohadir/htdocs" ) {
   print "Creating $kohadir/htdocs...\n";
   mkdir ("$kohadir/htdocs", 0750);
}
unless ( -d "$kohadir/cgi-bin" ) {
   print "Creating $kohadir/cgi-bin...\n";
   mkdir ("$kohadir/cgi-bin", 0750);
}
unless ( -d "$kohadir/modules" ) {
   print "Creating $kohadir/modules...\n";
   mkdir ("$kohadir/modules", 0750);
}
unless ( -d "$kohadir/scripts" ) {
   print "Creating $kohadir/scripts...\n";
   mkdir ("$kohadir/scripts", 0750);
}
unless ( -d $opacdir ) {
   print "Creating $opacdir...\n";
   my $result=mkdir ($opacdir, 0770);
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
   chown (0, (getgrnam($httpduser))[2], "$opacdir");
   chmod (0770, "$opacdir");
}
unless ( -d "$opacdir/htdocs" ) {
   print "Creating $opacdir/htdocs...\n";
   mkdir ("$opacdir/htdocs", 0750);
}
unless ( -d "$opacdir/cgi-bin" ) {
   print "Creating $opacdir/cgi-bin...\n";
   mkdir ("$opacdir/cgi-bin", 0750);
}



print "\n\nINSTALLING KOHA...\n";
print "\n\n==================\n";
print "Copying internet-html files to $kohadir/htdocs...\n";
system("cp -R intranet-html/* $kohadir/htdocs/");
print "Copying intranet-cgi files to $kohadir/cgi-bin...\n";
system("cp -R intranet-cgi/* $kohadir/cgi-bin/");
print "Copying script files to $kohadir/scripts...\n";
system("cp -R scripts/* $kohadir/scripts/");
print "Copying module files to $kohadir/modules...\n";
system("cp -R modules/* $kohadir/modules/");
print "Copying opac-html files to $opacdir/htdocs...\n";
system("cp -R opac-html/* $opacdir/htdocs/");
print "Copying opac-cgi files to $opacdir/cgi-bin...\n";
system("cp -R opac-cgi/* $opacdir/cgi-bin/");

system("chown -R root.$httpduser $opacdir");
system("chown -R root.$httpduser $kohadir");



#Create the configuration file
open(SITES,">$etcdir/koha.conf") or warn "Couldn't create file
at $etcdir.  Must have write capability.\n";
print SITES <<EOP
database=$dbname
hostname=$hostname
user=$user
pass=$pass
intrahtdocs=$kohadir/cgi-bin/koha-tmpl/intranet-tmpl
opachtdocs=$kohadir/cgi-bin/koha-tmpl/opac-tmpl
kohalogdir=$kohalogdir
kohaversion=$kohaversion
httpduser=$httpduser
EOP
;
close(SITES);

#
# Set ownership of the koha.conf file for security
#
chown((getpwnam($httpduser)) [2,3], "$etcdir/koha.conf") or warn "can't chown koha.conf: $!";
chmod 0440, "$etcdir/koha.conf";


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
		      /usr
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
my $result=system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass create $dbname");
if ($result) {
    print "\nCouldn't connect to the MySQL server for the reason given above.\n";
    print "This is a serious problem, the database will not get installed.\n";
    print "Press <ENTER> to continue...";
    <STDIN>;
    print "\n";
} else {
    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname < koha.mysql");
    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass mysql -e \"insert into user (Host,User,Password) values ('$hostname','$user',password('$pass'))\"\;");
    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass mysql -e \"insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv, index_priv, alter_priv) values ('%','$dbname','$user','Y','Y','Y','Y','Y','Y','Y','Y')\"");
    system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass reload");

    system ("perl -I $kohadir/modules scripts/updater/updatedatabase");


    print qq|

SAMPLE DATA
===========
If you are installing Koha for evaluation purposes,  I have a batch of sample
data that you can install now.

If you are installing Koha with the intention of populating it with your own
data, you probably don't want this sample data installed.
|;#'
    print "\nWould you like to install the sample data? Y/[N]: ";
    chomp($input = <STDIN>);
    if ($input =~/^y/i) {
	system("gunzip sampledata-1.2.gz");
	system("cat sampledata-1.2 | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
	system("gzip -9 sampledata-1.2");
	system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname -e \"insert into branches (branchcode,branchname,issuing) values ('MAIN', 'Main Library', 1)\"");
	system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname -e \"insert into printers (printername,printqueue,printtype) values ('Circulation Desk Printer', 'lp', 'hp')\"");
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
	    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname -e \"insert into branches (branchcode,branchname,issuing) values ('$branchcode', '$branch', 1)\"");
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
	    system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname -e \"insert into printers (printername,printqueue,printtype) values ('$printername', '$printerqueue', '')\"");
	}
    }


}

print qq|

UPDATING DATABASE (MARC TABLES)
===============================
|;

$answer="";
while ($answer ne "1" && $answer ne "2" && $answer ne "3") {
	print qq|
You can import marc parameters for :
1- english marc21 or for
2- french unimarc.
3- none.
Please choose which parameter you want to install. Note if you choose 3, nothing will be added, and it can be a BIG job to manually create those tables
|;
	$answer = <STDIN>;
	chomp $answer;
}
if ($answer eq "1") {
system("cat script/misc/marc_datas/marc21_en/structure_def.sql | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
}
if ($answer eq "2") {
system("cat scripts/misc/marc_datas/unimarc_fr/structure_def.sql | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
system("cat scripts/misc/lang-datas/fr/stopwords.sql | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
}

#system ("perl -I $kohadir/modules scripts/marc/fill_usmarc.pl");
system ("perl -I $kohadir/modules scripts/marc/updatedb2marc.pl");

chmod 0770, $kohalogdir;
chown((getpwnam($httpduser)) [2,3], $kohalogdir) or warn "can't chown $kohalogdir: $!";

# LAUNCH SCRIPT
print "Modifying Z39.50 daemon launch script...\n";
my $newfile='';
open (L, "$kohadir/scripts/z3950daemon/z3950-daemon-launch.sh");
while (<L>) {
    if (/^RunAsUser=/) {
	$newfile.="RunAsUser=$httpduser\n";
    } elsif (/^KohaZ3950Dir=/) {
	$newfile.="KohaZ3950Dir=$kohadir/scripts/z3950daemon\n";
    } else {
	$newfile.=$_;
    }
}
close L;
system("mv $kohadir/scripts/z3950daemon/z3950-daemon-launch.sh $kohadir/scripts/z3950daemon/z3950-daemon-launch.sh.orig");
open L, ">$kohadir/scripts/z3950daemon/z3950-daemon-launch.sh";
print L $newfile;
close L;


# SHELL SCRIPT
print "Modifying Z39.50 daemon wrapper script...\n";
$newfile='';
open (S, "$kohadir/scripts/z3950daemon/z3950-daemon-shell.sh");
while (<S>) {
    if (/^KohaModuleDir=/) {
	$newfile.="KohaModuleDir=$kohadir/modules\n";
    } elsif (/^KohaZ3950Dir=/) {
	$newfile.="KohaZ3950Dir=$kohadir/scripts/z3950daemon\n";
    } elsif (/^LogDir=/) {
	$newfile.="LogDir=$kohalogdir\n";
    } else {
	$newfile.=$_;
    }
}
close S;

system("mv $kohadir/scripts/z3950daemon/z3950-daemon-shell.sh $kohadir/scripts/z3950daemon/z3950-daemon-shell.sh.orig");
open S, ">$kohadir/scripts/z3950daemon/z3950-daemon-shell.sh";
print S $newfile;
close S;
chmod 0750, "$kohadir/scripts/z3950daemon/z3950-daemon-launch.sh";
chmod 0750, "$kohadir/scripts/z3950daemon/z3950-daemon-shell.sh";
chmod 0750, "$kohadir/scripts/z3950daemon/processz3950queue";
chown(0, (getpwnam($httpduser)) [3], "$kohadir/scripts/z3950daemon/z3950-daemon-shell.sh") or warn "can't chown $kohadir/scripts/z3950daemon/z3950-daemon-shell.sh: $!";
chown(0, (getpwnam($httpduser)) [3], "$kohadir/scripts/z3950daemon/processz3950queue") or warn "can't chown $kohadir/scripts/z3950daemon/processz3950queue: $!";


#RESTART APACHE
print "\n\n";
print qq|

COMPLETED
=========
Congratulations ... your Koha installation is almost complete!
The final step is to restart your webserver.

You will be able to connect to your Librarian interface at:

   http://$servername\:$kohaport/

and the OPAC interface at :

   http://$servername\:$opacport/


Be sure to read the INSTALL, and Hints files.

For more information visit http://www.koha.org

Would you like to restart your webserver now? (Y/[N]):
|;

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
