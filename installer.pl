#!/usr/bin/perl -w # please develop with -w

use diagnostics;
use strict; # please develop with the strict pragma

system('clear');
print qq|
**********************************
* Welcome to the Koha Installer  *
**********************************

This installer will prompt you with a series of questions.
It assumes you (or your system administrator) has installed:
  * Apache (http://httpd.apache.org/)
  * Perl (http://www.perl.org)

and one of the following database applications:
  * MySql (http://www.mysql.org)

on some type of Unix or Unix-like operating system


Are Apache, Perl, and a database from the list above installed 
on this system? (Y/[N]):
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
# Test for Perl - Do we need to explicity check versions?
#
print "\nChecking perl modules ...\n";
    unless (eval "require 5.004") {
    die "Sorry, you need at least Perl 5.004\n";
}

#
# Test for Perl Dependancies
#
my @missing = ();
unless (eval require DBI)               { push @missing,"DBI" };
unless (eval require Date::Manip)       { push @missing,"Date::Manip" };
unless (eval require DBD::mysql)        { push @missing,"DBD::mysql" };
unless (eval require Set::Scalar)       { push @missing,"Set::Scalar" };

#
# Print out a list of any missing modules
#
if (@missing > 0) {
    print "\n\n";
    print "You are missing some Perl modules which are required by Koha.\n";
    print "Once these modules have been installed, rerun this installery.\n";
    print "They can be installed by running (as root) the following:\n";
    foreach my $module (@missing) {
	print "   perl -MCPAN -e 'install \"$module\"'\n";
	exit(1);
    }} else{
    print "All modules appear to be installed, continuing...\n";
};


print "\n";
print "Testing for mysql - still to be done\n";
#test for MySQL?
#print "Are you using MySql?(Y/[N]): ";
#$answer = $_;                      
#chomp $answer
#if ($answer eq "Y" || $answer eq "y") {
    # FIXME
    # there is no $password or $KohaDBNAME yet
#    system("mysqladmin -uroot -p$password create $KohaDBNAME ");
#    system("mysql -u$root -p$password ");
    #need to get to mysql prompt  HOW DO I DO THIS?
    
    # FIXME 
    # you could pipe this into mysql in the shell that system generates
    # can this be done from dbi?
#    system("grant all privileges on Koha.* to koha@localhost identified by 'kohapassword'; ");
#} else {
#    print qq|
#You will need to use the MySQL database system for your application.
#The installer currently does not support an automated setup with this database.
#|;
#  };

print "\n";
#
# FIXME
# there is no updatedatabase program yet
#
#system ("perl updatedatabase -I /pathtoC4 ");

#
#KOHA conf
#
print qq|
Koha uses a small configuration file that is usually placed in your
/etc/ files directory (although you can technically place
it anywhere you wish).

Please enter the full path to your configuration files
directory (the default Koha conf file is "koha.conf").
The path is usually something like /etc/ by default.  The
configuration file, will be created here.
|;

#Get the path to the koha.conf directory
my $conf_path;
my $dbname;
my $hostname;
my $user;
my $pass;
my $inc_path;
do {
	print "Enter path:";
	chomp($conf_path = <STDIN>);
	print "$conf_path is not a directory.\n" if !-d $conf_path;
} until -d $conf_path;


print "\n";
print "\n";
print qq|
Please provide the name of the mysql database for koha. 
This is normally "Koha".
|;

#Get the database name
do {
	print "Enter database name:";
	chomp($dbname = <STDIN>);
};


print "\n";
print "\n";
print qq|
Please provide the hostname for mysql.  Unless the database is located 
on another machine this is likely to be "localhost".
|;

#Get the hostname for the database
do {
	print "Enter hostname:";
	chomp($hostname = <STDIN>);
};


print "\n";
print "\n";
print qq|
Please provide the name of the user, who has full administrative 
rights to the $dbname database, when authenicating from $hostname.
|;

#Get the username for the database
do {
	print "Enter username:";
	chomp($user = <STDIN>);
};


print "\n";
print "\n";
print qq|
Please provide the password for the user $user.
|;

#Get the password for the database user
do {
	print "Enter password:";
	chomp($pass = <STDIN>);
};


print "\n";
print "\n";
print qq|
Please provide the full path to your Koha OPAC installation.
Usually /usr/local/www/koha/htdocs
|;

#Get the installation path for OPAC
do {
	print "Enter installation path:";
	chomp($inc_path = <STDIN>);
};


#Create the configuration file
# FIXME
# maybe this should warn instead of dieing, and write to stdout if 
# the config file can't be opened for writing
# 
open(SITES,">$conf_path/koha.conf") or die "Couldn't create file
at $conf_path.  Must have write capability.\n";
print SITES <<EOP
database=$dbname
hostname=$hostname
user=$user
password=$pass
includes=$inc_path/includes
EOP
;
close(SITES);

print "Successfully created the Koha configuration file.\n";

print "\n";
print "\n";
my $apache_owner;
print qq|
The permissions on the koha.conf file should also be strict, 
since they contain the database password.
Please supply the username that your apache webserver runs under. 
|;
do {
	print "Enter apache user:";
	chomp($apache_owner = <STDIN>);
};


#
# Set ownership of the koha.conf file for security
# FIXME - this will only work if run as root.
#

chown((getpwnam($apache_owner)) [2,3], "$conf_path/koha.conf") or die "can't chown koha.conf: $!";

print "\n";
print "\n";

#
#SETUP opac
#
my $apache_conf_path;
my $svr_admin;
my $docu_root;
my $svr_name;

print qq|
Koha needs to setup your Apache configuration file for the
OPAC virtual host.

Please enter the filename and path to your Apache Configuration file 
usually located in \"/usr/local/apache/conf/httpd.conf\".
|;
do {
	print "Enter path:";
	chomp($apache_conf_path = <STDIN>);
	print "$conf_path is not a valid file.\n" if !-f $apache_conf_path;
} until -f $apache_conf_path;


print qq|
Please enter the servername for your OPAC.
Usually opac.your.domain
|;
do {
	print "Enter servername address:";
	chomp($svr_name = <STDIN>);
};


print qq|
Please enter the e-mail address for your webserver admin.
Usually webmaster\@your.domain
|;
do {
	print "Enter e-mail address:";
	chomp($svr_admin = <STDIN>);
};


print qq|
Please enter the full path to your OPAC\'s document root.
usually something like \"/usr/local/www/opac/htdocs\".
|;
do {
	print "Enter Document Roots Path:";
	chomp($docu_root = <STDIN>);
};


#
# Update Apache Conf File.
#
# FIXME
# maybe this should warn instead of dieing, and write to stdout if 
# the config file can't be opened for writing
# 
open(SITES,">>$apache_conf_path") or die "Couldn't write to file 
$conf_path.  Must have write capability.\n";
print SITES <<EOP

<VirtualHost $svr_name>
    ServerAdmin $svr_admin
    DocumentRoot $docu_root
    ServerName $svr_name
    ErrorLog logs/opac-error_log
    TransferLog logs/opac-access_log common
</VirtualHost>

EOP
;
close(SITES);

print "Successfully updated Apache Configuration file.\n";



###RESTART APACHE
# FIXME
# this is a pretty rude thing to do on a system ...
# perhaps asking the user first would be better.
#
#system('/etc/rc.d/init.d/httpd restart');

#
# It is completed
#
print "\nCongratulations ... your Koha installation is complete!\n";
print "\nYou will need to restart your webserver before using Koha!\n";




