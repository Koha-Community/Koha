package Install; #assumes Install.pm

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

sub releasecandidatewarning {
    my $language=shift;
    my $kohaversion=shift;
    my $message=getmessage('ReleaseCandidateWarning', $language, [$kohaversion, $kohaversion]);
    my $answer=showmessage($message, 'yn', 'n');

    if ($answer =~ /y/i) {
	print getmessage('continuing', $language);
    } else {
	my $message=getmessage('WatchForReleaseAnnouncements', $language);
	print $message;
	exit;
    };
}


#
# Test for Perl and Modules
#
#
sub checkperlmodules {
    my $language=shift;
    my $message = getmessage('CheckingPerlModules', $language);
    showmessage($message, 'none');
    
    unless (eval "require 5.6.0") {
	die getmessage('PerlVersionFailure', $language, ['5.6.0']);
    }

    my @missing = ();
    unless (eval {require DBI})               { push @missing,"DBI" };
    unless (eval {require Date::Manip})       { push @missing,"Date::Manip" };
    unless (eval {require DBD::mysql})        { push @missing,"DBD::mysql" };
    unless (eval {require Set::Scalar})       { push @missing,"Set::Scalar" };
    unless (eval {require Net::Z3950})        { 
	my $message = getmessage('NETZ3950Missing', $language);
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
	my $message=getmessage('MissingPerlModules', $language, [$missing]);
	showmessage($message, 'none');
	exit;
    }


}


sub getmessage {
    my $messagename=shift;
    my $lang=shift;
    my $variables=shift;
    my $message=$messages->{$messagename}->{$lang} || $messages->{$messagename}->{en} || "Error: No message named $messagename in Install.pm\n";
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
	    my $options=$1;
	    ($defaultresponse) || ($defaultresponse=substr($options,0,1));
	    my $response=<STDIN>;
	    chomp $response;
	    ($response) || ($response=$defaultresponse);
	    return $response;
	}
	if ($responsetype =~/^free$/i) {
	    (defined($defaultresponse)) || ($defaultresponse='');
	    my $response=<STDIN>;
	    chomp $response;
	    ($response) || ($response=$defaultresponse);
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
    my $language=shift;
    my $opacdir = '/usr/local/koha/opac';
    my $intranetdir = '/usr/local/koha/intranet';
    my $getdirinfo=1;
    while ($getdirinfo) {
	# Loop until opac directory and koha directory are different
	my $message=getmessage('GetOpacDir', $language, [$opacdir]);
	$opacdir=showmessage($message, 'free', $opacdir);

	my $message=getmessage('GetIntranetDir', $language, [$intranetdir]);
	$intranetdir=showmessage($message, 'free', $intranetdir);

	if ($intranetdir eq $opacdir) {
	    print qq|

You must specify different directories for the OPAC and INTRANET files!
 :: $intranetdir :: $opacdir ::
|;
<STDIN>
	} else {
	    $getdirinfo=0;
	}
    }
    return ($opacdir, $intranetdir);
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
    my ($language,$dbname,$hostname,$user,$pass)=@_;
#Get the database name

    my $message=getmessage('DatabaseName', $language, [$dbname]);
    $dbname=showmessage($message, 'free', $dbname);

#Get the hostname for the database
    
    $message=getmessage('DatabaseHost', $language, [$hostname]);
    $hostname=showmessage($message, 'free', $hostname);

#Get the username for the database

    $message=getmessage('DatabaseUser', $language, [$dbname, $hostname, $user]);
    $user=showmessage($message, 'free', $user);

#Get the password for the database user

    while ($pass eq '') {
	my $message=getmessage('DatabasePassword', $language, [$user]);
	$pass=showmessage($message, 'free', $pass);
	if ($pass eq '') {
	    my $message=getmessage('BlankPassword', $language);
	    showmessage($message,'PressEnter');
	}
    }
    return($dbname,$hostname,$user,$pass);
}

END { }       # module clean-up code here (global destructor)

