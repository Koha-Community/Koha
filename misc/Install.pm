package Install; #assumes Install.pm


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

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(	&checkperlmodules
		&getmessage
		&showmessage
		&releasecandidatewarning
		&getinstallationdirectories
		&getdatabaseinfo
		&getapacheinfo
		&getapachevhostinfo
		&updateapacheconf
		&basicauthentication
		&installfiles
		&databasesetup
		&updatedatabase
		&populatedatabase
		&restartapache
		&loadconfigfile
		);


my $messages;
$messages->{'continuing'}->{en}="Great!  Continuing setup.\n\n";
$messages->{'WelcomeToKohaInstaller'}->{en}=qq|
=================================
= Welcome to the Koha Installer =
=================================

Welcome to the Koha install script!  This script will prompt you for some
basic information about your desired setup, then install Koha according to
your specifications.  To accept the default value for any question, simply hit
Enter at the prompt.

Please be sure to read the documentation, or visit the Koha website at 
http://www.koha.org for more information.

Are you ready to begin the installation? (Y/[N]): |;
$messages->{'ReleaseCandidateWarning'}->{en}=qq|
=====================
= RELEASE CANDIDATE =
=====================

WARNING WARNING WARNING WARNING WARNING

You are about to install Koha version %s.  This version of Koha is a
release candidate.  It is not intended to be installed on production systems.
It is being released so that users can test it before we release a final
version.

Are you sure you want to install Koha %s? (Y/[N]): |;
$messages->{'WatchForReleaseAnnouncements'}->{en}=qq|

