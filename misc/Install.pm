package Install; #assumes Install.pm


# Copyright 2000-2002 Katipo Communications
# Contains parts Copyright 2003 MJ Ray
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
#
# Recent Authors
# MJR: my.cnf, etcdir, prefix, new display, apache conf, copying fixups

use strict;
use POSIX;
#MJR: everyone will have these modules, right?
# They look like part of perl core to me
use Term::Cap;
use Term::ANSIColor qw(:constants);
use Text::Wrap;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

=head1 NAME

Install.pm - Perl module containing the bulk of the installation logic

=head1 DESCRIPTION

The Install.pm module contains the bulk
of the code to do installation;
this code is used by installer.pl
to perform an actual installation.

=head2 Internal functions (not meant to be used outside of Install.pm)

=over 4

=cut

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
		&read_autoinstall_file
		&checkperlmodules
		&checkabortedinstall
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
		&backupkoha
		&finalizeconfigfile
		&loadconfigfile
		&backupmycnf
		&restoremycnf
		);

use vars qw( $kohaversion $newversion );			# set in loadconfigfile and installer.pl
use vars qw( $language );			# set in installer.pl
use vars qw( $domainname );			# set in installer.pl

use vars qw( $etcdir );				# set in installer.pl, usu. /etc
use vars qw( $intranetdir $opacdir $kohalogdir );
use vars qw( $realhttpdconf $httpduser );
use vars qw( $servername $svr_admin $opacport $intranetport );
use vars qw( $mysqldir );
use vars qw( $database $mysqluser );
use vars qw( $mysqlpass );			# normally should not be used
use vars qw( $hostname $user $pass );	# virtual hosting

=item heading

    $messages->{'WelcomeToKohaInstaller'
	= heading('Welcome to the Koha Installer') . qq|...|;

The heading function takes one string, the text to be displayed as
the heading, and returns a formatted heading (currently formatted
with ANSI colours).

This reduces the likelihood of pod2man(1) etc. misinterpreting
a line of equal signs as illegal POD directives.

=cut

my $termios = POSIX::Termios->new();
$termios->getattr();
my $terminal = Term::Cap->Tgetent({OSPEED=>$termios->getospeed()});
my $clear_string = "\n";

sub heading ($) {
  my $title = shift;
  my $bal = 5;
  return($clear_string.ON_BLUE.WHITE.BOLD." "x$bal.uc($title)." "x$bal.RESET."\n\n");
}

my $mycnf = $ENV{HOME}."/.my.cnf";
my $mytmpcnf = `mktemp my.cnf.koha.XXXXXX`;
chomp($mytmpcnf);

my $messages;
$messages->{'continuing'}->{en}="Great!  Continuing...\n\n";
$messages->{'WelcomeToKohaInstaller'}->{en} =
   heading('Welcome to the Koha Installer') . qq|
This program will ask some questions and try to install koha for you.
You need to know: where most koha files should be stored (you can set
the prefix environment variable for this); the username and password of
a mysql superuser; and details of your library setup.  You may also need
to know details of your Apache setup.

If you want to install the Koha configuration files somewhere other than
/etc (for multiple Koha versions on one system, for example), you should
set the etcdir environment variable.  Please look at your manuals for
details of how to set that.

Recommended answers are given in brackets after each question.  To accept
the default value for any question (indicated by []), simply hit Enter
at the prompt.

You also can define an auto_install_file, that will answer every question automatically.
To use this feature, run ./installer.pl -i /path/to/auto_install_file 

Are you ready to begin the installation? ([Y]/N): |;

$messages->{'WelcomeToUpgrader'}->{en} =
   heading('Welcome to the Koha Upgrader') . qq|
You are attempting to upgrade from Koha %s to %s.

We recommend that you do a complete backup of all your files before upgrading.
This upgrade script will make a backup copy of your files for you.

Would you like to proceed?  (Y/[N]):|;

$messages->{'AbortingInstall'}->{en} =
   heading('ABORTING') . qq|
Aborting as requested.  Please rerun when you are ready.
|;

$messages->{'ReleaseCandidateWarning'}->{en} =
   heading('RELEASE CANDIDATE') . qq|
WARNING: You are about to install Koha version %s.  This is a
release candidate, It is NOT bugfree.
However, it works, and has been declared stable enough to
be released.

Most people should answer Yes here.

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

...or by installing packages for your distribution, if available.

IMPORTANT NOTE : If you use Perl 5.8.0, you might need to 
edit NET::Z3950's Makefile.PL and yazwrap/Makefile.PL to include:

    'DEFINE' => '-D_GNU_SOURCE',

Also note that some installations of Perl on Red Hat will generate a lot of
"'my_perl' undeclared" errors when running make in Net-Z3950.  This is fixed by
inserting in yazwrap/ywpriv.h a line saying #include "XSUB.h"

Press the <ENTER> key to continue: |;	#'

$messages->{'CheckingPerlModules'}->{en} = heading('PERL MODULES') . qq|
Checking perl modules ...
|;

$messages->{'PerlVersionFailure'}->{en}="Sorry, you need at least Perl %s\n";

$messages->{'MissingPerlModules'}->{en} = heading('MISSING PERL MODULES') . qq|
You are missing some Perl modules required by Koha.
Please run this again after installing them.
They may be installed by finding packages from your operating system supplier, or running (as root) the following commands:

%s
|;

$messages->{'AllPerlModulesInstalled'}->{en} =
   heading('PERL MODULES AVAILABLE') . qq|
All required perl modules are installed.

Press <ENTER> to continue: |;
$messages->{'KohaVersionInstalled'}->{en}="You currently have Koha %s on your system.";
$messages->{'KohaUnknownVersionInstalled'}->{en}="I am not able to determine what version of Koha is installed now.";
$messages->{'KohaAlreadyInstalled'}->{en} =
   heading('Koha already installed') . qq|
It looks like Koha is already installed on your system (%s/koha.conf exists).
If you would like to upgrade your system to %s, please use
the koha.upgrade script in this directory.

%s

|;
$messages->{'GetOpacDir'}->{en} = heading('OPAC DIRECTORY') . qq|
Please supply the directory you want Koha to store its OPAC files in.  This
directory will be auto-created for you if it doesn't exist.

OPAC Directory [%s]: |;	#'

$messages->{'GetIntranetDir'}->{en} =
   heading('LIBRARIAN DIRECTORY') . qq|
Please supply the directory you want Koha to store its Librarian interface
files in.  This directory will be auto-created for you if it doesn't exist.

Intranet Directory [%s]: |;	#'

$messages->{'GetKohaLogDir'}->{en} = heading('LOG DIRECTORY') . qq|
Specify a directory where log files will be written.

Koha Log Directory [%s]: |;

$messages->{'AuthenticationWarning'}->{en} = heading('Authentication') . qq|
This release of Koha has a new authentication module.
You will be required to log in to
access some features.

IMPORTANT: You can log in using the userid and password from the %s/koha.conf configuration file at any time.
Use the "Members" screen to add passwords for other accounts and set their flags.

Press the <ENTER> key to continue: |;

$messages->{'Completed'}->{en} = heading('INSTALLATION COMPLETE') . qq|
Congratulations ... your Koha installation is complete!
You will be able to connect to your Librarian interface at:
   http://%s\:%s/
   use the koha admin mysql login and password to connect to this interface.
and the OPAC interface at:
   http://%s\:%s/
Please read the Hints file and visit http://www.koha.org
Press <ENTER> to exit the installer: |;

$messages->{'UpgradeCompleted'}->{en} = heading('UPGRADE COMPLETE') . qq|
Congratulations ... your Koha upgrade is finished!

If you are upgrading from a version of Koha
prior to 1.2.1, it is likely that you will have to modify your Apache
configuration to point it to the new files.

In your INTRANET VirtualHost section you should have:
  DocumentRoot %s/htdocs
  ScriptAlias /cgi-bin/koha/ %s/cgi-bin/
  SetEnv PERL5LIB %s/modules

In the OPAC VirtualHost section you should have:
  DocumentRoot %s/htdocs
  ScriptAlias /cgi-bin/koha/ %s/cgi-bin/
  SetEnv PERL5LIB %s/modules

You may also need to uncomment a "LoadModules env_module ... " line and restart
Apache.
If you're upgrading from 1.2.x version of Koha note that the MARC DB is NOT populated.
To populate it :
* launch Koha
* Go to Parameters >> Marc structure option and Koha-MARC links option.
* Modify default MARC structure to fit your needs.
* open a console
* type:
cd /path/to/koha/misc
export PERL5LIB=/path/to/koha
./koha2marc.pl
the old DB is "copied" in the new MARC one.
Koha 2.0.0 is ready :-)

Please report any problems you encounter through http://bugs.koha.org/

