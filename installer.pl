#!perl 

print "**********************************\n";
print "* Welcome to the Koha Installer  *\n";
print "**********************************\n";
print "\n\n\n";
print "This installer will prompt you with a series of questions.\n";
print "It assumes you (or your system administrator) has installed: \n";
print "  * Apache (http://www.apache.org) \n";
print "  * Perl (http://www.perl.org) \n \n";
print "and one of the following database applications:";
print "  * MySql (http://www.mysql.org) \n\n";
print "on some type of Unix or Unix-like operating system \n";
print "\n\n";
print "Is Apache, Perl, and a database from the list above installed on this system?\n";
print "\n";
$answer = chomp $_;                      
if ($answer eq "Y") {
	print "Great!  \n";
  };
if ($answer eq "N") {
	print "You will need to setup database space for your application.  \n";
	print "The installer currently does not support an automated setup with this database.\n";
	print "Please be sure to read the documentation.";
  };
print "I need to unpack the Koha TarFile -- where is it?  ";
$answer = chomp $_;    
system("tar -x $answer"); #unpack fill out
#test for Perl and Apache?
print "Are you using MySql?[Y/N]: ";
$answer = chomp $_;                      
if ($answer eq "Y") {
	system("mysqladmin -uroot -ppassword create $KohaDBNAME ");
	system("mysql -u$root -p$password ");
	#need to get to mysql prompt  HOW DO I DO THIS?
	system("grant all privileges on Koha.* to koha@localhost identified by 'kohapassword'; ");

  };
if ($answer eq "N") {
	print "You will need to setup database space for your application.  \n";
	print "The installer currently does not support an automated setup with this database.\n";
  };
print "\n";
system ("perl updatedatabase -I /pathtoC4 ");

#KOHA conf
print "You will need to add the following to the Koha configuration file\n";
print "database=Koha\n";
print "hostname=localhost\n";
print "user=Koha\n";
print "pass=$password\n";
print "includes=/usr/local/www/koha/htdocs/includes\n";

#SETUP opac
#   <VirtualHost opac.your.site>                         
#   ServerAdmin webmaster@your.site                            
#   DocumentRoot /usr/local/www/opac/htdocs                     
#   ServerName opac.your.site                      
#   ErrorLog logs/opac-error_log       
#   TransferLog logs/opac-access_log               
#   </VirtualHost>


###RESTART APACHE
system('/etc/rc.d/init.d/httpd restart');