Watch for announcements of Koha releases on the Koha mailing list or the Koha
web site (http://www.koha.org/).

|;

$messages->{'NETZ3950Missing'}->{en}=qq|

The Net::Z3950 module is missing.  This module is necessary if you want to use
Koha's Z39.50 client to download bibliographic records from other libraries.
To install this module, you will need the yaz client installed from
http://www.indexdata.dk/yaz/ and then you can install the perl module with the
command:

perl -MCPAN -e 'install Net::Z3950'

Press the <ENTER> key to continue: |;

$messages->{'CheckingPerlModules'}->{en}=qq|

==================
= PERL & MODULES =
==================

Checking perl modules ...
|;

$messages->{'PerlVersionFailure'}->{en}="Sorry, you need at least Perl %s\n";

$messages->{'MissingPerlModules'}->{en}=qq|

========================
= MISSING PERL MODULES =
========================

You are missing some Perl modules which are required by Koha.
Once these modules have been installed, rerun this installer.
They can be installed by running (as root) the following:

%s
|;

$messages->{'AllPerlModulesInstalled'}->{en}=qq|

==============================
= ALL PERL MODULES INSTALLED =
==============================

All mandatory perl modules are installed.

Press <ENTER> to continue: |;
$messages->{'KohaVersionInstalled'}->{en}="You currently have Koha %s on your system.";
$messages->{'KohaUnknownVersionInstalled'}->{en}="I am not able to determine what version of Koha is installed now.";
$messages->{'KohaAlreadyInstalled'}->{en}=qq|
==========================
= Koha already installed =
==========================

It looks like Koha is already installed on your system (/etc/koha.conf exists
already).  If you would like to upgrade your system to %s, please use
the koha.upgrade script in this directory.

%s

|;
$messages->{'GetOpacDir'}->{en}=qq|
==================
= OPAC DIRECTORY =
==================

Please supply the directory you want Koha to store its OPAC files in.  This
directory will be auto-created for you if it doesn't exist.

OPAC Directory [%s]: |;

$messages->{'GetIntranetDir'}->{en}=qq|
=================================
= INTRANET/LIBRARIANS DIRECTORY =
=================================

Please supply the directory you want Koha to store its Intranet/Librarians
files in.  This directory will be auto-created for you if it doesn't exist.

Intranet Directory [%s]: |;

$messages->{'GetKohaLogDir'}->{en}=qq|
======================
= KOHA LOG DIRECTORY =
======================

Specify a log directory where any Koha daemons can create log files.

Koha Log Directory [%s]: |;

$messages->{'AuthenticationWarning'}->{en}=qq|
==================
= Authentication =
==================

This release of Koha has a new authentication module.  If you are not already
using basic authentication on your intranet, you will be required to log in to
access some of the features of the intranet.  You can log in using the userid
and password from the /etc/koha.conf configuration file at any time.  Use the
"Members" module to add passwords for other accounts and set their permissions.

Press the <ENTER> key to continue: |;

$messages->{'Completed'}->{en}=qq|
==============================
= KOHA INSTALLATION COMPLETE =
==============================

Congratulations ... your Koha installation is complete!

You will be able to connect to your Librarian interface at:

   http://%s\:%s/

and the OPAC interface at :

   http://%s\:%s/


Be sure to read the INSTALL, and Hints files. 

For more information visit http://www.koha.org

Press <ENTER> to exit the installer: |;

sub releasecandidatewarning {
    my $message=getmessage('ReleaseCandidateWarning', [$::newversion, $::newversion]);
    my $answer=showmessage($message, 'yn', 'n');

    if ($answer =~ /y/i) {
	print getmessage('continuing');
    } else {
	my $message=getmessage('WatchForReleaseAnnouncements');
	print $message;
	exit;
    };
}


#
# Test for Perl and Modules
#
#
sub checkperlmodules {
    my $message = getmessage('CheckingPerlModules');
    showmessage($message, 'none');
    
    unless (eval "require 5.006_000") {
	die getmessage('PerlVersionFailure', ['5.6.0']);
    }

    my @missing = ();
    unless (eval {require DBI})               { push @missing,"DBI" };
    unless (eval {require Date::Manip})       { push @missing,"Date::Manip" };
    unless (eval {require DBD::mysql})        { push @missing,"DBD::mysql" };
    unless (eval {require HTML::Template})          { push @missing,"HTML::Template" };
    unless (eval {require Set::Scalar})       { push @missing,"Set::Scalar" };
    unless (eval {require Digest::MD5})       { push @missing,"Digest::MD5" };
    unless (eval {require MARC::Record})       { push @missing,"MARC::Record" };
    unless (eval {require Net::Z3950})        { 
	my $message = getmessage('NETZ3950Missing');
	showmessage($message, 'PressEnter', '', 1);
	if ($#missing>=0) {
	    push @missing, "Net::Z3950";
	}
    }

#
# Print out a list of any missing modules
#

    if (@missing > 0) {
	my $missing='';
	foreach my $module (@missing) {
	    $missing.="   perl -MCPAN -e 'install \"$module\"'\n";
	}
	my $message=getmessage('MissingPerlModules', [$missing]);
	showmessage($message, 'none');
	exit;
    } else {
	showmessage(getmessage('AllPerlModulesInstalled'), 'PressEnter', '', 1);
    }


    unless (-x "/usr/bin/perl") {
	my $realperl=`which perl`;
	chomp $realperl;
	$realperl = showmessage(getmessage('NoUsrBinPerl'), 'none');
	until (-x $realperl) {
	    $realperl=showmessage(getmessage('AskLocationOfPerlExecutable', $realperl), 'free', $realperl, 1);
	}
	my $response=showmessage(getmessage('ConfirmPerlExecutableSymlink', $realperl), 'yn', 'y', 1);
	unless ($response eq 'n') {
	    system("ln -s $realperl /usr/bin/perl");
	}
    }


}

$messages->{'NoUsrBinPerl'}->{en}=qq|

========================================
= Perl is not located in /usr/bin/perl =
========================================

The Koha perl scripts expect to find the perl executable in the /usr/bin
directory.  It is not there on your system.

|;

$messages->{'AskLocationOfPerlExecutable'}->{en}=qq|Location of Perl Executable: [%s]: |;
$messages->{'ConfirmPerlExecutableSymlink'}->{en}=qq|
The Koha scripts will _not_ work without a symlink from %s to /usr/bin/perl

May I create this symlink? ([Y]/N): 
: |;

sub getmessage {
    my $messagename=shift;
    my $variables=shift;
    my $message=$messages->{$messagename}->{$::language} || $messages->{$messagename}->{en} || "Error: No message named $messagename in Install.pm\n";
    if (defined($variables)) {
	$message=sprintf $message, @$variables;
    }
    return $message;
}


sub showmessage {
    my $message=shift;
    my $responsetype=shift;
    my $defaultresponse=shift;
    my $noclear=shift;
    ($noclear) || (system('clear'));
    if ($responsetype =~ /^yn$/) {
	$responsetype='restrictchar yn';
    }
    print $message;
    SWITCH: {
	if ($responsetype =~/^restrictchar (.*)/i) {
	    my $response='\0';
	    my $options=$1;
	    until ($options=~/$response/) {
		($defaultresponse) || ($defaultresponse=substr($options,0,1));
		$response=<STDIN>;
		chomp $response;
		(length($response)) || ($response=$defaultresponse);
		unless ($options=~/$response/) {
		    ($noclear) || (system('clear'));
		    print "Invalid Response.  Choose from [$options].\n\n";
		    print $message;
		}
	    }
	    return $response;
	}
	if ($responsetype =~/^free$/i) {
	    (defined($defaultresponse)) || ($defaultresponse='');
	    my $response=<STDIN>;
	    chomp $response;
	    ($response) || ($response=$defaultresponse);
	    return $response;
	}
	if ($responsetype =~/^numerical$/i) {
	    (defined($defaultresponse)) || ($defaultresponse='');
	    my $response='';
	    until ($response=~/^\d+$/) {
		$response=<STDIN>;
		chomp $response;
		($response) || ($response=$defaultresponse);
		unless ($response=~/^\d+$/) {
		    ($noclear) || (system('clear'));
		    print "Invalid Response ($response).  Response must be a number.\n\n";
		    print $message;
		}
	    }
	    return $response;
	}
	if ($responsetype =~/^email$/i) {
	    (defined($defaultresponse)) || ($defaultresponse='');
	    my $response='';
	    until ($response=~/.*\@.*\..*/) {
		$response=<STDIN>;
		chomp $response;
		($response) || ($response=$defaultresponse);
		unless ($response=~/.*\@.*\..*/) {
		    ($noclear) || (system('clear'));
		    print "Invalid Response ($response).  Response must be a valid email address.\n\n";
		    print $message;
		}
	    }
	    return $response;
	}
	if ($responsetype =~/^PressEnter$/i) {
	    <STDIN>;
	    return;
	}
	if ($responsetype =~/^none$/i) {
	    return;
	}
    }
}

sub getinstallationdirectories {
    $::opacdir = '/usr/local/koha/opac';
    $::intranetdir = '/usr/local/koha/intranet';
    my $getdirinfo=1;
    while ($getdirinfo) {
	# Loop until opac directory and koha directory are different
	my $message=getmessage('GetOpacDir', [$::opacdir]);
	$::opacdir=showmessage($message, 'free', $::opacdir);

	$message=getmessage('GetIntranetDir', [$::intranetdir]);
	$::intranetdir=showmessage($message, 'free', $::intranetdir);

	if ($::intranetdir eq $::opacdir) {
	    print qq|

You must specify different directories for the OPAC and INTRANET files!
 :: $::intranetdir :: $::opacdir ::
|;
<STDIN>
	} else {
	    $getdirinfo=0;
	}
    }
    $::kohalogdir='/var/log/koha';
    my $message=getmessage('GetKohaLogDir', [$::kohalogdir]);
    $::kohalogdir=showmessage($message, 'free', $::kohalogdir);


    unless ( -d $::intranetdir ) {
       my $result=mkdir ($::intranetdir, oct(770));
       if ($result==0) {
	   my @dirs = split(m#/#, $::intranetdir);
	    my $checkdir='';
	    foreach (@dirs) {
		$checkdir.="$_/";
		unless (-e "$checkdir") {
		    mkdir($checkdir, 0775);
		}
	    }
       }
       chown (oct(0), (getgrnam($::httpduser))[2], "$::intranetdir");
       chmod (oct(770), "$::intranetdir");
    }
    unless ( -d "$::intranetdir/htdocs" ) {
       mkdir ("$::intranetdir/htdocs", oct(750));
    }
    unless ( -d "$::intranetdir/cgi-bin" ) {
       mkdir ("$::intranetdir/cgi-bin", oct(750));
    }
    unless ( -d "$::intranetdir/modules" ) {
       mkdir ("$::intranetdir/modules", oct(750));
    }
    unless ( -d "$::intranetdir/scripts" ) {
       mkdir ("$::intranetdir/scripts", oct(750));
    }
    unless ( -d $::opacdir ) {
       my $result=mkdir ($::opacdir, oct(770));
       if ($result==0) {
	   my @dirs = split(m#/#, $::opacdir);
	    my $checkdir='';
	    foreach (@dirs) {
		$checkdir.="$_/";
		unless (-e "$checkdir") {
		    mkdir($checkdir, 0775);
		}
	    }
       }
       chown (oct(0), (getgrnam($::httpduser))[2], "$::opacdir");
       chmod (oct(770), "$::opacdir");
    }
    unless ( -d "$::opacdir/htdocs" ) {
       mkdir ("$::opacdir/htdocs", oct(750));
    }
    unless ( -d "$::opacdir/cgi-bin" ) {
       mkdir ("$::opacdir/cgi-bin", oct(750));
    }


    unless ( -d $::kohalogdir ) {
       my $result=mkdir ($::kohalogdir, oct(770));
       if ($result==0) {
	   my @dirs = split(m#/#, $::kohalogdir);
	    my $checkdir='';
	    foreach (@dirs) {
		$checkdir.="$_/";
		unless (-e "$checkdir") {
		    mkdir($checkdir, 0775);
		}
	    }
       }

       chown (oct(0), (getgrnam($::httpduser))[2,3], "$::kohalogdir");
       chmod (oct(770), "$::kohalogdir");
    }
}



$messages->{'DatabaseName'}->{en}=qq|
==========================
= Name of MySQL database =
==========================

Please provide the name of the mysql database for your koha installation.

Database name [%s]: |;

$messages->{'DatabaseHost'}->{en}=qq|
=================
= Database Host =
=================

Please provide the hostname for mysql.  Unless the database is located on
another machine this will be "localhost".

Database host [%s]: |;

$messages->{'DatabaseUser'}->{en}=qq|
=================
= Database User =
=================

Please provide the name of the user, who will have full administrative rights
to the %s database, when authenticating from %s.

Database user [%s]: |;

$messages->{'DatabasePassword'}->{en}=qq|
=====================
= Database Password =
=====================

Please provide a good password for the user %s.

Database Password: |;

$messages->{'BlankPassword'}->{en}=qq|
==================
= BLANK PASSWORD =
==================

You must not use a blank password for your MySQL user!

Press <ENTER> to try again: 
|;

sub getdatabaseinfo {

    $::dbname = 'Koha';
    $::hostname = 'localhost';
    $::user = 'kohaadmin';
    $::pass = '';

#Get the database name

    my $message=getmessage('DatabaseName', [$::dbname]);
    $::dbname=showmessage($message, 'free', $::dbname);

#Get the hostname for the database
    
    $message=getmessage('DatabaseHost', [$::hostname]);
    $::hostname=showmessage($message, 'free', $::hostname);

#Get the username for the database

    $message=getmessage('DatabaseUser', [$::dbname, $::hostname, $::user]);
    $::user=showmessage($message, 'free', $::user);

#Get the password for the database user

    while ($::pass eq '') {
	my $message=getmessage('DatabasePassword', [$::user]);
	$::pass=showmessage($message, 'free', $::pass);
	if ($::pass eq '') {
	    my $message=getmessage('BlankPassword');
	    showmessage($message,'PressEnter');
	}
    }
}



$messages->{'FoundMultipleApacheConfFiles'}->{en}=qq|
================================
= MULTIPLE APACHE CONFIG FILES =
================================

I found more than one possible Apache configuration file:

%s

Choose the correct file [1]: |;

$messages->{'NoApacheConfFiles'}->{en}=qq|
===============================
= NO APACHE CONFIG FILE FOUND =
===============================

I was not able to find your Apache configuration file.

The file is usually called httpd.conf or apache.conf.

Please specify the location of your config file: |;

$messages->{'NotAFile'}->{en}=qq|
=======================
= FILE DOES NOT EXIST =
=======================

The file %s does not exist.

Please press <ENTER> to continue: |;

$messages->{'EnterApacheUser'}->{en}=qq|
====================
= NEED APACHE USER =
====================

I was not able to determine the user that Apache is running as.  This
information is necessary in order to set the access privileges correctly on
/etc/koha.conf.  This user should be set in one of the Apache configuration
files using the "User" directive.

Enter the Apache userid: |;

$messages->{'InvalidUserid'}->{en}=qq|
==================
= INVALID USERID =
==================

The userid %s is not a valid userid on this system.

Press <ENTER> to continue: |;

sub getapacheinfo {
    my @confpossibilities;

    foreach my $httpdconf (qw(/usr/local/apache/conf/httpd.conf
			  /usr/local/etc/apache/httpd.conf
			  /usr/local/etc/apache/apache.conf
			  /var/www/conf/httpd.conf
			  /etc/apache/conf/httpd.conf
			  /etc/apache/conf/apache.conf
			  /etc/apache-ssl/conf/apache.conf
			  /etc/apache-ssl/httpd.conf
			  /etc/httpd/conf/httpd.conf
			  /etc/httpd/httpd.conf)) {
	if ( -f $httpdconf ) {
	    push @confpossibilities, $httpdconf;
	}
    }

    if ($#confpossibilities==-1) {
	my $message=getmessage('NoApacheConfFiles');
	my $choice='';
	until (-f $choice) {
	    $choice=showmessage($message, "free", 1);
	    if (-f $choice) {
		$::realhttpdconf=$choice;
	    } else {
		showmessage(getmessage('NotAFile', [$choice]),'PressEnter', '', 1);
	    }
	}
    } elsif ($#confpossibilities>0) {
	my $conffiles='';
	my $counter=1;
	my $options='';
	foreach (@confpossibilities) {
	    $conffiles.="   $counter: $_\n";
	    $options.="$counter";
	    $counter++;
	}
	my $message=getmessage('FoundMultipleApacheConfFiles', [$conffiles]);
	my $choice=showmessage($message, "restrictchar $options", 1);
	$::realhttpdconf=$confpossibilities[$choice-1];
    } else {
	$::realhttpdconf=$confpossibilities[0];
    }
    unless (open (HTTPDCONF, $::realhttpdconf)) {
	warn "Insufficient privileges to open $::realhttpdconf for reading.\n";
	sleep 4;
    }

    while (<HTTPDCONF>) {
	if (/^\s*User\s+"?([-\w]+)"?\s*$/) {
	    $::httpduser = $1;
	}
    }
    close(HTTPDCONF);




    unless ($::httpduser) {
	my $message=getmessage('EnterApacheUser');
	until (length($::httpduser) && getpwnam($::httpduser)) {
	    $::httpduser=showmessage($message, "free", '');
	    if (length($::httpduser)>0) {
		unless (getpwnam($::httpduser)) {
		    my $message=getmessage('InvalidUserid', [$::httpduser]);
		    showmessage($message,'PressEnter');
		}
	    } else {
	    }
	}
	print "AU: $::httpduser\n";
    }
}


$messages->{'ApacheConfigIntroduction'}->{en}=qq|
========================
= APACHE CONFIGURATION =
========================

Koha needs to setup your Apache configuration file for the
OPAC and LIBRARIAN virtual hosts.  By default this installer
will do this by using one ip address and two different ports
for the virtual hosts.  There are other ways to set this up,
and the installer will leave comments in httpd.conf detailing
what these other options are.


Press <ENTER> to continue: |;

$messages->{'GetVirtualHostEmail'}->{en}=qq|
=============================
= WEB SERVER E-MAIL CONTACT =
=============================

Enter the e-mail address to be used as a contact for the virtual hosts (this
address is displayed if any errors are encountered).

E-mail contact [%s]: |;

$messages->{'GetServerName'}->{en}=qq|
======================================
= WEB SERVER HOST NAME OR IP ADDRESS =
======================================

Please enter the domain name or ip address of your computer.

Host name or IP Address [%s]: |;

$messages->{'GetOpacPort'}->{en}=qq|
==========================
= OPAC VIRTUAL HOST PORT =
==========================

Please enter the port for your OPAC interface.  This defaults to port 80, but
if you are already serving web content from this server, you should change it
to a different port (8000 might be a good choice).

Enter the OPAC Port [%s]: |;

$messages->{'GetIntranetPort'}->{en}=qq|
==============================
= INTRANET VIRTUAL HOST PORT =
==============================

Please enter the port for your Intranet interface.  This must be different from
the OPAC port (%s).

Enter the Intranet Port [%s]: |;


sub getapachevhostinfo {

    $::svr_admin = "webmaster\@$::domainname";
    $::servername=`hostname -f`;
    chomp $::servername;
    $::opacport=80;
    $::intranetport=8080;

    showmessage(getmessage('ApacheConfigIntroduction'), 'PressEnter');

    $::svr_admin=showmessage(getmessage('GetVirtualHostEmail', [$::svr_admin]), 'email', $::svr_admin);
    $::servername=showmessage(getmessage('GetServerName', [$::servername]), 'free', $::servername);


    $::opacport=showmessage(getmessage('GetOpacPort', [$::opacport]), 'numerical', $::opacport);
    $::intranetport=showmessage(getmessage('GetIntranetPort', [$::opacport, $::intranetport]), 'numerical', $::intranetport);

}

$messages->{'StartUpdateApache'}->{en}=qq|
=================================
= UPDATING APACHE CONFIGURATION =
=================================

Checking for modules that need to be loaded...
|;

$messages->{'LoadingApacheModuleModEnv'}->{en}="Loading SetEnv Apache module.\n";

$messages->{'LoadingApacheModuleModInc'}->{en}="Loading Includes Apache module.\n";

$messages->{'ApacheConfigBackupFailed'}->{en}=qq|
======================================
= APACHE CONFIGURATION BACKUP FAILED =
======================================

An error occurred while trying to make a backup copy of %s.

  %s

No changes will be made to the apache configuration file at this time.

Press <ENTER> to continue: |;


$messages->{'ApacheAlreadyConfigured'}->{en}=qq|
=============================
= APACHE ALREADY CONFIGURED =
=============================

%s appears to already have an entry for Koha
Virtual Hosts.  You may need to edit %s
f anything has changed since it was last set up.  This
script will not attempt to modify an existing Koha apache
configuration.

Press <ENTER> to continue: |;

sub updateapacheconf {
    my $logfiledir=`grep ^ErrorLog $::realhttpdconf`;
    chomp $logfiledir;

    if ($logfiledir) {
	$logfiledir=~m#ErrorLog (.*)/[^/]*$#;
	$logfiledir=$1;
    }

    unless ($logfiledir) {
	$logfiledir='logs';
    }

    showmessage(getmessage('StartUpdateApache'), 'none');

    my $httpdconf;
    my $envmodule=0;
    my $includesmodule=0;
    open HC, $::realhttpdconf;
    while (<HC>) {
	if (/^\s*#\s*LoadModule env_module /) {
	    s/^\s*#\s*//;
	    showmessage(getmessage('LoadingApacheModuleModEnv'));
	    $envmodule=1;
	}
	if (/^\s*#\s*LoadModule includes_module /) {
	    s/^\s*#\s*//;
	    showmessage(getmessage('LoadingApacheModuleModInc'));
	}
	if (/\s*LoadModule includes_module / ) {
	    $includesmodule=1;
	}
	$httpdconf.=$_;
    }

    my $backupfailed=0;
    $backupfailed=`cp -f $::realhttpdconf $::realhttpdconf\.prekoha`;
    if ($backupfailed) {
	showmessage(getmessage('ApacheConfigBackupFailed', [$::realhttpdconf,$backupfailed ]), 'PressEnter');
	return;
    }

    if ($envmodule || $includesmodule) {
	open HC, ">$::realhttpdconf";
	print HC $httpdconf;
	close HC;
    }


    
    if (`grep 'VirtualHost $::servername' $::realhttpdconf`) {
	showmessage(getmessage('ApacheAlreadyConfigured', [$::realhttpdconf, $::realhttpdconf]), 'PressEnter');
	return;
    } else {
	my $includesdirectives='';
	if ($includesmodule) {
	    $includesdirectives.="Options +Includes\n";
	    $includesdirectives.="   AddHandler server-parsed .html\n";
	}
	open(SITE,">>$::realhttpdconf") or warn "Insufficient priveleges to open $::realhttpdconf for writing.\n";
	my $opaclisten = '';
	if ($::opacport != 80) {
	    $opaclisten="Listen $::opacport";
	}
	my $intranetlisten = '';
	if ($::intranetport != 80) {
	    $intranetlisten="Listen $::intranetport";
	}
	print SITE <<EOP

# Ports to listen to for Koha
$opaclisten
$intranetlisten

# NameVirtualHost is used by one of the optional configurations detailed below

#NameVirtualHost 11.22.33.44

# KOHA's OPAC Configuration
<VirtualHost $::servername\:$::opacport>
   ServerAdmin $::svr_admin
   DocumentRoot $::opacdir/htdocs
   ServerName $::servername
   ScriptAlias /cgi-bin/koha/ $::opacdir/cgi-bin/
   ErrorLog $logfiledir/opac-error_log
   TransferLog $logfiledir/opac-access_log
   SetEnv PERL5LIB "$::intranetdir/modules"
   $includesdirectives
</VirtualHost>

# KOHA's INTRANET Configuration
<VirtualHost $::servername\:$::intranetport>
   ServerAdmin $::svr_admin
   DocumentRoot $::intranetdir/htdocs
   ServerName $::servername
   ScriptAlias /cgi-bin/koha/ "$::intranetdir/cgi-bin/"
   ErrorLog $logfiledir/koha-error_log
   TransferLog $logfiledir/koha-access_log
   SetEnv PERL5LIB "$::intranetdir/modules"
   $includesdirectives
</VirtualHost>

# If you want to use name based Virtual Hosting:
#   1. remove the two Listen lines
#   2. replace $::servername\:$::opacport wih your.opac.domain.name
#   3. replace ServerName $::servername wih ServerName your.opac.domain.name
#   4. replace $::servername\:$::intranetport wih your intranet domain name
#   5. replace ServerName $::servername wih ServerName your.intranet.domain.name
#
# If you want to use NameVirtualHost'ing (using two names on one ip address):
#   1.  Follow steps 1-5 above
#   2.  Uncomment the NameVirtualHost line and set the correct ip address

EOP


    }
}

$messages->{'IntranetAuthenticationQuestion'}->{en}=qq|
===========================
= INTRANET AUTHENTICATION =
===========================

I can set it up so that the Intranet/Librarian site is password protected using
Apache's Basic Authorization.

Would you like to do this ([Y]/N): |;

$messages->{'BasicAuthUsername'}->{en}="Please enter a userid for intranet access [%s]: ";
$messages->{'BasicAuthPassword'}->{en}="Please enter a password for %s: ";
$messages->{'BasicAuthPasswordWasBlank'}->{en}="\nYou cannot use a blank password!\n\n";

sub basicauthentication {
    my $message=getmessage('IntranetAuthenticationQuestion');
    my $answer=showmessage($message, 'yn', 'y');

    my $apacheauthusername='librarian';
    my $apacheauthpassword='';
    if ($answer=~/^y/i) {
	($apacheauthusername) = showmessage(getmessage('BasicAuthUsername', [ $apacheauthusername]), 'free', $apacheauthusername, 1);
	$apacheauthusername=~s/[^a-zA-Z0-9]//g;
	while (! $apacheauthpassword) {
	    ($apacheauthpassword) = showmessage(getmessage('BasicAuthPassword', [ $apacheauthusername]), 'free', 1);
	    if (!$apacheauthpassword) {
		($apacheauthpassword) = showmessage(getmessage('BasicAuthPasswordWasBlank'), 'none', '', 1);
	    }
	}
	open AUTH, ">/etc/kohaintranet.pass";
	my $chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
	my $salt=substr($chars, int(rand(length($chars))),1);
	$salt.=substr($chars, int(rand(length($chars))),1);
	print AUTH $apacheauthusername.":".crypt($apacheauthpassword, $salt)."\n";
	close AUTH;
	open(SITE,">>$::realhttpdconf") or warn "Insufficient priveleges to open $::realhttpdconf for writing.\n";
	print SITE <<EOP

<Directory $::intranetdir>
    AuthUserFile /etc/kohaintranet.pass
    AuthType Basic
    AuthName "Koha Intranet (for librarians only)"
    Require  valid-user
</Directory>
EOP
    }
    close(SITE);
}

$messages->{'InstallFiles'}->{en}=qq|
====================
= INSTALLING FILES =
====================

Copying files to installation directories:

|;


$messages->{'CopyingFiles'}->{en}="Copying %s to %s.\n";



sub installfiles {


    showmessage(getmessage('InstallFiles'),'none');
    print getmessage('CopyingFiles', ['intranet-html', "$::intranetdir/htdocs" ]);
    system("cp -R intranet-html/* $::intranetdir/htdocs/");
    print getmessage('CopyingFiles', ['intranet-cgi', "$::intranetdir/cgi-bin" ]);
    system("cp -R intranet-cgi/* $::intranetdir/cgi-bin/");
    print getmessage('CopyingFiles', ['stand-alone scripts', "$::intranetdir/scripts" ]);
    system("cp -R scripts/* $::intranetdir/scripts/");
    print getmessage('CopyingFiles', ['perl modules', "$::intranetdir/modules" ]);
    system("cp -R modules/* $::intranetdir/modules/");
    print getmessage('CopyingFiles', ['opac-html', "$::opacdir/htdocs" ]);
    system("cp -R opac-html/* $::opacdir/htdocs/");
    print getmessage('CopyingFiles', ['opac-cgi', "$::opacdir/cgi-bin" ]);
    system("cp -R opac-cgi/* $::opacdir/cgi-bin/");
    system("touch $::opacdir/cgi-bin/opac");

    system("chown -R root.$::httpduser $::opacdir");
    system("chown -R root.$::httpduser $::intranetdir");

    # Create /etc/koha.conf

    my $old_umask = umask(027); # make sure koha.conf is never world-readable
    open(SITES,">$::etcdir/koha.conf.tmp") or warn "Couldn't create file at $::etcdir. Must have write capability.\n";
    print SITES qq|
database=$::dbname
hostname=$::hostname
user=$::user
pass=$::pass
includes=$::intranetdir/htdocs/includes
intranetdir=$::intranetdir
opacdir=$::opacdir
kohalogdir=$::kohalogdir
kohaversion=$::kohaversion
httpduser=$::httpduser
|;
    close(SITES);
    umask($old_umask);

    chown((getpwnam($::httpduser)) [2,3], "$::etcdir/koha.conf.tmp") or warn "can't chown koha.conf: $!";
    chmod 0440, "$::etcdir/koha.conf.tmp";

    chmod 0750, "$::intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh";
    chmod 0750, "$::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh";
    chmod 0750, "$::intranetdir/scripts/z3950daemon/processz3950queue";
    chown(0, (getpwnam($::httpduser)) [3], "$::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh") or warn "can't chown $::intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh: $!";
    chown(0, (getpwnam($::httpduser)) [3], "$::intranetdir/scripts/z3950daemon/processz3950queue") or warn "can't chown $::intranetdir/scripts/z3950daemon/processz3950queue: $!";

}

$messages->{'MysqlRootPassword'}->{en}=qq|
============================
= MYSQL ROOT USER PASSWORD =
============================

To allow us to create the koha database please supply your
mysql server's root user password:

Enter MySql root user password: |;

$messages->{'InvalidMysqlRootPassword'}->{en}="Invalid Password.  Please try again.";

$messages->{'CreatingDatabase'}->{en}=qq|
=====================
= CREATING DATABASE =
=====================

Creating the MySql database for Koha...

|;

$messages->{'CreatingDatabaseError'}->{en}=qq|
===========================
= ERROR CREATING DATABASE =
===========================

Couldn't connect to the MySQL server for the reason given above.
This is a serious problem, the database will not get installed.

Press <ENTER> to continue: |;

$messages->{'SampleData'}->{en}=qq|
===============
= SAMPLE DATA =
===============

If you are installing Koha for evaluation purposes,  I have a batch of sample
data that you can install now.

If you are installing Koha with the intention of populating it with your own
data, you probably don't want this sample data installed.

Would you like to install the sample data? Y/[N]: |;

$messages->{'SampleDataInstalled'}->{en}=qq|
=========================
= SAMPLE DATA INSTALLED =
=========================

Sample data has been installed.  For some suggestions on testing Koha, please
read the file doc/HOWTO-Testing.  If you find any bugs, please submit them at
http://bugs.koha.org/.  If you need help with testing Koha, you can post a
question through the koha-devel mailing list, or you can check for a developer
online at +irc.katipo.co.nz:6667 channel #koha.

You can find instructions for subscribing to the Koha mailing lists at:

    http://www.koha.org


Press <ENTER> to continue: |;

$messages->{'AddBranchPrinter'}->{en}=qq|
==========================
= Add Branch and Printer =
==========================

Would you like to install an initial branch and printer? [Y]/N: |;

$messages->{'BranchName'}->{en}="Branch Name [%s]: ";
$messages->{'BranchCode'}->{en}="Branch Code (4 letters or numbers) [%s]: ";
$messages->{'PrinterQueue'}->{en}="Printer Queue [%s]: ";
$messages->{'PrinterName'}->{en}="Printer Name [%s]: ";
$messages->{'BlankMysqlPassword'}->{en}=qq|
========================
= Blank MySql Password =
========================

Do not leave your MySql root password blank unless you know exactly what you
are doing.  To change your MySql root password use the mysqladmin command:

mysqladmin password NEWPASSWORDHERE

Press <ENTER> to continue: 
|;

sub databasesetup {
    $::mysqluser = 'root';
    $::mysqlpass = '';

    foreach my $mysql (qw(/usr/local/mysql
			  /opt/mysql
			  /usr
			  )) {
       if ( -d $mysql  && -f "$mysql/bin/mysqladmin") {
	    $::mysqldir=$mysql;
       }
    }
    if (!$::mysqldir){
	print "I don't see mysql in the usual places.\n";
	for (;;) {
	    print "Where have you installed mysql? ";
	    chomp($::mysqldir = <STDIN>);
	    last if -f "$::mysqldir/bin/mysqladmin";
	print <<EOP;

I can't find it there either. If you compiled mysql yourself,
please give the value of --prefix when you ran configure.

The file mysqladmin should be in bin/mysqladmin under the directory that you
provide here.

EOP
	}
    }


    my $needpassword=1;
    while ($needpassword) {
	$::mysqlpass=showmessage(getmessage('MysqlRootPassword'), 'free');
	$::mysqlpass_quoted = $::mysqlpass;
	$::mysqlpass_quoted =~ s/"/\\"/g;
	$::mysqlpass_quoted="-p\"$::mysqlpass_quoted\"";
	$::mysqlpass eq '' and $::mysqlpass_quoted='';
	my $result=system("$::mysqldir/bin/mysqladmin -u$::mysqluser $::mysqlpass_quoted proc > /dev/null 2>&1");
	if ($result) {
	    print getmessage('InvalidMysqlRootPassword');
	} else {
	    if ($::mysqlpass eq '') {
		showmessage(getmessage('BlankMysqlPassword'), 'PressEnter');
	    }
	    $needpassword=0;
	}
    }

    showmessage(getmessage('CreatingDatabase'),'none');

    my $result=system("$::mysqldir/bin/mysqladmin", "-u$::mysqluser", "-p$::mysqlpass", "create", "$::dbname");
    if ($result) {
	showmessage(getmessage('CreatingDatabaseError'),'PressEnter', '', 1);
    } else {
	# Populate the Koha database
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname < koha.mysql");
	# Set up permissions
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted mysql -e \"insert into user (Host,User,Password) values ('$::hostname','$::user',password('$::pass'))\"\;");
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted mysql -e \"insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv, index_priv, alter_priv) values ('%','$::dbname','$::user','Y','Y','Y','Y','Y','Y','Y','Y')\"");
	system("$::mysqldir/bin/mysqladmin -u$::mysqluser $::mysqlpass_quoted reload");





    }

}

$messages->{'UpdateMarcTables'}->{en}=qq|
=========================================
= UPDATING MARC FIELD DEFINITION TABLES =
=========================================

You can import marc parameters for :

  1 MARC21
  2 UNIMARC
  3 none

Please choose which parameter you want to install. Note if you choose 3,
nothing will be added, and it can be a BIG job to manually create those tables

Choose MARC definition [1]: |;


sub updatedatabase {
    my $result=system ("perl -I $::intranetdir/modules scripts/updater/updatedatabase");
    if ($result) {
	print "Problem updating database...\n";
	exit;
    }

    my $response=showmessage(getmessage('UpdateMarcTables'), 'restrictchar 123', '1');

    if ($response == 1) {
	system("cat script/misc/marc_datas/marc21_en/structure_def.sql | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
    }
    if ($response == 2) {
	system("cat scripts/misc/marc_datas/unimarc_fr/structure_def.sql | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
	system("cat scripts/misc/lang-datas/fr/stopwords.sql | $mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname");
    }

    system ("perl -I $kohadir/modules scripts/marc/updatedb2marc.pl");

    
    print "\n\nFinished updating database. Press <ENTER> to continue...";
    <STDIN>;
}

sub populatedatabase {
    my $response=showmessage(getmessage('SampleData'), 'yn', 'n');
    if ($response =~/^y/i) {
	system("gunzip sampledata-1.2.gz");
	system("cat sampledata-1.2 | $::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname");
	system("gzip -9 sampledata-1.2");
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into branches (branchcode,branchname,issuing) values ('MAIN', 'Main Library', 1)\"");
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'IS')\"");
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'CU')\"");
	system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into printers (printername,printqueue,printtype) values ('Circulation Desk Printer', 'lp', 'hp')\"");
	showmessage(getmessage('SampleDataInstalled'), 'PressEnter','',1);
    } else {
	my $input;
	my $response=showmessage(getmessage('AddBranchPrinter'), 'yn', 'y');

	unless ($response =~/^n/i) {
	    my $branch='Main Library';
	    $branch=showmessage(getmessage('BranchName', [$branch]), 'free', $branch, 1);
	    $branch=~s/[^A-Za-z0-9\s]//g;

	    my $branchcode=$branch;
	    $branchcode=~s/[^A-Za-z0-9]//g;
	    $branchcode=uc($branchcode);
	    $branchcode=substr($branchcode,0,4);
	    $branchcode=showmessage(getmessage('BranchCode', [$branchcode]), 'free', $branchcode, 1);
	    $branchcode=~s/[^A-Za-z0-9]//g;
	    $branchcode=uc($branchcode);
	    $branchcode=substr($branchcode,0,4);
	    $branchcode or $branchcode='DEF';

	    system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into branches (branchcode,branchname,issuing) values ('$branchcode', '$branch', 1)\"");
	    system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'IS')\"");
	    system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'CU')\"");

	    my $printername='Library Printer';
	    $printername=showmessage(getmessage('PrinterName', [$printername]), 'free', $printername, 1);
	    $printername=~s/[^A-Za-z0-9\s]//g;

	    my $printerqueue='lp';
	    $printerqueue=showmessage(getmessage('PrinterQueue', [$printerqueue]), 'free', $printerqueue, 1);
	    $printerqueue=~s/[^A-Za-z0-9]//g;
	    system("$::mysqldir/bin/mysql -u$::mysqluser $::mysqlpass_quoted $::dbname -e \"insert into printers (printername,printqueue,printtype) values ('$printername', '$printerqueue', '')\"");

	}
    }
}

