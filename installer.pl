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
print "Unpack the tarball - still to be done.\n";
#
#  Hmm, on further thought, this file came out of the tarball ... so
#  is it likely to be untarred again?
#
#print "I need to unpack the Koha TarFile -- where is it?  ";
#$answer = $_;
#chomp $answer;    

# FIXME?  using system is probably not the best way to do this 
# tar on solaris may not work properly, etc.
#system("tar -x $answer"); #unpack fill out

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
unless (eval require Date::Manip)       { push @missing,"Datr::Manip" }
unless (eval require DBD::mysql)        { push @missing,"DBD::mysql" }
unless (eval require Set::Scalar)       { push @missing,"Set::Scalar" }

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


#Create the configuration file
open(SITES,">$conf_path/koha.conf") or die "Couldn't create file
at $conf_path.  Must have write capability.\n";
print SITES <<EOP
database=$dbname
hostname=$hostname
user=$user
password=$pass
EOP
;
close(SITES);

print "Successfully created configuration file.\n";


# FIXME
# Again, this may be something to automate.  We could ask a 
# series of questions, then fill out a form with the answers and 
# edit the existing config file in place.  (Again, giving the
# installer.pl user a chance to edit the file first.)
#

#SETUP opac
#   <VirtualHost opac.your.site>                         
#   ServerAdmin webmaster@your.site                            
#   DocumentRoot /usr/local/www/opac/htdocs                     
#   ServerName opac.your.site                      
#   ErrorLog logs/opac-error_log       
#   TransferLog logs/opac-access_log               
#   </VirtualHost>


###RESTART APACHE
# FIXME
# this is a pretty rude thing to do on a system ...
# perhaps asking the user first would be better.
#
#system('/etc/rc.d/init.d/httpd restart');

#
# It is competed
#
print "\nCongratulations ... your Koha installation is complete!\n";