#!/usr/bin/perl -w # please develop with -w


use strict; # please develop with the strict pragma

print <<EOM;
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
EOM

my $answer = $_;                      
chomp $answer;

if ($answer eq "Y" || $answer eq "y") {
	print "Great!  \n";
    } else {
    print <<EOM;
You will need to setup database space for your application.
The installer currently does not support an automated setup with this database.
Please be sure to read the documentation.
EOM
    exit(1);
  };


#
#  Hmm, on further thought, this file came out of the tarball ... so
#  is it likely to be untarred again?
#
print "I need to unpack the Koha TarFile -- where is it?  ";
$answer = $_;
chomp $answer;    

# FIXME?  using system is probably not the best way to do this 
# tar on solaris may not work properly, etc.
system("tar -x $answer"); #unpack fill out


#test for Perl and Apache?
print "Are you using MySql?(Y/[N]): ";
$answer = $_;                      
chomp $answer
if ($answer eq "Y" || $answer eq "y") {
    # FIXME
    # there is no $password or $KohaDBNAME yet
    system("mysqladmin -uroot -p$password create $KohaDBNAME ");
    system("mysql -u$root -p$password ");
    #need to get to mysql prompt  HOW DO I DO THIS?
    
    # FIXME 
    # you could pipe this into mysql in the shell that system generates
    # can this be done from dbi?
    system("grant all privileges on Koha.* to koha@localhost identified by 'kohapassword'; ");
} else {
    print <<EOM;
You will need to use the MySQL database system for your application.
The installer currently does not support an automated setup with this database.
EOM
  };

print "\n";
#
# FIXME
# there is no updatedatabase program yet
#
system ("perl updatedatabase -I /pathtoC4 ");

#KOHA conf

# FIXME
# is there a reason we don't just create the conf file here?
# We could ask where the file is to be kept, update our 
# scripts to look for it there, and just write out to the
# new file (possibly allowing the installer.pl user to edit the
# file first).
#
print <<EOM;
You will need to add the following to the Koha configuration file\n";
database=Koha\n";
hostname=localhost\n";
user=Koha\n";
pass=$password\n";
includes=/usr/local/www/koha/htdocs/includes\n";
EOM


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
system('/etc/rc.d/init.d/httpd restart');