Press <ENTER> to exit the installer: |;

#'
sub releasecandidatewarning {
    my $message=getmessage('ReleaseCandidateWarning', [$newversion, $newversion]);
    my $answer=showmessage($message, 'yn', 'n');

    if ($answer =~ /y/i) {
	print getmessage('continuing');
    } else {
	my $message=getmessage('WatchForReleaseAnnouncements');
	print $message."\n";
	exit;
    };
}

sub read_autoinstall_file
{
	my $fname = shift;	# Config file to read
	my $retval = {};	# Return value: ref-to-hash holding the
				# configuration

	open (CONF, $fname) or return undef;

	while (<CONF>)
	{
		my $var;		# Variable name
		my $value;		# Variable value

		chomp;
		s/#.*//;		# Strip comments
		next if /^\s*$/;	# Ignore blank lines

		# Look for a line of the form
		#	var = value
		if (!/^\s*(\w+)\s*=\s*(.*?)\s*$/)
		{
			next;
		}

		# Found a variable assignment
		# variable that was already set.
		$var = $1;
		$value = $2;
		$retval->{$var} = $value;
	}
	close CONF;
	if ($retval->{MysqlRootPassword} eq "XXX") {
		print "ERROR : the root password is XXX. It is NOT valid. Edit your auto_install_file\n";
	}
	return $retval;
}

=back

=head2 Accessor functions (for installer.pl)

=over 4

=cut

=item setlanguage

    setlanguage('en');

Sets the installation language, normally "en" (English).
In fact, only "en" is supported.

=cut

sub setlanguage ($) {
    ($language) = @_;
}

=item setdomainname

    setdomainname('example.org');

Sets the domain name of the host.

The domain name should not contain a leading dot;
otherwise, the results are undefined.

=cut

sub setdomainname ($) {
    ($domainname) = @_;
}

=item setetcdir

    setetcdir('/etc');

Sets the sysconfdir, normally /etc.
This should be an absolute path; a trailing / is not required.

=cut

sub setetcdir ($) {
    ($etcdir) = @_;
}

=item getkohaversion

    getkohaversion();

Gets the Koha version as known by the previous config file.

=cut

sub getkohaversion () {
    return($kohaversion);
}

=item setkohaversion

    setkohaversion('1.3.3RC26');

Sets the Koha version as known by the installer.

=cut

sub setkohaversion ($) {
    ($newversion) = @_;
}

=item getservername

    my $servername = getservername;

Gets the name of the Koha virtual server as specified by the user.

=cut

sub getservername () {
    $servername;
}

=item getopacport

    $port = getopacport;

Gets the port that will run the Koha OPAC virtual server,
as specified by the user.

=cut

sub getopacport () {
    $opacport;
}

=item getintranetport

    $port = getintranetport;

Gets the port that will run the Koha INTRANET virtual server,
as specified by the user.

=cut

sub getintranetport () {
    $intranetport;
}

=back

=head2 Miscellaneous utility functions

=over 4

=cut

=item dirname

    dirname $path;

Does the equivalent of dirname(1). Given a path $path, return the
parent directory of $path (best guess), except when $path seems to
be the same as /, in which case $path itself is returned unchanged.

=cut

sub dirname ($;$) {
    my($path) = @_;
    if ($path =~ /[^\/]/s) {
	if ($path =~ /\//) {
	    $path =~ s/\/+[^\/]+\/*$//s;
	} else {
	    $path = '.';
	}
    }
    return $path;
}

=item mkdir_parents

    mkdir_parents $path;
    mkdir_parents $path, $mode;

Does the equivalent of mkdir -p, or mkdir --parents. Given a path $path,
create the directory $path, recursively creating any intermediate
directories. If $mode is given, the directory will be created with
mode $mode.

WARNING: If $path already exists, mkdir_parents will just return
successfully (just like mkdir -p), whether the mode of $path conforms
to $mode or not. (This is the behaviour of the mkdir -p command.)

=cut

sub mkdir_parents {
    my($path, $mode) = @_;
    my $ok = -d($path)? 1: defined $mode? mkdir($path, $mode): mkdir($path);

    if (!$ok && $! == ENOENT) {
	my $parent = dirname($path);
	$ok = mkdir_parents($parent, $mode);

	# retry and at the same time make sure that $! is set correctly
	$ok = defined $mode? mkdir($path, $mode): mkdir($path);
    }
    return $ok;
}


=item getmessage

    getmessage($msgid);
    getmessage($msgid, $variables);

Gets a localized message (format string) with message id $msgid,
and, if an array reference of variables $variables is given,
substitutes variables in the format string with @$variables.
Returns the found message string, with variable substitutions
if specified.

$msgid must be the message identifier corresponding to a defined
message string (a valid key to the $messages hash in the Installer
package). getmessage throws an exception if the message cannot be
found.

=cut

sub getmessage {
    my $messagename=shift;
    my $variables=shift;
    my $message=$messages->{$messagename}->{$language} || $messages->{$messagename}->{en} || RED.BOLD."Error: No message named $messagename in Install.pm\n";
    if (defined($variables)) {
	$message=sprintf $message, @$variables;
    }
    return $message;
}


=item showmessage

    showmessage($message, 'none');
    showmessage($message, 'none', undef, $noclear);

    $result = showmessage($message, 'yn');
    $result = showmessage($message, 'yn', $defaultresponse);
    $result = showmessage($message, 'yn', $defaultresponse, $noclear);

    $result = showmessage($message, 'restrictchar CHARS');
    $result = showmessage($message, 'free');
    $result = showmessage($message, 'silentfree');
    $result = showmessage($message, 'numerical');
    $result = showmessage($message, 'email');
    $result = showmessage($message, 'PressEnter');

Shows a message and optionally gets a response from the user.

The first two arguments, the message and the response type,
are mandatory.  The message must be the actual string to
display; the caller is responsible for calling getmessage if
required.

The response type must be one of "none", "yn", "free", "silentfree"
"numerical", "email", "PressEnter", or a string consisting
of "restrictchar " followed by a list of allowed characters
(space can be specified). (Case is not significant, but case is
significant in the list of allowed characters.) If a response
type other than the above-listed is specified, the result is
undefined.

Note that the response type "yn" is equivalent to "restrictchar yn".
Because "restrictchar" is case-sensitive, the user is expected
to enter "y" or "n" in lowercase only.

Note that the response type of "email" does not actually
guarantee that the returned value is a well-formed RFC-822
email address, nor does it accept all well-formed RFC-822 email
addresses. What it does is to restrict the returned value to a
string that is looks reasonably likely to be an email address
in the "real world", given the premise that the user is trying
to enter a real email address.

If a response type other than "none" or "PressEnter" is
specified, a third argument, specifying the default value, can
be specified:  If this default response is not specified, the
default response is the first allowed character if the response
type is "restrictchar", otherwise the default response is the
empty string. This default response is used when the user does
not specify a value (i.e., presses Enter without typing in
anything), showmessage will assume that the default response is
the user's response.

Note that because the response type "yn" is equivalent to
"restrictchar yn", the default value for response type "yn",
if unspecified, is "y".

The screen is normally cleared before the message is displayed;
if a fourth argument is specified and is nonzero, this
screen-clearing is not done.

=cut
#'

sub showmessage {
    #MJR: Maybe refactor to use anonymous functions that
    # check the responses instead of RnP branching.
    my $message=join('',fill('','',(shift)));
    my $responsetype=shift;
    my $defaultresponse=shift;
    my $noclear=shift;
    $noclear = 0 unless defined $noclear; # defaults to "clear"
    ($noclear) || (print $clear_string);
    if ($responsetype =~ /^yn$/) {
	$responsetype='restrictchar ynYN';
    }
    print RESET.$message;
    if ($responsetype =~/^restrictchar (.*)/i) {
	my $response='\0';
	my $options=$1;
	until ($options=~/$response/) {
	    (defined($defaultresponse)) || ($defaultresponse=substr($options,0,1));
	    $response=<STDIN>;
	    chomp $response;
	    (length($response)) || ($response=$defaultresponse);
            if ( $response=~/.*[\:\(\)\^\$\*\!\\].*/ ) {
                ($noclear) || (print $clear_string);
                print RED."Response contains invalid characters.  Choose from [$options].\n\n";
                print RESET.$message;
                $response='\0';
            } else {
                unless ($options=~/$response/) {
                    ($noclear) || (print $clear_string);
                    print RED."Invalid Response.  Choose from [$options].\n\n";
                    print RESET.$message;
                }
            }
	}
	return $response;
    } elsif ($responsetype =~/^(silent)?free$/i) {
	(defined($defaultresponse)) || ($defaultresponse='');
	if ($responsetype =~/^(silent)/i) { setecho(0) }; 
	my $response=<STDIN>;
	if ($responsetype =~/^(silent)/i) { setecho(1) }; 
	chomp $response;
	($response) || ($response=$defaultresponse);
	return $response;
    } elsif ($responsetype =~/^numerical$/i) {
	(defined($defaultresponse)) || ($defaultresponse='');
	my $response='';
	until ($response=~/^\d+$/) {
	    $response=<STDIN>;
	    chomp $response;
	    ($response) || ($response=$defaultresponse);
	    unless ($response=~/^\d+$/) {
		($noclear) || (print $clear_string);
		print RED."Invalid Response ($response).  Response must be a number.\n\n";
		print RESET.$message;
	    }
	}
	return $response;
    } elsif ($responsetype =~/^email$/i) {
	(defined($defaultresponse)) || ($defaultresponse='');
	my $response='';
	until ($response=~/.*\@.*\..*/) {
	    $response=<STDIN>;
	    chomp $response;
	    ($response) || ($response=$defaultresponse);
	    if ($response!~/.*\@.*\..*/) {
			($noclear) || (print $clear_string);
			print RED."Invalid Response ($response).  Response must be a valid email address.\n\n";
			print RESET.$message;
	    }
	}
	return $response;
    } elsif ($responsetype =~/^PressEnter$/i) {
	<STDIN>;
	return;
    } elsif ($responsetype =~/^none$/i) {
	return;
    } else {
	# FIXME: There are a few places where we will get an undef as the
	# response type. Should we thrown an exception here, or should we
	# legitimize this usage and say "none" is the default if not specified?
	#die "Illegal response type \"$responsetype\"";
    }
}


