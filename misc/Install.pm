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
@EXPORT = qw(	&checkperlmodules
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
		&finalizeconfigfile
		&loadconfigfile
		&backupmycnf
		&restoremycnf
		);

use vars qw( $kohaversion );			# set in installer.pl
use vars qw( $language );			# set in installer.pl
use vars qw( $domainname );			# set in installer.pl

use vars qw( $etcdir );				# set in installer.pl, usu. /etc
use vars qw( $intranetdir $opacdir $kohalogdir );
use vars qw( $realhttpdconf $httpduser );
use vars qw( $servername $svr_admin $opacport $intranetport );
use vars qw( $mysqldir );
use vars qw( $database $mysqluser );
use vars qw( $mysqlpass );			# normally should not be used
use vars qw( $dbname $hostname $user $pass );	# virtual hosting

use vars qw( $newversion );			# XXX this seems to be unused

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
my $clear_string = $terminal->Tputs('cl');

sub heading ($) {
  my $title = shift;
  my $bal = 5;
  return($clear_string."koha-".$kohaversion." Installer\n".ON_BLUE.WHITE.BOLD." "x$bal.uc($title)." "x$bal.RESET."\n\n");
}

my $mycnf = $ENV{HOME}."/.my.cnf";
my $mytmpcnf = `mktemp my.cnf.koha.XXXXXX`;

my $messages;
$messages->{'continuing'}->{en}="Great!  Continuing setup.\n\n";
$messages->{'WelcomeToKohaInstaller'}->{en} =
   heading('Welcome to the Koha Installer') . qq|
Welcome to the Koha install script!  This script will prompt you for some
basic information about your desired setup, then install Koha for you.

If you want to install the Koha configuration file somewhere other than /etc
(eg for non-root installation, or multiple Koha versions on one system), you
should set the etcdir and prefix environment variables.  If this is your
only koha installation on this machine and you are running this as root, the
default should be OK.

To accept the default value for any question, simply hit Enter at the prompt.

Please be sure to read the documentation, or visit the Koha website at
http://www.koha.org for more information.

Are you ready to begin the installation? ([Y]/N): |;
$messages->{'ReleaseCandidateWarning'}->{en} =
   heading('RELEASE CANDIDATE') . qq|
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

IMPORTANT NOTE : If you use PERL5.8.0 (RedHat 8.0 or Mandrake 9.x), you MUST install 
manually the Net::Z3950 and edit Makefile.PL and yazwrap/Makefile.PL to include:
    'DEFINE' => '-D_GNU_SOURCE',
Also note that some installations of Perl on Red Hat will generate a lot of
"'my_perl' undeclared" errors when running make in Net-Z3950.  This is fixed by
inserting the following line in yazwrap/ywpriv.h :
   #include "XSUB.h"

Press the <ENTER> key to continue: |;	#'

$messages->{'CheckingPerlModules'}->{en} = heading('PERL & MODULES') . qq|
Checking perl modules ...
|;

$messages->{'PerlVersionFailure'}->{en}="Sorry, you need at least Perl %s\n";

$messages->{'MissingPerlModules'}->{en} = heading('MISSING PERL MODULES') . qq|
You are missing some Perl modules which are required by Koha.
Once these modules have been installed, rerun this installer.
They can be installed by running (as root) the following:

%s
|;

$messages->{'AllPerlModulesInstalled'}->{en} =
   heading('ALL PERL MODULES INSTALLED') . qq|
All mandatory perl modules are installed.

Press <ENTER> to continue: |;
$messages->{'KohaVersionInstalled'}->{en}="You currently have Koha %s on your system.";
$messages->{'KohaUnknownVersionInstalled'}->{en}="I am not able to determine what version of Koha is installed now.";
$messages->{'KohaAlreadyInstalled'}->{en} =
   heading('Koha already installed') . qq|
It looks like Koha is already installed on your system (%s/koha.conf exists
already).  If you would like to upgrade your system to %s, please use
the koha.upgrade script in this directory.

%s

|;
$messages->{'GetOpacDir'}->{en} = heading('OPAC DIRECTORY') . qq|
Please supply the directory you want Koha to store its OPAC files in.  This
directory will be auto-created for you if it doesn't exist.

