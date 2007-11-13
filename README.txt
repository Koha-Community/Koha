Koha - award-winning GPL Integrated Library System

Koha aims to be a full-featured Integrated Library System. Developed
initially in New Zealand by Katipo Communications Ltd and first deployed
in January of 2000 for Horowhenua Library Trust, it is currently
maintained by a team of software providers and library technology staff
from around the globe.


STRUCTURE
=========

Koha 3.0 has been restructured from Koha 2.2 to use Zebra,
a high-performance, general-purpose structured text indexing and
retrieval engine.  Zebra speaks Z39.50, building on one of Koha's most
useful features.

General library data is held in MySQL, and Koha 3.0 supports MySQL 5,
using foreign keys and other recent features.

Apache 2 is the recommended web server and VirtualHost configuration
files are generated for it.


INSTALLATION
============

Koha 3.0 comes with a new installer, based on MakeMaker, the tool that
is usually used to install CPAN modules.  This means that if you know
how to customise CPAN-installed modules, the same things should work
for you with Koha.  If not, don't worry.  If you want to customise the
installation more than described below, run "man ExtUtils::MakeMaker"

Koha 3.0 introduces multi-dbms support. With this release you may elect
to install over MySQL 5 or PostgreSQL 8.2.5. Further databases will
be added over time.

You need to have a server running MySQL 5 or PostgreSQL 8.2.5, Zebra
and some webserver (preferably Apache) before installing Koha.
 
MySQL 5: Create a database called 'koha,' owned by 'kohaadmin'
user, with a password set. Note: kohaadmin must have at least the
following privileges: SELECT, INSERT, UPDATE, DELETE, CREATE, DROP.

PostgreSQL 8.2.5: Create a database called 'koha,' owned by 'kohaadmin' 
user, with a password set. Note: kohaadmin must be a superuser. You
must also add plpgsql to the koha database.

Default installation instructions:

0. export DB_PASS=thePasswordYouChose
1. perl Makefile.PL
2. make
3. sudo make install
4. ln -s /usr/share/koha/etc/koha-httpd.conf /etc/apache2/sites-available/koha
5. a2enmod enable rewrite
6. a2ensite koha && /etc/init.d/apache2 reload
7. zebrasrv -c /usr/share/koha/etc/koha-conf.xml
8. Browse to http://servername:8080/ and answer the questions

OR if you want to install all dependencies from CPAN and are root, you can
replace steps 1-3 with "perl install-CPAN.pl" but this is non-standard and
may not be safe.  Nevertheless, it's pretty cool when it works.

The defaults will install Koha to places that follow relevant standards,
such as the File Hierarchy Standard.  If you want to install Koha to a
different directory like /opt/koha, then replace step 1 with:
1a. export PREFIX=/opt/koha
1b. export CGI_DIR=/opt/koha/cgi
1c. export LOG_DIR=/opt/koha/log
1d. perl Makefile.PL PREFIX=/opt/koha

You can change most of the defaults in a similar way, such as DB_HOST.
For full instructions on how to override the default settings, run
perldoc rewrite-config.PL


IF YOU HAVE PROBLEMS
====================

IF THIS IS A PRE-RELEASE TREE: please contact developers by email via
http://lists.nongnu.org/mailman/listinfo/koha-devel
or
http://dir.gmane.org/gmane.education.libraries.koha.devel

IF THIS IS A RELEASED VERSION: please see the support pages at
http://www.koha.org/

Released versions usually have three-digit numbers, like 3.00.01,
while other version number styles are usually snapshots or previews.


DEVELOPER NOTES
===============

For instructions on how to package releases, run perldoc Makefile.PL
