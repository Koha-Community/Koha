#!/usr/bin/perl -w # please develop with -w

use diagnostics;
use strict; # please develop with the strict pragma

unless ($< == 0) {
    print "You must be root to run this script.\n";
    exit 1;
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
This installer currently does not support an completely automated 
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
unless (eval {require Set::Scalar})       { push @missing,"Set::Scalar" };

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
my $domainname = 'hostname -d';
my $opacdir = '/usr/local/www/opac';
my $kohadir = '/usr/local/www/koha';
print qq|

OPAC DIRECTORY
==============
Please supply the directory you want Koha to store its OPAC files in.  Leave off
the trailing slash.  This directory will be auto-created for you if it doesn't
exist.

Usually $opacdir
|;

print "Enter directory: ";
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

Usually $kohadir
|;

print "Enter directory: ";
chomp($input = <STDIN>);

if ($input) {
  $kohadir = $input;
}

#
#KOHA conf
#
my $etcdir = '/etc';
my $dbname = 'koha';
my $hostname = 'localhost';
my $user = 'kohaadmin';
my $pass = '';

print qq|

KOHA.CONF
=========
Koha uses a small configuration file that is usually placed in your /etc/ files 
directory. The configuration file, will be created in this directory

|;

#Get the path to the koha.conf directory
print "Enter the path to your [$etcdir]: ";
chomp($input = <STDIN>);

if ($input) {
  $etcdir = $input;
}


#Get the database name
print qq|

Please provide the name of the mysql database for your koha installation.
This is normally "$dbname".

|;

print "Enter database name:";
chomp($input = <STDIN>);

if ($input) {
  $dbname = $input;
}


#Get the hostname for the database
print qq|

Please provide the hostname for mysql.  Unless the database is located on another 
machine this will be "localhost".
|;

print "Enter hostname:";
chomp($input = <STDIN>);

if ($input) {
  $hostname = $input;
}

#Get the username for the database
print qq|

Please provide the name of the user, who will full administrative rights to the 
$dbname database, when authenticating from $hostname.

If no user is entered it will default to $user.
|;

print "Enter username:";
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


#Create the configuration file
open(SITES,">$etcdir/koha.conf") or warn "Couldn't create file
at $etcdir.  Must have write capability.\n";
print SITES <<EOP
database=$dbname
hostname=$hostname
user=$user
pass=$pass
includes=$kohadir/htdocs/includes
EOP
;
close(SITES);

print "Successfully created the Koha configuration file.\n";

my $httpduser;
my $realhttpdconf;

foreach my $httpdconf (qw(/usr/local/apache/conf/httpd.conf
                      /usr/local/etc/apache/httpd.conf
                      /usr/local/etc/apache/apache.conf
                      /var/www/conf/httpd.conf
                      /etc/apache/conf/httpd.conf
                      /etc/apache/conf/apache.conf
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
$httpduser ||= 'Undetermined';

#
# Set ownership of the koha.conf file for security
#
chown((getpwnam($httpduser)) [2,3], "$etcdir/koha.conf") or warn "can't chown koha.conf: $!";

#
#SETUP opac
#
my $svr_admin = 'webmaster@$domainname';
my $opac_svr_name = 'opac.$domainname';
my $koha_svr_name = 'koha.$domainname';

print qq|

OPAC and KOHA/LIBRARIAN CONFIGURATION
=====================================
Koha needs to setup your Apache configuration file for the
OPAC virtual host.

Please enter the e-mail address for your webserver admin.
Usually $svr_admin
|;

print "Enter e-mail address:";
chomp($input = <STDIN>);

if ($input) {
  $svr_admin = $input;
}


print qq|

Please enter the servername for your OPAC interface.
Usually $opac_svr_name
|;
print "Enter servername address:";
chomp($input = <STDIN>);

if ($input) {
  $opac_svr_name = $input;
}

print qq|

Please enter the servername for your Intranet/Librarian interface.
Usually $koha_svr_name
|;
print "Enter servername address:";
chomp($input = <STDIN>);

if ($input) {
  $koha_svr_name = $input;
}


#
# Update Apache Conf File.
#
print qq|

UPDATING APACHE.CONF
====================

|;
open(SITE,">>$realhttpdconf") or warn "Insufficient priveleges to open $realhttpdconf for writing.\n";
print SITE <<EOP

<VirtualHost $opac_svr_name>
   ServerAdmin $svr_admin
   DocumentRoot $opacdir/htdocs
   ServerName $opac_svr_name
   ScriptAlias /cgi-bin/ $opacdir/cgi-bin
   ErrorLog logs/opac-error_log
   TransferLog logs/opac-access_log common
   SetEnv PERL5LIB "$kohadir/modules"
</VirtualHost>

<VirtualHost $koha_svr_name>
   ServerAdmin $svr_admin
   DocumentRoot $kohadir/htdocs
   ServerName $koha_svr_name
   ScriptAlias /cgi-bin/ "$kohadir/cgi-bin"
   ErrorLog logs/koha-error_log
   TransferLog logs/koha-access_log common
   SetEnv PERL5LIB "$kohadir/modules"
</VirtualHost>

EOP
;
close(SITE);
print "Successfully updated Apache Configuration file.\n";


#
# Setup the modules directory
#
print qq|

CREATING REQUIRED DIRECTORIES
=============================

|;

unless ( -d $kohadir ) {
   print "Creating $kohadir...\n";
   mkdir ($kohadir, oct(770));
   chown (oct(0), (getgrnam($httpduser))[2], "$kohadir");
   chmod (oct(770), "$kohadir");
}
unless ( -d "$kohadir/htdocs" ) {
   print "Creating $kohadir/htdocs...\n";
   mkdir ("$kohadir/htdocs", oct(750));
}
unless ( -d "$kohadir/cgi-bin" ) {
   print "Creating $kohadir/cgi-bin...\n";
   mkdir ("$kohadir/cgi-bin", oct(750));
}
unless ( -d "$kohadir/modules" ) {
   print "Creating $kohadir/modules...\n";
   mkdir ("$kohadir/modules", oct(750));
}
unless ( -d $opacdir ) {
   print "Creating $opacdir...\n";
   mkdir ($opacdir, oct(770));
   chown (oct(0), (getgrnam($httpduser))[2], "$opacdir");
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
print "Copying internet-html files to $kohadir/htdocs...\n";
system("cp -R intranet-html/* $kohadir/htdocs/");
print "Copying intranet-cgi files to $kohadir/cgi-bin...\n";
system("cp -R intranet-cgi/* $kohadir/cgi-bin/");
print "Copying script files to $kohadir/modules...\n";
system("cp -R modules/* $kohadir/modules/");
print "Copying opac-html files to $opacdir/htdocs...\n";
system("cp -R opac-html/* $opacdir/htdocs/");
print "Copying opac-cgi files to $opacdir/cgi-bin...\n";
system("cp -R opac-cgi/* $opacdir/cgi-bin/");

print qq|

MYSQL CONFIGURATION
===================
|;
my $mysql;
my $mysqldir;
my $mysqluser = 'root';
my $mysqlpass = '';

foreach my $mysql (qw(/usr/local/mysql
                      /opt/mysql)) {
   if ( -d $mysql ) {
            $mysql=$mysqldir;
   }
}
if (!$mysqldir){
    $mysqldir='/usr';
}
print qq|
To allow us to create the koha database please supply the 
mysql\'s root users password
|;

print "Enter mysql\'s root users password: ";
chomp($input = <STDIN>);

if ($input) {
  $mysqlpass = $input;
}


print qq|

CREATING DATABASE
=================
|;
system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass create $dbname");
system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass $dbname < koha.mysql");
system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass mysql -e \"insert into user (Host,User,Password) values ('$hostname','$user',password('$pass'))\"\;");
system("$mysqldir/bin/mysql -u$mysqluser -p$mysqlpass mysql -e \"insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv) values ('%','$dbname','$user','Y','Y','Y','Y');");
system("$mysqldir/bin/mysqladmin -u$mysqluser -p$mysqlpass reload");

system ("perl scripts/updater/updatedatabase -I $kohadir/modules");


#RESTART APACHE
system('clear');
print qq|
COMPLETED
=========
Congratulations ... your Koha installation is almost complete!
The final step is to restart your webserver.

Be sure to read the INSTALL, and Hints files. 

For more information visit http://www.koha.org

Would you like to restart your webserver now? (Y/[N]):
|;

my $restart = <STDIN>;
chomp $restart;

if ($answer eq "Y" || $answer eq "y") {
	system('/etc/rc.d/init.d/httpd restart');
    } else {
    print qq|
print "\nCongratulations ... your Koha installation is complete!\n";
print "\nYou will need to restart your webserver before using Koha!\n";
|;
    exit;
};