OPAC Directory [%s]: |;	#'

$messages->{'GetIntranetDir'}->{en} =
   heading('INTRANET/LIBRARIANS DIRECTORY') . qq|
Please supply the directory you want Koha to store its Intranet/Librarians
files in.  This directory will be auto-created for you if it doesn't exist.

Intranet Directory [%s]: |;	#'

$messages->{'GetKohaLogDir'}->{en} = heading('KOHA LOG DIRECTORY') . qq|
Specify a log directory where any Koha daemons can create log files.

Koha Log Directory [%s]: |;

$messages->{'AuthenticationWarning'}->{en} = heading('Authentication') . qq|
This release of Koha has a new authentication module.  If you are not already
using basic authentication on your intranet, you will be required to log in to
access some of the features of the intranet.  You can log in using the userid
and password from the %s/koha.conf configuration file at any time.  Use the
"Members" module to add passwords for other accounts and set their permissions.

Press the <ENTER> key to continue: |;

$messages->{'Completed'}->{en} = heading('KOHA INSTALLATION COMPLETE') . qq|
Congratulations ... your Koha installation is complete!

You will be able to connect to your Librarian interface at:

   http://%s\:%s/
   use mysql login and password to connect to this interface. Then, go to admin page, and create whatever fits your needs.

and the OPAC interface at :

   http://%s\:%s/

Be sure to read the Hints file.

For more information visit http://www.koha.org

Press <ENTER> to exit the installer: |;