$messages->{'RestartApache'}->{en}=qq|
==================
= RESTART APACHE =
==================

Apache needs to be restarted to load the new configuration for Koha.

Would you like to restart Apache now?  [Y]/N: |;

sub restartapache {

    my $response=showmessage(getmessage('RestartApache'), 'yn', 'y');



    unless ($response=~/^n/i) {
	# Need to support other init structures here?
	if (-e "/etc/rc.d/init.d/httpd") {
	    system('/etc/rc.d/init.d/httpd restart');
	} elsif (-e "/etc/init.d/apache") {
	    system('/etc//init.d/apache restart');
	} elsif (-e "/etc/init.d/apache-ssl") {
	    system('/etc/init.d/apache-ssl restart');
	}
    }

}


sub loadconfigfile {
    my %configfile;

    open (KC, "/etc/koha.conf");
    while (<KC>) {
     chomp;
     (next) if (/^\s*#/);
     if (/(.*)\s*=\s*(.*)/) {
       my $variable=$1;
       my $value=$2;
       # Clean up white space at beginning and end
       $variable=~s/^\s*//g;
       $variable=~s/\s*$//g;
       $value=~s/^\s*//g;
       $value=~s/\s*$//g;
       $configfile{$variable}=$value;
     }
    }

    $::intranetdir=$configfile{'intranetdir'};
    $::opacdir=$configfile{'opacdir'};
    $::kohaversion=$configfile{'kohaversion'};
    $::kohalogdir=$configfile{'kohalogdir'};
    $::database=$configfile{'database'};
    $::hostname=$configfile{'hostname'};
    $::user=$configfile{'user'};
    $::pass=$configfile{'pass'};
}

END { }       # module clean-up code here (global destructor)

1;