=back

=item startsysout

	startsysout;

Changes the display to show system output until the next showmessage call.
At the time of writing, this means using red text.

=cut

sub startsysout {
	print RED."\n";
}


=back

=head2 Subtasks of doing an installation

=over 4

=cut

=item checkabortedinstall

    checkabortedinstall;

Checks whether a previous installation process has been abnormally
aborted, by checking whether $etcidr/koha.conf is a symlink matching
a particular pattern.  If an aborted installation is detected, give
the user a chance to abort, before trying to recover the aborted
installation.

FIXME: The recovery is not complete; it only partially rolls back
some changes.

=cut

sub checkabortedinstall () {
    if (-l("$etcdir/koha.conf")
        && readlink("$etcdir/koha.conf") =~ /\.tmp$/
    ) {
        print qq|
I have detected that you tried to install Koha before, but the installation
was aborted.  I will try to continue, but there might be problems if the
database is already created.

|;
        print "Please press <ENTER> to continue: ";
        <STDIN>;

        # Remove the symlink after the <STDIN>, so the user can back out
        unlink "$etcdir/koha.conf"
            || die "Failed to remove incomplete $etcdir/koha.conf: $!\n";
    }
}

=item checkpaths

	checkpaths;

Make sure that we loaded the right dirs from an old koha.conf

=cut

#FIXME: update to use Install.pm
sub checkpaths {
if ($opacdir && $intranetdir) {
    print qq|

I believe that your old files are located in:

  OPAC:      $opacdir
  LIBRARIAN: $intranetdir


Does this look right?  ([Y]/N):
|;
    my $answer = <STDIN>;
    chomp $answer;

    if ($answer =~/n/i) {
	$intranetdir='';
	$opacdir='';
    } else {
	print "Great! continuing upgrade... \n";
    }
}

if (!$opacdir || !$intranetdir) {
    $intranetdir='';
    $opacdir='';
    while (!$intranetdir) {
	print "Please specify the location of your LIBRARIAN files: ";

	my $answer = <STDIN>;
	chomp $answer;

	if ($answer) {
	    $intranetdir=$answer;
	}
	if (! -e "$intranetdir/htdocs") {
	    print "\nCouldn't find the htdocs directory here.  That doesn't look right.\nPlease enter another location.\n\n";
	    $intranetdir='';
	}
    }
    while (!$opacdir) {
	print "Please specify the location of your OPAC files: ";  

	my $answer = <STDIN>;
	chomp $answer;

	if ($answer) {
	    $opacdir=$answer;
	}
	if (! -e "$opacdir/htdocs") {
	    print "\nCouldn't find the htdocs directory here.  That doesn't look right.\nPlease enter another location.\n\n";
	    $opacdir='';
	}
    }
}

}

=item checkperlmodules

    checkperlmodules;

Test whether the version of Perl is new enough, whether Perl is
found at the expected location, and whether all required modules
have been installed.

=cut

sub checkperlmodules {
#
# Test for Perl and Modules
#
	my ($auto_install) = @_;
    my $message = getmessage('CheckingPerlModules');
    showmessage($message, 'none');

    unless ($] >= 5.006001) {			# Bug 179
	die getmessage('PerlVersionFailure', ['5.6.1']);
    }
	startsysout();

    my @missing = ();
    unless (eval {require DBI})              { push @missing,"DBI" };
    unless (eval {require Date::Manip})      { push @missing,"Date::Manip" };
    unless (eval {require DBD::mysql})       { push @missing,"DBD::mysql" };
    unless (eval {require HTML::Template})   { push @missing,"HTML::Template" };
#    unless (eval {require Set::Scalar})      { push @missing,"Set::Scalar" };
    unless (eval {require Digest::MD5})      { push @missing,"Digest::MD5" };
    unless (eval {require MARC::Record})     { push @missing,"MARC::Record" };
    unless (eval {require Mail::Sendmail})   { push @missing,"Mail::Sendmail" };
    unless (eval {require Event})       {
		if ($#missing>=0) { # only when $#missing >= 0 so this isn't fatal
		    push @missing, "Event";
		}
    }
    unless (eval {require Net::Z3950})       {
	showmessage(getmessage('NETZ3950Missing'), 'PressEnter', '', 1);
		if ($#missing>=0) { # see above note
		    push @missing, "Net::Z3950";
		}
    }

#
# Print out a list of any missing modules
#

    if (@missing > 0) {
	my $missing='';
	if (POSIX::setlocale(LC_ALL) ne "C") {
		$missing.="   export LC_ALL=C\n";  
	}
	foreach my $module (@missing) {
	    $missing.="   perl -MCPAN -e 'install \"$module\"'\n";
	}
	my $message=getmessage('MissingPerlModules', [$missing]);
	showmessage($message, 'none');
	print "\n";
	exit;
    } else {
	showmessage(getmessage('AllPerlModulesInstalled'), 'PressEnter', '', 1) unless $auto_install->{NoPressEnter};
    }


	startsysout();
    unless (-x "/usr/bin/perl") {
	my $realperl=`which perl`;
	chomp $realperl;
	$realperl = showmessage(getmessage('NoUsrBinPerl'), 'none');
	until (-x $realperl) {
	    $realperl=showmessage(getmessage('AskLocationOfPerlExecutable', $realperl), 'free', $realperl, 1);
	}
	my $response=showmessage(getmessage('ConfirmPerlExecutableSymlink', $realperl), 'yn', 'y', 1);
	unless ($response eq 'n') {
		startsysout();
	    system("ln -s $realperl /usr/bin/perl");
	}
    }


}

$messages->{'NoUsrBinPerl'}->{en} =
   heading('No /usr/bin/perl') . qq|
Koha expects to find the perl executable in the /usr/bin
directory.  It is not there on your system.

|;

$messages->{'AskLocationOfPerlExecutable'}->{en}=qq|Location of Perl Executable [%s]: |;
$messages->{'ConfirmPerlExecutableSymlink'}->{en}=qq|
Some Koha scripts will _not_ work without a symlink from %s to /usr/bin/perl

Most users should answer Y here.

May I try to create this symlink? ([Y]/N):|;

$messages->{'DirFailed'}->{en} = RED.qq|
We could not create %s, but continuing anyway...

|;



=item getinstallationdirectories

    getinstallationdirectories;

Get the various installation directories from the user, and then
create those directories (if they do not already exist).

These pieces of information are saved to global variables; the
function does not return any values.

=cut

