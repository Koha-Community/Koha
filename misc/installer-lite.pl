#!/usr/bin/perl -w # please develop with -w

# $Id$

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

use diagnostics;
use strict; # please develop with the strict pragma

system('clear');
print qq|
*******************************************
* Welcome to the Koha Installation Guide  *
*******************************************

This installer will guide you through the process of installing Koha.
It is not a completely automated installation, but a guide for further
information please read the documentation or visit the Koha website at
http://www.koha.org

To successfully use Koha you need some additional software:

* A webserver (It was built to work with Apache, but there is no reason
it should not work with any other webserver).

* Mysql (You could intead use postgres, or another sql based database)

* Perl

Are you ready to go through the installation process now? (Y/[N]):
|;

my $answer = <STDIN>;
chomp $answer;

if ($answer eq "Y" || $answer eq "y") {
	print "Beginning setup... \n";
    } else {
    print qq|
When you are ready to complete the installation just run this installer again.
|;
    exit;
};

print "\n";


#
# Test for Perl - Do we need to explicity check versions?
#
print "\nChecking that perl and the required modules are installed ...\n";
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
    print "Perl and required modules appear to be installed, continuing...\n";
};


print "\n";

#
#KOHA conf
#
print qq|
Koha uses a small configuration file that is usually placed in your
/etc/ files directory (note: if you wish to place the koha.conf in
another location you will need to manually edit additional files).

We will help you to now create your koha.conf file, once this file
has been created, please copy it to your destination folder
(note: this may need to be done by your systems administrator).
|;

my $dbname;
my $hostname;
my $user;
my $pass;
my $inc_path;

print "\n";
print "\n";
print qq|
Please provide the name of the mysql database that you wish to use
for koha. This is normally "Koha".
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
Please provide the name of the mysql user, who will have full administrative
rights to the $dbname database, when authenicating from $hostname.
It is recommended that you do not use your "root" user.
|;

#Set the username for the database
do {
	print "Enter username:";
	chomp($user = <STDIN>);
};


print "\n";
print "\n";
print qq|
Please provide a password for the mysql user $user.
|;

#Set the password for the database user
do {
	print "Enter password:";
	chomp($pass = <STDIN>);
};

print "\n";
print "\n";
print qq|
Please provide the full path to your Koha Intranet/Librarians installation.
Usually /usr/local/www/koha/htdocs
|;

#Get the password for the database user
do {
	print "Enter installation path:";
	chomp($inc_path = <STDIN>);
};


#Create the configuration file
open(SITES,">koha.conf") or die "Couldn't create file.
Must have write capability.\n";
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

#
#SETUP Virtual Host Directives
#
#OPAC Settings
#
my $opac_svr_admin;
my $opac_docu_root;
my $opac_svr_name;

print qq|
You need to setup your Apache configuration file for the
OPAC virtual host.

Please enter the servername for the OPAC interface.
Usually opac.your.domain
|;
do {
	print "Enter servername address:";
	chomp($opac_svr_name = <STDIN>);
};


print qq|
Please enter the e-mail address for your webserver admin.
Usually webmaster\@your.domain
|;
do {
	print "Enter e-mail address:";
	chomp($opac_svr_admin = <STDIN>);
};


print qq|
Please enter the full path to your OPAC\'s document root.
usually something like \"/usr/local/www/opac/htdocs\".
|;
do {
	print "Enter Document Roots Path:";
	chomp($opac_docu_root = <STDIN>);
};


#
# Update Apache Conf File.
#
open(SITES,">>koha-apache.conf") or die "Couldn't write to file.
Must have write capability.\n";
print SITES <<EOP

<VirtualHost $opac_svr_name>
    ServerAdmin $opac_svr_admin
    DocumentRoot $opac_docu_root
    ServerName $opac_svr_name
    ErrorLog logs/opac-error_log
    TransferLog logs/opac-access_log common
</VirtualHost>

EOP
;
close(SITES);


#
#Intranet Settings
#
my $intranet_svr_admin;
my $intranet_svr_name;

print qq|
You need to setup your Apache configuration file for the
Intranet/librarian virtual host.

Please enter the servername for your Intranet/Librarian interface.
Usually koha.your.domain
|;
do {
	print "Enter servername address:";
	chomp($intranet_svr_name = <STDIN>);
};


print qq|
Please enter the e-mail address for your webserver admin.
Usually webmaster\@your.domain
|;
do {
	print "Enter e-mail address:";
	chomp($intranet_svr_admin = <STDIN>);
};



#
# Update Apache Conf File.
#
open(SITES,">>koha-apache.conf") or die "Couldn't write to file.
Must have write capability.\n";
print SITES <<EOP

<VirtualHost $intranet_svr_name>
    ServerAdmin $intranet_svr_admin
    DocumentRoot $inc_path
    ServerName $intranet_svr_name
    ErrorLog logs/opac-error_log
    TransferLog logs/opac-access_log common
</VirtualHost>

EOP
;
close(SITES);


print "Successfully created the Apache Virtual Host Configuration file.\n";

system('clear');
print qq|
*******************************************
* Koha Installation Guide - Continued     *
*******************************************

In order to finish the installation of Koha, there is still a couple
of steps that you will need to complete.

  * Setup mysql
	1. Create a new mysql database called for example Koha
	   From command line: mysqladmin -uroot -ppassword create Koha

	2. Set up a koha user and password in mysql
           Log in to mysql: mysql -uroot -ppassword

	   To create a user called "koha" who has full administrative
	   rights to the "Koha" database when authenticating from
	   "localhost", enter the following on mysql command line:

	    grant all privileges on Koha.* to koha\@localhost identified by 'kohapassword'\;

	   Press ENTER, and if you see no errors then enter \q to quit mysql.


	3. Use the mysql script to create the tables
	   mysql -uusername -ppassword Koha < koha.mysql

	4. Update your database tables
	   perl updatedatabase -I /pathtoC4

	5. Update your database to use MARC
	   perl marc/fill_usmarc.pl -I /pathtoC4 to put MARC21 - english datas in parameter table
	   perl marc/updatedb2marc.pl -I /pathtoC4 to update biblios from old-DB to MARC-DB (!!! it may be long : 30 biblios/second)

  * Koha.conf
	1. Copy Koha.conf to /etc/
	   If you wish to locate the file in another location please read
	   the INSTALL and Hints files.


|;
#
# It is completed
#
print "\nCongratulations ... your Koha installation is complete!\n";
print "\nYou will need to restart your webserver before using Koha!\n";