sub releasecandidatewarning {
    my $message=getmessage('ReleaseCandidateWarning', [$newversion, $newversion]);
    my $answer=showmessage($message, 'yn', 'n');

    if ($answer =~ /y/i) {
	print getmessage('continuing');
    } else {
	my $message=getmessage('WatchForReleaseAnnouncements');
	print $message;
	exit;
    };
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

=item setkohaversion

    setkohaversion('1.3.3RC26');

Sets the Koha version as known by the installer.

=cut

sub setkohaversion ($) {
    ($kohaversion) = @_;
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

sub mkdir_parents ($;$) {
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
    my $message=$messages->{$messagename}->{$language} || $messages->{$messagename}->{en} || "Error: No message named $messagename in Install.pm\n";
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
    my $message=shift;
    my $responsetype=shift;
    my $defaultresponse=shift;
    my $noclear=shift;
    $noclear = 0 unless defined $noclear; # defaults to "clear"
    ($noclear) || (print $clear_string);
    if ($responsetype =~ /^yn$/) {
	$responsetype='restrictchar ynYN';
    }
    print $message;
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
                print "Response contains invalid characters.  Choose from [$options].\n\n";
                print $message;
                $response='\0';
            } else {
                unless ($options=~/$response/) {
                    ($noclear) || (print $clear_string);
                    print "Invalid Response.  Choose from [$options].\n\n";
                    print $message;
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
		print "Invalid Response ($response).  Response must be a number.\n\n";
		print $message;
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
			print "Invalid Response ($response).  Response must be a valid email address.\n\n";
			print $message;
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

    my $message = getmessage('CheckingPerlModules');
    showmessage($message, 'none');

    unless ($] >= 5.006001) {			# Bug 179
	die getmessage('PerlVersionFailure', ['5.6.1']);
    }

    my @missing = ();
    unless (eval {require DBI})              { push @missing,"DBI" };
    unless (eval {require Date::Manip})      { push @missing,"Date::Manip" };
    unless (eval {require DBD::mysql})       { push @missing,"DBD::mysql" };
    unless (eval {require HTML::Template})   { push @missing,"HTML::Template" };
#    unless (eval {require Set::Scalar})      { push @missing,"Set::Scalar" };
    unless (eval {require Digest::MD5})      { push @missing,"Digest::MD5" };
    unless (eval {require MARC::Record})     { push @missing,"MARC::Record" };
    unless (eval {require Mail::Sendmail})   { push @missing,"Mail::Sendmail" };
    unless (eval {require Net::Z3950})       {
	showmessage(getmessage('NETZ3950Missing'), 'PressEnter', '', 1);
	if ($#missing>=0) { # XXX why only when $#missing >= 0?
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

$messages->{'NoUsrBinPerl'}->{en} =
   heading('Perl is not located in /usr/bin/perl') . qq|
The Koha perl scripts expect to find the perl executable in the /usr/bin
directory.  It is not there on your system.

|;

$messages->{'AskLocationOfPerlExecutable'}->{en}=qq|Location of Perl Executable: [%s]: |;
$messages->{'ConfirmPerlExecutableSymlink'}->{en}=qq|
The Koha scripts will _not_ work without a symlink from %s to /usr/bin/perl

May I create this symlink? ([Y]/N):
: |;

$messages->{'DirFailed'}->{en} = qq|
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
	if (!$ENV{prefix}) { $ENV{prefix} = "/usr/local"; }
    $opacdir = $ENV{prefix}.'/koha/opac';
    $intranetdir = $ENV{prefix}.'/koha/intranet';
    my $getdirinfo=1;
    while ($getdirinfo) {
	# Loop until opac directory and koha directory are different
	my $message=getmessage('GetOpacDir', [$opacdir]);
	$opacdir=showmessage($message, 'free', $opacdir);

	$message=getmessage('GetIntranetDir', [$intranetdir]);
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
    $kohalogdir=$ENV{prefix}.'/koha/log';
    my $message=getmessage('GetKohaLogDir', [$kohalogdir]);
    $kohalogdir=showmessage($message, 'free', $kohalogdir);


    # FIXME: Need better error handling for all mkdir calls here
    unless ( -d $intranetdir ) {
       mkdir_parents (dirname($intranetdir), 0775) || print getmessage('DirFailed','parents of '.$intranetdir);
       mkdir ($intranetdir,                  0770) || print getmessage('DirFailed',$intranetdir);
       if ($>==0) { chown (oct(0), (getgrnam($httpduser))[2], "$intranetdir"); }
       chmod 0770, "$intranetdir";
    }
    mkdir_parents ("$intranetdir/htdocs",    0750);
    mkdir_parents ("$intranetdir/cgi-bin",   0750);
    mkdir_parents ("$intranetdir/modules",   0750);
    mkdir_parents ("$intranetdir/scripts",   0750);
    unless ( -d $opacdir ) {
       mkdir_parents (dirname($opacdir),     0775) || print getmessage('DirFailed','parents of '.$opacdir);
       mkdir ($opacdir,                      0770) || print getmessage('DirFailed',$opacdir);
       if ($>==0) { chown (oct(0), (getgrnam($httpduser))[2], "$opacdir"); }
       chmod (oct(770), "$opacdir");
    }
    mkdir_parents ("$opacdir/htdocs",        0750);
    mkdir_parents ("$opacdir/cgi-bin",       0750);


    unless ( -d $kohalogdir ) {
       mkdir_parents (dirname($kohalogdir),  0775) || print getmessage('DirFailed','parents of '.$kohalogdir);
       mkdir ($kohalogdir,                   0770) || print getmessage('DirFailed',$kohalogdir);
       if ($>==0) { chown (oct(0), (getgrnam($httpduser))[2,3], "$kohalogdir"); }
       chmod (oct(770), "$kohalogdir");
    }
}



=item getdatabaseinfo

    getdatabaseinfo;

Get various pieces of information related to the Koha database:
the name of the database, the host on which the SQL server is
running, and the database user name.

These pieces of information are saved to global variables; the
function does not return any values.

=cut

$messages->{'DatabaseName'}->{en} = heading('Name of MySQL database') . qq|
Please provide the name that you wish to give your koha database.
It must not exist already on the database server.

Database name [%s]: |;

$messages->{'DatabaseHost'}->{en} = heading('Database Host') . qq|
Please provide the hostname for mysql.  Unless the database is located on
another machine this will be "localhost".

Database host [%s]: |;

$messages->{'DatabaseUser'}->{en} = heading('Database User') . qq|
Please provide the name of the user who will have full administrative rights
to the %s database, when authenticating from %s.

This user will also be used to access Koha's INTRANET interface.

Database user [%s]: |;

$messages->{'DatabasePassword'}->{en} = heading('Database Password') . qq|
Please provide a good password for the user %s.

This password will also be used to access Koha's INTRANET interface.

Password for database user %s: |;

$messages->{'BlankPassword'}->{en} = heading('BLANK PASSWORD') . qq|
You must not use a blank password for your MySQL user.

Press <ENTER> to try again: 
|;

sub getdatabaseinfo {

    $dbname = 'Koha';
    $hostname = 'localhost';
    $user = 'kohaadmin';
    $pass = '';

#Get the database name

    my $message=getmessage('DatabaseName', [$dbname]);
    $dbname=showmessage($message, 'free', $dbname);

#Get the hostname for the database
    
    $message=getmessage('DatabaseHost', [$hostname]);
    $hostname=showmessage($message, 'free', $hostname);

#Get the username for the database

    $message=getmessage('DatabaseUser', [$dbname, $hostname, $user]);
    $user=showmessage($message, 'free', $user);

#Get the password for the database user

    while ($pass eq '') {
	my $message=getmessage('DatabasePassword', [$user, $user]);
	$pass=showmessage($message, 'free', $pass);
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
   heading('MULTIPLE APACHE CONFIG FILES') . qq|
I found more than one possible Apache configuration file:

%s

Choose the correct file [1]: |;

$messages->{'NoApacheConfFiles'}->{en} =
   heading('NO APACHE CONFIG FILE FOUND') . qq|
I was not able to find your Apache configuration file.

The file is usually called httpd.conf or apache.conf.

Please specify the location of your config file: |;

$messages->{'NotAFile'}->{en} = heading('FILE DOES NOT EXIST') . qq|
The file %s does not exist.

Please press <ENTER> to continue: |;

$messages->{'EnterApacheUser'}->{en} = heading('NEED APACHE USER') . qq|
I was not able to determine the user that Apache is running as.  This
information is necessary in order to set the access privileges correctly on
%s/koha.conf.  This user should be set in one of the Apache configuration
files using the "User" directive.

Enter the Apache userid: |;

$messages->{'InvalidUserid'}->{en} = heading('INVALID USERID') . qq|
The userid %s is not a valid userid on this system.

Press <ENTER> to continue: |;

sub getapacheinfo {
    my @confpossibilities;

    foreach my $httpdconf (qw(/usr/local/apache/conf/httpd.conf
			  /usr/local/etc/apache/httpd.conf
			  /usr/local/etc/apache/apache.conf
			  /var/www/conf/httpd.conf
			  /etc/apache2/httpd.conf
			  /etc/apache2/apache.conf
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
	warn "Insufficient privileges to open $realhttpdconf for reading.\n";
	sleep 4;
    }

    while (<HTTPDCONF>) {
	if (/^\s*User\s+"?([-\w]+)"?\s*$/) {
	    $httpduser = $1;
	}
    }
    close(HTTPDCONF);




    unless ($httpduser) {
	my $message=getmessage('EnterApacheUser', [$etcdir]);
	until (length($httpduser) && getpwnam($httpduser)) {
	    $httpduser=showmessage($message, "free", '');
	    if (length($httpduser)>0) {
		unless (getpwnam($httpduser)) {
		    my $message=getmessage('InvalidUserid', [$httpduser]);
		    showmessage($message,'PressEnter');
		}
	    } else {
	    }
	}
	print "AU: $httpduser\n";
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
OPAC and LIBRARIAN virtual hosts.  By default this installer
will do this by using one ip address and two different ports
for the virtual hosts.  There are other ways to set this up,
and the installer will leave comments in
%s/koha-httpd.conf detailing
what these other options are.

NOTE: You will need to add lines to your main httpd.conf to
  Include %s/koha-httpd.conf
and to make sure it is listening on the right ports
(using the Listen directive).

Press <ENTER> to continue: |;

$messages->{'GetVirtualHostEmail'}->{en} =
   heading('WEB SERVER E-MAIL CONTACT') . qq|
Enter the e-mail address to be used as a contact for the virtual hosts (this
address is displayed if any errors are encountered).

E-mail contact [%s]: |;

$messages->{'GetServerName'}->{en} =
   heading('WEB SERVER HOST NAME OR IP ADDRESS') . qq|
Please enter the host name or IP address that you wish to use for koha.
Normally, this should be a name or IP that belongs to this machine.

Host name or IP Address [%s]: |;

$messages->{'GetOpacPort'}->{en} = heading('OPAC VIRTUAL HOST PORT') . qq|
Please enter the port for your OPAC interface.  This defaults to port 80, but
if you are already serving web content from this host, you should change it
to a different port (8000 might be a good choice).

Enter the OPAC Port [%s]: |;

$messages->{'GetIntranetPort'}->{en} =
   heading('INTRANET VIRTUAL HOST PORT') . qq|
Please enter the port for your Intranet interface.  This must be different from
the OPAC port (%s).

Enter the Intranet Port [%s]: |;


sub getapachevhostinfo {

    $svr_admin = "webmaster\@$domainname";
    $servername=`hostname`;
    chomp $servername;
    $opacport=80;
    $intranetport=8080;

    showmessage(getmessage('ApacheConfigIntroduction',[$etcdir,$etcdir]), 'PressEnter');

    $svr_admin=showmessage(getmessage('GetVirtualHostEmail', [$svr_admin]), 'email', $svr_admin);
    $servername=showmessage(getmessage('GetServerName', [$servername]), 'free', $servername);


    $opacport=showmessage(getmessage('GetOpacPort', [$opacport]), 'numerical', $opacport);
    $intranetport=showmessage(getmessage('GetIntranetPort', [$opacport, $intranetport]), 'numerical', $intranetport);

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
installer did not find statements for them in your config.  Please
make sure that they are enabled for your Koha host.

Press <ENTER> to continue: |;


$messages->{'ApacheAlreadyConfigured'}->{en} =
   heading('APACHE ALREADY CONFIGURED') . qq|
%s appears to already have an entry for Koha
Virtual Hosts.  You may need to edit %s
if anything has changed since it was last set up.  This
script will not attempt to modify an existing Koha apache
configuration.

Press <ENTER> to continue: |;

sub updateapacheconf {
    my $logfiledir=$kohalogdir.'/logs';
    my $httpdconf = $etcdir."/koha-httpd.conf";
   
    showmessage(getmessage('StartUpdateApache'), 'none');
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

    if (`grep 'VirtualHost $servername' "$httpdconf"`) {
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

$messages->{'IntranetAuthenticationQuestion'}->{en} =
   heading('INTRANET AUTHENTICATION') . qq|
I can set it up so that the Intranet/Librarian site is password protected using
Apache's Basic Authorization.

This is going to be phased out very soon. However, setting this up can provide
an extra layer of security before the new authentication system is completely
in place.

Would you like to do this ([Y]/N): |;	#'

$messages->{'BasicAuthUsername'}->{en}="Please enter a userid for intranet access [%s]: ";
$messages->{'BasicAuthPassword'}->{en}="Please enter a password for %s: ";
$messages->{'BasicAuthPasswordWasBlank'}->{en}="\nYou cannot use a blank password!\n\n";

sub basicauthentication {
    my $message=getmessage('IntranetAuthenticationQuestion');
    my $answer=showmessage($message, 'yn', 'y');
    my $httpdconf = $etcdir."/koha-httpd.conf";

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
	open AUTH, ">$etcdir/kohaintranet.pass";
	my $chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
	my $salt=substr($chars, int(rand(length($chars))),1);
	$salt.=substr($chars, int(rand(length($chars))),1);
	print AUTH $apacheauthusername.":".crypt($apacheauthpassword, $salt)."\n";
	close AUTH;
	open(SITE,">>$httpdconf") or warn "Insufficient priveleges to open $realhttpdconf for writing.\n";
	print SITE <<EOP

<Directory $intranetdir>
    AuthUserFile $etcdir/kohaintranet.pass
    AuthType Basic
    AuthName "Koha Intranet (for librarians only)"
    Require  valid-user
</Directory>
EOP
    }
    close(SITE);
}


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


$messages->{'CopyingFiles'}->{en}="Copying %s to %s.\n";



sub installfiles {

	#MJR: preserve old files, just in case
	sub neatcopy {
		my $desc = shift;
		my $src = shift;
		my $tgt = shift;
		
		if (-d $tgt) {
    		print getmessage('CopyingFiles', ["old ".$desc,$tgt.".old"]);
			system("mv ".$tgt." ".$tgt.".old");
		}

    	print getmessage('CopyingFiles', [$desc,$tgt]);
	    system("cp -R ".$src." ".$tgt);
	}

    showmessage(getmessage('InstallFiles'),'none');

    neatcopy("admin templates", 'intranet-html', "$intranetdir/htdocs");
    neatcopy("admin interface", 'intranet-cgi', "$intranetdir/cgi-bin");
    neatcopy("main scripts", 'scripts', "$intranetdir/scripts");
    neatcopy("perl modules", 'modules', "$intranetdir/modules");
    neatcopy("OPAC templates", 'opac-html', "$opacdir/htdocs");
    neatcopy("OPAC interface", 'opac-cgi', "$opacdir/cgi-bin");
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
database=$dbname
hostname=$hostname
user=$user
pass=$pass
includes=$opacdir/htdocs/includes
intranetdir=$intranetdir
opacdir=$opacdir
kohalogdir=$kohalogdir
kohaversion=$kohaversion
httpduser=$httpduser
intrahtdocs=$intranetdir/htdocs/intranet-tmpl
opachtdocs=$opacdir/htdocs/opac-tmpl
|;
    close(SITES);
    umask($old_umask);

	#MJR: can't help but this be broken, can we?
    chmod 0440, "$etcdir/koha.conf.tmp";
	
	#MJR: does this contain any passwords?
    chmod 0755, "$intranetdir/scripts/z3950daemon/z3950-daemon-launch.sh", "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh", "$intranetdir/scripts/z3950daemon/processz3950queue";

	if ($> == 0) {
	    chown((getpwnam($httpduser)) [2,3], "$etcdir/koha.conf.tmp") or warn "can't chown koha.conf: $!";
    	chown(0, (getpwnam($httpduser)) [3], "$intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh") or warn "can't chown $intranetdir/scripts/z3950daemon/z3950-daemon-shell.sh: $!";
    	chown(0, (getpwnam($httpduser)) [3], "$intranetdir/scripts/z3950daemon/processz3950queue") or warn "can't chown $intranetdir/scripts/z3950daemon/processz3950queue: $!";
	} #MJR: FIXME: Should report that we haven't chown()d.
}


=item databasesetup

    databasesetup;

Finds out where the MySQL utitlities are located in the system,
then create the Koha database structure and MySQL permissions.

=cut

$messages->{'MysqlRootPassword'}->{en} =
   heading('MYSQL ROOT USER PASSWORD') . qq|
To allow us to create the koha database please enter your
mysql server's root user password:

Password: |;	#'

$messages->{'CreatingDatabase'}->{en} = heading('CREATING DATABASE') . qq|
Creating the MySQL database for Koha...

|;

$messages->{'CreatingDatabaseError'}->{en} =
   heading('ERROR CREATING DATABASE') . qq|
Couldn't connect to the MySQL server for the reason given above.
This is a serious problem, the database will not get installed.

Press <ENTER> to continue: |;	#'

$messages->{'SampleData'}->{en} = heading('SAMPLE DATA') . qq|
If you are installing Koha for evaluation purposes,  I have a batch of sample
data that you can install now.

If you are installing Koha with the intention of populating it with your own
data, you probably don't want this sample data installed.

Would you like to install the sample data? Y/[N]: |;	#'

$messages->{'SampleDataInstalled'}->{en} =
   heading('SAMPLE DATA INSTALLED') . qq|
Sample data has been installed.  For some suggestions on testing Koha, please
read the file doc/HOWTO-Testing.  If you find any bugs, please submit them at
http://bugs.koha.org/.  If you need help with testing Koha, you can post a
question through the koha-devel mailing list, or you can check for a developer
online at +irc.katipo.co.nz:6667 channel #koha.

You can find instructions for subscribing to the Koha mailing lists at:

    http://www.koha.org


Press <ENTER> to continue: |;

$messages->{'AddBranchPrinter'}->{en} = heading('Add Branch and Printer') . qq|
Would you like to install an initial branch and printer? [Y]/N: |;

$messages->{'BranchName'}->{en}="Branch Name [%s]: ";
$messages->{'BranchCode'}->{en}="Branch Code (4 letters or numbers) [%s]: ";
$messages->{'PrinterQueue'}->{en}="Printer Queue [%s]: ";
$messages->{'PrinterName'}->{en}="Printer Name [%s]: ";

sub databasesetup {
    $mysqluser = 'root';
    $mysqlpass = '';

    foreach my $mysql (qw(/usr/local/mysql
			  /opt/mysql
			  /usr
			  )) {
       if ( -d $mysql  && -f "$mysql/bin/mysqladmin") {
	    $mysqldir=$mysql;
       }
    }
    if (!$mysqldir){
	print "I don't see mysql in the usual places.\n";
	for (;;) {
	    print "Where have you installed mysql? ";
	    chomp($mysqldir = <STDIN>);
	    last if -f "$mysqldir/bin/mysqladmin";
	print <<EOP;

I can't find it there either. If you compiled mysql yourself,
please give the value of --prefix when you ran configure.

The file mysqladmin should be in bin/mysqladmin under the directory that you
provide here.

EOP
#'
	}
    }
    # we must not put the mysql root password on the command line
	$mysqlpass=	showmessage(getmessage('MysqlRootPassword'),'silentfree');
	
	showmessage(getmessage('CreatingDatabase'),'none');
	# set the login up
	setmysqlclipass($mysqlpass);
	# Set up permissions
	print system("$mysqldir/bin/mysql -u$mysqluser mysql -e \"insert into user (Host,User,Password) values ('$hostname','$user',password('$pass'))\"\;");
	system("$mysqldir/bin/mysql -u$mysqluser mysql -e \"insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv, index_priv, alter_priv) values ('%','$dbname','$user','Y','Y','Y','Y','Y','Y','Y','Y')\"");
	system("$mysqldir/bin/mysqladmin -u$mysqluser reload");
	# Change to admin user login
	setmysqlclipass($pass);
	my $result=system("$mysqldir/bin/mysqladmin", "-u$user", "create", "$dbname");
	if ($result) {
		showmessage(getmessage('CreatingDatabaseError'),'PressEnter', '', 1);
	} else {
		# Create the database structure
		system("$mysqldir/bin/mysql -u$user $dbname < koha.mysql");
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
   heading('UPDATING MARC FIELD DEFINITION TABLES') . qq|
You can import marc parameters for :

  1 MARC21
  2 UNIMARC
  N none

Please choose which parameter you want to install. Note if you choose N,
nothing will be added, and it can be a BIG job to manually create those tables

Choose MARC definition [1]: |;

$messages->{'Language'}->{en} = heading('CHOOSE LANGUAGES') . qq|
This version of koha supports a few languages.
Enter your language preference : either en, fr, es, pl or zh_TW

Note that the en is always choosen when the system does not finds the
language you choose in a specific screen.

fr : all is translated (except pictures)
es : a few intranet is translated (including pictures)
pl : OPAC and a few intranet is translated
zh_TW : partial translation

Whether you specify a language here, you can always go to the
intranet interface and change it from the system preferences.

Which language do you choose? |;

sub updatedatabase {
    # At this point, $etcdir/koha.conf must exist, for C4::Context
    $ENV{"KOHA_CONF"}=$etcdir.'/koha.conf.tmp';
	my $result=system ("perl -I $intranetdir/modules scripts/updater/updatedatabase");
	if ($result) {
		restoremycnf();
		print "Problem updating database...\n";
		exit;
	}

	my $response=showmessage(getmessage('UpdateMarcTables'), 'restrictchar 12N', '1');

	if ($response eq '1') {
		system("cat scripts/misc/marc_datas/marc21_en/structure_def.sql | $mysqldir/bin/mysql -u$user $dbname");
	}
	if ($response eq '2') {
		system("cat scripts/misc/marc_datas/unimarc_fr/structure_def.sql | $mysqldir/bin/mysql -u$user $dbname");
		system("cat scripts/misc/lang-datas/fr/stopwords.sql | $mysqldir/bin/mysql -u$user $dbname");
	}

	$result = system ("perl -I $intranetdir/modules scripts/marc/updatedb2marc.pl");
	if ($result) {
		print "Problem updating database to MARC...\n";
		restoremycnf();
		exit;
	}
	delete($ENV{"KOHA_CONF"});

	print "\n\nFinished updating of database. Press <ENTER> to continue...";
	<STDIN>;
}


=item populatedatabase

    populatedatabase;

Populate the non-MARC tables. If the user wants to install the
sample data, install them.

=cut

sub populatedatabase {
# 	my $response=showmessage(getmessage('SampleData'), 'yn', 'n');
# 	if ($response =~/^y/i) {
#
# FIXME: These calls are now unsafe and should either be removed
# or updated to use -u$user and no mysqlpass_quoted
#
# 		system("gunzip -d < sampledata-1.2.gz | $mysqldir/bin/mysql -u$mysqluser $mysqlpass_quoted $dbname");
# 		system("$mysqldir/bin/mysql -u$mysqluser $mysqlpass_quoted $dbname -e \"insert into branches (branchcode,branchname,issuing) values ('MAIN', 'Main Library', 1)\"");
# 		system("$mysqldir/bin/mysql -u$mysqluser $mysqlpass_quoted $dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'IS')\"");
# 		system("$mysqldir/bin/mysql -u$mysqluser $mysqlpass_quoted $dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'CU')\"");
# 		system("$mysqldir/bin/mysql -u$mysqluser $mysqlpass_quoted $dbname -e \"insert into printers (printername,printqueue,printtype) values ('Circulation Desk Printer', 'lp', 'hp')\"");
# 		showmessage(getmessage('SampleDataInstalled'), 'PressEnter','',1);
# 	} else {
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

		system("$mysqldir/bin/mysql -u$user $dbname -e \"insert into branches (branchcode,branchname,issuing) values ('$branchcode', '$branch', 1)\"");
		system("$mysqldir/bin/mysql -u$user $dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'IS')\"");
		system("$mysqldir/bin/mysql -u$user $dbname -e \"insert into branchrelations (branchcode,categorycode) values ('MAIN', 'CU')\"");

		my $printername='Library Printer';
		$printername=showmessage(getmessage('PrinterName', [$printername]), 'free', $printername, 1);
		$printername=~s/[^A-Za-z0-9\s]//g;

		my $printerqueue='lp';
		$printerqueue=showmessage(getmessage('PrinterQueue', [$printerqueue]), 'free', $printerqueue, 1);
		$printerqueue=~s/[^A-Za-z0-9]//g;
		system("$mysqldir/bin/mysql -u$user $dbname -e \"insert into printers (printername,printqueue,printtype) values ('$printername', '$printerqueue', '')\"");
# 		}
	my $language=showmessage(getmessage('Language'), 'free', 'en');
	system("$mysqldir/bin/mysql -u$user $dbname -e \"update systempreferences set value='$language' where variable='opaclanguages'\"");
	}
}


=item restartapache

    restartapache;

Asks the user whether to restart Apache, and restart it if the user
wants so.

FIXME: If the installer does not know how to restart the Apache
server (e.g., if the user is not actually using Apache), it still
asks the question.

=cut

$messages->{'RestartApache'}->{en} = heading('RESTART APACHE') . qq|
Apache needs to be restarted to load the new configuration for Koha.
This requires the root password.

Would you like to try to restart Apache now?  [Y]/N: |;

sub restartapache {

    my $response=showmessage(getmessage('RestartApache'), 'yn', 'y');



    unless ($response=~/^n/i) {
	# Need to support other init structures here?
	if (-e "/etc/rc.d/init.d/httpd") {
	    system('su root -c /etc/rc.d/init.d/httpd restart');
	} elsif (-e "/etc/init.d/apache") {
	    system('su root -c /etc//init.d/apache restart');
	} elsif (-e "/etc/init.d/apache-ssl") {
	    system('su root -c /etc/init.d/apache-ssl restart');
	}
    }

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
	if (-e $mycnf) {
		unlink($mycnf);
	}
	if (-e $mytmpcnf) {
		rename $mytmpcnf,$mycnf;
	}
}

=back

=head1 SEE ALSO

buildrelease.pl,
installer.pl

=cut

1;