sub getinstallationdirectories {
	my ($auto_install) = @_;
	if (!$ENV{prefix}) { $ENV{prefix} = "/usr/local"; } #"
    $opacdir = $ENV{prefix}.'/koha/opac';
    $intranetdir = $ENV{prefix}.'/koha/intranet';
    my $getdirinfo=1;
    while ($getdirinfo) {
	# Loop until opac directory and koha directory are different
	my $message;
	if ($auto_install->{GetOpacDir}) {
		$opacdir=$auto_install->{GetOpacDir};
		print ON_YELLOW.BLACK."auto-setting OpacDir to : $opacdir".RESET."\n";
	} else {
		$message=getmessage('GetOpacDir', [$opacdir]);
		$opacdir=showmessage($message, 'free', $opacdir);
	}
	if ($auto_install->{GetIntranetDir}) {
		$intranetdir=$auto_install->{GetIntranetDir};
		print ON_YELLOW.BLACK."auto-setting IntranetDir to : $intranetdir".RESET."\n";
	} else {
		$message=getmessage('GetIntranetDir', [$intranetdir]);
		$intranetdir=showmessage($message, 'free', $intranetdir);
	}
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
    $kohalogdir=$ENV{prefix}.'/koha/log';
	if ($auto_install->{GetOpacDir}) {
		$kohalogdir=$auto_install->{KohaLogDir};
		print ON_YELLOW.BLACK."auto-setting log dir to : $kohalogdir".RESET."\n";
	} else {
	    my $message=getmessage('GetKohaLogDir', [$kohalogdir]);
    	$kohalogdir=showmessage($message, 'free', $kohalogdir);
	}


    # FIXME: Need better error handling for all mkdir calls here
    unless ( -d $intranetdir ) {
       mkdir_parents (dirname($intranetdir), 0775) || print getmessage('DirFailed',['parents of '.$intranetdir]);
       mkdir ($intranetdir,                  0770) || print getmessage('DirFailed',[$intranetdir]);
       if ($>==0) { chown (oct(0), (getgrnam($httpduser))[2], "$intranetdir"); }
       chmod 0770, "$intranetdir";
    }
    mkdir_parents ("$intranetdir/htdocs",    0750);
    mkdir_parents ("$intranetdir/cgi-bin",   0750);
    mkdir_parents ("$intranetdir/modules",   0750);
    mkdir_parents ("$intranetdir/scripts",   0750);
    unless ( -d $opacdir ) {
       mkdir_parents (dirname($opacdir),     0775) || print getmessage('DirFailed',['parents of '.$opacdir]);
       mkdir ($opacdir,                      0770) || print getmessage('DirFailed',[$opacdir]);
       if ($>==0) { chown (oct(0), (getgrnam($httpduser))[2], "$opacdir"); }
       chmod (oct(770), "$opacdir");
    }
    mkdir_parents ("$opacdir/htdocs",        0750);
    mkdir_parents ("$opacdir/cgi-bin",       0750);


    unless ( -d $kohalogdir ) {
       mkdir_parents (dirname($kohalogdir),  0775) || print getmessage('DirFailed',['parents of '.$kohalogdir]);
       mkdir ($kohalogdir,                   0770) || print getmessage('DirFailed',[$kohalogdir]);
       if ($>==0) { chown (oct(0), (getgrnam($httpduser))[2,3], "$kohalogdir"); }
       chmod (oct(770), "$kohalogdir");
    }
}

=item getmysqldir

	getmysqldir;

Get the MySQL database server installation directory, automatically if possible.

=cut

$messages->{'WhereIsMySQL'}->{en} = heading('MYSQL LOCATION').qq|
Koha can't find the MySQL command-line tools. If you installed a MySQL package, you may need to install an additional package containing mysqladmin.
If you compiled mysql yourself,
please give the value of --prefix when you ran configure.
The file mysqladmin should be in bin/mysqladmin under the directory that you give here.

MySQL installation directory: |;
#'
sub getmysqldir {
    foreach my $mysql (qw(/usr/local/mysql
			  /opt/mysql
			  /usr/local
			  /usr
			  )) {
       if ( -d $mysql  && -f "$mysql/bin/mysqladmin") { #"
	    $mysqldir=$mysql;
       }
    }
    if (!$mysqldir){
	for (;;) {
	    $mysqldir = showmessage(getmessage('WhereIsMySQL'),'free');
	    last if -f "$mysqldir/bin/mysqladmin";
	}
    }
    return($mysqldir);
}

=item getdatabaseinfo

    getdatabaseinfo;

Get various pieces of information related to the Koha database:
the name of the database, the host on which the SQL server is
running, and the database user name.

These pieces of information are saved to global variables; the
function does not return any values.

=cut

$messages->{'DatabaseName'}->{en} = heading('Database Name') . qq|
Please provide the name that you wish to give your koha database.
It must not exist already on the database server.

Most users give a short single-word name for their library here.

Database name [%s]: |;

$messages->{'DatabaseHost'}->{en} = heading('Database Host') . qq|
Please provide the mysql server name.  Unless the database is stored on
another machine, this should be "localhost".

Database host [%s]: |;

$messages->{'DatabaseUser'}->{en} = heading('Database User') . qq|
We are going to create a new mysql user for Koha. This user will have full administrative rights
to the database called %s when they connect from %s.
This is also the name of the Koha librarian superuser.

Most users give a single-word name here.

Database user [%s]: |;

$messages->{'DatabasePassword'}->{en} = heading('Database Password') . qq|
Please provide a good password for the user %s.

IMPORTANT: You can log in using this user and password at any time.

Password for database user %s: |;

$messages->{'BlankPassword'}->{en} = heading('BLANK PASSWORD') . qq|
You must not use a blank password for your MySQL user.

Press <ENTER> to try again: 
|;

sub getdatabaseinfo {
	my ($auto_install) = @_;
    $database = 'Koha';
    $hostname = 'localhost';
    $user = 'kohaadmin';
    $pass = '';

#Get the database name
	my $message;
	
	if ($auto_install->{database}) {
		$database=$auto_install->{database};
		print ON_YELLOW.BLACK."auto-setting database to : $database".RESET."\n";
	} else {
		$message=getmessage('DatabaseName', [$database]);
		$database=showmessage($message, 'free', $database);
	}
#Get the hostname for the database
    
	if ($auto_install->{DatabaseHost}) {
		$hostname=$auto_install->{DatabaseHost};
		print ON_YELLOW.BLACK."auto-setting database host to : $hostname".RESET."\n";
	} else {
		$message=getmessage('DatabaseHost', [$hostname]);
		$hostname=showmessage($message, 'free', $hostname);
	}
#Get the username for the database

	if ($auto_install->{DatabaseUser}) {
		$user=$auto_install->{DatabaseUser};
		print ON_YELLOW.BLACK."auto-setting DB user to : $user".RESET."\n";
	} else {
		$message=getmessage('DatabaseUser', [$database, $hostname, $user]);
		$user=showmessage($message, 'free', $user);
	}
#Get the password for the database user

    while ($pass eq '') {
		my $message=getmessage('DatabasePassword', [$user, $user]);
		if ($auto_install->{DatabasePassword}) {
			$pass=$auto_install->{DatabasePassword};
			print ON_YELLOW.BLACK."auto-setting database password to : $pass".RESET."\n";
		} else {
				$pass=showmessage($message, 'free', $pass);
		}
		if ($pass eq '') {
			my $message=getmessage('BlankPassword');
			showmessage($message,'PressEnter');
		}
    }
}



=item getapacheinfo

    getapacheinfo;

Get various pieces of information related to the Apache server:
the location of the configuration file and, if needed, the Unix
user that the Koha CGI will be run under.

These pieces of information are saved to global variables; the
function does not return any values.

=cut

$messages->{'FoundMultipleApacheConfFiles'}->{en} = 
   heading('MULTIPLE APACHE CONFIG FILES FOUND') . qq|
I found more than one possible Apache configuration file:

%s

Enter number of the file to read [1]: |;

$messages->{'NoApacheConfFiles'}->{en} =
   heading('NO APACHE CONFIG FILE FOUND') . qq|
I was not able to find your Apache configuration file.

The file is usually called httpd.conf, apache.conf or similar.

Please enter the full name, starting with /: |;

$messages->{'NotAFile'}->{en} = heading('FILE DOES NOT EXIST') . qq|
The file %s does not exist.

Please press <ENTER> to continue: |;

$messages->{'EnterApacheUser'}->{en} = heading('NEED APACHE USER') . qq\
The installer could not find the User setting in the Apache configuration file.
This is used to set up access permissions for
%s/koha.conf.  This user should be set in one of the Apache configuration.
Please try to find it and enter the user name below.  You might find
that "ps u|grep apache" will tell you.  It probably is NOT "root".

Enter the Apache userid: \;

$messages->{'InvalidUserid'}->{en} = heading('INVALID USER') . qq|
The userid %s is not a valid userid on this system.

Press <ENTER> to continue: |;

sub getapacheinfo {
	my ($auto_install) = @_;
    my @confpossibilities;

    foreach my $httpdconf (qw(/usr/local/apache/conf/httpd.conf
			  /usr/local/etc/apache/httpd.conf
			  /usr/local/etc/apache/apache.conf
			  /var/www/conf/httpd.conf
			  /etc/apache2/httpd.conf
			  /etc/apache2/apache2.conf
			  /etc/apache/conf/httpd.conf
			  /etc/apache/conf/apache.conf
			  /etc/apache/httpd.conf
			  /etc/apache-ssl/conf/apache.conf
			  /etc/apache-ssl/httpd.conf
			  /etc/httpd/conf/httpd.conf
			  /etc/httpd/httpd.conf
			  /etc/httpd/2.0/conf/httpd2.conf
			  )) {
		if ( -f $httpdconf ) {
			push @confpossibilities, $httpdconf;
		}
    }

    if ($#confpossibilities==-1) {
		my $message=getmessage('NoApacheConfFiles');
		my $choice='';
		$realhttpdconf='';
		until (-f $realhttpdconf) {
			$choice=showmessage($message, "free", 1);
			if (-f $choice) {
			$realhttpdconf=$choice;
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
		$realhttpdconf=$confpossibilities[$choice-1];
    } else {
		$realhttpdconf=$confpossibilities[0];
    }
    unless (open (HTTPDCONF, "<$realhttpdconf")) {
	warn RED."Insufficient privileges to open $realhttpdconf for reading.\n";
	sleep 4;
    }

    while (<HTTPDCONF>) {
		if (/^\s*User\s+"?([-\w]+)"?\s*$/) {
			$httpduser = $1;
		}
    }
    close(HTTPDCONF);

    unless (defined($httpduser)) {
		my $message;
		if ($auto_install->{EnterApacheUser}) {
			$message = $auto_install->{EnterApacheUser};
			print ON_YELLOW.BLACK."auto-setting Apache User to : $message".RESET."\n";
		} else {
			$message=getmessage('EnterApacheUser', [$etcdir]);
		}
		until (defined($httpduser) && length($httpduser) && getpwnam($httpduser)) {
			if ($auto_install->{EnterApacheUser}) {
				$httpduser = $auto_install->{EnterApacheUser};
			} else {
				$httpduser=showmessage($message, "free", '');
			}
			if (length($httpduser)>0) {
				unless (getpwnam($httpduser)) {
					my $message=getmessage('InvalidUserid', [$httpduser]);
					showmessage($message,'PressEnter');
				}
			} else {
			}
		}
	}
}


=item getapachevhostinfo

    getapachevhostinfo;

Gets various pieces of information related to virtual hosting:
the webmaster email address, virtual hostname, and the ports
that the OPAC and INTRANET modules run on.

These pieces of information are saved to global variables; the
function does not return any values.

=cut

$messages->{'ApacheConfigIntroduction'}->{en} =
   heading('APACHE CONFIGURATION') . qq|
Koha needs to write an Apache configuration file for the
OPAC and Librarian sites.  By default this installer
will do this by using one name and two different ports
for the virtual hosts.  There are other ways to set this up,
and the installer will leave comments in
%s/koha-httpd.conf about them.

NOTE: You will need to add lines to your main httpd.conf to
include %s/koha-httpd.conf
and to make sure it is listening on the right ports
(using the Listen directive).

Press <ENTER> to continue: |;

$messages->{'GetVirtualHostEmail'}->{en} =
   heading('WEB E-MAIL CONTACT') . qq|
Enter the e-mail address to be used as a contact for Koha.  This
address is displayed if fatal errors are encountered.

E-mail contact [%s]: |;

$messages->{'GetServerName'}->{en} =
   heading('WEB HOST NAME OR IP ADDRESS') . qq|
Please enter the host name or IP address that you wish to use for koha.
Normally, this should be a name or IP that belongs to this machine.

Host name or IP Address [%s]: |;

$messages->{'GetOpacPort'}->{en} = heading('OPAC PORT') . qq|
Please enter the port for your OPAC interface.  This defaults to port 80, but
if you are already serving web content with this hostname, you should change it
to a different port (8000 might be a good choice, but check any firewalls).

Enter the OPAC Port [%s]: |;

$messages->{'GetIntranetPort'}->{en} =
   heading('LIBRARIAN PORT') . qq|
Please enter the port for your Librarian interface.  This must be different from
the OPAC port (%s).

Enter the Intranet Port [%s]: |;


sub getapachevhostinfo {
	my ($auto_install) = @_;
    $svr_admin = "webmaster\@$domainname";
    $servername=`hostname`;
    chomp $servername;
    $opacport=80;
    $intranetport=8080;

	if ($auto_install->{GetVirtualHostEmail}) {
		$svr_admin=$auto_install->{GetVirtualHostEmail};
		print ON_YELLOW.BLACK."auto-setting VirtualHostEmail to : $svr_admin".RESET."\n";
	} else {
		showmessage(getmessage('ApacheConfigIntroduction',[$etcdir,$etcdir]), 'PressEnter');
		$svr_admin=showmessage(getmessage('GetVirtualHostEmail', [$svr_admin]), 'email', $svr_admin);
	}
	if ($auto_install->{servername}) {
		$servername=$auto_install->{servername};
		print ON_YELLOW.BLACK."auto-setting server name to : $servername".RESET."\n";
	} else {
    	$servername=showmessage(getmessage('GetServerName', [$servername]), 'free', $servername);
	}
	if ($auto_install->{opacport}) {
		$opacport=$auto_install->{opacport};
		print ON_YELLOW.BLACK."auto-setting opac port to : $opacport".RESET."\n";
	} else {
	    $opacport=showmessage(getmessage('GetOpacPort', [$opacport]), 'numerical', $opacport);
	}
	if ($auto_install->{intranetport}) {
		$intranetport=$auto_install->{intranetport};
		print ON_YELLOW.BLACK."auto-setting intranet port to : $intranetport".RESET."\n";
	} else {
	    $intranetport=showmessage(getmessage('GetIntranetPort', [$opacport, $intranetport]), 'numerical', $intranetport);
	}

}


=item updateapacheconf

    updateapacheconf;

Updates the Apache config file according to parameters previously
specified by the user.

It will append fully-commented directives at the end of the original
Apache config file.  The old config file is renamed with an extension
of .prekoha.

If you need to uninstall Koha for any reason, the lines between

    # Ports to listen to for Koha

and the block of comments beginning with

    # If you want to use name based Virtual Hosting:

must be removed.

=cut

$messages->{'StartUpdateApache'}->{en} =
   heading('UPDATING APACHE CONFIGURATION') . qq|
Checking for modules that need to be loaded...
|;

$messages->{'ApacheConfigMissingModules'}->{en} =
   heading('APACHE CONFIGURATION NEEDS UPDATE') . qq|
Koha uses the mod_env and mod_include apache features, but the
installer did not find them in your config.  Please
make sure that they are enabled for your Koha site.

Press <ENTER> to continue: |;


$messages->{'ApacheAlreadyConfigured'}->{en} =
   heading('APACHE ALREADY CONFIGURED') . qq|
%s appears to already have an entry for Koha.  You may need to edit %s
if anything has changed since it was last set up.  This
script will not attempt to modify an existing Koha apache
configuration.

Press <ENTER> to continue: |;

sub updateapacheconf {
	my ($auto_install)=@_;
    my $logfiledir=$kohalogdir;
    my $httpdconf = $etcdir."/koha-httpd.conf";
   
    showmessage(getmessage('StartUpdateApache'), 'none') unless $auto_install->{NoPressEnter};
	# to be polite about it: I don't think this should touch the main httpd.conf

	# QUESTION: Should we warn for includes_module too?
    my $envmodule=0;
    my $includesmodule=0;
    open HC, "<$realhttpdconf";
    while (<HC>) {
	if (/^\s*#\s*LoadModule env_module /) {
	    showmessage(getmessage('ApacheConfigMissingModules'));
	    $envmodule=1;
	}
	if (/\s*LoadModule includes_module / ) {
	    $includesmodule=1;
	}
    }

	startsysout;
    if (`grep -q 'VirtualHost $servername' "$httpdconf" 2>/dev/null`) {
	showmessage(getmessage('ApacheAlreadyConfigured', [$httpdconf, $httpdconf]), 'PressEnter');
	return;
    } else {
	my $includesdirectives='';
	if ($includesmodule) {
	    $includesdirectives.="Options +Includes\n";
	    $includesdirectives.="   AddHandler server-parsed .html\n";
	}
	open(SITE,">$httpdconf") or warn "Insufficient priveleges to open $httpdconf for writing.\n";
	my $opaclisten = '';
	if ($opacport != 80) {
	    $opaclisten="Listen $opacport";
	}
	my $intranetlisten = '';
	if ($intranetport != 80) {
	    $intranetlisten="Listen $intranetport";
	}
	print SITE <<EOP

# Ports to listen to for Koha
# uncomment these if they aren't already in main httpd.conf
#$opaclisten
#$intranetlisten

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
   SetEnv PERL5LIB "$intranetdir/modules"
   SetEnv KOHA_CONF "$etcdir/koha.conf"
   $includesdirectives
</VirtualHost>

# KOHA's INTRANET Configuration
<VirtualHost $servername\:$intranetport>
   ServerAdmin $svr_admin
   DocumentRoot $intranetdir/htdocs
   ServerName $servername
   ScriptAlias /cgi-bin/koha/ "$intranetdir/cgi-bin/"
   ErrorLog $logfiledir/koha-error_log
   TransferLog $logfiledir/koha-access_log
   SetEnv PERL5LIB "$intranetdir/modules"
   SetEnv KOHA_CONF "$etcdir/koha.conf"
   $includesdirectives
</VirtualHost>

# If you want to use name based Virtual Hosting:
#   1. remove the two Listen lines
#   2. replace $servername\:$opacport wih your.opac.domain.name
#   3. replace ServerName $servername wih ServerName your.opac.domain.name
#   4. replace $servername\:$intranetport wih your intranet domain name
#   5. replace ServerName $servername wih ServerName your.intranet.domain.name
#
# If you want to use NameVirtualHost'ing (using two names on one ip address):
#   1.  Follow steps 1-5 above
#   2.  Uncomment the NameVirtualHost line and set the correct ip address

EOP


    }
}


=item basicauthentication

    basicauthentication;

Asks the user whether HTTP basic authentication is wanted, and,
if so, the user name and password for the basic authentication.

These pieces of information are saved to global variables; the
function does not return any values.

=cut

# $messages->{'IntranetAuthenticationQuestion'}->{en} =
#    heading('LIBRARIAN AUTHENTICATION') . qq|
# The Librarian site can be password protected using
# Apache's Basic Authorization instead of Koha user details.
# 
# This method going to be phased out very soon.  Most users should answer N here.
# 
# Would you like to do this (Y/[N]): |;	#'
# 
# $messages->{'BasicAuthUsername'}->{en}="Please enter a username for librarian access [%s]: ";
# $messages->{'BasicAuthPassword'}->{en}="Please enter a password for %s: ";
# $messages->{'BasicAuthPasswordWasBlank'}->{en}="\nYou cannot use a blank password!\n\n";
# 
# sub basicauthentication {
#     my $message=getmessage('IntranetAuthenticationQuestion');
#     my $answer=showmessage($message, 'yn', 'n');
#     my $httpdconf = $etcdir."/koha-httpd.conf";
# 
#     my $apacheauthusername='librarian';
#     my $apacheauthpassword='';
#     if ($answer=~/^y/i) {
# 	($apacheauthusername) = showmessage(getmessage('BasicAuthUsername', [ $apacheauthusername]), 'free', $apacheauthusername, 1);
# 	$apacheauthusername=~s/[^a-zA-Z0-9]//g;
# 	while (! $apacheauthpassword) {
# 	    ($apacheauthpassword) = showmessage(getmessage('BasicAuthPassword', [ $apacheauthusername]), 'free', 1);
# 	    if (!$apacheauthpassword) {
# 		($apacheauthpassword) = showmessage(getmessage('BasicAuthPasswordWasBlank'), 'none', '', 1);
# 	    }
# 	}
# 	open AUTH, ">$etcdir/kohaintranet.pass";
# 	my $chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
# 	my $salt=substr($chars, int(rand(length($chars))),1);
# 	$salt.=substr($chars, int(rand(length($chars))),1);
# 	print AUTH $apacheauthusername.":".crypt($apacheauthpassword, $salt)."\n";
# 	close AUTH;
# 	open(SITE,">>$httpdconf") or warn "Insufficient priveleges to open $realhttpdconf for writing.\n";
# 	print SITE <<EOP
# 
# <Directory $intranetdir>
#     AuthUserFile $etcdir/kohaintranet.pass
#     AuthType Basic
#     AuthName "Koha Intranet (for librarians only)"
#     Require  valid-user
# </Directory>
# EOP
#     }
#     close(SITE);
# }


=item installfiles

    installfiles

Install the Koha files to the specified OPAC and INTRANET
directories (usually in /usr/local/koha).

The koha.conf file is created, but as koha.conf.tmp. The
caller is responsible for calling finalizeconfigfile when
installation is completed, to rename it back to koha.conf.

=cut

$messages->{'InstallFiles'}->{en} = heading('INSTALLING FILES') . qq|
Copying files to installation directories:

|;

$messages->{'OldFiles'}->{en} = heading('OLD FILES') . qq|
Any files from the previous edition of Koha have been
copied to a dated backup directory alongside the new
installation. You should move any custom files that you
want to keep (such as your site templates) into the new
directories and then move the backup off of the live
server.

Press ENTER to continue:|;


$messages->{'CopyingFiles'}->{en}="Copying %s to %s.\n";



sub installfiles {

	my ($auto_install) = @_;
	#MJR: preserve old files, just in case
	sub neatcopy {
		my $desc = shift;
		my $src = shift;
		my $tgt = shift;
		if (-e $tgt) {
    		print getmessage('CopyingFiles', ["old ".$desc,$tgt.strftime("%Y%m%d%H%M",localtime())]) unless ($auto_install->{NoPressEnter});
			startsysout();
			system("mv ".$tgt." ".$tgt.strftime("%Y%m%d%H%M",localtime()));
		}
		print getmessage('CopyingFiles', [$desc,$tgt]) unless ($auto_install->{NoPressEnter});
		startsysout;
		system("cp -R ".$src." ".$tgt);
	}

	my ($auto_install) = @_;
	showmessage(getmessage('InstallFiles'),'none') unless ($auto_install->{NoPressEnter});

	neatcopy("admin templates", 'intranet-html', "$intranetdir/htdocs");
	neatcopy("admin interface", 'intranet-cgi', "$intranetdir/cgi-bin");
	neatcopy("main scripts", 'scripts', "$intranetdir/scripts");
	neatcopy("perl modules", 'modules', "$intranetdir/modules");
	neatcopy("OPAC templates", 'opac-html', "$opacdir/htdocs");
	neatcopy("OPAC interface", 'opac-cgi', "$opacdir/cgi-bin");
	startsysout();
	system("touch $opacdir/cgi-bin/opac");

	#MJR: is this necessary?
	if ($> == 0) {
		system("chown -R $httpduser:$httpduser $opacdir $intranetdir");
	}
	system("chmod -R a+rx $opacdir $intranetdir");

	# Create /etc/koha.conf

	my $old_umask = umask(027); # make sure koha.conf is never world-readable
	open(SITES,">$etcdir/koha.conf.tmp") or warn "Couldn't create file at $etcdir. Must have write capability.\n";
	print SITES qq|
database=$database
hostname=$hostname
user=$user
pass=$pass
intranetdir=$intranetdir
opacdir=$opacdir
kohalogdir=$kohalogdir
kohaversion=$newversion
httpduser=$httpduser
intrahtdocs=$intranetdir/htdocs/intranet-tmpl
opachtdocs=$opacdir/htdocs/opac-tmpl
|;
	close(SITES);
	umask($old_umask);

	startsysout();
	#MJR: can't help but this be broken, can we?
	chmod 0440, "$etcdir/koha.conf.tmp";
	
	#MJR: does this contain any passwords?
	chmod 0755, "$intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh", "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh", "$intranetdir/scripts/z3950daemon/processz3950queue";

	#MJR: generate our own settings, to remove the /home/paul hardwired links
	open(FILE,">$intranetdir/scripts/z3950daemon/z3950-daemon-options");
	print FILE "RunAsUser=$httpduser\nKohaZ3950Dir=$intranetdir/scripts/z3950daemon\nKohaModuleDir=$intranetdir/modules\nLogDir=$kohalogdir\nKohaConf=$etcdir/koha.conf";
	close(FILE);

	if ($> == 0) {
	    chown((getpwnam($httpduser)) [2,3], "$etcdir/koha.conf.tmp") or warn "can't chown koha.conf: $!";
		chown(0, (getpwnam($httpduser)) [3], "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh") or warn "can't chown $intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh: $!";
		chown(0, (getpwnam($httpduser)) [3], "$intranetdir/scripts/z3950daemon/processz3950queue") or warn "can't chown $intranetdir/scripts/z3950daemon/processz3950queue: $!";
	} #MJR: report that we haven't chown()d.
	else {
		print "Please check permissions in $intranetdir/scripts/z3950daemon\n";
	}
	showmessage(getmessage('OldFiles'),'PressEnter') unless $auto_install->{NoPressEnter};
}


=item databasesetup

    databasesetup;

Finds out where the MySQL utitlities are located in the system,
then create the Koha database structure and MySQL permissions.

=cut

$messages->{'MysqlRootPassword'}->{en} =
   heading('MYSQL ROOT USER PASSWORD') . qq|
To create the koha database, please enter your
mysql server's root user password:

Password: |;	#'

$messages->{'CreatingDatabase'}->{en} = heading('CREATING DATABASE') . qq|
Creating the MySQL database for Koha...

|;

$messages->{'CreatingDatabaseError'}->{en} =
   heading('ERROR CREATING DATABASE') . qq|
Couldn't connect to the MySQL server for the reason given above.
This is a serious problem, the database will not get installed.

Press <ENTER> to continue: |;	#'

$messages->{'SampleData'}->{en} = heading('SAMPLE DATA') . qq|
If you are installing Koha for evaluation purposes,
you can install some sample data now.

If you are installing Koha to use your own
data, you probably don't want this sample data installed.

Would you like to install the sample data? Y/[N]: |;	#'

$messages->{'SampleDataInstalled'}->{en} =
   heading('SAMPLE DATA INSTALLED') . qq|
Sample data has been installed.  For some suggestions on testing Koha, please
read the file doc/HOWTO-Testing.  If you find any bugs, please submit them at
http://bugs.koha.org/.  If you need help with testing Koha, you can post a
question through the koha-devel mailing list, or you can check for a developer
online at irc.katipo.co.nz:6667 channel #koha.

You can find instructions for subscribing to the Koha mailing lists at:

    http://www.koha.org


Press <ENTER> to continue: |;

$messages->{'AddBranchPrinter'}->{en} = heading('Add Branch and Printer') . qq|
Would you like to describe an initial branch and printer? [Y]/N: |;

$messages->{'BranchName'}->{en}="Branch Name [%s]: ";
$messages->{'BranchCode'}->{en}="Branch Code (4 letters or numbers) [%s]: ";
$messages->{'PrinterQueue'}->{en}="Printer Queue [%s]: ";
$messages->{'PrinterName'}->{en}="Printer Name [%s]: ";

sub databasesetup {
	my ($auto_install) = @_;
    $mysqluser = 'root';
    $mysqlpass = '';
	my $mysqldir = getmysqldir();

	if ($auto_install->{MysqlRootPassword}) {
		$mysqlpass=$auto_install->{MysqlRootPassword};
	} else {
    	# we must not put the mysql root password on the command line
		$mysqlpass=	showmessage(getmessage('MysqlRootPassword'),'silentfree');
	}
	
	showmessage(getmessage('CreatingDatabase'),'none') unless ($auto_install->{NoPressEnter});
	# set the login up
	setmysqlclipass($mysqlpass);
	# Set up permissions
	startsysout();
	print system("$mysqldir/bin/mysql -u$mysqluser mysql -e \"insert into user (Host,User,Password) values ('$hostname','$user',password('$pass'))\"\;");#"
	system("$mysqldir/bin/mysql -u$mysqluser mysql -e \"insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv, index_priv, alter_priv) values ('%','$database','$user','Y','Y','Y','Y','Y','Y','Y','Y')\"");
	system("$mysqldir/bin/mysqladmin -u$mysqluser reload");
	# Change to admin user login
	setmysqlclipass($pass);
	my $result=system("$mysqldir/bin/mysqladmin", "-u$user", "create", "$database");
	if ($result) {
		showmessage(getmessage('CreatingDatabaseError'),'PressEnter', '', 1);
	} else {
		# Create the database structure
		startsysout();
		system("$mysqldir/bin/mysql -u$user $database < koha.mysql");
	}

}


=item updatedatabase

    updatedatabase;

Updates the Koha database structure, including the addition of
MARC tables.

The MARC tables are also populated in addition to being created.

Because updatedatabase calls scripts/updater/updatedatabase to
do the actual update, and that script uses C4::Context,
$etcdir/koha.conf must exist at this point. We use the KOHA_CONF
environment variable to do this.

FIXME: (See checkabortedinstall as it depends on old symlink way.)

=cut

$messages->{'UpdateMarcTables'}->{en} =
   heading('MARC FIELD DEFINITIONS') . qq|
You can import MARC settings for:

  1 MARC21
  2 UNIMARC
  N none

NOTE: If you choose N,
nothing will be added, and you must create them all yourself.
Only choose N if you want to use a MARC format not listed here,
such as DANMARC.  We would like to hear from you if you do.

Choose MARC definition [1]: |;

$messages->{'Language'}->{en} = heading('CHOOSE LANGUAGE') . qq|
This version of koha supports a few languages.

  en : default language, all pages available
  fr : complete translation (except pictures)
  es : partial librarian site translation (including pictures)
  pl : complete OPAC and partial librarian translation
  zh_TW : partial translation

en is used when a screen is not available in your language

If you specify a language here, you can still
change it from the system preferences screen in the librarian sit.

Which language do you choose? |;

sub updatedatabase {
	my ($auto_install) = @_;
    # At this point, $etcdir/koha.conf must exist, for C4::Context
    $ENV{"KOHA_CONF"}=$etcdir.'/koha.conf';
    if (! -e $ENV{"KOHA_CONF"}) { $ENV{"KOHA_CONF"}=$etcdir.'/koha.conf.tmp'; }
	startsysout();	
	my $result=system ("perl -I $intranetdir/modules scripts/updater/updatedatabase -s");
	if ($result) {
		restoremycnf();
		print "Problem updating database...\n";
		exit;
	}
	my $response;
	if ($auto_install->{UpdateMarcTables}) {
		$response=$auto_install->{UpdateMarcTables};
		print ON_YELLOW.BLACK."auto-setting UpdateMarcTable to : $response".RESET."\n";
	} else {
		$response=showmessage(getmessage('UpdateMarcTables'), 'restrictchar 12N', '1');
	}
	startsysout();
	if ($response eq '1') {
		system("cat scripts/misc/marc_datas/marc21_en/structure_def.sql | $mysqldir/bin/mysql -u$user $database");
		system("cat scripts/misc/lang-datas/en/stopwords.sql | $mysqldir/bin/mysql -u$user $database");
	}
	if ($response eq '2') {
		system("cat scripts/misc/marc_datas/unimarc_fr/structure_def.sql | $mysqldir/bin/mysql -u$user $database");
		system("cat scripts/misc/lang-datas/fr/stopwords.sql | $mysqldir/bin/mysql -u$user $database");
	}
	delete($ENV{"KOHA_CONF"});

	print RESET."\nFinished updating of database. Press <ENTER> to continue..." unless ($auto_install->{NoPressEnter});
	<STDIN> unless ($auto_install->{NoPressEnter});
}


=item populatedatabase

    populatedatabase;

Populate the non-MARC tables. If the user wants to install the
sample data, install them.

=cut

$messages->{'ConfirmFileUpload'}->{en} = qq|
Confirm loading of this file into Koha  [Y]/N: |;

sub populatedatabase {
	my ($auto_install) = @_;
	my $input;
	my $response;
	my $branch;
	if ($auto_install->{BranchName}) {
		$branch=$auto_install->{BranchName};
		print ON_YELLOW.BLACK."auto-setting a branch : $branch".RESET."\n";
	} else {
		$response=showmessage(getmessage('AddBranchPrinter'), 'yn', 'y');
		unless ($response =~/^n/i) {
			$branch=showmessage(getmessage('BranchName', [$branch]), 'free', $branch, 1);
			$branch=~s/[^A-Za-z0-9\s]//g;
		}
	}
	if ($branch) {
		my $branchcode=$branch;
		$branchcode=~s/[^A-Za-z0-9]//g;
		$branchcode=uc($branchcode);
		$branchcode=substr($branchcode,0,4);
		if ($auto_install->{BranchCode}) {
			$branchcode=$auto_install->{BranchCode};
			print ON_YELLOW.BLACK."auto-setting branch code : $branchcode".RESET."\n";
		} else {
			$branchcode=showmessage(getmessage('BranchCode', [$branchcode]), 'free', $branchcode, 1);
		}
		$branchcode=~s/[^A-Za-z0-9]//g;
		$branchcode=uc($branchcode);
		$branchcode=substr($branchcode,0,4);
		$branchcode or $branchcode='DEF';

		startsysout();
		system("$mysqldir/bin/mysql -u$user $database -e \"insert into branches (branchcode,branchname,issuing) values ('$branchcode', '$branch', 1)\"");
		system("$mysqldir/bin/mysql -u$user $database -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'IS')\"");
		system("$mysqldir/bin/mysql -u$user $database -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'CU')\"");

		my $printername;
		my $printerqueue;
		if ($auto_install->{PrinterName}) {
			$printername=$auto_install->{PrinterName};
			print ON_YELLOW.BLACK."auto-setting a printer : $printername".RESET."\n";
		} else {
			$printername=showmessage(getmessage('PrinterName', [$printername]), 'free', $printername, 1);
			$printername=~s/[^A-Za-z0-9\s]//g;
		}
		if ($auto_install->{PrinterQueue}) {
			$printerqueue=$auto_install->{PrinterQueue};
			print ON_YELLOW.BLACK."auto-setting printer queue to : $printerqueue".RESET."\n";
		} else {
			$printerqueue=showmessage(getmessage('PrinterQueue', [$printerqueue]), 'free', $printerqueue, 1);
			$printerqueue=~s/[^A-Za-z0-9]//g;
		}
		startsysout();	
		system("$mysqldir/bin/mysql -u$user $database -e \"insert into printers (printername,printqueue,printtype) values ('$printername', '$printerqueue', '')\"");
	}
	my $language;
	if ($auto_install->{Language}) {
		$language=$auto_install->{Language};
		print ON_YELLOW.BLACK."auto-setting language to : $language".RESET."\n";
	} else {
		$language=showmessage(getmessage('Language'), 'free', 'en');
	}
	startsysout();	
	system("$mysqldir/bin/mysql -u$user $database -e \"update systempreferences set value='$language' where variable='opaclanguages'\"");
	# CHECK for any other file to append...
	my @sql;
	push @sql,"FINISHED";
	if (-d "scripts/misc/sql-datas") {
	    opendir D, "scripts/misc/sql-datas";
	    foreach my $sql (readdir D) {
			next unless ($sql =~ /.txt$/);
			push @sql, $sql;
	    }
	}
	my $loopend=0;
	while (not $loopend) {
		print heading("SELECT SQL FILE");
		print qq|
Select a file to append to the Koha DB.
enter a number. A detailled explanation of the file will be given
if you confirm, the file will be added to the DB
|;
		for (my $i=0;$i<=$#sql;$i++) {
			print "$i => ".$sql[$i]."\n";
		}
		my $response =<STDIN>;
		if ($response==0) {
			$loopend = 1;
		} else {
			# show the content of the file
			my $FileToUpload = $sql[$response];
			open FILE,"scripts/misc/sql-datas/$FileToUpload";
			my $content = <FILE>;
			print heading("INSERT $FileToUpload ?")."$content\n";
			# ask confirmation
			$response=showmessage(getmessage('ConfirmFileUpload'), 'yn', 'y');
			# if confirmed, upload the file in the DB
			unless ($response =~/^n/i) {
				$FileToUpload =~ s/\.txt/\.sql/;
				system("$mysqldir/bin/mysql -u$user $database <scripts/misc/sql-datas/$FileToUpload");
			}
		}
	}
}

=item restartapache

    restartapache;

Asks the user whether to restart Apache, and restart it if the user
wants so.

=cut

$messages->{'RestartApache'}->{en} = heading('RESTART APACHE') . qq|
The web server daemon needs to be restarted to load the new configuration for Koha.
The installer can do this if you are using Apache and give the root password.

Would you like to try to restart Apache now?  [Y]/N: |;

sub restartapache {
	my ($auto_install)=@_;
	my $response;
    $response=showmessage(getmessage('RestartApache'), 'yn', 'y') unless ($auto_install->{NoPressEnter});
    $response='y' if ($auto_install->{NoPressEnter});

    unless ($response=~/^n/i) {
		startsysout();
		# Need to support other init structures here?
		if (-e "/etc/rc.d/init.d/httpd") {
			system('su root -c "/etc/rc.d/init.d/httpd restart"');
		} elsif (-e "/etc/init.d/apache") {
			system('su root -c "/etc/init.d/apache restart"');
		} elsif (-e "/etc/init.d/apache-ssl") {
			system('su root -c "/etc/init.d/apache-ssl restart"');
		}
	}
}

=item backupkoha

   backupkoha;

This function attempts to back up all koha's details.

=cut

$messages->{'BackupDir'}->{en} = heading('BACKUP STORAGE').qq|
The upgrader will now try to backup your old files.

Please specify a directory to store the backup in [%s]: |;

$messages->{'BackupSummary'}->{en} = heading('BACKUP SUMMARY').qq|
Backed up:

%6d biblio entries
%6d biblioitems entries
%6d items entries
%6d borrowers

File Listing
---------------------------------------------------------------------
%s
---------------------------------------------------------------------

Does this look right? ([Y]/N): |;

#FIXME: rewrite to use Install.pm
sub backupkoha {
my $backupdir=$ENV{'prefix'}.'/backups';

my $answer = showmessage(getmessage('BackupDir',[$backupdir]),'free',$backupdir);

if (! -e $backupdir) {
	my $result=mkdir ($backupdir, oct(770));
	if ($result==0) {
		my @dirs = split(m#/#, $backupdir);
		my $checkdir='';
		foreach (@dirs) {
			$checkdir.="$_/";
			unless (-e "$checkdir") {
				mkdir($checkdir, 0775);
			}
		}
	}
}

chmod 0770, $backupdir;

# Backup MySql database
#
#
my $mysqldir = getmysqldir();

my ($sec, $min, $hr, $day, $month, $year) = (localtime(time))[0,1,2,3,4,5];
$month++;
$year+=1900;
my $date= sprintf "%4d-%02d-%02d_%02d:%02d:%02d", $year, $month, $day,$hr,$min,$sec;

open (MD, "$mysqldir/bin/mysqldump --user=$user --password=$pass --host=$hostname $database|");

(open BF, ">$backupdir/Koha.backup_$date") || (die "Error opening up backup file $backupdir/Koha.backup_$date: $!\n");

my $itemcounter=0;
my $bibliocounter=0;
my $biblioitemcounter=0;
my $membercounter=0;

while (<MD>) {
	(/insert into items /i) && ($itemcounter++);
	(/insert into biblioitems /i) && ($biblioitemcounter++);
	(/insert into biblio /i) && ($bibliocounter++);
	(/insert into borrowers /i) && ($membercounter++);
	print BF $_;
}

close BF;
close MD;

my $filels=`ls -hl $backupdir/Koha.backup_$date`;
chomp $filels;
$answer = showmessage(getmessage('BackupSummary',[$bibliocounter, $biblioitemcounter, $itemcounter, $membercounter, $filels]),'yn');

if ($answer=~/^n/i) {
    print qq|

Aborting.  The database dump is located in:

	$backupdir/Koha.backup_$date

|;
    exit;
} else {
	print "Great! continuing upgrade... \n";
};



}

=item finalizeconfigfile

   finalizeconfigfile;

This function must be called when the installation is complete,
to rename the koha.conf.tmp file to koha.conf.

Currently, failure to rename the file results only in a warning.

=cut

sub finalizeconfigfile {
	restoremycnf();
   rename "$etcdir/koha.conf.tmp", "$etcdir/koha.conf"
      || showmessage(<<EOF, 'PressEnter', undef, 1);
An unexpected error, $!, occurred
while the Koha config file is being saved to its final location,
$etcdir/koha.conf.

Couldn't rename file at $etcdir. Must have write capability.

Press Enter to continue.
EOF
#'
}


=item loadconfigfile

   loadconfigfile

Open the existing koha.conf file and get its values,
saving the values to some global variables.

If the existing koha.conf file cannot be opened for any reason,
the file is silently ignored.

=cut

sub loadconfigfile {
    my %configfile;

	#MJR: reverted to r1.53.  Please call setetcdir().  Do NOT hardcode this.
	#FIXME: make a dated backup
    open (KC, "<$etcdir/koha.conf");
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

	#MJR: Reverted this too. You do not mess with my privates. Please ask for new functions if required.
    $intranetdir=$configfile{'intranetdir'};
    $opacdir=$configfile{'opacdir'};
    $kohaversion=$configfile{'kohaversion'};
    $kohalogdir=$configfile{'kohalogdir'};
    $database=$configfile{'database'};
    $hostname=$configfile{'hostname'};
    $user=$configfile{'user'};
    $pass=$configfile{'pass'};
}

END { }       # module clean-up code here (global destructor)

### These things may move

sub setecho {
my $state=shift;
my $t = POSIX::Termios->new;

$t->getattr();
if ($state) {
  $t->setlflag(($t->getlflag) | &POSIX::ECHO);
  }
else {
  $t->setlflag(($t->getlflag) & !(&POSIX::ECHO));
  }
$t->setattr();
}

sub setmysqlclipass {
	my $pass = shift;
	open(MYCNF,">$mycnf");
	chmod(0600,$mycnf);
	print MYCNF "[client]\npassword=$pass\n";
	close(MYCNF);
}

sub backupmycnf {
	if (-e $mycnf) {
		rename $mycnf,$mytmpcnf;
	}
}

sub restoremycnf {
	if (defined $mycnf && -e $mycnf) {
		unlink($mycnf);
	}
	if (defined $mytmpcnf && -e $mytmpcnf) {
		rename $mytmpcnf,$mycnf;
	}
}

=back

=head1 SEE ALSO

buildrelease.pl
installer.pl
koha.upgrade

=cut

1;
